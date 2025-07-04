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
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 10)

            Circle()
                .trim(from: 0, to: CGFloat(1 - Double(timeRemaining) / Double(duration)))
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.25), value: timeRemaining)

            Text("\(timeRemaining) sec")
                .font(.title)
                .foregroundColor(.white)
        }
        .frame(width: 220, height: 220)
        .padding(.bottom, 20)
    }
}
