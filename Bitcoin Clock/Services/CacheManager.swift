//
//  CacheManager.swift
//  Bitcoin Clock
//
//  Created by nightguarder on 08.04.26.
//

import Foundation

public final class CacheManager {
    static let shared = CacheManager()
    
    private let userDefaults = UserDefaults.standard
    private let cacheKey = "cached_bitcoin_data"
    private let lastFetchKey = "last_fetch_timestamp"
    private let debounceInterval: TimeInterval = 30
    
    private init() {}
    
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
    
    func canFetch() -> Bool {
        guard let lastFetch = lastFetchTime else { return true }
        return Date().timeIntervalSince(lastFetch) >= debounceInterval
    }
    
    func clearCache() {
        userDefaults.removeObject(forKey: cacheKey)
        userDefaults.removeObject(forKey: lastFetchKey)
    }
}
