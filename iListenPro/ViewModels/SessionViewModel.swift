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
    
    /*private func transcribe(url: URL) -> AnyPublisher<String, Error> {
        Just("I had a really long day but I’m feeling better now.")
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }*/
    
    private func generateAIResponse(to text: String) -> AnyPublisher<String, Error> {
        Just("It sounds like you’ve been carrying a lot. I'm really glad you shared that.")
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
extension SessionViewModel {
    func startSession() {
        currentSession = Session(date: Date())
        isRecording = true
        isPaused = false
        timeRemaining = duration
        
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
        
        // Add audioRecorder.startRecording() here if needed
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
