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
    
    func clearCache() {
        userDefaults.removeObject(forKey: cacheKey)
        userDefaults.removeObject(forKey: lastFetchKey)
    }
}
