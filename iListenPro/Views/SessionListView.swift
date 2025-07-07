//
//  SessionListView.swift
//  iListenPro
//
//  Created by Anurag Pandit on 03/07/25.
//


import SwiftUI

struct SessionListView: View {
    let sessions: [Session]
    
    var body: some View {
        List {
            ForEach(sessions) { session in
                NavigationLink(destination: SessionDetailView(session: session)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.date, style: .date)
                            .font(.headline)
                        
                        if let transcript = session.transcript {
                            Text(transcript.prefix(80) + "…")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        } else {
                            Text("No transcript available")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .navigationTitle("Previous Conversations")
    }
}

