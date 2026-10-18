//
//  BitcoinClock_Widget.swift
//  BitcoinClock-Widget
//
//  Created by nightguarder on 23.03.26.
//

import WidgetKit
import SwiftUI

struct BitcoinEntry: TimelineEntry {
    let date: Date
    let priceEUR: String
    let marketCap: String
    let change24h: Double
    let isCached: Bool
    
    init(date: Date, priceEUR: String, marketCap: String, change24h: Double, isCached: Bool = false) {
        self.date = date
        self.priceEUR = priceEUR
        self.marketCap = marketCap
        self.change24h = change24h
        self.isCached = isCached
    }
    
    init(from data: BitcoinData, isCached: Bool = false) {
        self.date = Date()
        self.priceEUR = String(format: "%.2f", data.priceEUR)
        self.marketCap = String(format: "%.2f T", data.marketCap / 1_000_000_000_000)
        self.change24h = data.change24h
        self.isCached = isCached
    }
}

struct Provider: TimelineProvider {
    private var cache = CacheManager.shared
    
    func placeholder(in context: Context) -> BitcoinEntry {
        BitcoinEntry(date: Date(), priceEUR: "0000.00", marketCap: "0.0 T", change24h: 0.0, isCached: false)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (BitcoinEntry) -> ()) {
        if let cached = cache.cachedData {
            completion(BitcoinEntry(from: cached, isCached: true))
            return
        }
        
        Task {
            let result = await ApiService.fetchBitcoin()
            
            switch result {
            case .success(let data):
                cache.cachedData = data
                completion(BitcoinEntry(from: data))
            case .failure:
                completion(placeholder(in: context))
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<BitcoinEntry>) -> Void) {
        Task {
            let entry: BitcoinEntry
            
            if let cached = cache.cachedData, cache.isCacheFresh {
                entry = BitcoinEntry(from: cached)
            } else {
                let result = await ApiService.fetchBitcoin()
                
                switch result {
                case .success(let data):
                    cache.cachedData = data
                    entry = BitcoinEntry(from: data)
                case .failure:
                    if let cached = cache.cachedData {
                        entry = BitcoinEntry(from: cached, isCached: true)
                    } else {
                        entry = placeholder(in: context)
                    }
                }
            }
            
            let nextRefresh = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
            completion(timeline)
        }
    }
}

struct BitcoinClock_WidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let foregroundColor = colorScheme == .dark ? Color.white : Color.black
        let dataOpacity: Double = entry.isCached ? 0.6 : 1.0
        
        switch family {
        case .systemSmall:
            VStack(spacing: 8) {
                Image(systemName: "bitcoinsign.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.orange)
                Text(entry.priceEUR)
                    .foregroundStyle(foregroundColor.opacity(dataOpacity))
                    .font(.headline)
            }
        case .systemMedium:
            HStack(spacing: 4) {
                Image(systemName: "bitcoinsign.circle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.orange)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center, spacing: 2) {
                        Image(systemName: "eurosign")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(foregroundColor.opacity(dataOpacity))
                        Text(entry.priceEUR)
                            .font(.system(size: 25, weight: .bold, design: .rounded))
                            .foregroundStyle(foregroundColor.opacity(dataOpacity))
                    }
                    
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Image(systemName: "eurosign")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondary)
                        Text(entry.marketCap)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: entry.change24h >= 0 ? "chart.line.uptrend.xyaxis" : "chart.line.downtrend.xyaxis")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(entry.change24h >= 0 ? .green : .red)
                        
                        Text(String(format: "%.2f %%", entry.change24h))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(entry.change24h >= 0 ? .green : .red)
                    }
                }
                
            }
            .padding()
        case .systemLarge:
            VStack(spacing: 16) {
                Image(systemName: "bitcoinsign.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.orange)
                
                Text("BTC / EUR")
                    .font(.title2)
                    .foregroundStyle(.orange)
                
                Text(entry.priceEUR)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(foregroundColor.opacity(dataOpacity))
                
                if entry.isCached {
                    Text("Cached")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Divider()
                    .background(.secondary)
                
                HStack(spacing: 40) {
                    VStack {
                        Text("Market Cap")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(entry.marketCap)
                            .font(.title3.bold())
                            .foregroundStyle(foregroundColor)
                    }
                    VStack {
                        Text("24h Change")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(String(format: "%.2f %%", entry.change24h))
                            .font(.title3.bold())
                            .foregroundStyle(entry.change24h >= 0 ? .green : .red)
                    }
                }
            }
            .padding()
        default:
            EmptyView()
        }
    }
}

struct BitcoinClock_Widget: Widget {
    let kind: String = "BitcoinClock_Widget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                BitcoinClock_WidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                BitcoinClock_WidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Bitcoin Clock")
        .description("Display live Bitcoin price")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct BitcoinClock_Widget_Preview_Small: PreviewProvider {
    static var previews: some View {
        BitcoinClock_WidgetEntryView(entry: BitcoinEntry(date: .now, priceEUR: "12345.123", marketCap: "1.23 T", change24h: 3.73, isCached: false))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

struct BitcoinClock_Widget_Preview_Medium: PreviewProvider {
    static var previews: some View {
        BitcoinClock_WidgetEntryView(entry: BitcoinEntry(date: .now, priceEUR: "12345.123", marketCap: "1.23 T", change24h: 3.73, isCached: false))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
