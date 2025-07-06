//
//  SessionViewModel.swift
//  iListenPro
//
//  Created by Anurag Pandit on 03/07/25.
//


import Foundation
import Combine
import UserNotifications
import SwiftUI
import AVFAudio
import Speech

class SessionViewModel: ObservableObject {
    @Published var sessions: [Session] = []
    @Published var currentSession: Session?
    @Published var encouragement: String?
    @Published var overlayView: AnyView = AnyView(EmptyView())
    @Published var isRecording = false
    @Published var isPaused = false
    @Published var timeRemaining: Int = 180
    let duration = 180
    
    private var timerCancellable: AnyCancellable?
    
    private let recorder = AudioRecorder()
    private let synthesizer = SpeechSynthesizer()
    private let store = SessionStore()
    private var cancellables = Set<AnyCancellable>()
    
    private var openAIAPIKey: String {
        // In production, use environment variables or secure storage
        // For development, you can set this in your scheme's environment variables
        return ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
    }
    
    var canEndEarly: Bool {
        return timeRemaining < (duration - 5) // allow early end after 5 seconds
    }
    
    init() {
        sessions = store.load()
        encouragement = "A few minutes of self-care can go a long way."
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
    
    /*
     private func transcribe(url: URL) -> AnyPublisher<String, Error> {
        Just("I had a really long day but I’m feeling better now.")
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    private func generateAIResponse(to text: String) -> AnyPublisher<String, Error> {
        Just("It sounds like you’ve been carrying a lot. I'm really glad you shared that.")
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
     */
}
extension SessionViewModel {
    func startSession() {
        let session = Session(date: Date())
        currentSession = session
        isRecording = true
        isPaused = false
        timeRemaining = duration
        
        // Start timer
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
        
        // Start recording and pipeline
        recorder.startRecording(duration: TimeInterval(duration))
            .flatMap { url in
                self.transcribe(url: url)
            }
            .flatMap { transcript -> AnyPublisher<String, Error> in
                self.currentSession?.transcript = transcript
                self.overlayView = AnyView(LoadingOverlay())
                return self.generateAIResponse(to: transcript)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Session error: \(error.localizedDescription)")
                    self.overlayView = AnyView(EmptyView())
                    self.isRecording = false
                    self.timerCancellable?.cancel()
                        print("OpenAI pipeline error:", error)
                }
            }, receiveValue: { reply in
                self.currentSession?.reply = reply
                print("AI replied:", reply)
                if let session = self.currentSession {
                    self.sessions.insert(session, at: 0)
                    self.store.save(self.sessions)
                    self.synthesizer.speak(text: reply) // 🔊 Speak the AI reply

                    self.overlayView = AnyView(
                        ReflectionOverlay(
                            transcript: session.transcript ?? "",
                            reply: reply,
                            onDismiss: {
                                self.overlayView = AnyView(EmptyView())
                            }
                        )
                    )

                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    self.overlayView = AnyView(EmptyView())
                }

                self.overlayView = AnyView(EmptyView())
                self.isRecording = false
                self.timerCancellable?.cancel()
            })
            .store(in: &cancellables)
    }

    
    func stopSession() {
        isRecording = false
        timerCancellable?.cancel()
        overlayView = AnyView(LoadingOverlay())
        
        // Mock pipeline or continue with Combine chain...
    }
    
    func togglePause() {
        isPaused.toggle()
    }
}
extension SessionViewModel {
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
}

extension SessionViewModel {
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
        // debug
        print("Sending to OpenAI:", String(data: body, encoding: .utf8)!)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                let status = (response as? HTTPURLResponse)?.statusCode ?? 0
                print("OpenAI HTTP status:", status, "; response:", String(data: data, encoding: .utf8)!)
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
    func endAndSendRecording() {
        isRecording = false
        timerCancellable?.cancel()

        recorder.stopManually() // stop early
    }
}
