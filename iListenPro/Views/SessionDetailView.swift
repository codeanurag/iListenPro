//
//  SessionDetailView.swift
//  iListenPro
//
//  Created by Anurag Pandit on 03/07/25.
//


import SwiftUI

struct SessionDetailView: View {
    let session: Session

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Date: \(session.date.formatted(date: .abbreviated, time: .shortened))")
                    .font(.headline)

                if let transcript = session.transcript {
                    Text("You said:")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text(transcript)
                        .font(.body)
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(10)
                }

                if let reply = session.reply {
                    Text("AI replied:")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text(reply)
                        .font(.body)
                        .padding()
                        .background(Color.blue.opacity(0.15))
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationTitle("Conversation")
        .background(Color.black.ignoresSafeArea())
        .foregroundColor(.white)
    }
}

