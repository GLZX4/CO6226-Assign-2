//
//  MatchLogicTests.swift
//  TennisStarterTests
//
//  Created by GEORGE HARRISON on 24/03/2025.
//  Copyright © 2025 University of Chester. All rights reserved.
//

import XCTest
@testable import TennisStarter

final class MatchLogicTests : XCTestCase {
    
    func testSetWinSixGames() {
        let set = Set()
        for _ in 0..<6 { set.addGameToPlayer1() }
        for _ in 0..<4 { set.addGameToPlayer2() }

        XCTAssertTrue(set.complete())
        XCTAssertEqual(set.winner(), "Player 1")
    }

    func testMatchNotCompleteAtTwoSets() {
        let match = Match()
        for _ in 0..<6 { match.addGamePlayer1() }
        for _ in 0..<6 { match.addGamePlayer1() }

        XCTAssertFalse(match.complete())
        XCTAssertNil(match.winner())
    }

    func testMatchCompleteAtThreeSets() {
        let match = Match()
        for _ in 0..<18 { match.addGamePlayer1() }

        XCTAssertTrue(match.complete())
        XCTAssertEqual(match.winner(), "Player 1")
    }

    func testTiebreakActivatesAtSixAll() {
        let match = Match()
        for _ in 0..<6 {
            match.addGamePlayer1()
            match.addGamePlayer2()
        }

        XCTAssertTrue(match.returnCurrentTieBreakStatus())
    }

    func testAlternatingSetWinners() {
        let match = Match()

        // First set to Player 1
        for _ in 0..<6 { match.addGamePlayer1() }

        // Second set to Player 2
        for _ in 0..<6 { match.addGamePlayer2() }

        // Third set to Player 1
        for _ in 0..<6 { match.addGamePlayer1() }

        XCTAssertFalse(match.complete())
        XCTAssertNil(match.winner())

        for _ in 0..<6 { match.addGamePlayer1() }

        XCTAssertTrue(match.complete())
        XCTAssertEqual(match.winner(), "Player 1")
    }

    func testLoadStateRestoresMatch() {
        let match = Match()
        match.loadState(player1Games: 3, player2Games: 4, player1Sets: 1, player2Sets: 2, tieBreakActive: false)

        XCTAssertEqual(match.returnCurrentGamesPlayer1(), 3)
        XCTAssertEqual(match.returnCurrentGamesPlayer2(), 4)
        XCTAssertEqual(match.player1Sets(), 1)
        XCTAssertEqual(match.player2Sets(), 2)
        XCTAssertFalse(match.returnCurrentTieBreakStatus())
    }

    func testMatchDoesNotCompleteTooEarly() {
        let match = Match()
        for _ in 0..<6 { match.addGamePlayer1() }
        for _ in 0..<6 { match.addGamePlayer1() }

        XCTAssertFalse(match.complete())
    }
}
