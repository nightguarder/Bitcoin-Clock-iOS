//
//  CacheManager.swift
//  Bitcoin Clock
//
//  Created by nightguarder on 08.04.26.
//

import Foundation

public final class CacheManager {
    static let shared = CacheManager()
    static let appGroupID = "group.com.nightguarder.BitcoinClock"
    
    private let userDefaults = UserDefaults(suiteName: CacheManager.appGroupID) ?? UserDefaults.standard
    private let cacheKey = "cached_bitcoin_data"
    private let lastFetchKey = "last_fetch_timestamp"
    private let debounceInterval: TimeInterval = 30
    private let maxCacheAge: TimeInterval = 300
    private let historyCacheKeyPrefix = "cached_price_history_"
    private let historyFetchKeyPrefix = "price_history_fetch_"
    private let historyMaxCacheAge: TimeInterval = 1800
    private let fearGreedCacheKey = "cached_fear_greed"
    private let fearGreedFetchKey = "fear_greed_fetch_timestamp"
    private let fearGreedMaxCacheAge: TimeInterval = 6 * 3600
    
    private init() {
        migrateLegacyCache()
    }
    
    private func migrateLegacyCache() {
        guard userDefaults.data(forKey: cacheKey) == nil else { return }
        
        let defaults = UserDefaults.standard
        let candidates = [
            (dataKey: cacheKey, timeKey: lastFetchKey),
            (dataKey: "widget_cached_bitcoin_data", timeKey: "widget_last_fetch_timestamp"),
        ]
        
        var best: (data: Data, timestamp: TimeInterval)?
        for candidate in candidates {
            guard let data = defaults.data(forKey: candidate.dataKey),
                  let decoded = try? JSONDecoder().decode(BitcoinData.self, from: data) else { continue }
            let stored = defaults.double(forKey: candidate.timeKey)
            let timestamp = stored > 0 ? stored : decoded.cachedAt.timeIntervalSince1970
            if timestamp > (best?.timestamp ?? 0) {
                best = (data, timestamp)
            }
        }
        
        guard let best else { return }
        userDefaults.set(best.data, forKey: cacheKey)
        userDefaults.set(best.timestamp, forKey: lastFetchKey)
    }
    
    var cachedData: BitcoinData? {
        get {
            guard let data = userDefaults.data(forKey: cacheKey) else { return nil }
            return try? JSONDecoder().decode(BitcoinData.self, from: data)
        }
        set {
            if let newValue = newValue,
               let data = try? JSONEncoder().encode(newValue) {
                userDefaults.set(data, forKey: cacheKey)
                userDefaults.set(Date().timeIntervalSince1970, forKey: lastFetchKey)
            } else {
                userDefaults.removeObject(forKey: cacheKey)
                userDefaults.removeObject(forKey: lastFetchKey)
            }
        }
    }
    
    var lastFetchTime: Date? {
        let timestamp = userDefaults.double(forKey: lastFetchKey)
        return timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : nil
    }
    
    var isCacheFresh: Bool {
        guard let lastFetch = lastFetchTime else { return false }
        return Date().timeIntervalSince(lastFetch) < maxCacheAge
    }
    
    func canFetch() -> Bool {
        guard let lastFetch = lastFetchTime else { return true }
        return Date().timeIntervalSince(lastFetch) >= debounceInterval
    }
    
    func cachedPriceHistory(_ range: ChartRange) -> [PricePoint]? {
        guard let data = userDefaults.data(forKey: historyCacheKeyPrefix + "\(range.rawValue)") else { return nil }
        return try? JSONDecoder().decode([PricePoint].self, from: data)
    }
    
    func setCachedPriceHistory(_ points: [PricePoint], for range: ChartRange) {
        guard let data = try? JSONEncoder().encode(points) else { return }
        userDefaults.set(data, forKey: historyCacheKeyPrefix + "\(range.rawValue)")
        userDefaults.set(Date().timeIntervalSince1970, forKey: historyFetchKeyPrefix + "\(range.rawValue)")
    }
    
    func isPriceHistoryFresh(_ range: ChartRange) -> Bool {
        let timestamp = userDefaults.double(forKey: historyFetchKeyPrefix + "\(range.rawValue)")
        guard timestamp > 0 else { return false }
        return Date().timeIntervalSince1970 - timestamp < historyMaxCacheAge
    }
    
    var cachedFearGreed: FearGreedData? {
        get {
            guard let data = userDefaults.data(forKey: fearGreedCacheKey) else { return nil }
            return try? JSONDecoder().decode(FearGreedData.self, from: data)
        }
        set {
            if let newValue = newValue,
               let data = try? JSONEncoder().encode(newValue) {
                userDefaults.set(data, forKey: fearGreedCacheKey)
                userDefaults.set(Date().timeIntervalSince1970, forKey: fearGreedFetchKey)
            } else {
                userDefaults.removeObject(forKey: fearGreedCacheKey)
                userDefaults.removeObject(forKey: fearGreedFetchKey)
            }
        }
    }
    
    var isFearGreedFresh: Bool {
        let timestamp = userDefaults.double(forKey: fearGreedFetchKey)
        guard timestamp > 0 else { return false }
        return Date().timeIntervalSince1970 - timestamp < fearGreedMaxCacheAge
    }
    
    func clearCache() {
        userDefaults.removeObject(forKey: cacheKey)
        userDefaults.removeObject(forKey: lastFetchKey)
    }
}
