//
//  OpenAIChatResponse.swift
//  iListenPro
//
//  Created by Anurag Pandit on 05/07/25.
//


import Foundation

struct OpenAIChatResponse: Decodable {
    let choices: [Choice]

    struct Choice: Decodable {
        let message: Message
    }

    struct Message: Decodable {
        let role: String
        let content: String
    }
}
