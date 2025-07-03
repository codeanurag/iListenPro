//
//  LoadingOverlay.swift
//  iListenPro
//
//  Created by Anurag Pandit on 03/07/25.
//


import SwiftUI

struct LoadingOverlay: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)

            Text("Listening to you…")
                .foregroundColor(.white)
                .font(.headline)
        }
        .padding(40)
        .background(Color.black.opacity(0.85).ignoresSafeArea())
    }
}
