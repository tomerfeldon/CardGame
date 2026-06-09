//
//  CardGameTests.swift
//  CardGameTests
//
//  Unit tests for the pure game logic (no UI involved).
//

import Testing
import CoreLocation
@testable import CardGame

struct CardGameTests {

    // MARK: - Card

    @Test func cardAssetNameAndDisplayRank() {
        let king = Card(suit: .clubs, rank: 13)
        #expect(king.assetName == "clubs_13")
        #expect(king.displayRank == "K")
        #expect(king.strength == 13)

        let ace = Card(suit: .diamonds, rank: 14)
        #expect(ace.assetName == "diamonds_14")
        #expect(ace.displayRank == "A")
    }

    // MARK: - Deck

    @Test func deckPoolIsTwentySixDistinctCards() {
        let pool = Deck.pool()
        #expect(pool.count == 26)
        let names = Set(pool.map { $0.assetName })
        #expect(names.count == 26)
    }

    // MARK: - Side selection

    @Test func eastOfTheMeridianPlaysEast() {
        let east = LocationService.referenceLongitude + 1
        #expect(LocationService.side(forLongitude: east) == .east)
    }

    @Test func westOfTheMeridianPlaysWest() {
        let west = LocationService.referenceLongitude - 1
        #expect(LocationService.side(forLongitude: west) == .west)
        // Exactly on the line counts as west (not strictly east).
        #expect(LocationService.side(forLongitude: LocationService.referenceLongitude) == .west)
    }

    // MARK: - GameEngine scoring

    private func engine(playerRank: Int, pcRank: Int, rounds: Int = 10) -> GameEngine {
        GameEngine(playerName: "Gabi", playerSide: .east, totalRounds: rounds) {
            (Card(suit: .clubs, rank: playerRank), Card(suit: .diamonds, rank: pcRank))
        }
    }

    @Test func strongerPlayerCardScoresForPlayer() {
        let game = engine(playerRank: 13, pcRank: 7)
        let round = game.playRound()
        #expect(round?.result == .player)
        #expect(game.playerScore == 1)
        #expect(game.pcScore == 0)
    }

    @Test func strongerPcCardScoresForPc() {
        let game = engine(playerRank: 5, pcRank: 9)
        let round = game.playRound()
        #expect(round?.result == .pc)
        #expect(game.pcScore == 1)
        #expect(game.playerScore == 0)
    }

    @Test func equalCardsScoreNothing() {
        let game = engine(playerRank: 8, pcRank: 8)
        let round = game.playRound()
        #expect(round?.result == .tie)
        #expect(game.playerScore == 0)
        #expect(game.pcScore == 0)
    }

    @Test func gameFinishesAfterTotalRounds() {
        let game = engine(playerRank: 13, pcRank: 2, rounds: 10)
        for _ in 0..<10 { _ = game.playRound() }
        #expect(game.isFinished)
        #expect(game.roundsPlayed == 10)
        #expect(game.playRound() == nil)   // no further rounds
        #expect(game.playerScore == 10)
    }

    @Test func playerWinsWhenScoreIsHigher() {
        let game = engine(playerRank: 13, pcRank: 2, rounds: 3)
        for _ in 0..<3 { _ = game.playRound() }
        #expect(game.winnerIsPlayer)
        #expect(game.winnerName == "Gabi")
        #expect(game.winnerScore == 3)
    }

    @Test func tieIsDecidedInFavourOfTheHouse() {
        // Every round is a tie -> 0:0 final -> house (PC) wins.
        let game = engine(playerRank: 8, pcRank: 8, rounds: 4)
        for _ in 0..<4 { _ = game.playRound() }
        #expect(!game.winnerIsPlayer)
        #expect(game.winnerName == "PC")
        #expect(game.winnerScore == 0)
    }
}
