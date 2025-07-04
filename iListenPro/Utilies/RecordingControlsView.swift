//
//  RecordingControlsView.swift
//  iListenPro
//
//  Created by Anurag Pandit on 04/07/25.
//
import SwiftUI

struct RecordingControlsView: View {
    @EnvironmentObject var sessionVM: SessionViewModel

    var body: some View {
        HStack(spacing: 16) {
            Button(action: {
                sessionVM.togglePause()
            }) {
                Text(sessionVM.isPaused ? "Resume" : "Pause")
                    .frame(width: 120)
            }
            .buttonStyle(PrimaryButtonStyle())
            
            Button(action: {
                sessionVM.stopSession()
            }) {
                Text("Stop")
                    .frame(width: 120)
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.top, 20)
    }
}


