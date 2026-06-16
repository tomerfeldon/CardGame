//
//  GameViewController.swift
//  CardGame
//
//  Auto-playing screen. No buttons: every 5 seconds the two cards flip to a new
//  face (shown ~3s), the stronger card scores a point, then they flip back.
//  After 10 rounds it moves on to the summary screen.
//
//  Lifecycle: the round timer and background music are paused when the app is
//  backgrounded (or the screen is left) and resumed when it returns.
//

import UIKit

final class GameViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet private weak var leftNameLabel: UILabel!
    @IBOutlet private weak var leftScoreLabel: UILabel!
    @IBOutlet private weak var rightNameLabel: UILabel!
    @IBOutlet private weak var rightScoreLabel: UILabel!
    @IBOutlet private weak var leftCardImageView: UIImageView!
    @IBOutlet private weak var rightCardImageView: UIImageView!
    @IBOutlet private weak var timerLabel: UILabel!

    // MARK: Configuration
    private var playerName = "Player"
    private var playerSide: Side = .west
    private var engine: GameEngine!

    // MARK: Round timing (seconds)
    private let secondsPerRound = 5
    private let facesVisibleSeconds = 3   // faces shown for 3s, then flipped back
    private var secondsLeft = 0
    private var timer: Timer?
    private var isPausedByLifecycle = false

    /// Called by the menu before the segue.
    func configure(playerName: String, playerSide: Side) {
        self.playerName = playerName
        self.playerSide = playerSide
    }

    // MARK: Convenience – map player/PC onto the correct physical side.
    private var playerCardView: UIImageView { playerSide == .east ? rightCardImageView : leftCardImageView }
    private var pcCardView: UIImageView { playerSide == .east ? leftCardImageView : rightCardImageView }
    private var playerScoreLabel: UILabel { playerSide == .east ? rightScoreLabel : leftScoreLabel }
    private var pcScoreLabel: UILabel { playerSide == .east ? leftScoreLabel : rightScoreLabel }
    private var playerCardBack: UIImage? { UIImage(named: "card_back_red") }
    private var pcCardBack: UIImage? { UIImage(named: "card_back_black") }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)

        engine = GameEngine(playerName: playerName, playerSide: playerSide)

        // Player / PC name + score labels, placed on the correct sides.
        if playerSide == .east {
            rightNameLabel.text = playerName
            leftNameLabel.text = "PC"
        } else {
            leftNameLabel.text = playerName
            rightNameLabel.text = "PC"
        }
        playerCardView.image = playerCardBack
        pcCardView.image = pcCardBack
        updateScores()
        timerLabel.text = "\(secondsPerRound)"

        registerLifecycleObservers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if engine.roundsPlayed == 0 {
            SoundManager.shared.startBackgroundMusic()
            beginRound()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Leaving the game stops the clock and the music.
        timer?.invalidate()
        SoundManager.shared.stopBackgroundMusic()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: App background / foreground
    private func registerLifecycleObservers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleEnterBackground),
            name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleEnterForeground),
            name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    @objc private func handleEnterBackground() {
        guard timer != nil, !engine.isFinished else { return }
        timer?.invalidate()
        timer = nil
        isPausedByLifecycle = true
        SoundManager.shared.pauseBackgroundMusic()
    }

    @objc private func handleEnterForeground() {
        guard isPausedByLifecycle, view.window != nil else { return }
        isPausedByLifecycle = false
        SoundManager.shared.resumeBackgroundMusic()
        startTick()   // resume the countdown from where it stopped
    }

    // MARK: Game loop
    private func beginRound() {
        guard let round = engine.playRound() else {
            endGame()
            return
        }

        revealFace(playerCardView, card: round.playerCard)
        revealFace(pcCardView, card: round.pcCard)
        SoundManager.shared.playCardFlip()
        updateScores()

        secondsLeft = secondsPerRound
        timerLabel.text = "\(secondsLeft)"
        startTick()
    }

    private func startTick() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        secondsLeft -= 1
        timerLabel.text = "\(max(secondsLeft, 0))"

        // After the faces have been visible for `facesVisibleSeconds`, flip back.
        if secondsLeft == secondsPerRound - facesVisibleSeconds {
            flipToBack(playerCardView, image: playerCardBack)
            flipToBack(pcCardView, image: pcCardBack)
            SoundManager.shared.playCardFlip()
        }

        if secondsLeft <= 0 {
            timer?.invalidate()
            if engine.isFinished {
                endGame()
            } else {
                beginRound()
            }
        }
    }

    private func endGame() {
        timer?.invalidate()
        SoundManager.shared.stopBackgroundMusic()
        performSegue(withIdentifier: "toSummary", sender: nil)
    }

    // MARK: UI helpers
    private func revealFace(_ imageView: UIImageView, card: Card) {
        UIView.transition(with: imageView,
                          duration: 0.4,
                          options: .transitionFlipFromLeft,
                          animations: { imageView.image = UIImage(named: card.assetName) })
    }

    private func flipToBack(_ imageView: UIImageView, image: UIImage?) {
        UIView.transition(with: imageView,
                          duration: 0.4,
                          options: .transitionFlipFromRight,
                          animations: { imageView.image = image })
    }

    private func updateScores() {
        playerScoreLabel.text = "\(engine.playerScore)"
        pcScoreLabel.text = "\(engine.pcScore)"
    }

    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "toSummary",
              let summary = segue.destination as? SummaryViewController else { return }
        summary.configure(winnerName: engine.winnerName, winnerScore: engine.winnerScore)
    }
}
