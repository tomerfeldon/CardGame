//
//  GameEngine.swift
//  CardGame
//
//  Pure game logic (no UIKit) so it can be unit tested independently of the UI.
//  Each round draws two cards; the higher strength scores a point. Equal cards
//  score nothing ("skip"). After `totalRounds` the game is finished.
//  A final tie is decided in favour of the house (PC).
//

import Foundation

final class GameEngine {

    enum RoundResult: Equatable {
        case player
        case pc
        case tie
    }

    struct Round {
        let playerCard: Card
        let pcCard: Card
        let result: RoundResult
    }

    let playerName: String
    let playerSide: Side
    let totalRounds: Int

    private(set) var roundsPlayed = 0
    private(set) var playerScore = 0
    private(set) var pcScore = 0

    /// Injectable so tests can supply deterministic cards.
    private let drawProvider: () -> (Card, Card)

    init(playerName: String,
         playerSide: Side,
         totalRounds: Int = 10,
         drawProvider: @escaping () -> (Card, Card) = Deck.drawTwo) {
        self.playerName = playerName
        self.playerSide = playerSide
        self.totalRounds = totalRounds
        self.drawProvider = drawProvider
    }

    var isFinished: Bool { roundsPlayed >= totalRounds }

    /// Plays one round and returns it, or nil if the game is already finished.
    @discardableResult
    func playRound() -> Round? {
        guard !isFinished else { return nil }

        let (playerCard, pcCard) = drawProvider()
        let result: RoundResult

        if playerCard.strength > pcCard.strength {
            result = .player
            playerScore += 1
        } else if pcCard.strength > playerCard.strength {
            result = .pc
            pcScore += 1
        } else {
            result = .tie   // equal cards – skip, no points
        }

        roundsPlayed += 1
        return Round(playerCard: playerCard, pcCard: pcCard, result: result)
    }

    /// The player wins only with a strictly higher score; a tie goes to the house (PC).
    var winnerIsPlayer: Bool { playerScore > pcScore }

    var winnerName: String { winnerIsPlayer ? playerName : "PC" }

    var winnerScore: Int { winnerIsPlayer ? playerScore : pcScore }
}
