//
//  iListenProApp.swift
//  iListenPro
//
//  Created by Anurag Pandit on 03/07/25.
//

import SwiftUI

@main
struct iListenProApp: App {
    @StateObject var sessionVM = SessionViewModel()
    @State var showingOnboarding = !UserDefaults.standard.bool(forKey: "didOnboard")
    
    var body: some Scene {
        WindowGroup {
            if showingOnboarding {
                OnboardingView(showingOnboarding: $showingOnboarding)
                    .environmentObject(sessionVM)
            } else {
                ContentView()
                    .environmentObject(sessionVM)
                    .onAppear { sessionVM.requestPermissionsAndScheduleReminder() }
            }
        }
    }
}
