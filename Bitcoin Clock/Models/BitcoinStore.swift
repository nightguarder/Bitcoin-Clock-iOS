//
//  BitcoinStore.swift
//  Bitcoin Clock
//
//  Created by nightguarder on 23.03.26.
//

import Foundation
import Combine

class BitcoinStore: ObservableObject {
    @Published var priceEUR: String = "Loading..."
    @Published var marketCap: String = "Loading..."
    @Published var change24h: Double = 0.0
    @Published var fgValue: Int = 0
    @Published var fgClassification: String = "Loading..."

    func fetchAll() async {
        let api = ApiService()

        async let bitcoinData = api.fetchBitcoin()
        async let fearGreedData = api.fetchFearGreed()

        if let data = await bitcoinData {
            await MainActor.run {
                self.priceEUR = String(format: "€%.2f", data.priceEUR)
                self.marketCap = String(format: "€%.2fT", data.marketCap / 1_000_000_000_000)
                self.change24h = data.change24h
            }
        } else {
            await MainActor.run {
                self.priceEUR = "Error"
                self.marketCap = "Error"
            }
        }

        if let data = await fearGreedData {
            await MainActor.run {
                self.fgValue = data.value
                self.fgClassification = data.classification
            }
        }
    }
}
