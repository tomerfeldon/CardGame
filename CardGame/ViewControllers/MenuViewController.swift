//
//  MenuViewController.swift
//  CardGame
//
//  Start screen: stores the player name, resolves the play side from the
//  device location, and enables START only once both name and side are known.
//

import UIKit

final class MenuViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet private weak var nameButton: UIButton!
    @IBOutlet private weak var greetingLabel: UILabel!
    @IBOutlet private weak var westImageView: UIImageView!
    @IBOutlet private weak var eastImageView: UIImageView!
    @IBOutlet private weak var westLabel: UILabel!
    @IBOutlet private weak var eastLabel: UILabel!
    @IBOutlet private weak var startButton: UIButton!

    // MARK: State
    private static let nameKey = "playerName"

    private var playerName: String? {
        get { UserDefaults.standard.string(forKey: Self.nameKey) }
        set { UserDefaults.standard.set(newValue, forKey: Self.nameKey) }
    }

    private var resolvedSide: Side?
    private let locationService = LocationService()

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)

        locationService.onSideResolved = { [weak self] side in
            DispatchQueue.main.async { self?.handleSideResolved(side) }
        }
        locationService.onFailure = { [weak self] in
            DispatchQueue.main.async { self?.handleLocationFailure() }
        }
        updateNameUI()
        refreshStartAvailability()

        // Re-sample location whenever the app comes back to the foreground
        // while the menu is on screen (spec: sample on every app open).
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sampleLocation()
    }

    @objc private func appWillEnterForeground() {
        guard isViewLoaded, view.window != nil else { return }
        sampleLocation()
    }

    /// Resets the resolved side and starts a fresh one-shot location request.
    private func sampleLocation() {
        resolvedSide = nil
        highlightSide(nil)
        refreshStartAvailability()
        locationService.start()
    }

    // MARK: Name handling
    @IBAction private func insertNameTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Insert name",
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addTextField { [weak self] field in
            field.placeholder = "Your name"
            field.text = self?.playerName
            field.autocapitalizationType = .words
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            let text = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let text, !text.isEmpty else { return }
            self?.playerName = text
            self?.updateNameUI()
            self?.refreshStartAvailability()
        })
        present(alert, animated: true)
    }

    private func updateNameUI() {
        if let name = playerName, !name.isEmpty {
            // Subsequent opens: show the name, hide the button.
            greetingLabel.text = "Hi \(name)"
            greetingLabel.isHidden = false
            nameButton.isHidden = true
        } else {
            // First time: show only the button, no greeting.
            greetingLabel.text = nil
            greetingLabel.isHidden = true
            nameButton.isHidden = false
        }
    }

    // MARK: Location handling
    private func handleSideResolved(_ side: Side) {
        resolvedSide = side
        highlightSide(side)
        refreshStartAvailability()
    }

    private func handleLocationFailure() {
        resolvedSide = nil
        highlightSide(nil)
        refreshStartAvailability()
        let alert = UIAlertController(
            title: "Location required",
            message: "The game needs your location to choose a side. Enable location (you can set a custom location in the simulator) and reopen this screen.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    /// Dims the side that is not in play; nil clears the highlight.
    private func highlightSide(_ side: Side?) {
        let westActive = side == .west
        let eastActive = side == .east
        westImageView.alpha = (side == nil || westActive) ? 1.0 : 0.3
        eastImageView.alpha = (side == nil || eastActive) ? 1.0 : 0.3
        westLabel.font = .boldSystemFont(ofSize: 17)
        eastLabel.font = .boldSystemFont(ofSize: 17)
        westLabel.textColor = westActive ? .systemBlue : .label
        eastLabel.textColor = eastActive ? .systemBlue : .label
    }

    private func refreshStartAvailability() {
        // Per the spec, the START button is shown only once a location (side)
        // has been resolved and a name exists — the game can't run without both.
        let ready = (playerName?.isEmpty == false) && (resolvedSide != nil)
        startButton.isHidden = !ready
        startButton.isEnabled = ready
    }

    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "toGame",
              let game = segue.destination as? GameViewController,
              let name = playerName, let side = resolvedSide else { return }
        game.configure(playerName: name, playerSide: side)
    }
}
