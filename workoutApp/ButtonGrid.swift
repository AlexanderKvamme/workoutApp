//
//  ButtonGrid.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 05/08/2025.
//  Copyright © 2025 Alexander Kvamme. All rights reserved.
//

import UIKit

struct ButtonGridItem {
    let title: String
    let icon: String?
    let color: UIColor
    let font: UIFont
    let action: () -> Void
    
    init(title: String, icon: String? = nil, color: UIColor = .black, font: UIFont = UIFont.boldSystemFont(ofSize: 20), action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.color = color
        self.font = font
        self.action = action
    }
}

class ButtonGridView: UIView {
    
    // MARK: - Properties
    
    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.distribution = .fill // Changed to .fill for better control
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // Spacer view to push buttons to bottom
    private let topSpacer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return view
    }()
    
    private var buttons: [FormFittingActionButton] = []
    private var items: [ButtonGridItem] = []
    private let buttonsPerRow: Int
    
    // MARK: - Initializers
    
    init(items: [ButtonGridItem], buttonsPerRow: Int = 2) {
        self.items = items
        self.buttonsPerRow = buttonsPerRow
        super.init(frame: .zero)
        setupView()
        createButtons()
        layoutButtons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupView() {
        addSubview(containerStackView)
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func createButtons() {
        buttons = items.map { item in
            FormFittingActionButton(
                title: item.title,
                icon: item.icon,
                color: item.color,
                font: item.font,
                action: item.action
            )
        }
    }
    
    private func layoutButtons() {
        // Clear existing arranged subviews
        containerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add flexible spacer at the top to push buttons to bottom
        containerStackView.addArrangedSubview(topSpacer)
        
        // Group buttons into rows
        let buttonRows = buttons.chunked(into: buttonsPerRow)
        
        for buttonRow in buttonRows {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.spacing = 16
            rowStackView.alignment = .center
            rowStackView.distribution = .fill // Let buttons size themselves
            rowStackView.translatesAutoresizingMaskIntoConstraints = false
            
            buttonRow.forEach { button in
                rowStackView.addArrangedSubview(button)
            }
            
            containerStackView.addArrangedSubview(rowStackView)
        }
        
        // Set priorities to ensure buttons stay at bottom
        for arrangedSubview in containerStackView.arrangedSubviews {
            if arrangedSubview != topSpacer {
                arrangedSubview.setContentHuggingPriority(.required, for: .vertical)
                arrangedSubview.setContentCompressionResistancePriority(.required, for: .vertical)
            }
        }
    }
    
    // MARK: - Public Methods
    
    func updateItems(_ newItems: [ButtonGridItem]) {
        self.items = newItems
        createButtons()
        layoutButtons()
    }
}

// MARK: - Array Extension

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
