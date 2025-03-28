//
//  GameController.swift
//  TennisStarter
//
//  Created by GEORGE HARRISON on 27/03/2025.
//  Copyright © 2025 University of Chester. All rights reserved.
//

import Foundation

class GameController {
    private(set) var match = Match()
    private(set) var game = Game()

    var onMatchComplete: ((String) -> Void)?
    
    func addPointToPlayer1() {
        game.addPointToPlayer1()
        if game.player1Won() {
            match.addGamePlayer1()
            game.resetGame()
        }
        checkMatchStatus()
    }

    func addPointToPlayer2() {
        game.addPointToPlayer2()
        if game.player2Won() {
            match.addGamePlayer2()
            game.resetGame()
        }
        checkMatchStatus()
    }

    private func checkMatchStatus() {
        if match.complete(), let winner = match.winner() {
            onMatchComplete?(winner)
        }
    }
}
