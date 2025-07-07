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
    @Published var overlayView: AnyView = AnyView(EmptyView())
    @Published var isRecording = false
    @Published var isPaused = false
    @Published var timeRemaining: Int = 180
    @Published var isProcessingResponse = false

    let duration = 180

    var canEndEarly: Bool {
        return timeRemaining < (duration - 5)
    }

    private let recorder = AudioRecorder()
    private let synthesizer = SpeechSynthesizer()
    private let store = SessionStore()
    private var cancellables = Set<AnyCancellable>()
    private var timerCancellable: AnyCancellable?

    init() {
        sessions = store.load()
        encouragement = "A few minutes of self-care can go a long way."
    }
    
    private var openAIAPIKey: String {
        // In production, use environment variables or secure storage
        // For development, you can set this in your scheme's environment variables
        return ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
    }

    func startSession() {
        let session = Session(date: Date())
        currentSession = session
        isRecording = true
        isPaused = false
        timeRemaining = duration
        
        // Start countdown timer
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isRecording, !self.isPaused else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.stopSession()
                }
            }
        
        // Start audio recording and transcription/AI flow
        recorder.startRecording(duration: TimeInterval(duration))
            .sink(receiveCompletion: { _ in }, receiveValue: { url in
                self.processRecording(at: url)
            })
            .store(in: &cancellables)
    }

    func stopSession() {
        isRecording = false
        timerCancellable?.cancel()
        recorder.stopManually()
    }

    func endAndSendRecording() {
        isRecording = false
        isProcessingResponse = true
        timerCancellable?.cancel()
        recorder.stopManually()
    }

    func togglePause() {
        isPaused.toggle()
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
        request.addValue("Bearer \(openAIAPIKey)",
                         forHTTPHeaderField: "Authorization")
        request.addValue("application/json",
                         forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                let status = (response as? HTTPURLResponse)?.statusCode ?? 0
                guard status == 200 else {
                    throw URLError(.badServerResponse)
                }

                let result = try JSONDecoder().decode(OpenAIChatResponse.self, from: data)
                return result.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines) ?? "I'm here to listen anytime."
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

extension SessionViewModel {
    func processRecording(at url: URL) {
        isProcessingResponse = true

        transcribe(url: url)
            .flatMap { transcript -> AnyPublisher<String, Error> in
                self.currentSession?.transcript = transcript

                DispatchQueue.main.async {
                    self.overlayView = AnyView(LoadingOverlay())
                }

                return Just(transcript)
                    .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
                    .flatMap { self.generateAIResponse(to: $0) }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isProcessingResponse = false
                if case .failure(let error) = completion {
                    self.overlayView = AnyView(EmptyView())
                }
            }, receiveValue: { reply in
                self.currentSession?.reply = reply
                self.synthesizer.speak(text: reply)

                self.overlayView = AnyView(
                    ReflectionOverlay(
                        transcript: self.currentSession?.transcript ?? "",
                        reply: reply,
                        onDismiss: {
                            self.overlayView = AnyView(EmptyView())
                        }
                    )
                )
                self.isProcessingResponse = false
            })
            .store(in: &cancellables)
    }
}
