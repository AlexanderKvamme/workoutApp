//
//  BodySettingsViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 21/05/2026.
//  Copyright © 2026 Alexander Kvamme. All rights reserved.
//

import SwiftUI
import UIKit

// MARK: - SwiftUI Settings View

struct BodySettingsView: View {

    struct GroupOption: Identifiable {
        let id: String
        let title: String
        let detail: String
    }

    // MARK: State

    @State private var enabledGroupIDs: Set<String>
    @State private var freshDays:   Int
    @State private var staleDays:   Int
    @State private var fadeDays:    Int
    @State private var warningDays: Int

    let options: [GroupOption]
    var onGroupsChanged: ((Set<String>) -> Void)?
    var onThresholdChanged: (() -> Void)?

    // MARK: Init

    init(
        options: [GroupOption],
        enabledGroupIDs: Set<String>,
        onGroupsChanged: ((Set<String>) -> Void)? = nil,
        onThresholdChanged: (() -> Void)? = nil
    ) {
        self.options = options
        self._enabledGroupIDs = State(initialValue: enabledGroupIDs)
        self._freshDays   = State(initialValue: Self.threshold(StatusViewController.kFreshDays,   fallback: 2))
        self._staleDays   = State(initialValue: Self.threshold(StatusViewController.kStaleDays,   fallback: 5))
        self._fadeDays    = State(initialValue: Self.threshold(StatusViewController.kFadeDays,    fallback: 10))
        self._warningDays = State(initialValue: Self.threshold(StatusViewController.kWarningDays, fallback: 14))
        self.onGroupsChanged    = onGroupsChanged
        self.onThresholdChanged = onThresholdChanged
    }

    private static func threshold(_ key: String, fallback: Int) -> Int {
        let v = UserDefaults.standard.integer(forKey: key)
        return v > 0 ? v : fallback
    }

    // MARK: Body

    var body: some View {
        NavigationStack {
            Form {

                // MARK: Groupings
                Section {
                    ForEach(options) { option in
                        Toggle(isOn: Binding(
                            get: { enabledGroupIDs.contains(option.id) },
                            set: { on in
                                if on { enabledGroupIDs.insert(option.id) }
                                else  { enabledGroupIDs.remove(option.id) }
                                onGroupsChanged?(enabledGroupIDs)
                            }
                        )) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(option.title)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(UIColor.akDark))
                                Text(option.detail)
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.vertical, 4)
                        }
                        .tint(Color(UIColor.akDark))
                    }
                } header: {
                    sectionHeader("Muscle Groupings")
                }
                .listRowBackground(rowBackground)

                // MARK: Freshness thresholds
                Section {
                    stepperRow("Fresh (pitch black)",  days: $freshDays,   key: StatusViewController.kFreshDays)
                    stepperRow("Stale (dark gray)",    days: $staleDays,   key: StatusViewController.kStaleDays)
                    stepperRow("Faded (gray)",         days: $fadeDays,    key: StatusViewController.kFadeDays)
                    stepperRow("Warning (red)",        days: $warningDays, key: StatusViewController.kWarningDays)
                } header: {
                    sectionHeader("Muscle Freshness (days since last workout)")
                } footer: {
                    Text("Muscles not trained within the warning period turn red on the body map — a sign your body may be losing muscle mass.")
                        .foregroundColor(.secondary)
                }
                .listRowBackground(rowBackground)
            }
            .scrollContentBackground(.hidden)
            .background(bgColor.ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .tint(Color(UIColor.akDark))
        }
    }

    // MARK: Sub-views

    private var bgColor: Color {
        Color(UIColor.systemGroupedBackground)
    }

    private var rowBackground: Color {
        Color(UIColor.secondarySystemGroupedBackground)
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text).foregroundColor(Color(UIColor.akDark))
    }

    private func stepperRow(_ label: String, days: Binding<Int>, key: String) -> some View {
        Stepper(
            value: days,
            in: 0...365,
            step: 1
        ) {
            HStack {
                Text(label)
                    .foregroundColor(Color(UIColor.akDark))
                Spacer()
                Text("\(days.wrappedValue) days")
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }
        }
        .onChange(of: days.wrappedValue) { _, newValue in
            UserDefaults.standard.set(newValue, forKey: key)
            onThresholdChanged?()
        }
    }
}
