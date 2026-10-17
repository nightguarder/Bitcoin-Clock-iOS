//
//  StatusBannerView.swift
//  Bitcoin Clock
//
//  Created by nightguarder on 17.10.26.
//

import SwiftUI

struct StatusBannerView: View {
    @ObservedObject var store: BitcoinStore

    var body: some View {
        Group {
            if let error = store.errorMessage {
                Label(error, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            } else if store.isUsingCachedData {
                Label("Offline — showing cached data", systemImage: "wifi.slash")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
        }
    }
}
