//
//  FearGreedData.swift
//  Bitcoin Clock
//
//  Created by nightguarder on 23.03.26.
//

import SwiftUI

struct FearGreedView: View {
    @ObservedObject var store: BitcoinStore

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Fear & Greed")
                    .font(.title2)
                    .foregroundStyle(.orange)
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 20)
                        .frame(width: 150, height: 150)

                    Circle()
                        .trim(from: 0, to: CGFloat(store.fgValue) / 100)
                        .stroke(colorForValue(store.fgValue), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(-90))

                    Text("\(store.fgValue)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(.white)
                }

                Text(store.fgClassification)
                    .font(.title3)
                    .foregroundStyle(colorForValue(store.fgValue))
            }
        }
    }

    private func colorForValue(_ value: Int) -> Color {
        switch value {
        case 0...25: return .red
        case 26...50: return .orange
        case 51...75: return .yellow
        default: return .green
        }
    }
}
