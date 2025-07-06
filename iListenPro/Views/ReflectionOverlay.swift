//
//  ReflectionOverlay.swift
//  iListenPro
//
//  Created by Anurag Pandit on 06/07/25.
//


import SwiftUI

struct ReflectionOverlay: View {
    let transcript: String
    let reply: String
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("You said:")
                .font(.headline)
                .foregroundColor(.white)

            Text(transcript)
                .font(.body)
                .foregroundColor(.white)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)

            Divider().background(Color.white)

            Text("AI replied:")
                .font(.headline)
                .foregroundColor(.white)

            Text(reply)
                .font(.body)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(10)

            Spacer()

            Button("Done") {
                onDismiss()
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.top, 24)
        }
        .padding()
        .background(Color.black.opacity(0.95).ignoresSafeArea())
    }
}
