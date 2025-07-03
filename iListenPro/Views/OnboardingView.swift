//
//  OnboardingView.swift
//  iListenPro
//
//  Created by Anurag Pandit on 03/07/25.
//

import SwiftUI
struct OnboardingView: View {
  @Binding var showingOnboarding: Bool
  @EnvironmentObject var sessionVM: SessionViewModel

  var body: some View {
    VStack(spacing: 24) {
      Text("Welcome!")
        .font(.largeTitle)
      Text("This app helps you reflect daily in just 3 minutes.")
        .multilineTextAlignment(.center)
      Button("Got it!") {
        UserDefaults.standard.set(true, forKey: "didOnboard")
        showingOnboarding = false
      }
      .buttonStyle(.borderedProminent)
    }
    .padding()
  }
}
