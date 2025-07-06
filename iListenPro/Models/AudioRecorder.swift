//
//  AudioRecorder.swift
//  iListenPro
//
//  Created by Anurag Pandit on 03/07/25.
//


import AVFoundation
import Combine
class AudioRecorder {
    private var recorder: AVAudioRecorder?
    private var recordingSubject: PassthroughSubject<URL, Error>?
    
    func startRecording(duration: TimeInterval) -> AnyPublisher<URL, Error> {
        let subject = PassthroughSubject<URL, Error>()
        recordingSubject = subject
        
        let filename = FileManager.default.temporaryDirectory.appendingPathComponent("recording.m4a")
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .default)
            try session.setActive(true)
            
            recorder = try AVAudioRecorder(url: filename, settings: settings)
            recorder?.record(forDuration: duration)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.stopManually()
            }
            
        } catch {
            subject.send(completion: .failure(error))
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    func stopManually() {
        recorder?.stop()
        if let url = recorder?.url {
            recordingSubject?.send(url)
            recordingSubject?.send(completion: .finished)
        }
    }
}
