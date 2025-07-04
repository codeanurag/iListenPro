//
//  PrimaryButtonStyle.swift
//  iListenPro
//
//  Created by Anurag Pandit on 04/07/25.
//


import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(Color.blue.opacity(configuration.isPressed ? 0.6 : 0.8))
            .cornerRadius(12)
    }
}
