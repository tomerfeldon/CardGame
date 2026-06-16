//
//  SummaryViewController.swift
//  CardGame
//
//  Shows the winner and their score, with a button back to the main menu.
//

import UIKit

final class SummaryViewController: UIViewController {

    @IBOutlet private weak var winnerLabel: UILabel!
    @IBOutlet private weak var scoreLabel: UILabel!

    private var winnerName = ""
    private var winnerScore = 0

    func configure(winnerName: String, winnerScore: Int) {
        self.winnerName = winnerName
        self.winnerScore = winnerScore
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        winnerLabel.text = "Winner: \(winnerName)"
        scoreLabel.text = "score: \(winnerScore)"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Victory / end-of-game sound.
        SoundManager.shared.playWin()
    }

    @IBAction private func backToMenuTapped(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
}
