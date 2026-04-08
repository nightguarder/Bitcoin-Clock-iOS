//
//  BitcoinStore.swift
//  Bitcoin Clock
//
//  Created by nightguarder on 23.03.26.
//

import Foundation
import Combine

public class BitcoinStore: ObservableObject {
    private let cache = CacheManager.shared
    
    @Published var priceEUR: String = "Loading..."
    @Published var marketCap: String = "Loading..."
    @Published var change24h: Double = 0.0
    @Published var circulatingSupply: Double = 0.0
    @Published var lastUpdated: Date = Date()
    @Published var errorMessage: String? = nil
    @Published var isUsingCachedData: Bool = false
    
    init() {
        loadCachedData()
    }
    
    private func loadCachedData() {
        if let cached = cache.cachedData {
            priceEUR = String(format: "€%.2f", cached.priceEUR)
            marketCap = String(format: "€%.2fT", cached.marketCap / 1_000_000_000_000)
            change24h = cached.change24h
            circulatingSupply = cached.circulatingSupply
            lastUpdated = cached.cachedAt
            isUsingCachedData = true
        }
    }

    func fetchAll() async {
        guard cache.canFetch() else { return }
        
        let api = ApiService()
        errorMessage = nil
        
        let result = await api.fetchBitcoin()
        
        await MainActor.run {
            switch result {
            case .success(let data):
                let cacheData = BitcoinData(from: data)
                self.cache.cachedData = cacheData
                
                self.priceEUR = String(format: "€%.2f", data.priceEUR)
                self.marketCap = String(format: "€%.2fT", data.marketCap / 1_000_000_000_000)
                self.change24h = data.change24h
                self.circulatingSupply = data.circulatingSupply
                self.lastUpdated = cacheData.cachedAt
                self.errorMessage = nil
                self.isUsingCachedData = false
            case .failure(let error):
                if let cached = self.cache.cachedData {
                    self.priceEUR = String(format: "€%.2f", cached.priceEUR)
                    self.marketCap = String(format: "€%.2fT", cached.marketCap / 1_000_000_000_000)
                    self.change24h = cached.change24h
                    self.circulatingSupply = cached.circulatingSupply
                    self.lastUpdated = cached.cachedAt
                    self.isUsingCachedData = true
                    self.errorMessage = error.localizedDescription
                } else {
                    self.priceEUR = "Loading..."
                    self.marketCap = "Loading..."
                    self.change24h = 0.0
                    self.errorMessage = error.localizedDescription
                    self.isUsingCachedData = false
                }
            }
        }
    }
}
