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
    @Published var circulatingSupply: Double = 0.0

    func fetchAll() async {
        let api = ApiService()

        if let data = await api.fetchBitcoin() {
            await MainActor.run {
                self.priceEUR = String(format: "€%.2f", data.priceEUR)
                self.marketCap = String(format: "€%.2fT", data.marketCap / 1_000_000_000_000)
                self.change24h = data.change24h
                self.circulatingSupply = data.circulatingSupply
            }
        } else {
            await MainActor.run {
                self.priceEUR = "Error"
                self.marketCap = "Error"
            }
        }
    }
}
