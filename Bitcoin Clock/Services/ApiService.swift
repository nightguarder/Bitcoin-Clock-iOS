//
//  ApiService.swift
//  Bitcoin Clock
//
//  Created by nightguarder on 24.03.26.
//

import Foundation

class ApiService {

    func fetchBitcoin() async -> BitcoinData? {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=eur&include_market_cap=true&include_24hr_change=true") else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            guard let dataArray = json?["bitcoin"] as? [String:Any],
                  let priceEUR = dataArray["eur"] as? Double,
                  let marketCap = dataArray["eur_market_cap"] as? Double,
                  let change24h = dataArray["eur_24h_change"] as? Double
                   
            else {return nil}
                   
            return BitcoinData(priceEUR: priceEUR, marketCap: marketCap, change24h: change24h)
        } catch {
            return nil
        }
    }
    
    //Fetch from https://alternative.me/crypto/api/
    func fetchFearGreed() async -> FearGreedData? {
        guard let url = URL(string: "https://api.alternative.me/fng/?limit=1") else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            guard let dataArray = json?["data"] as? [[String: Any]],
                  let first = dataArray.first,
                  let valueStr = first["value"] as? String,
                  let value = Int(valueStr),
                  let classification = first["value_classification"] as? String else { return nil }
            return FearGreedData(value: value, classification: classification)
        } catch {
            return nil
        }
    }
}
