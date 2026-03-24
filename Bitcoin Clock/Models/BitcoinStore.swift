//
//  BitcoinStore 2.swift
//  Bitcoin Clock
//
//  Created by nightguarder on 23.03.26.
//

import Foundation

@Observable
class BitcoinStore {
    var priceEUR: String = "Loading..."
    var marketCap: String = "Loading..."
    var change24h: Double = 0.0
    var fgValue: Int = 0
    var fgClassification: String = "Loading..."

    func fetchAll() async {
        let api = ApiService()

        if let data = await api.fetchBitcoin() {
            priceEUR = String(format: "€%.2f", data.priceEUR)
            marketCap = String(format: "€%.2fT", data.marketCap / 1_000_000_000_000)
            change24h = data.change24h
        } else {
            print("CoinGecko fetch failed")
        }

        if let data = await api.fetchFearGreed() {
            fgValue = data.value
            fgClassification = data.classification
        }
    }
}
