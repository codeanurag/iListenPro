//
//  SessionUIState.swift
//  iListenPro
//
//  Created by Anurag Pandit on 07/07/25.
//


enum SessionUIState: Equatable {
    case idle
    case recording
    case processing
    case reflecting(transcript: String, reply: String)
    case error(String)
}

