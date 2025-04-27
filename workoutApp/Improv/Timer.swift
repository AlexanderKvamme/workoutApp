//
//  Timer.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 26/04/2025.
//  Copyright © 2025 Alexander Kvamme. All rights reserved.
//

import AKKIT
import UIKit

class TimerView: UIView {
    
    // MARK: - Properties
    
    private var timeLabel: UILabel!
    private var startTime: Date?
    private var timer: Timer?
    private var elapsedTime: TimeInterval = 0
    private var isRunning = false
    private var timerFormat: TimerFormat = .minutesSeconds
    
    enum TimerFormat {
        case secondsOnly
        case minutesSeconds
        case hoursMinutesSeconds
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
        
        // Create time label
        timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.textAlignment = .center
        timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 24, weight: .medium)
        timeLabel.font = AKFont.round(.black, 22)
        timeLabel.text = formatTime(0)
        addSubview(timeLabel)
        
        // Center the label
        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -2),
            timeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 0),
            timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -0)
        ])
    }
    
    // MARK: - Public Methods
    
    /// Configure the timer view
    /// - Parameters:
    ///   - format: Format to display the time (seconds only, minutes:seconds, or hours:minutes:seconds)
    ///   - textColor: Color of the timer text
    ///   - font: Font for the timer text
    func configure(format: TimerFormat = .minutesSeconds,
                  textColor: UIColor = .black,
                  font: UIFont? = nil) {
        self.timerFormat = format
        timeLabel.textColor = textColor
        
        if let font = font {
            timeLabel.font = font
        }
        
        // Update the display
        updateDisplay()
    }
    
    /// Start the timer from 0
    func start() {
        // Reset and start
        reset()
        
        startTime = Date()
        isRunning = true
        
        // Create and schedule timer
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
        
        // Add to common run loop modes to ensure timer runs during scrolling
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    /// Pause the timer
    func pause() {
        guard isRunning else { return }
        
        // Store elapsed time
        if let startTime = startTime {
            elapsedTime = Date().timeIntervalSince(startTime)
        }
        
        // Stop the timer
        timer?.invalidate()
        timer = nil
        isRunning = false
        startTime = nil
    }
    
    /// Resume the timer from where it was paused
    func resume() {
        guard !isRunning else { return }
        
        // Set new start time based on stored elapsed time
        startTime = Date().addingTimeInterval(-elapsedTime)
        isRunning = true
        
        // Create and schedule timer
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
        
        // Add to common run loop modes
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    /// Stop the timer and reset to 0
    func reset() {
        timer?.invalidate()
        timer = nil
        startTime = nil
        elapsedTime = 0
        isRunning = false
        updateDisplay()
    }
    
    /// Get the current elapsed time in seconds
    func getElapsedTime() -> TimeInterval {
        if let startTime = startTime {
            return Date().timeIntervalSince(startTime)
        } else {
            return elapsedTime
        }
    }
    
    // MARK: - Private Methods
    
    private func updateTimer() {
        guard let startTime = startTime else { return }
        
        // Calculate elapsed time
        let currentTime = Date()
        let elapsed = currentTime.timeIntervalSince(startTime)
        
        // Update display
        timeLabel.text = formatTime(elapsed)
    }
    
    private func updateDisplay() {
        timeLabel.text = formatTime(elapsedTime)
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let totalSeconds = Int(timeInterval)
        
        switch timerFormat {
        case .secondsOnly:
            return String(format: "%d", totalSeconds)
            
        case .minutesSeconds:
            let minutes = (totalSeconds / 60) % 60
            let seconds = totalSeconds % 60
            return String(format: "%02d:%02d", minutes, seconds)
            
        case .hoursMinutesSeconds:
            let hours = totalSeconds / 3600
            let minutes = (totalSeconds / 60) % 60
            let seconds = totalSeconds % 60
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }
}
