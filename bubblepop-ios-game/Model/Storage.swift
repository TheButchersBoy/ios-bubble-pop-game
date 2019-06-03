//
//  Storage.swift
//  bubblepop-ios-game
//
//  Created by Nathan Carr on 12/5/19.
//  Copyright © 2019 Nathan Carr. All rights reserved.
//

import Foundation

// Struct for storing data
struct Storage: Codable {
    let settingsArchiveURL: URL
    let leaderboardArchiveURL: URL
    
    // Data error enums
    enum DataError: Error {
        case dataNotSaved
        case dataNotFound
    }
    
    init() {
        // Initiate .json data stores
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // Set up URLs
        leaderboardArchiveURL = directory.appendingPathComponent("leaderboard")
            .appendingPathExtension("json")
        settingsArchiveURL = directory.appendingPathComponent("game_settings")
            .appendingPathExtension("json")
    }
    
    // Read data from file
    func read(from archive: URL) throws -> Data {
        if let data = try? Data(contentsOf: archive) {
            return data
        }
        throw DataError.dataNotFound
    }
    
    // Write data to file
    func write(_ data: Data, to archive: URL) throws {
        do {
            try data.write(to: archive, options: .noFileProtection)
        }
        catch {
            throw DataError.dataNotSaved
        }
    }
    
    func loadLeaderboard() throws -> [Leaderboard] {
        let data = try read(from: leaderboardArchiveURL)
        if let leaderboard = try? JSONDecoder().decode([Leaderboard].self, from: data) {
            return leaderboard
        }
        throw DataError.dataNotFound
    }
    
    func loadSettings() throws -> Settings {
        let data = try read(from: settingsArchiveURL)
        if let settings = try? JSONDecoder().decode(Settings.self, from: data) {
            return settings
        }
        throw DataError.dataNotFound
    }
    
    func saveData(scores: [Leaderboard]) throws {
        let data = try JSONEncoder().encode(scores)
        try write(data, to: leaderboardArchiveURL)
    }
    
    func saveData(settings: Settings) throws {
        let data = try JSONEncoder().encode(settings)
        try write(data, to: settingsArchiveURL)
    }
}
