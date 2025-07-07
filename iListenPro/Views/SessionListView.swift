//
//  SessionListView.swift
//  iListenPro
//
//  Created by Anurag Pandit on 03/07/25.
//


import SwiftUI

struct SessionListView: View {
    @EnvironmentObject var sessionVM: SessionViewModel

    var body: some View {
        List {
            ForEach(sessionVM.sessions) { session in
                NavigationLink(destination: SessionDetailView(session: session)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.date, style: .date)
                            .font(.headline)
                            .foregroundColor(.white)

                        if let transcript = session.transcript {
                            Text(transcript.prefix(80) + "…")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        } else {
                            Text("No transcript available")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 6)
                }
                .listRowBackground(Color.black)
            }
            .onDelete(perform: deleteSessions)
        }
        .listStyle(.plain)
        .background(Color.black)
        .navigationTitle("Previous Conversations")
        .foregroundColor(.white)
    }

    private func deleteSessions(at offsets: IndexSet) {
        sessionVM.sessions.remove(atOffsets: offsets)
        sessionVM.store.save(sessionVM.sessions)
    }
}


