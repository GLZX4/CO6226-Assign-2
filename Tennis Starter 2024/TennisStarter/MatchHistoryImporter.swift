//
//  MatchHistoryImporter.swift
//  TennisStarter
//
//  Created by GEORGE HARRISON on 19/03/2025.
//  Copyright © 2025 University of Chester. All rights reserved.
//

import Foundation

//code for saving and reading data to json adapted from the following sources:
// https://medium.com/@lrkhan/storing-app-data-locally-99e36d4b91a0
// https://www.swiftyplace.com/blog/codable-how-to-simplify-converting-json-data-to-swift-objects-and-vice-versa
//

class MatchHistoryImporter {
    static let shared = MatchHistoryImporter()
    private let filename = "history.json"
    
    private var fileURL: URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentDirectory.appendingPathComponent(filename)
    }
    
    func saveMatch(_ result: MatchResult) {
        var matches = loadMatches()
        matches.append(result)

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(matches)
            try data.write(to: fileURL)
            print("Saved match history at: \(fileURL.path)")
        } catch {
            print("Failed to save match history: \(error)")
        }
    }

    
    func loadMatches() -> [MatchResult] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let data = try Data(contentsOf: fileURL)
            return try decoder.decode([MatchResult].self, from: data)
        } catch {
            print("Error decoding match history: \(error)")
            return []
        }
    }
}
