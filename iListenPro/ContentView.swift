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
            VStack(spacing: 40) {
                Text("How was your day today?")
                    .font(.title2)
                    .padding(.top, 80)

                Button(action: sessionVM.startSession) {
                    Text("Start Conversation")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 60)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)

                if let encouragement = sessionVM.encouragement {
                    Text(encouragement)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()

                if let current = sessionVM.currentSession {
                    NavigationLink("View today's conversation", destination: SessionDetailView(session: current))
                }

                if !sessionVM.sessions.isEmpty {
                    NavigationLink("Previous sessions", destination: SessionListView(sessions: sessionVM.sessions))
                }
            }
            .overlay(sessionVM.overlayView)
            .navigationTitle("iListen")
        }
    }
}

