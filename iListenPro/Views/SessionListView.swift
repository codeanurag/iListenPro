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
        List(sessions) { session in
            NavigationLink(destination: SessionDetailView(session: session)) {
                VStack(alignment: .leading) {
                    Text(session.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.headline)
                    Text(session.summary)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Past Sessions")
    }
}
