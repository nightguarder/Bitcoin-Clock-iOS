//
//  FearGreedView.swift
//  Bitcoin Clock
//

import SwiftUI

struct FearGreedView: View {
    @ObservedObject var store: BitcoinStore
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color.black : Color.white).ignoresSafeArea()

            VStack {
                StatusBannerView(store: store)

                ScrollView {
                    VStack(spacing: 24) {
                        Text("Fear & Greed Index")
                            .font(.title2)
                            .foregroundStyle(.orange)

                        if let fearGreed = store.fearGreed {
                            gauge(value: fearGreed.current.value)
                                .frame(width: 220, height: 130)

                            VStack(spacing: 4) {
                                Text("\(fearGreed.current.value)")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundStyle(colorForValue(fearGreed.current.value))
                                Text(fearGreed.current.classification)
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            }

                            historyBars(fearGreed.history)

                            Text("Data from alternative.me")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .padding(.top, 8)
                        } else {
                            ProgressView("Loading…")
                                .padding(.top, 60)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                }
                .refreshable {
                    await store.fetchAll(forceRefresh: true)
                }
            }
        }
    }

    private func gauge(value: Int) -> some View {
        let fraction = min(max(Double(value) / 100.0, 0), 1)

        return ZStack {
            Circle()
                .trim(from: 0.5, to: 1.0)
                .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 18, lineCap: .round))

            Circle()
                .trim(from: 0.5, to: 0.5 + 0.5 * fraction)
                .stroke(colorForValue(value), style: StrokeStyle(lineWidth: 18, lineCap: .round))
        }
    }

    private func historyBars(_ history: [FearGreedEntry]) -> some View {
        VStack(spacing: 8) {
            Text("Last \(history.count) days")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(alignment: .bottom, spacing: 10) {
                ForEach(Array(history.enumerated()), id: \.offset) { _, entry in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(colorForValue(entry.value))
                            .frame(width: 18, height: CGFloat(entry.value) / 100 * 70 + 8)
                        Text(dayLabel(entry.date))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.top, 12)
    }

    private func colorForValue(_ value: Int) -> Color {
        switch value {
        case ..<25: return .red
        case ..<45: return .orange
        case ..<55: return .yellow
        case ..<75: return .green.opacity(0.7)
        default: return .green
        }
    }

    private func dayLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}
