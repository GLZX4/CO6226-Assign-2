import UIKit
import AVFoundation

class ViewController: UIViewController {

    // MARK: - IBOutlets

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

        if let saved = UserDefaults.standard.dictionary(forKey: "savedGame"),
           !isSavedMatchComplete() {
            showResumePrompt()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updatePreviousSetLabels()
    }


    @IBAction func p1AddPointPressed(_ sender: UIButton) {
        animateButton(sender)
        game.addPointToPlayer1()
        if game.player1Won() {
            match.addGamePlayer1()
            game.resetGame()
        }
        handlePostPoint()
    }

    @IBAction func p2AddPointPressed(_ sender: UIButton) {
        animateButton(sender)
        game.addPointToPlayer2()
        if game.player2Won() {
            match.addGamePlayer2()
            game.resetGame()
        }
        handlePostPoint()
    }

    private func handlePostPoint() {
        if match.complete() {
            showWinnerAlert()
            playSound(named: "Sound")
        }
        updateUI()
        saveGame()
    }


    @IBAction func startGamePressed(_ sender: UIButton) {
        player1Name = p1NameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Player 1"
        player2Name = p2NameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Player 2"
        initalServerPlayer1 = firstServerSegment.selectedSegmentIndex == 0

        p1NameLabel.text = player1Name
        p2NameLabel.text = player2Name
        p1Button.setTitle(player1Name, for: .normal)
        p2Button.setTitle(player2Name, for: .normal)

        p1NameField.isHidden = true
        p2NameField.isHidden = true
        firstServerSegment.isHidden = true
        startGameButton.isHidden = true
        gameContainerView.isHidden = false

        updateServingColours()
        updateUI()

        DispatchQueue.main.async {
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func restartPressed(_ sender: AnyObject) {
        resetToNewGame()
    }


    private func showResumePrompt() {
        let alert = UIAlertController(
            title: "Resume Match?",
            message: "Would you like to continue your previous match or start a new one?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Continue", style: .default) { _ in self.loadGame() })
        alert.addAction(UIAlertAction(title: "Start New", style: .destructive) {
            _ in
            UserDefaults.standard.removeObject(forKey: "savedGame")
            self.resetToNewGame()
        })
        present(alert, animated: true)
    }

    private func resetToNewGame() {
        game = Game()
        match = Match()

        player1Name = "Player 1"
        player2Name = "Player 2"

        p1NameLabel.text = player1Name
        p2NameLabel.text = player2Name
        p1NameField.text = ""
        p2NameField.text = ""

        p1NameField.isHidden = false
        p2NameField.isHidden = false
        firstServerSegment.isHidden = false
        startGameButton.isHidden = false
        gameContainerView.isHidden = true

        updateUI()
    }


    private func showWinnerAlert() {
        let winner = match.winner() ?? "No Winner Yet"
        let winnerName = winner == "Player 1" ? player1Name :
                         winner == "Player 2" ? player2Name : winner

        let result = MatchResult(
            winner: winnerName,
            player1Sets: match.player1Sets(),
            player2Sets: match.player2Sets(),
            timestamp: Date(),
            completeGame: true
        )
        MatchHistoryImporter.shared.saveMatch(result)

        let alert = UIAlertController(title: "Match Over", message: "\(winnerName) wins the match!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)

        updatePreviousSetLabels()
    }


    private func updateUI() {
        p1Button.setTitle(player1Name, for: .normal)
        p2Button.setTitle(player2Name, for: .normal)

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
        p1PointsLabel.backgroundColor = game.gamePointsForPlayer1() > 0 ? .green : .clear
        p2PointsLabel.backgroundColor = game.gamePointsForPlayer2() > 0 ? .green : .clear
    }

    private func updateServingColours() {
        guard !gameContainerView.isHidden else {
            p1NameLabel.backgroundColor = .clear
            p2NameLabel.backgroundColor = .clear
            p1NameLabel.textColor = .label
            p2NameLabel.textColor = .label
            return
        }

        let totalGames = match.returnCurrentGamesPlayer1() + match.returnCurrentGamesPlayer2()
        let isPlayer1Serving = (totalGames % 2 == 0) ? initalServerPlayer1 : !initalServerPlayer1

        if isPlayer1Serving {
            p1NameLabel.backgroundColor = .purple
            p1NameLabel.textColor = .white
            p2NameLabel.backgroundColor = .clear
            p2NameLabel.textColor = .label
        } else {
            p2NameLabel.backgroundColor = .purple
            p2NameLabel.textColor = .white
            p1NameLabel.backgroundColor = .clear
            p1NameLabel.textColor = .label
        }
    }


    private func updatePreviousSetLabels() {
        let matches = MatchHistoryImporter.shared.loadMatches()
        guard let lastMatch = matches.last else {
            p1PreviousSetsLabel.text = "-"
            p2PreviousSetsLabel.text = "-"
            return
        }
        p1PreviousSetsLabel.text = "\(lastMatch.player1Sets)"
        p2PreviousSetsLabel.text = "\(lastMatch.player2Sets)"
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
        guard let saved = UserDefaults.standard.dictionary(forKey: "savedGame") else { return }

        match.loadState(
            player1Games: saved["player1GamesWon"] as? Int ?? 0,
            player2Games: saved["player2GamesWon"] as? Int ?? 0,
            player1Sets: saved["player1Sets"] as? Int ?? 0,
            player2Sets: saved["player2Sets"] as? Int ?? 0,
            tieBreakActive: saved["tieBreakActive"] as? Bool ?? false
        )

        player1Name = saved["player1Name"] as? String ?? "Player 1"
        player2Name = saved["player2Name"] as? String ?? "Player 2"
        p1NameLabel.text = player1Name
        p2NameLabel.text = player2Name
        p1Button.setTitle(player1Name, for: .normal)
        p2Button.setTitle(player2Name, for: .normal)

        p1NameField.isHidden = true
        p2NameField.isHidden = true
        firstServerSegment.isHidden = true
        startGameButton.isHidden = true
        gameContainerView.isHidden = false

        game.resetGame()
        updateUI()
    }

    private func isSavedMatchComplete() -> Bool {
        guard let saved = UserDefaults.standard.dictionary(forKey: "savedGame") else { return false }
        let p1 = saved["player1Sets"] as? Int ?? 0
        let p2 = saved["player2Sets"] as? Int ?? 0
        return p1 == 3 || p2 == 3
    }


    private func animateButton(_ button: UIButton) {
        UIView.animate(withDuration: 0.1) {
            button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 3,
                           options: .allowUserInteraction) {
                button.transform = .identity
            }
        }
    }

    private func playSound(named: String) {
        guard let soundURL = Bundle.main.url(forResource: named, withExtension: "wav") else { return }
        audioPlayer = try? AVAudioPlayer(contentsOf: soundURL)
        audioPlayer?.play()
    }


    @IBAction func previousMatchesPressed(_ sender: UIButton) {
        saveGame()
        performSegue(withIdentifier: "showMatchHistory", sender: self)
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
}
