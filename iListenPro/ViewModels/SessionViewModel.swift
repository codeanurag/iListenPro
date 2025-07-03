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

class SessionViewModel: ObservableObject {
    @Published var sessions: [Session] = []
    @Published var currentSession: Session?
    @Published var encouragement: String?
    @Published var overlayView: AnyView = AnyView(EmptyView())

    private let recorder = AudioRecorder()
    private let synthesizer = SpeechSynthesizer()
    private let store = SessionStore()
    private var cancellables = Set<AnyCancellable>()

    init() {
        sessions = store.load()
        encouragement = "A few minutes of self-care can go a long way."
    }

    func startSession() {
        let session = Session(date: Date())
        currentSession = session
        overlayView = AnyView(RecordingOverlay())
        
        recorder.startRecording(duration: 180)
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
                    print("Error during session: \(error.localizedDescription)")
                    self.overlayView = AnyView(EmptyView())
                }
            }, receiveValue: { reply in
                self.currentSession?.reply = reply
                if let session = self.currentSession {
                    self.sessions.insert(session, at: 0)
                    self.store.save(self.sessions)
                    self.synthesizer.speak(text: reply)
                }
                self.overlayView = AnyView(EmptyView())
            })
            .store(in: &cancellables)
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
}
