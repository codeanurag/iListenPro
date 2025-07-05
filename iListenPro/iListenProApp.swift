//
//  iListenProApp.swift
//  iListenPro
//
//  Created by Anurag Pandit on 03/07/25.
//

import SwiftUI
import Speech

@main
struct iListenProApp: App {
    @StateObject var sessionVM = SessionViewModel()
    @State var showingOnboarding = !UserDefaults.standard.bool(forKey: "didOnboard")

    var body: some Scene {
        WindowGroup {
            if showingOnboarding {
                OnboardingView(showingOnboarding: $showingOnboarding)
                    .environmentObject(sessionVM)
                    .onAppear {
                        SFSpeechRecognizer.requestAuthorization { status in
                            DispatchQueue.main.async {
                                if status == .authorized {
                                    print("Speech recognition authorized")
                                } else {
                                    print("Speech recognition not authorized: \(status)")
                                }
                            }
                        }
                    }
            } else {
                ContentView()
                    .environmentObject(sessionVM)
                    .onAppear {
                        sessionVM.requestPermissionsAndScheduleReminder()
                    }
            }
        }
    }
}
