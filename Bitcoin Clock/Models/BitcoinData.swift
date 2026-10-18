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

struct PricePoint: Codable {
    let date: Date
    let price: Double
}

enum ChartRange: Int, CaseIterable, Identifiable {
    case day = 1
    case week = 7
    case month = 30
    case quarter = 90
    case year = 365

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .day: return "24H"
        case .week: return "7D"
        case .month: return "1M"
        case .quarter: return "3M"
        case .year: return "1Y"
        }
    }

    var days: Int { min(rawValue, 365) }
}

struct FearGreedEntry: Codable {
    let value: Int
    let classification: String
    let date: Date
}

struct FearGreedData: Codable {
    let current: FearGreedEntry
    let history: [FearGreedEntry]
    let cachedAt: Date
}
