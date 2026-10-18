//
//  MarketCapView.swift
//  Bitcoin Clock
//
//  Created by nightguarder on 23.03.26.
//

import SwiftUI

struct MarketCapView: View {
    @ObservedObject var store: BitcoinStore
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color.black : Color.white).ignoresSafeArea()
            VStack {
                
                StatusBannerView(store: store)
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.orange)

                        HStack(spacing: 40) {
                            VStack {
                                Text("Market Cap")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(store.marketCap)
                                    .font(.title3.bold())
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                            }
                            VStack {
                                Text("24h Change")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                HStack(spacing: 4) {
                                    Image(systemName: store.change24h >= 0 ? "chart.line.uptrend.xyaxis" : "chart.line.downtrend.xyaxis")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(store.change24h >= 0 ? .green : .red)
                                    Text(String(format: "%.2f %%", store.change24h))
                                        .font(.title3.bold())
                                        .foregroundStyle(store.change24h >= 0 ? .green : .red)
                                }
                            }
                        }
                        
                    }
                }
                .refreshable {
                    await store.fetchAll(forceRefresh: true)
                }
            }
        }
    }
}
