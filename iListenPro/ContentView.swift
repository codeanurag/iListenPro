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
                
                if showRecordingUI {
                    VStack(spacing: 24) {
                        CircularCountdownView(
                            timeRemaining: sessionVM.timeRemaining,
                            duration: sessionVM.duration
                        )
                        RecordingControlsView()
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeOut(duration: 0.4), value: showRecordingUI)
                }
                
                Spacer()
                
                if !sessionVM.isRecording {
                    Button(action: {
                        sessionVM.startSession()
                        withAnimation {
                            showRecordingUI = true
                        }
                    }) {
                        Text("Start Conversation")
                            .frame(maxWidth: .infinity, minHeight: 52)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal)
                }
                NavigationLink("Previous Conversations", destination: SessionListView(sessions: sessionVM.sessions))
                    .foregroundColor(.blue)
                    .padding(.bottom, 12)
            }
            .padding(.bottom, 40)
        }
        .onChange(of: sessionVM.isRecording) { isRecording in
            if !isRecording {
                withAnimation {
                    showRecordingUI = false
                }
            }
        }
    }
}




