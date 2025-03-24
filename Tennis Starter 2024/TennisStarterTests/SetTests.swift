//
//  SetTests.swift
//  TennisStarterTests
//
//  Created by GEORGE HARRISON on 24/03/2025.
//  Copyright © 2025 University of Chester. All rights reserved.
//

import XCTest
@testable import TennisStarter

final class SetTests: XCTestCase {
    
    func testPlayer1WinsSetWithoutTiebreak() {
        let set = Set()
        for _ in 0..<6 { set.addGameToPlayer1() }
        for _ in 0..<4 { set.addGameToPlayer2() }
        
        XCTAssertTrue(set.complete())
        XCTAssertEqual(set.winner(), "Player 1")
    }

    func testPlayer2WinsSetWithoutTiebreak() {
        let set = Set()
        for _ in 0..<2 { set.addGameToPlayer1() }
        for _ in 0..<6 { set.addGameToPlayer2() }
        
        XCTAssertTrue(set.complete())
        XCTAssertEqual(set.winner(), "Player 2")
    }
    
    func testSetIncompleteAt5to5() {
        let set = Set()
        for _ in 0..<5 { set.addGameToPlayer1() }
        for _ in 0..<5 { set.addGameToPlayer2() }
        
        XCTAssertFalse(set.complete())
        XCTAssertNil(set.winner())
    }
    
    func testSetGoesToTiebreak() {
        let set = Set()
        for _ in 0..<6 {
            set.addGameToPlayer1()
            set.addGameToPlayer2()
        }
        XCTAssertTrue(set.isTieBreakActive())
    }
    
    func testTiebreakVictory() {
        let set = Set()
        for _ in 0..<6 {
            set.addGameToPlayer1()
            set.addGameToPlayer2()
        }
        
        for _ in 0..<7 {
            set.addGameToPlayer1()
        }
        
        XCTAssertTrue(set.complete())
        XCTAssertEqual(set.winner(), "Player 1")
    }
    
    func testSetNotWonAt6to5() {
        let set = Set()
        for _ in 0..<6 { set.addGameToPlayer1() }
        for _ in 0..<5 { set.addGameToPlayer2() }
        
        XCTAssertFalse(set.complete())
        XCTAssertNil(set.winner())
    }
    
    func testLoadStateWorksCorrectly() {
        let set = Set()
        set.loadState(player1Games: 4, player2Games: 3, tieBreakActive: false)
        
        XCTAssertEqual(set.player1Games(), 4)
        XCTAssertEqual(set.player2Games(), 3)
        XCTAssertFalse(set.isTieBreakActive())
    }
}
