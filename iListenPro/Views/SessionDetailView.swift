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
        ZStack {
            // 🔲 Background behind everything (removes all lines)
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Date: \(session.date.formatted(date: .abbreviated, time: .shortened))")
                        .font(.headline)
                        .foregroundColor(.white)

                    if let transcript = session.transcript {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("You said:")
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            Text(transcript)
                                .font(.body)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }

                    if let reply = session.reply {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("AI replied:")
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            Text(reply)
                                .font(.body)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue.opacity(0.25))
                                .cornerRadius(12)
                        }
                    }

                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle("Conversation")
        .navigationBarTitleDisplayMode(.inline)
    }
}

