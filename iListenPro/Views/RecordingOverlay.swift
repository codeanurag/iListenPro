//
//  RecordingOverlay.swift
//  iListenPro
//
//  Created by Anurag Pandit on 03/07/25.
//


import SwiftUI
import Combine

struct RecordingOverlay: View {
    @State private var timeRemaining: Int = 180
    @State private var isPaused = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 32) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 10)
                
                Circle()
                    .trim(from: 0, to: CGFloat(1 - Double(timeRemaining) / 180.0))
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.25), value: timeRemaining)
                
                Text("\(timeRemaining) sec")
                    .font(.title)
                    .foregroundColor(.white)
            }
            .frame(width: 200, height: 200)
            
            HStack(spacing: 40) {
                Button(action: {
                    isPaused.toggle()
                }) {
                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 28))
                        .frame(width: 60, height: 60)
                        .background(Color.gray.opacity(0.5))
                        .clipShape(Circle())
                }
                
                Button(action: {
                    timeRemaining = 0 // simulate stop
                }) {
                    Image(systemName: "stop.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 28))
                        .frame(width: 60, height: 60)
                        .background(Color.red.opacity(0.8))
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.85).ignoresSafeArea())
        .onReceive(timer) { _ in
            guard !isPaused else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
    }
}

