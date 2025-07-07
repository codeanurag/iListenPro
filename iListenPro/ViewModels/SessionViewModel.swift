//
//  SessionViewModel.swift
//  iListenPro
//
//  Created by Anurag Pandit on 03/07/25.
//

import Foundation
import Combine
import SwiftUI
import AVFoundation
import Speech
import UserNotifications

class SessionViewModel: ObservableObject {
    @Published var sessions: [Session] = []
    @Published var currentSession: Session?
    @Published var encouragement: String?
    @Published var timeRemaining: Int = 180
    @Published var uiState: SessionUIState = .idle
    @Published var isPaused = false
    private var useMockAI = true
    let duration = 180
    let store = SessionStore()

    var canEndEarly: Bool {
        return timeRemaining < (duration - 5)
    }
    
    private var openAIAPIKey: String {
        // In production, use environment variables or secure storage
        // For development, you can set this in your scheme's environment variables
        return ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
    }

    private let recorder = AudioRecorder()
    private let synthesizer = SpeechSynthesizer()
    private var cancellables = Set<AnyCancellable>()
    private var timerCancellable: AnyCancellable?

    init() {
        sessions = store.load()
        encouragement = "A few minutes of self-care can go a long way."
    }

    func togglePause() {
        isPaused.toggle()

        if isPaused {
            recorder.pause()
        } else {
            recorder.resume()
        }
    }

    func startSession() {
        let session = Session(date: Date())
        currentSession = session
        timeRemaining = duration
        uiState = .recording

        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, case .recording = self.uiState else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.stopSession()
                }
            }

        recorder.startRecording(duration: TimeInterval(duration))
            .sink(receiveCompletion: { _ in }, receiveValue: { url in
                self.processRecording(at: url)
            })
            .store(in: &cancellables)
    }

    func stopSession() {
        timerCancellable?.cancel()
        if case .recording = uiState {
            uiState = .processing
        }
        recorder.stopManually()
    }

    func endAndSendRecording() {
        timerCancellable?.cancel()
        if case .recording = uiState {
            uiState = .processing
        }
        recorder.stopManually()
    }

    func requestPermissionsAndScheduleReminder() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            self.scheduleReminder()
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission { _ in }
    }

    private func scheduleReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Reflect with iListen"
        content.body = "How was your day today?"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 21

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func processRecording(at url: URL) {
        uiState = .processing

        transcribe(url: url)
            .flatMap { transcript -> AnyPublisher<String, Error> in
                self.currentSession?.transcript = transcript
                return Just(transcript)
                    .delay(for: .milliseconds(200), scheduler: DispatchQueue.main)
                    .flatMap { self.generateAIResponse(to: $0) }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.uiState = .error("Something went wrong: \(error.localizedDescription)")
                }
            }, receiveValue: { reply in
                self.currentSession?.reply = reply
                if let session = self.currentSession {
                    self.sessions.insert(session, at: 0)
                    self.store.save(self.sessions)
                    self.synthesizer.speak(text: reply)
                    self.uiState = .reflecting(
                        transcript: session.transcript ?? "",
                        reply: reply
                    )
                } else {
                    self.uiState = .error("Missing session")
                }
            })
            .store(in: &cancellables)
    }

    private func transcribe(url: URL) -> AnyPublisher<String, Error> {
        Future { promise in
            let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
            let request = SFSpeechURLRecognitionRequest(url: url)

            guard let recognizer = recognizer, recognizer.isAvailable else {
                promise(.failure(NSError(domain: "SpeechRecognizerUnavailable", code: -1)))
                return
            }

            recognizer.recognitionTask(with: request) { result, error in
                if let error = error {
                    DispatchQueue.main.async {
                        promise(.failure(error))
                    }
                } else if let result = result, result.isFinal {
                    DispatchQueue.main.async {
                        promise(.success(result.bestTranscription.formattedString))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private func generateAIResponse(to text: String) -> AnyPublisher<String, Error> {
        let prompt = """
        The following is a short, supportive response to someone reflecting on their day. Be warm, human, and empathetic.

        Me: \(text)
        Listener:
        """

        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a supportive, empathetic listener. Keep replies short and kind."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.8
        ]

        guard let url = URL(string: "https://api.openai.com/v1/chat/completions"),
              let body = try? JSONSerialization.data(withJSONObject: requestBody) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        print("📤 Sending request to OpenAI")
        print("🔐 API Key Present:", !openAIAPIKey.isEmpty)
        print("🧠 Prompt:\n", prompt)
        
        if useMockAI {
            return Just("Thanks for sharing that. You’re doing great just by reflecting today.")
                .delay(for: .seconds(1), scheduler: DispatchQueue.main)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let responseText = String(data: data, encoding: .utf8) ?? "No response body"

                print("🔍 OpenAI API Status Code:", statusCode)
                print("📩 Response body:\n", responseText)

                guard statusCode == 200 else {
                    throw NSError(domain: "OpenAIError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: responseText])
                }

                let result = try JSONDecoder().decode(OpenAIChatResponse.self, from: data)
                return result.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines) ?? "I'm here to listen anytime."
            }

            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

