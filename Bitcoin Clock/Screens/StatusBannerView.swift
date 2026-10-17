//
//  StatusBannerView.swift
//  Bitcoin Clock
//
//  Created by nightguarder on 17.10.26.
//

import SwiftUI

struct StatusBannerView: View {
    @ObservedObject var store: BitcoinStore

    private var age: TimeInterval { Date().timeIntervalSince(store.lastUpdated) }

    @ViewBuilder
    var body: some View {
        if let error = store.errorMessage {
            VStack(spacing: 2) {
                Label(error, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                if store.isUsingCachedData {
                    ageText
                }
            }
            .padding(.horizontal)
        } else if store.isUsingCachedData && age > 60 {
            ageText
                .padding(.horizontal)
        }
    }

    private var ageText: some View {
        Label {
            Text("Showing data from \(store.lastUpdated, style: .relative)")
                .font(.caption)
        } icon: {
            Image(systemName: "clock.arrow.circlepath")
        }
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
    }
}
