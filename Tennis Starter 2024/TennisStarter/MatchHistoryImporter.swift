//
//  MatchHistoryImporter.swift
//  TennisStarter
//
//  Created by GEORGE HARRISON on 19/03/2025.
//  Copyright © 2025 University of Chester. All rights reserved.
//

import Foundation

class MatchHistoryImporter {
    static let shared = MatchHistoryImporter()
    private let filename = "history.json"
    
    private var fileURL: URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentDirectory.appendingPathComponent(filename)
    }
    
    func saveMatch(_ match: MatchResult) {
        try? FileManager.default.removeItem(at: fileURL)
        print("Deleted history.json, please save a new match.")

        var matches = loadMatches()
        matches.append(match)
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        do {
            let data = try encoder.encode(matches)
            try data.write(to: fileURL)
            let jsonString = String(data: data, encoding: .utf8) ?? "Could not convert JSON"
            print("Saved match history JSON content: \(jsonString)")
        } catch {
            print("Error saving match: \(error.localizedDescription)")
        }
    }

    
    func loadMatches() -> [MatchResult] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601  // Ensure it decodes the correct date format

        do {
            let data = try Data(contentsOf: fileURL)
            print("Match history JSON content: \(String(data: data, encoding: .utf8) ?? "N/A")")
            return try decoder.decode([MatchResult].self, from: data)
        } catch {
            print("Error decoding match history: \(error.localizedDescription)")
            return []
        }
    }
}
