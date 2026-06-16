//
//  SoundManager.swift
//  CardGame
//
//  Centralised audio playback: looping background music plus one-shot effects
//  (card flip, win). Background music must stop while the game is not running
//  (leaving the screen / app backgrounded), per the assignment.
//

import AVFoundation

final class SoundManager {

    static let shared = SoundManager()

    private var musicPlayer: AVAudioPlayer?
    private var flipPlayer: AVAudioPlayer?
    private var winPlayer: AVAudioPlayer?

    private init() {
        configureSession()
        musicPlayer = makePlayer(named: "bg_music", loops: -1, volume: 0.5)
        flipPlayer  = makePlayer(named: "card_flip", loops: 0, volume: 1.0)
        winPlayer   = makePlayer(named: "win_game", loops: 0, volume: 1.0)
    }

    private func configureSession() {
        // .ambient: respects the silent switch and mixes politely; fine for a game.
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    private func makePlayer(named name: String, loops: Int, volume: Float) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("SoundManager: missing sound file \(name).mp3")
            return nil
        }
        let player = try? AVAudioPlayer(contentsOf: url)
        player?.numberOfLoops = loops
        player?.volume = volume
        player?.prepareToPlay()
        return player
    }

    // MARK: Background music
    func startBackgroundMusic() {
        guard let player = musicPlayer, !player.isPlaying else { return }
        player.currentTime = 0
        player.play()
    }

    func stopBackgroundMusic() {
        musicPlayer?.stop()
        musicPlayer?.currentTime = 0
    }

    func pauseBackgroundMusic() {
        musicPlayer?.pause()
    }

    func resumeBackgroundMusic() {
        guard let player = musicPlayer, !player.isPlaying else { return }
        player.play()
    }

    // MARK: One-shot effects
    func playCardFlip() {
        flipPlayer?.currentTime = 0
        flipPlayer?.play()
    }

    func playWin() {
        winPlayer?.currentTime = 0
        winPlayer?.play()
    }
}
