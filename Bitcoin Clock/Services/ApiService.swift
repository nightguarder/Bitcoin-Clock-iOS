//
//  ApiService.swift
//  Bitcoin Clock
//
//  Created by nightguarder on 24.03.26.
//

import Foundation

enum ApiError: Error, LocalizedError {
    case invalidURL
    case networkError(String)
    case invalidResponse
    case rateLimited
    case decodingError(String)
    case noData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidResponse:
            return "Invalid response from server"
        case .rateLimited:
            return "Rate limited. Please wait a moment."
        case .decodingError(let message):
            return "Failed to parse data: \(message)"
        case .noData:
            return "No data received"
        }
    }
}

class ApiService {

    func fetchBitcoin() async -> Result<BitcoinData, ApiError> {
        print("[ApiService] fetchBitcoin() called")
        
        let urlString = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=eur&ids=bitcoin"
        
        guard let url = URL(string: urlString) else {
            print("[ApiService] ERROR: Invalid URL")
            return .failure(.invalidURL)
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        request.httpMethod = "GET"
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        
        print("[ApiService] Making request...")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            print("[ApiService] Response received")
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("[ApiService] ERROR: Not HTTPURLResponse")
                return .failure(.invalidResponse)
            }
            
            print("[ApiService] HTTP Status: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 429 {
                print("[ApiService] ERROR: Rate limited (429)")
                return .failure(.rateLimited)
            }
            if httpResponse.statusCode != 200 {
                print("[ApiService] ERROR: Non-200 status")
                return .failure(.invalidResponse)
            }
            
            if data.isEmpty {
                print("[ApiService] ERROR: Empty data")
                return .failure(.noData)
            }
            
            let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
            
            guard let array = json,
                  let bitcoin = array.first,
                  let priceEUR = bitcoin["current_price"] as? Double,
                  let marketCap = bitcoin["market_cap"] as? Double,
                  let change24h = bitcoin["price_change_percentage_24h"] as? Double,
                  let circulatingSupply = bitcoin["circulating_supply"] as? Double else {
                print("[ApiService] ERROR: Decoding failed")
                return .failure(.decodingError("Missing required fields"))
            }
            
            print("[ApiService] SUCCESS: priceEUR=\(priceEUR)")
            return .success(BitcoinData(priceEUR: priceEUR, marketCap: marketCap, change24h: change24h, circulatingSupply: circulatingSupply))
        } catch {
            print("[ApiService] ERROR: \(error.localizedDescription)")
            return .failure(.networkError(error.localizedDescription))
        }
    }
}
