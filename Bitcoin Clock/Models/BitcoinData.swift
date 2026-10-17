//
//  BitcoinData.swift
//  Bitcoin Clock
//
//  Created by nightguarder on 23.03.26.
//

import Foundation

struct BitcoinData: Codable {
    let priceEUR: Double
    let marketCap: Double
    let change24h: Double
    let circulatingSupply: Double
    let cachedAt: Date

    init(priceEUR: Double, marketCap: Double, change24h: Double, circulatingSupply: Double) {
        self.priceEUR = priceEUR
        self.marketCap = marketCap
        self.change24h = change24h
        self.circulatingSupply = circulatingSupply
        self.cachedAt = Date()
    }
}
