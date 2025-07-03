//
//  AudioRecorder.swift
//  iListenPro
//
//  Created by Anurag Pandit on 03/07/25.
//


import AVFoundation
import Combine

class AudioRecorder: NSObject, AVAudioRecorderDelegate {
    private var recorder: AVAudioRecorder?
    private var subject = PassthroughSubject<URL, Error>()

    func startRecording(duration: TimeInterval) -> Future<URL, Error> {
        Future { promise in
            let filename = FileManager.default.temporaryDirectory.appendingPathComponent("recording.m4a")
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            do {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(.record, mode: .default)
                try session.setActive(true)

                self.recorder = try AVAudioRecorder(url: filename, settings: settings)
                self.recorder?.delegate = self
                self.recorder?.record(forDuration: duration)

                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    self.recorder?.stop()
                    promise(.success(filename))
                }
            } catch {
                promise(.failure(error))
            }
        }
    }
}
