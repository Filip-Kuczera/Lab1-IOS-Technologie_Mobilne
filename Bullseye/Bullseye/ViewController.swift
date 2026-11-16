import UIKit
import AVFoundation

class ViewController: UIViewController {

    // MARK: - Kontrolki (budowane kodem; odpowiedniki outletów ze storyboardu)
    private let backgroundImageView = UIImageView()
    private let targetLabel = UILabel()       // "XXX" – wylosowana wartość
    private let slider = UISlider()
    private let scoreLabel = UILabel()        // "XXXXX" – suma punktów
    private let roundLabel = UILabel()        // "XX" – numer rundy

    // MARK: - Stan gry
    private var targetValue = 0
    private var score = 0
    private var round = 1
    private let totalRounds = 10

    // MARK: - Dźwięk
    private var audioPlayer: AVAudioPlayer?

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }
    override var prefersStatusBarHidden: Bool { true }

    // MARK: - Cykl życia
    override func viewDidLoad() {
        super.viewDidLoad()
        try? AVAudioSession.sharedInstance().setCategory(.playback)

        setupBackground()
        setupInterface()
        setupSliderAppearance()
        startNewGame()
    }

    // MARK: - Interfejs
    private func makeLabel(_ text: String, size: CGFloat = 18, bold: Bool = false) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = bold ? .boldSystemFont(ofSize: size) : .systemFont(ofSize: size)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }

    private func setupBackground() {
        // UIImageView na samym dole hierarchii, przypięty do wszystkich krawędzi
        backgroundImageView.image = UIImage(named: "Background.png")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(backgroundImageView, at: 0)
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupInterface() {
        let guide = view.safeAreaLayoutGuide

        // --- Wiersz 1: "Przesuń suwak jak najbliżej wartości: XXX"
        let titleLabel = makeLabel("Przesuń suwak jak najbliżej wartości:", size: 20)
        targetLabel.textColor = .white
        targetLabel.font = .monospacedDigitSystemFont(ofSize: 22, weight: .bold)
        targetLabel.setContentHuggingPriority(.required, for: .horizontal)
        targetLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        let topRow = UIStackView(arrangedSubviews: [titleLabel, targetLabel])
        topRow.axis = .horizontal
        topRow.spacing = 8
        topRow.alignment = .center

        // --- Wiersz 2: "1" [slider] "100"
        slider.minimumValue = 1
        slider.maximumValue = 100
        slider.value = 50
        slider.setContentHuggingPriority(.defaultLow, for: .horizontal)
        let minLabel = makeLabel("1", size: 20, bold: true)
        let maxLabel = makeLabel("100", size: 20, bold: true)
        let sliderRow = UIStackView(arrangedSubviews: [minLabel, slider, maxLabel])
        sliderRow.axis = .horizontal
        sliderRow.spacing = 12
        sliderRow.alignment = .center

        // --- Przycisk "Sprawdź"
        let checkButton = UIButton(type: .system)
        checkButton.setTitle("Sprawdź", for: .normal)
        checkButton.titleLabel?.font = .boldSystemFont(ofSize: 24)
        checkButton.tintColor = UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1)
        checkButton.addTarget(self, action: #selector(checkTapped(_:)), for: .touchUpInside)

        // --- Środkowy blok (wiersze 1-3) wyśrodkowany w pionie
        let centerStack = UIStackView(arrangedSubviews: [topRow, sliderRow, checkButton])
        centerStack.axis = .vertical
        centerStack.spacing = 24
        centerStack.alignment = .fill
        centerStack.translatesAutoresizingMaskIntoConstraints = false
        topRow.alignment = .center
        view.addSubview(centerStack)

        // --- Dolny pasek: Restart | Punkty: X | Runda: X | (i)
        let restartButton = UIButton(type: .system)
        restartButton.setTitle("Restart", for: .normal)
        restartButton.titleLabel?.font = .systemFont(ofSize: 20)
        restartButton.tintColor = UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1)
        restartButton.addTarget(self, action: #selector(restartTapped(_:)), for: .touchUpInside)

        scoreLabel.textColor = .white
        scoreLabel.font = .monospacedDigitSystemFont(ofSize: 20, weight: .bold)
        roundLabel.textColor = .white
        roundLabel.font = .monospacedDigitSystemFont(ofSize: 20, weight: .bold)

        let scoreStack = UIStackView(arrangedSubviews: [makeLabel("Punkty:", size: 20), scoreLabel])
        scoreStack.spacing = 6
        let roundStack = UIStackView(arrangedSubviews: [makeLabel("Runda:", size: 20), roundLabel])
        roundStack.spacing = 6

        let infoButton = UIButton(type: .infoLight)
        infoButton.tintColor = UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1)
        infoButton.addTarget(self, action: #selector(infoTapped(_:)), for: .touchUpInside)

        let bottomRow = UIStackView(arrangedSubviews: [restartButton, scoreStack, roundStack, infoButton])
        bottomRow.axis = .horizontal
        bottomRow.distribution = .equalSpacing
        bottomRow.alignment = .center
        bottomRow.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomRow)

        // --- Auto Layout
        NSLayoutConstraint.activate([
            centerStack.centerYAnchor.constraint(equalTo: guide.centerYAnchor, constant: -10),
            centerStack.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 24),
            centerStack.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -24),

            bottomRow.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 24),
            bottomRow.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -24),
            bottomRow.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -16)
        ])
    }

    /// Zmiana wyglądu suwaka (kod z polecenia).
    private func setupSliderAppearance() {
        let thumbImageNormal = UIImage(named: "SliderIcon.png")!
        slider.setThumbImage(thumbImageNormal, for: .normal)

        let insets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)

        let trackLeftImage = UIImage(named: "SliderLeft.png")!
        let trackLeftResizable = trackLeftImage.resizableImage(withCapInsets: insets)
        slider.setMinimumTrackImage(trackLeftResizable, for: .normal)

        let trackRightImage = UIImage(named: "SliderRight.png")!
        let trackRightResizable = trackRightImage.resizableImage(withCapInsets: insets)
        slider.setMaximumTrackImage(trackRightResizable, for: .normal)
    }

    // MARK: - Logika gry
    private func startNewGame() {
        score = 0
        round = 1
        startNewRound()
    }

    private func startNewRound() {
        targetValue = Int.random(in: 1...100)
        slider.value = 50
        updateLabels()
    }

    private func updateLabels() {
        targetLabel.text = String(targetValue)
        scoreLabel.text = String(score)
        roundLabel.text = String(round)
    }

    private func nextRound() {
        if round >= totalRounds {
            showGameOver()
        } else {
            round += 1
            startNewRound()
        }
    }

    private func showGameOver() {
        playSound("win")
        let alert = UIAlertController(title: "GAME OVER",
                                      message: "Zdobyte punkty: \(score)",
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "Graj ponownie", style: .default) { [weak self] _ in
            self?.startNewGame()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Akcje
    @IBAction func checkTapped(_ sender: UIButton) {
        let chosen = Int(slider.value.rounded())
        let points = 100 - abs(targetValue - chosen)   // 0...100
        score += points
        scoreLabel.text = String(score)

        if points == 100 {
            playSound("nice_shot")
        }

        let alert = UIAlertController(title: "Twój wynik: \(points) pkt",
                                      message: "Wylosowana wartość: \(targetValue)\nUstawiona wartość: \(chosen)",
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "Graj", style: .default) { [weak self] _ in
            self?.nextRound()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    @IBAction func restartTapped(_ sender: UIButton) {
        playSound("restart")
        startNewGame()
    }

    @IBAction func infoTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "O grze",
                                      message: "Ustaw suwak jak najbliżej wylosowanej wartości i naciśnij „Sprawdź”. Za każdą rundę możesz dostać od 0 do 100 punktów. Gra trwa 10 rund.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Dźwięk
    private func playSound(_ name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("couldn't find sound file: \(name)")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("couldn't load sound file")
        }
    }
}
