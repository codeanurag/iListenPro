//
//  ContentView.swift
//  iListenPro
//
//  Created by Anurag Pandit on 03/07/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sessionVM: SessionViewModel

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if sessionVM.isRecording {
                VStack(spacing: 32) {
                    CircularCountdownView(
                        timeRemaining: sessionVM.timeRemaining,
                        duration: sessionVM.duration
                    )
                    RecordingControlsView()
                }
            } else {
                VStack {
                    Spacer()

                    Text("How was your day today?")
                        .font(.title2)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()

                    Text(sessionVM.encouragement ?? "")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 40)

                    NavigationLink("Previous Conversations", destination: SessionListView(sessions: sessionVM.sessions))
                        .foregroundColor(.blue)
                        .padding(.bottom, 20)

                    Button(action: {
                        sessionVM.startSession()
                    }) {
                        Text("Start Conversation")
                            .frame(maxWidth: .infinity, minHeight: 52)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal)
            }
        }
    }
}


