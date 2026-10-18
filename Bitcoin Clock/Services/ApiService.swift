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

    private static func get(_ urlString: String) async -> Result<Data, ApiError> {
        guard let url = URL(string: urlString) else {
            return .failure(.invalidURL)
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        request.httpMethod = "GET"
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.invalidResponse)
            }

            if httpResponse.statusCode == 429 {
                return .failure(.rateLimited)
            }
            if httpResponse.statusCode != 200 {
                return .failure(.invalidResponse)
            }

            if data.isEmpty {
                return .failure(.noData)
            }

            return .success(data)
        } catch {
            return .failure(.networkError(error.localizedDescription))
        }
    }

    static func fetchBitcoin() async -> Result<BitcoinData, ApiError> {
        let urlString = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=eur&ids=bitcoin"

        let result = await get(urlString)
        guard case .success(let data) = result else {
            if case .failure(let error) = result { return .failure(error) }
            return .failure(.noData)
        }

        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]

            guard let array = json,
                  let bitcoin = array.first,
                  let priceEUR = bitcoin["current_price"] as? Double,
                  let marketCap = bitcoin["market_cap"] as? Double,
                  let change24h = bitcoin["price_change_percentage_24h"] as? Double,
                  let circulatingSupply = bitcoin["circulating_supply"] as? Double else {
                return .failure(.decodingError("Missing required fields"))
            }

            return .success(BitcoinData(priceEUR: priceEUR, marketCap: marketCap, change24h: change24h, circulatingSupply: circulatingSupply))
        } catch {
            return .failure(.decodingError(error.localizedDescription))
        }
    }

    static func fetchPriceHistory(range: ChartRange = .week) async -> Result<[PricePoint], ApiError> {
        let urlString = "https://api.coingecko.com/api/v3/coins/bitcoin/market_chart?vs_currency=eur&days=\(range.days)"

        let result = await get(urlString)
        guard case .success(let data) = result else {
            if case .failure(let error) = result { return .failure(error) }
            return .failure(.noData)
        }

        do {
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let prices = json["prices"] as? [[Any]] else {
                return .failure(.decodingError("Missing required fields"))
            }

            let points: [PricePoint] = prices.compactMap { pair in
                guard let millis = pair.first as? Double,
                      let price = pair.last as? Double else { return nil }
                return PricePoint(date: Date(timeIntervalSince1970: millis / 1000), price: price)
            }

            guard points.count >= 2 else {
                return .failure(.noData)
            }

            return .success(points)
        } catch {
            return .failure(.decodingError(error.localizedDescription))
        }
    }

    static func fetchFearGreed() async -> Result<FearGreedData, ApiError> {
        let urlString = "https://api.alternative.me/fng/?limit=7"

        let result = await get(urlString)
        guard case .success(let data) = result else {
            if case .failure(let error) = result { return .failure(error) }
            return .failure(.noData)
        }

        do {
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let dataArray = json["data"] as? [[String: Any]] else {
                return .failure(.decodingError("Missing required fields"))
            }

            var entries: [FearGreedEntry] = []
            for item in dataArray {
                guard let valueString = item["value"] as? String,
                      let value = Int(valueString),
                      let classification = item["value_classification"] as? String,
                      let timestampString = item["timestamp"] as? String,
                      let timestamp = TimeInterval(timestampString) else { continue }
                entries.append(FearGreedEntry(value: value,
                                              classification: classification,
                                              date: Date(timeIntervalSince1970: timestamp)))
            }

            guard let current = entries.first else {
                return .failure(.noData)
            }

            entries.reverse()

            return .success(FearGreedData(current: current, history: entries, cachedAt: Date()))
        } catch {
            return .failure(.decodingError(error.localizedDescription))
        }
    }
}
