//
//  Match .swift
//  TennisStarter
//
//  Created by GEORGE HARRISON on 30/01/2025.
//  Copyright © 2025 University of Chester. All rights reserved.
//
class Match {
    private var player1SetsWon: Int = 0
    private var player2SetsWon: Int = 0
    private var currentSet: Set = Set()

    func addGamePlayer1() {
        currentSet.addGameToPlayer1()
        if currentSet.complete() {
            if currentSet.player1Games() > currentSet.player2Games() {
                player1SetsWon += 1
            } else {
                player2SetsWon += 1
            }
            if !complete() {
                currentSet = Set() // Start a new set
            }
        }
    }

    func addGamePlayer2() {
        currentSet.addGameToPlayer2()
        if currentSet.complete() {
            if currentSet.player1Games() > currentSet.player2Games() {
                player1SetsWon += 1
            } else {
                player2SetsWon += 1
            }
            if !complete() {
                currentSet = Set() // Start a new set
            }
        }
    }

    func player1Sets() -> Int {
        return player1SetsWon
    }

    func player2Sets() -> Int {
        return player2SetsWon
    }

    func returnCurrentGamesPlayer1() -> Int {
        return currentSet.player1Games()
    }

    func returnCurrentGamesPlayer2() -> Int {
        return currentSet.player2Games()
    }
    
    func returnCurrentTieBreakStatus() -> Bool {
        return Set.isTieBreakActive(currentSet)()
    }
    func winner() -> String? {
        if player1SetsWon >= 3 {
            return "Player 1"
        } else if player2SetsWon >= 3 {
            return "Player 2"
        }
        return nil
    }

    func complete() -> Bool {
        return player1SetsWon == 3 || player2SetsWon == 3
    }
    
    func loadState(player1Games: Int, player2Games: Int, player1Sets: Int, player2Sets: Int, tieBreakActive: Bool) {
        player1SetsWon = player1Sets
        player2SetsWon = player2Sets
        currentSet = Set()
        currentSet.loadState(player1Games: player1Games, player2Games: player2Games, tieBreakActive: tieBreakActive)
    }
}
