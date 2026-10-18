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
    
    @Published var chartRange: ChartRange = .week
    @Published var pricePoints: [PricePoint] = []
    @Published var fearGreed: FearGreedData? = nil
    
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
        if let history = cache.cachedPriceHistory(chartRange) {
            pricePoints = history
        }
        fearGreed = cache.cachedFearGreed
    }

    func fetchAll(forceRefresh: Bool = false) async {
        if !forceRefresh && !cache.canFetch() { return }
        
        errorMessage = nil
        
        async let marketResult = ApiService.fetchBitcoin()
        async let historyResult = ApiService.fetchPriceHistory(range: chartRange)
        async let fearGreedResult = ApiService.fetchFearGreed()
        
        let (market, history, fearGreed) = await (marketResult, historyResult, fearGreedResult)
        
        await MainActor.run {
            self.applyMarketResult(market, forceRefresh: forceRefresh)
            self.applyHistoryResult(history, for: self.chartRange)
            self.applyFearGreedResult(fearGreed)
        }
    }
    
    func setChartRange(_ range: ChartRange) async {
        guard range != chartRange else { return }
        chartRange = range
        
        if let cached = cache.cachedPriceHistory(range) {
            pricePoints = cached
        } else {
            pricePoints = []
        }
        
        let result = await ApiService.fetchPriceHistory(range: range)
        await MainActor.run {
            guard self.chartRange == range else { return }
            self.applyHistoryResult(result, for: range)
        }
    }
    
    private func applyMarketResult(_ result: Result<BitcoinData, ApiError>, forceRefresh: Bool) {
        switch result {
        case .success(let data):
            self.cache.cachedData = data
            
            self.priceEUR = String(format: "€%.2f", data.priceEUR)
            self.marketCap = String(format: "€%.2fT", data.marketCap / 1_000_000_000_000)
            self.change24h = data.change24h
            self.circulatingSupply = data.circulatingSupply
            self.lastUpdated = data.cachedAt
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
    
    private func applyHistoryResult(_ result: Result<[PricePoint], ApiError>, for range: ChartRange) {
        switch result {
        case .success(let points):
            self.cache.setCachedPriceHistory(points, for: range)
            if self.chartRange == range {
                self.pricePoints = points
            }
        case .failure:
            if self.pricePoints.isEmpty {
                self.pricePoints = self.cache.cachedPriceHistory(range) ?? []
            }
        }
    }
    
    private func applyFearGreedResult(_ result: Result<FearGreedData, ApiError>) {
        switch result {
        case .success(let data):
            self.cache.cachedFearGreed = data
            self.fearGreed = data
        case .failure:
            self.fearGreed = self.cache.cachedFearGreed
        }
    }
}
