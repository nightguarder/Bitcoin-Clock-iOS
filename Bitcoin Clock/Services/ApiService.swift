//
//  ApiService.swift
//  Bitcoin Clock
//
//  Created by nightguarder on 24.03.26.
//

import Foundation

class ApiService {

    func fetchBitcoin() async -> BitcoinData? {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=eur&ids=bitcoin") else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
            guard let bitcoin = json?.first,
                  let priceEUR = bitcoin["current_price"] as? Double,
                  let marketCap = bitcoin["market_cap"] as? Double,
                  let change24h = bitcoin["price_change_percentage_24h"] as? Double,
                  let circulatingSupply = bitcoin["circulating_supply"] as? Double
                   
            else {return nil}
                   
            return BitcoinData(priceEUR: priceEUR, marketCap: marketCap, change24h: change24h, circulatingSupply: circulatingSupply)
        } catch {
            return nil
        }
    }
     
}
