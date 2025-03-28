//
//  MatchPersistence.swift
//  TennisStarter
//
//  Created by GEORGE HARRISON on 27/03/2025.
//  Copyright © 2025 University of Chester. All rights reserved.
//

import Foundation


struct MatchStatePersistence {
    static let key = "savedGame"

    static func save(match: Match, game: Game, p1Name: String, p2Name: String) {
        let state: [String: Any] = [
            "player1": game.player1Score(),
            "player2": game.player2Score(),
            "player1GamesWon": match.returnCurrentGamesPlayer1(),
            "player2GamesWon": match.returnCurrentGamesPlayer2(),
            "player1Sets": match.player1Sets(),
            "player2Sets": match.player2Sets(),
            "tieBreakActive": match.returnCurrentTieBreakStatus(),
            "player1Name": p1Name,
            "player2Name": p2Name
        ]
        UserDefaults.standard.set(state, forKey: key)
    }

    static func load() -> [String: Any]? {
        return UserDefaults.standard.dictionary(forKey: key)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }

    static func isComplete() -> Bool {
        guard let state = load() else { return false }
        let p1 = state["player1Sets"] as? Int ?? 0
        let p2 = state["player2Sets"] as? Int ?? 0
        return p1 == 3 || p2 == 3
    }
}
