import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var p1Button: UIButton!
    @IBOutlet weak var p2Button: UIButton!
    
    @IBOutlet weak var viewMatchHistory: UIButton!
    
    @IBOutlet weak var p1NameLabel: UILabel!
    @IBOutlet weak var p2NameLabel: UILabel!

    @IBOutlet weak var p1PointsLabel: UILabel!
    @IBOutlet weak var p2PointsLabel: UILabel!

    @IBOutlet weak var p1GamesLabel: UILabel!
    @IBOutlet weak var p2GamesLabel: UILabel!

    @IBOutlet weak var p1SetsLabel: UILabel!
    @IBOutlet weak var p2SetsLabel: UILabel!

    @IBOutlet weak var p1PreviousSetsLabel: UILabel!
    @IBOutlet weak var p2PreviousSetsLabel: UILabel!
    
    @IBOutlet weak var p1NameField: UITextField!
    @IBOutlet weak var p2NameField: UITextField!
    
    @IBOutlet weak var firstServerSegment: UISegmentedControl!
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var gameContainerView: UIView!

    
    var player1Name: String = "Player 1"
    var player2Name: String = "Player 2"
    private var initalServerPlayer1: Bool = false


    private var game = Game()
    private var match = Match()
    var audioPlayer: AVAudioPlayer?
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if UserDefaults.standard.dictionary(forKey: "savedGame") != nil,
           !isSavedMatchComplete() {
            showResumePrompt()
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func previousMatchesPressed(_ sender: UIButton) {
        saveGame()
        performSegue(withIdentifier: "showMatchHistory", sender: self)
    }


    
    @IBAction func p1AddPointPressed(_ sender: UIButton) {
        animateButton(sender)
        game.addPointToPlayer1()

        if game.player1Won() {
            match.addGamePlayer1()
            game.resetGame()
        }

        if match.complete() {
            showWinnerAlert()
            playSound(named: "Sound")
        }

        updateUI()
        saveGame()
    }

    
    @IBAction func p2AddPointPressed(_ sender: UIButton) {
        animateButton(sender)
        game.addPointToPlayer2()

        if game.player2Won() {
            match.addGamePlayer2()
            game.resetGame()
        }

        if match.complete() {
            showWinnerAlert()
            playSound(named: "Sound")
        }

        updateUI()
        saveGame()
    }

    
    @IBAction func restartPressed(_ sender: AnyObject) {
            self.game = Game()
            self.match = Match()

            self.p1NameField.text = ""
            self.p2NameField.text = ""

            self.p1NameField.isHidden = false
            self.p2NameField.isHidden = false
            self.firstServerSegment.isHidden = false
            self.startGameButton.isHidden = false
            self.gameContainerView.isHidden = true

            self.updateUI()

    }


    private func updateUI() {
        p1Button.setTitle("\(player1Name)", for: .normal)
        p2Button.setTitle("\(player2Name)", for: .normal)

        p1PointsLabel.text = game.player1Score()
        p2PointsLabel.text = game.player2Score()

        p1GamesLabel.text = "\(match.returnCurrentGamesPlayer1())"
        p2GamesLabel.text = "\(match.returnCurrentGamesPlayer2())"

        p1SetsLabel.text = "\(match.player1Sets())"
        p2SetsLabel.text = "\(match.player2Sets())"

        p1Button.isEnabled = !match.complete()
        p2Button.isEnabled = !match.complete()

        updateMatchPointColour()
        updateServingColours()
    }

    
    private func updateMatchPointColour() {
        if game.gamePointsForPlayer1() > 0 {
            p1PointsLabel.backgroundColor = .green
        } else {
            p1PointsLabel.backgroundColor = .clear
        }

        if game.gamePointsForPlayer2() > 0 {
            p2PointsLabel.backgroundColor = .green
        } else {
            p2PointsLabel.backgroundColor = .clear
        }
    }
    
    private func showResumePrompt() {
        let alert = UIAlertController(
            title: "Resume Match?",
            message: "Would you like to continue your previous match or start a new one?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Continue", style: .default) { _ in
            self.loadGame()
        })

        alert.addAction(UIAlertAction(title: "Start New", style: .destructive) { _ in
            UserDefaults.standard.removeObject(forKey: "savedGame")
            self.resetToNewGame()
        })

        present(alert, animated: true, completion: nil)
    }

    private func resetToNewGame() {
        game = Game()
        match = Match()
        
        p1NameField.text = ""
        p2NameField.text = ""

        p1NameField.isHidden = false
        p2NameField.isHidden = false
        firstServerSegment.isHidden = false
        startGameButton.isHidden = false
        gameContainerView.isHidden = true

        player1Name = "Player 1"
        player2Name = "Player 2"
        p1NameLabel.text = player1Name
        p2NameLabel.text = player2Name

        updateUI()
    }


    
    private func updateServingColours() {
        guard !gameContainerView.isHidden else {
            p1NameLabel.backgroundColor = .clear
            p2NameLabel.backgroundColor = .clear
            return
        }

        let totalGames = match.returnCurrentGamesPlayer1() + match.returnCurrentGamesPlayer2()
        let isPlayer1Serving = (totalGames % 2 == 0) ? initalServerPlayer1 : !initalServerPlayer1

        p1NameLabel.backgroundColor = isPlayer1Serving ? .purple : .clear
        p2NameLabel.backgroundColor = isPlayer1Serving ? .clear : .purple
    }


    
    private func persistCurrentGame() {
        let gameState: [String: Any] = [
            "player1": game.player1Score(),
            "player2": game.player2Score(),
            "player1GamesWon": match.returnCurrentGamesPlayer1(),
            "player2GamesWon": match.returnCurrentGamesPlayer2(),
            "player1Sets": match.player1Sets(),
            "player2Sets": match.player2Sets(),
            "tieBreakActive": match.returnCurrentTieBreakStatus(),
            "player1Name": player1Name,
            "player2Name": player2Name
        ]
        UserDefaults.standard.set(gameState, forKey: "savedGame")
    }


    
    private func showWinnerAlert() {
        let winner = match.winner() ?? "No Winner Yet"
        
        let winnerName: String
        
        if winner == "Player 1" {
            winnerName = player1Name
        } else if winner == "Player 2" {
            winnerName = player2Name
        } else {
            winnerName = winner
        }
        let matchResult = MatchResult (
            winner: winnerName,
            player1Sets: match.player1Sets(),
            player2Sets: match.player2Sets(),
            timestamp: Date(),
            completeGame: true
        )
        MatchHistoryImporter.shared.saveMatch(matchResult)
        
        let alert = UIAlertController(title: "Match Over", message: "\(winnerName) wins the match!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    
    private func animateButton(_ button: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 3, options: .allowUserInteraction, animations: {
                button.transform = .identity
            })
        }
    }

    
    private func playSound(named soundName: String) {
        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: "wav") else { return }
        audioPlayer = try? AVAudioPlayer(contentsOf: soundURL)
        audioPlayer?.play()
    }

    private func saveGame() {
        let gameState: [String: Any] = [
            "player1": game.player1Score(),
            "player2": game.player2Score(),
            "player1GamesWon": match.returnCurrentGamesPlayer1(),
            "player2GamesWon": match.returnCurrentGamesPlayer2(),
            "player1Sets": match.player1Sets(),
            "player2Sets": match.player2Sets(),
            "tieBreakActive": match.returnCurrentTieBreakStatus(),
            "player1Name": player1Name,
            "player2Name": player2Name
        ]
        

        UserDefaults.standard.set(gameState, forKey: "savedGame")
    }

    private func loadGame() {
        guard let savedState = UserDefaults.standard.dictionary(forKey: "savedGame") else { return }
        print(savedState)
        match.loadState(
            player1Games: savedState["player1GamesWon"] as? Int ?? 0,
            player2Games: savedState["player2GamesWon"] as? Int ?? 0,
            player1Sets: savedState["player1Sets"] as? Int ?? 0,
            player2Sets: savedState["player2Sets"] as? Int ?? 0,
            tieBreakActive: savedState["tieBreakActive"] as? Bool ?? false
        )
        
        player1Name = savedState["player1Name"] as? String ?? "Player 1"
        
        if let name1 = savedState["player1Name"] as? String {
            player1Name = name1
            p1NameLabel.text = name1

        } else {
            print("⚠️ Cannot find player 1 name: \(String(describing: savedState["player1Name"]))")
        }

        if let name2 = savedState["player2Name"] as? String {
            player2Name = name2
            p2NameLabel.text = name2

        } else {
            print("⚠️ Cannot find player 2 name: \(String(describing: savedState["player2Name"]))")
        }

        p1NameField.isHidden = true
        p2NameField.isHidden = true
        firstServerSegment.isHidden = true
        startGameButton.isHidden = true
        gameContainerView.isHidden = false

        game.resetGame()
        updateUI()
    }


    @IBAction func savePressed(_ sender: UIButton) {
        animateButton(sender)
        saveGame()
        updateUI()
    }

    @IBAction func loadPressed(_ sender: UIButton) {
        animateButton(sender)
        loadGame()
        updateUI()
    }
    
    @IBAction func startGamePressed(_ sender: UIButton) {
        player1Name = p1NameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Player 1"
        player2Name = p2NameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Player 2"

        initalServerPlayer1 = firstServerSegment.selectedSegmentIndex == 0

        p1Button.setTitle(player1Name, for: .normal)
        p1NameLabel.text = player1Name
        p2Button.setTitle(player2Name, for: .normal)
        p2NameLabel.text = player2Name

        p1NameField.isHidden = true
        p2NameField.isHidden = true
        firstServerSegment.isHidden = true
        startGameButton.isHidden = true
        gameContainerView.isHidden = false

        updateServingColours()

        DispatchQueue.main.async {
            self.view.layoutIfNeeded()
        }
    }
    
    private func isSavedMatchComplete() -> Bool {
        guard let savedState = UserDefaults.standard.dictionary(forKey: "savedGame") else { return false }
        let player1Sets = savedState["player1Sets"] as? Int ?? 0
        let player2Sets = savedState["player2Sets"] as? Int ?? 0
        return player1Sets == 3 || player2Sets == 3
    }


}
