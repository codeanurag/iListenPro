//
//  Session.swift
//  iListenPro
//
//  Created by Anurag Pandit on 03/07/25.
//


import Foundation

struct Session: Identifiable, Codable {
    let id: UUID
    let date: Date
    var transcript: String?
    var reply: String?

    init(date: Date) {
        self.id = UUID()
        self.date = date
    }

    var summary: String {
        reply?.prefix(60).appending("...") ?? "No reply yet"
    }
}
