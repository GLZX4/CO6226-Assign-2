//
//  Set.swift
//  TennisStarter
//
//  Created by GEORGE HARRISON on 30/01/2025.
//  Copyright © 2025 University of Chester. All rights reserved.
//
class Set {
    private var player1GamesWon: Int = 0
    private var player2GamesWon: Int = 0
    private var player1TieBreakPoints: Int = 0
    private var player2TieBreakPoints: Int = 0
    private var tieBreakActive: Bool = false

    func addGameToPlayer1() {
        if !complete() {
            if tieBreakActive {
                player1TieBreakPoints += 1
                if checkTieBreakWinner() {
                    tieBreakActive = false
                    player1GamesWon += 1
                }
            } else {
                player1GamesWon += 1
            }
            checkTieBreak()
        }
    }

    func addGameToPlayer2() {
        if !complete() {
            if tieBreakActive {
                player2TieBreakPoints += 1
                if checkTieBreakWinner() {
                    tieBreakActive = false
                    player2GamesWon += 1
                }
            } else {
                player2GamesWon += 1
            }
            checkTieBreak()
        }
    }

    func player1Games() -> Int {
        return player1GamesWon
    }

    func player2Games() -> Int {
        return player2GamesWon
    }

    func isTieBreakActive() -> Bool {
        return tieBreakActive
    }

    func complete() -> Bool {
        return hasWon(player1GamesWon, player2GamesWon) || hasWon(player2GamesWon, player1GamesWon)
    }


    private func hasWon(_ playerGames: Int, _ opponentGames: Int) -> Bool {
        if tieBreakActive {
            return false
        }

        if playerGames >= 6 && playerGames - opponentGames >= 2 {
            return true
        }

        if playerGames == 7 && (opponentGames == 5 || opponentGames == 6) {
            return true
        }

        return false
    }




    private func checkTieBreak() {
        if player1GamesWon == 6 && player2GamesWon == 6 {
            tieBreakActive = true
        }
    }

    private func checkTieBreakWinner() -> Bool {
        return (player1TieBreakPoints >= 7 || player2TieBreakPoints >= 7) &&
               abs(player1TieBreakPoints - player2TieBreakPoints) >= 2
    }
    
    func winner() -> String? {
        if complete() {
            if hasWon(player1GamesWon, player2GamesWon) {
                return "Player 1"
            } else if hasWon(player2GamesWon, player1GamesWon) {
                return "Player 2"
            }
        }
        return nil
    }


    
    func loadState(player1Games: Int, player2Games: Int, tieBreakActive: Bool) {
        self.player1GamesWon = player1Games
        self.player2GamesWon = player2Games
        self.tieBreakActive = tieBreakActive

        if !tieBreakActive {
            player1TieBreakPoints = 0
            player2TieBreakPoints = 0
        }
    }
}
