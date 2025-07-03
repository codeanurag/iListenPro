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
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // replace with CoreML voice if integrated
        utterance.rate = 0.45
        synthesizer.speak(utterance)
    }
}
