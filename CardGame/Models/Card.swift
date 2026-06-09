//
//  Card.swift
//  CardGame
//
//  A single playing card. Strength is the card rank (Ace is high = 14).
//

import Foundation

struct Card: Equatable {

    enum Suit: String, CaseIterable {
        case clubs
        case diamonds
    }

    let suit: Suit
    let rank: Int   // 2...14  (J = 11, Q = 12, K = 13, A = 14)

    /// The strength used to compare two cards. Higher wins the round.
    var strength: Int { rank }

    /// Matches the imageset names created in Assets.xcassets, e.g. "clubs_13".
    var assetName: String { "\(suit.rawValue)_\(rank)" }

    /// Human readable rank, e.g. "K", "7", "A".
    var displayRank: String {
        switch rank {
        case 14: return "A"
        case 13: return "K"
        case 12: return "Q"
        case 11: return "J"
        default: return "\(rank)"
        }
    }
}
