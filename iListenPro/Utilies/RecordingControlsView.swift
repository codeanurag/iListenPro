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
        VStack(spacing: 24) {
            HStack(spacing: 16) {
                Button(action: {
                    sessionVM.togglePause()
                }) {
                    Text("Pause")
                        .frame(width: 100)
                }
                .buttonStyle(PrimaryButtonStyle())

                Button(action: {
                    sessionVM.stopSession()
                }) {
                    Text("Stop")
                        .frame(width: 100)
                }
                .buttonStyle(PrimaryButtonStyle())
            }

            Button(action: {
                sessionVM.endAndSendRecording()
            }) {
                Text("End & Send")
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.top, 8)
            .disabled(!sessionVM.canEndEarly)
            .opacity(sessionVM.canEndEarly ? 1.0 : 0.4)
        }
    }
}
