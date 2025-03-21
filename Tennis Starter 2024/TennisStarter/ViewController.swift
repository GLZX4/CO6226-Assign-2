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


    private var game = Game()
    private var match = Match()
    var audioPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func previousMatchesPressed(_ sender: UIButton) {
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
    }

    
    @IBAction func restartPressed(_ sender: AnyObject) {
        let alert = UIAlertController(
            title: "Restart Match",
            message: "Are you sure you want to restart the match?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Restart", style: .destructive) { _ in
            self.game = Game()
            self.match = Match()

            // Reset player names
            self.p1NameField.text = ""
            self.p2NameField.text = ""

            // Show name input fields again
            self.p1NameField.isHidden = false
            self.p2NameField.isHidden = false
            self.firstServerSegment.isHidden = false
            self.startGameButton.isHidden = false
            self.gameContainerView.isHidden = true  // Hide match UI

            self.updateUI()
        })

        present(alert, animated: true, completion: nil)
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

    
    private func updateServingColours() {
        // This is a simplified placeholder:
        let isPlayer1Serving = match.returnCurrentGamesPlayer1() % 2 == 0
        p1NameLabel.backgroundColor = isPlayer1Serving ? .purple : .clear
        p2NameLabel.backgroundColor = isPlayer1Serving ? .clear : .purple
    }

    
    private func showWinnerAlert() {
        let winner = match.winner() ?? "No Winner Yet"
        let matchResult = MatchResult (
            winner: winner,
            player1Sets: match.player1Sets(),
            player2Sets: match.player2Sets(),
            timestamp: Date()
        )
        MatchHistoryImporter.shared.saveMatch(matchResult)
        
        let alert = UIAlertController(title: "Match Over", message: "\(winner) wins the match!", preferredStyle: .alert)
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
            player1Name : game.player1Score(),
            player2Name: game.player2Score(),
            "player1GamesWon": match.returnCurrentGamesPlayer1(),
            "player2GamesWon": match.returnCurrentGamesPlayer2(),
            "player1Sets": match.player1Sets(),
            "player2Sets": match.player2Sets(),
            "tieBreakActive": match.returnCurrentTieBreakStatus()
        ]
        UserDefaults.standard.set(gameState, forKey: "savedGame")
    }

    private func loadGame() {
        guard let savedState = UserDefaults.standard.dictionary(forKey: "savedGame") else { return }
        match.loadState(
            player1Games: savedState["player1GamesWon"] as? Int ?? 0,
            player2Games: savedState["player2GamesWon"] as? Int ?? 0,
            player1Sets: savedState["player1Sets"] as? Int ?? 0,
            player2Sets: savedState["player2Sets"] as? Int ?? 0,
            tieBreakActive: savedState["tieBreakActive"] as? Bool ?? false
        )
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

        p1Button.setTitle(player1Name, for: .normal)
        p1NameLabel.text = player1Name
        p2Button.setTitle(player2Name, for: .normal)
        p2NameLabel.text = player2Name


        p1NameField.isHidden = true
        p2NameField.isHidden = true

        firstServerSegment.isHidden = true
        startGameButton.isHidden = true
        gameContainerView.isHidden = false

        DispatchQueue.main.async {
            self.view.layoutIfNeeded()
        }

    }
}
