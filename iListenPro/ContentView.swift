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
        NavigationStack {
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
                    
                    if case .recording = sessionVM.uiState {
                        VStack(spacing: 24) {
                            CircularCountdownView(
                                timeRemaining: sessionVM.timeRemaining,
                                duration: sessionVM.duration
                            )
                            RecordingControlsView()
                        }
                    }
                    
                    if case .processing = sessionVM.uiState {
                        VStack(spacing: 24) {
                            CircularCountdownView(
                                timeRemaining: sessionVM.timeRemaining,
                                duration: sessionVM.duration
                            )
                            LoadingOverlay()
                        }
                    }
                    
                    Spacer()
                    
                    if case .idle = sessionVM.uiState {
                        NavigationLink(
                            destination: SessionListView()
                                .environmentObject(sessionVM)
                        ) {
                            Text("Previous Conversations")
                        }
                        
                        Button(action: {
                            sessionVM.startSession()
                        }) {
                            Text("Start Conversation")
                                .frame(maxWidth: .infinity, minHeight: 52)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.horizontal)
                    }
                    
                    if case .error(let message) = sessionVM.uiState {
                        Text(message)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }
                .padding(.bottom, 40)
                
                if case .reflecting(let transcript, let reply) = sessionVM.uiState {
                    ReflectionOverlay(
                        transcript: transcript,
                        reply: reply,
                        onDismiss: {
                            sessionVM.uiState = .idle
                        }
                    )
                }
            }
        }
    }
}


