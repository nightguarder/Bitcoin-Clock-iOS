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
                Text("⚠ \(error) — last updated \(store.lastUpdated, style: .relative)")
                    .foregroundStyle(.red)
            } else {
                Text("Last updated \(store.lastUpdated, style: .relative)")
                    .foregroundStyle(.secondary)
            }
        }
        //carefull this is added to every screen the component is in
        .font(.caption)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.top)
    }
}
