//
//  SpeechSynthesizer.swift
//  iListenPro
//
//  Created by Anurag Pandit on 03/07/25.
//


import AVFoundation

class SpeechSynthesizer {
    private let synthesizer = AVSpeechSynthesizer()

    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // Customize as needed
        utterance.rate = 0.45
        utterance.pitchMultiplier = 1.0
        synthesizer.speak(utterance)
    }
}
