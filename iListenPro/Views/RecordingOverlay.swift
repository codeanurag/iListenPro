//
//  RecordingOverlay.swift
//  iListenPro
//
//  Created by Anurag Pandit on 03/07/25.
//


import SwiftUI

struct RecordingOverlay: View {
    @State private var secondsRemaining: Int = 180
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 20) {
            Text("Recording...")
                .font(.title2)
                .foregroundColor(.white)

            ProgressView(value: Double(180 - secondsRemaining), total: 180)
                .progressViewStyle(.linear)
                .tint(.white)
                .frame(width: 200)

            Text("\(secondsRemaining) sec left")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(40)
        .background(Color.black.opacity(0.85).ignoresSafeArea())
        .onReceive(timer) { _ in
            if secondsRemaining > 0 {
                secondsRemaining -= 1
            }
        }
    }
}
