//
//  MatchResult.swift
//  TennisStarter
//
//  Created by GEORGE HARRISON on 19/03/2025.
//  Copyright © 2025 University of Chester. All rights reserved.
//

import Foundation

struct MatchResult: Codable {
    let winner: String
    let player1Sets: Int
    let player2Sets: Int
    let timestamp: Date
}

