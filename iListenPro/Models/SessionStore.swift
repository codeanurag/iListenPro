//
//  SessionStore.swift
//  iListenPro
//
//  Created by Anurag Pandit on 03/07/25.
//


import Foundation

class SessionStore {
    private let key = "iListenSessions"

    func save(_ sessions: [Session]) {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func load() -> [Session] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let sessions = try? JSONDecoder().decode([Session].self, from: data) else {
            return []
        }
        return sessions
    }
}
