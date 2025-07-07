//
//  ContentView.swift
//  iListenPro
//
//  Created by Anurag Pandit on 03/07/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sessionVM: SessionViewModel
    @State private var showRecordingUI = false
    @State private var showControls = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                Text("How was your day today?")
                    .font(.title2)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text(sessionVM.encouragement ?? "")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // ✅ Show recording timer + controls during recording or processing
                if sessionVM.isRecording || sessionVM.isProcessingResponse {
                    VStack(spacing: 24) {
                        CircularCountdownView(
                            timeRemaining: sessionVM.timeRemaining,
                            duration: sessionVM.duration
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeOut(duration: 0.4), value: sessionVM.isRecording)

                        if sessionVM.isRecording {
                            RecordingControlsView()
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                                .animation(.easeOut(duration: 0.3).delay(0.3), value: sessionVM.isRecording)
                        }
                    }
                }

                Spacer()

                if !sessionVM.isRecording && !sessionVM.isProcessingResponse {
                    NavigationLink("Previous Conversations", destination: SessionListView(sessions: sessionVM.sessions))
                        .foregroundColor(.blue)
                        .padding(.bottom, 12)

                    Button(action: {
                        sessionVM.startSession()
                        withAnimation {
                            showRecordingUI = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            withAnimation {
                                showControls = true
                            }
                        }
                    }) {
                        Text("Start Conversation")
                            .frame(maxWidth: .infinity, minHeight: 52)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 40)
            .overlay(sessionVM.overlayView)
        }
        .onChange(of: sessionVM.isRecording) { isRecording in
            if !isRecording {
                withAnimation {
                    showRecordingUI = false
                    showControls = false
                }
            }
        }
    }
}
