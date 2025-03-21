//
//  PreviousMatchesViewController.swift
//  TennisStarter
//
//  Created by GEORGE HARRISON on 19/03/2025.
//  Copyright © 2025 University of Chester. All rights reserved.
//

import UIKit

class PreviousMatchesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    private var matchHistory: [MatchResult] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MatchCell")
        tableView.dataSource = self
        matchHistory = MatchHistoryImporter.shared.loadMatches()
        tableView.reloadData()
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchHistory.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MatchCell", for: indexPath)
        let match = matchHistory[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"

        cell.textLabel?.text = "🏆 \(match.winner) won \(match.player1Sets)-\(match.player2Sets)"
        cell.detailTextLabel?.text = "📅 \(dateFormatter.string(from: match.timestamp))"
        return cell
    }
}
