//
//  Deck.swift
//  CardGame
//
//  Builds the pool of available cards and draws cards at random.
//  The pool is the two fully-available suits (clubs A–K, diamonds A–K) = 26 cards.
//

import Foundation

enum Deck {

    /// The full pool of playable cards.
    static func pool() -> [Card] {
        var cards: [Card] = []
        for suit in Card.Suit.allCases {
            for rank in 2...14 {
                cards.append(Card(suit: suit, rank: rank))
            }
        }
        return cards
    }

    /// Draws two distinct random cards (one per player) for a single round.
    static func drawTwo() -> (Card, Card) {
        let shuffled = pool().shuffled()
        return (shuffled[0], shuffled[1])
    }
}
