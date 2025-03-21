class Game {
    private var player1: Int = 0
    private var player2: Int = 0

    func addPointToPlayer1() {
        if !complete() {
            player1 += 1
        }

    }

    func addPointToPlayer2() {
        if !complete() {
            player2 += 1
        }
    }

    func player1Score() -> String {
        return scoreToString(for: player1, opponent: player2)
    }

    func player2Score() -> String {
        return scoreToString(for: player2, opponent: player1)
    }

    func player1Won() -> Bool {
        return hasWon(playerPoints: player1, opponentPoints: player2)
    }

    func player2Won() -> Bool {
        return hasWon(playerPoints: player2, opponentPoints: player1)
    }
    
    func gamePointsForPlayer1() -> Int {
        return requiredToEqualize(winningPlayer: player1, losingPlayer: player2)
    }

    func gamePointsForPlayer2() -> Int {
        return requiredToEqualize(winningPlayer: player2, losingPlayer: player1)
    }

    func complete() -> Bool {
        return player1Won() || player2Won()
    }

    func resetGame() {
        player1 = 0
        player2 = 0
    }
    
    private func requiredToEqualize(winningPlayer: Int, losingPlayer: Int) -> Int {
        if winningPlayer == 3 && losingPlayer < 3 {
            return 3 - losingPlayer
        } else if winningPlayer == 4 && losingPlayer == 3 {
            return 1
        } else if winningPlayer >= 4 && losingPlayer >= 3 {
            return max(0, winningPlayer - losingPlayer - 1)
        }
        return 0
    }
    

    private func hasWon(playerPoints: Int, opponentPoints: Int) -> Bool {
        return (playerPoints >= 4 && playerPoints - opponentPoints >= 2)
    }

    private func scoreToString(for player: Int, opponent: Int) -> String {
        if complete() { return "" }
        if player >= 3 && opponent >= 3 {
            if player == opponent { return "40" }
            return player > opponent ? "A" : "40"
        }
        return ["0","15","30","40","A"][min(player, 4)]
    }

}
