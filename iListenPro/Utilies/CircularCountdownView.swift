//
//  CircularCountdownView.swift
//  iListenPro
//
//  Created by Anurag Pandit on 04/07/25.
//


import SwiftUI

struct CircularCountdownView: View {
    var timeRemaining: Int
    let duration: Int

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 10)

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.0), value: timeRemaining)

            // Time label
            Text("\(timeRemaining) sec")
                .font(.title)
                .foregroundColor(.white)
        }
        .frame(width: 220, height: 220)
    }

    private var progress: CGFloat {
        CGFloat(1 - Double(timeRemaining) / Double(duration))
    }
}

