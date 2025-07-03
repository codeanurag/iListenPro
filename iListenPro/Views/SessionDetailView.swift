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
        VStack(alignment: .leading, spacing: 16) {
            Text("You said:")
                .font(.headline)
            Text(session.transcript ?? "No transcription available.")
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)

            Divider()

            Text("AI replied:")
                .font(.headline)
            Text(session.reply ?? "No reply generated.")
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)

            Spacer()
        }
        .padding()
        .navigationTitle(session.date.formatted(date: .abbreviated, time: .shortened))
    }
}
