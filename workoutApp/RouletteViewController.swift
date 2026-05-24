//
//  RouletteViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 23/05/2026.
//  Copyright © 2026 Alexander Kvamme. All rights reserved.
//

import UIKit
import AKKIT
import SnapKit
import AVFoundation

class RouletteViewController: UIViewController {

    // MARK: - Properties

    private let suggestions: [(name: String, days: Int?)]
    private let pool: [String]
    private var currentIndex = 0
    private var selectedNames: [String] = []

    var onStartWorkout: (([String]) -> Void)?

    private var currentSuggestion: (name: String, days: Int?) { suggestions[currentIndex] }

    private let containerHeight: CGFloat = 110
    private let containerView = UIView()
    private let labelA = UILabel()
    private let labelB = UILabel()
    private var useA = true
    private var currentLabel: UILabel { useA ? labelA : labelB }
    private var incomingLabel: UILabel { useA ? labelB : labelA }

    private let subtitleLabel = UILabel()
    private let addAnotherButton = UIButton(type: .system)
    private let startWorkoutButton = UIButton(type: .system)

    // Stack of previously selected muscles shown above the roller
    private let selectedStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .center
        sv.spacing = 2
        sv.alpha = 0
        return sv
    }()

    // MARK: - Init

    init(suggestions: [(name: String, days: Int?)], pool: [String]) {
        self.suggestions = suggestions
        self.pool = pool
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupContainer()
        setupSelectedStack()
        setupLines()
        setupEdgeFades()
        setupSubtitle()
        setupBottomButtons()
        setupCloseButton()
        prepareAudio()
    }

    private func prepareAudio() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        // Silent pre-roll to eliminate first-play latency
        clickPlayer?.volume = 0
        clickPlayer?.play()
        clickPlayer?.stop()
        clickPlayer?.currentTime = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        spin()
    }

    // MARK: - UI Setup

    private func setupContainer() {
        containerView.clipsToBounds = true
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(containerHeight)
        }

        let w = UIScreen.main.bounds.width
        let font = AKFont.round(.black, 58)

        [labelA, labelB].forEach { label in
            label.font = font
            label.textColor = .white
            label.textAlignment = .center
            containerView.addSubview(label)
        }
        labelA.frame = CGRect(x: 0, y: 0, width: w, height: containerHeight)
        labelB.frame = CGRect(x: 0, y: containerHeight, width: w, height: containerHeight)
        labelA.text = pool.randomElement() ?? ""
    }

    private func setupSelectedStack() {
        view.addSubview(selectedStackView)
        selectedStackView.snp.makeConstraints { make in
            make.bottom.equalTo(containerView.snp.top).offset(-20)
            make.left.right.equalToSuperview().inset(32)
        }
    }

    private func setupEdgeFades() {
        let fadeHeight: CGFloat = 36
        for isTop in [true, false] {
            let fade = GradientView()
            fade.colors = isTop
                ? [UIColor.black, UIColor.black.withAlphaComponent(0)]
                : [UIColor.black.withAlphaComponent(0), UIColor.black]
            fade.isUserInteractionEnabled = false
            containerView.addSubview(fade)
            fade.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.height.equalTo(fadeHeight)
                if isTop {
                    make.top.equalToSuperview()
                } else {
                    make.bottom.equalToSuperview()
                }
            }
        }
    }

    private func setupLines() {
        let topLine = UIView()
        topLine.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        view.addSubview(topLine)
        topLine.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.bottom.equalTo(containerView.snp.top)
            make.height.equalTo(1)
        }

        let bottomLine = UIView()
        bottomLine.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        view.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalTo(containerView.snp.bottom)
            make.height.equalTo(1)
        }
    }

    private func setupSubtitle() {
        subtitleLabel.font = AKFont.round(.medium, 18)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.45)
        subtitleLabel.textAlignment = .center
        subtitleLabel.alpha = 0
        view.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(32)
        }
    }

    private func setupBottomButtons() {
        // Start workout button
        startWorkoutButton.setTitle("Start workout", for: .normal)
        startWorkoutButton.titleLabel?.font = AKFont.round(.bold, 19)
        startWorkoutButton.tintColor = .white
        startWorkoutButton.backgroundColor = UIColor(white: 0.14, alpha: 1)
        startWorkoutButton.layer.cornerRadius = 14
        startWorkoutButton.alpha = 0
        startWorkoutButton.addTarget(self, action: #selector(startWorkoutTapped), for: .touchUpInside)
        view.addSubview(startWorkoutButton)
        startWorkoutButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.width.equalTo(200)
            make.height.equalTo(50)
        }

        // Add another button sits above the start button
        addAnotherButton.setTitle("Add another", for: .normal)
        addAnotherButton.titleLabel?.font = AKFont.round(.bold, 17)
        addAnotherButton.tintColor = UIColor.white.withAlphaComponent(0.5)
        addAnotherButton.alpha = 0
        addAnotherButton.addTarget(self, action: #selector(addAnotherTapped), for: .touchUpInside)
        view.addSubview(addAnotherButton)
        addAnotherButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(startWorkoutButton.snp.top).offset(-12)
        }
    }

    private func setupCloseButton() {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        btn.setImage(UIImage(systemName: "xmark", withConfiguration: cfg), for: .normal)
        btn.tintColor = UIColor.white.withAlphaComponent(0.35)
        btn.addTarget(self, action: #selector(close), for: .touchUpInside)
        view.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalToSuperview().offset(-20)
        }
    }

    // MARK: - Animation

    private let spinHaptic = UIImpactFeedbackGenerator(style: .rigid)
    private var clickPlayer: AVAudioPlayer? = {
        guard let url = Bundle.main.url(forResource: "click", withExtension: "mp3") else { return nil }
        let player = try? AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
        return player
    }()

    private func spin() {
        guard !suggestions.isEmpty else { return }
        spinHaptic.prepare()
        let target = currentSuggestion.name
        let fillerPool = pool.filter { $0 != target }
        var fillers: [String] = []
        while fillers.count < 45 {
            fillers += fillerPool.shuffled()
        }
        fillers = Array(fillers.prefix(45))
        let sequence = fillers + [target]
        animateSequence(sequence, index: 0)
    }

    private func animateSequence(_ sequence: [String], index: Int) {
        guard index < sequence.count else { onLanded(); return }
        let name = sequence[index]
        let progress = sequence.count > 1 ? Double(index) / Double(sequence.count - 1) : 1.0
        // Roulette curve: stays fast most of the spin, then brakes hard near the end
        let interval = 0.04 + pow(progress, 4.5) * 0.76
        clickPlayer?.volume = Float(0.12 + progress * 0.58)
        clickPlayer?.currentTime = 0
        clickPlayer?.play()
        spinHaptic.impactOccurred(intensity: 0.15 + progress * 0.85)
        animateScroll(to: name, duration: interval * 0.75) {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * 0.05) {
                self.animateSequence(sequence, index: index + 1)
            }
        }
    }

    private func animateScroll(to text: String, duration: TimeInterval, completion: @escaping () -> Void) {
        let w = UIScreen.main.bounds.width
        let incoming = incomingLabel
        let outgoing = currentLabel

        incoming.text = text
        incoming.frame = CGRect(x: 0, y: containerHeight, width: w, height: containerHeight)

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut) {
            outgoing.frame.origin.y = -self.containerHeight
            incoming.frame.origin.y = 0
        } completion: { _ in
            outgoing.frame = CGRect(x: 0, y: self.containerHeight, width: w, height: self.containerHeight)
            self.useA.toggle()
            completion()
        }
    }

    private func onLanded() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        UIView.animate(withDuration: 0.32, delay: 0.03, usingSpringWithDamping: 0.42, initialSpringVelocity: 0.9) {
            self.currentLabel.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        } completion: { _ in
            UIView.animate(withDuration: 0.18) {
                self.currentLabel.transform = .identity
            }
        }

        updateSubtitle()
        UIView.animate(withDuration: 0.4, delay: 0.3) {
            self.subtitleLabel.alpha = 1
        }

        let hasMore = currentIndex + 1 < suggestions.count
        UIView.animate(withDuration: 0.4, delay: 0.5) {
            self.startWorkoutButton.alpha = 1
            if hasMore { self.addAnotherButton.alpha = 1 }
        }
    }

    private func updateSubtitle() {
        let days = currentSuggestion.days
        let text: String
        if let d = days {
            text = d == 0 ? "trained today" : "\(d) day\(d == 1 ? "" : "s") since last session"
        } else {
            text = "never trained"
        }
        subtitleLabel.text = text
    }

    private func addSelectionLabel(name: String) {
        let label = UILabel()
        label.text = name
        label.font = AKFont.round(.bold, 22)
        label.textColor = UIColor.white.withAlphaComponent(0.55)
        label.textAlignment = .center
        label.alpha = 0
        selectedStackView.addArrangedSubview(label)

        UIView.animate(withDuration: 0.3) {
            label.alpha = 1
            self.selectedStackView.alpha = 1
        }
    }

    // MARK: - Actions

    @objc private func addAnotherTapped() {
        guard currentIndex + 1 < suggestions.count else { return }

        // Archive current selection into the stack above the roller
        addSelectionLabel(name: currentSuggestion.name)
        selectedNames.append(currentSuggestion.name)

        currentIndex += 1
        addAnotherButton.alpha = 0
        subtitleLabel.alpha = 0

        spin()
    }

    @objc private func startWorkoutTapped() {
        let allSelected = selectedNames + [currentSuggestion.name]
        onStartWorkout?(allSelected)
    }

    @objc private func close() {
        dismiss(animated: true)
    }
}

// MARK: - GradientView

private class GradientView: UIView {
    var colors: [UIColor] = [] {
        didSet { gradientLayer.colors = colors.map(\.cgColor) }
    }

    override class var layerClass: AnyClass { CAGradientLayer.self }
    private var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    override init(frame: CGRect) {
        super.init(frame: frame)
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1)
    }
    required init?(coder: NSCoder) { fatalError() }
}
