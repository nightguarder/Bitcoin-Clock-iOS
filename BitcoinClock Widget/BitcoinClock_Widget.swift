//
//  BitcoinClock_Widget.swift
//  BitcoinClock-Widget
//
//  Created by nightguarder on 23.03.26.
//

import WidgetKit
import SwiftUI

struct BitcoinEntry: TimelineEntry{
    let date: Date
    let priceEUR: String
    let marketCap: String
    let change24h: Double
}
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> BitcoinEntry {
        BitcoinEntry(date: Date(), priceEUR: "0000.00", marketCap: "€0.0 T", change24h: 0.0)
    }
    func getSnapshot(in context: Context, completion: @escaping (BitcoinEntry) -> ()) {
            Task {
                let api = ApiService()
                if let data = await api.fetchBitcoin() {
                    let entry = BitcoinEntry(
                        date: Date(),
                        priceEUR: String(format: "%.2f", data.priceEUR),
                        marketCap: String(format: "%.2f T", data.marketCap / 1_000_000_000_000),
                        change24h: data.change24h
                    )
                    completion(entry)
                } else {
                    completion(placeholder(in: context))
                }
            }
        }
    func getTimeline(in context: Context, completion: @escaping (Timeline<BitcoinEntry>) -> Void) {
        Task {
            let api = ApiService()
            if let data = await api.fetchBitcoin() {
                let entry = BitcoinEntry(
                    date: Date(),
                    priceEUR: String(format: "%.2f", data.priceEUR),
                    marketCap: String(format: "%.2f T", data.marketCap / 1_000_000_000_000),
                    change24h: data.change24h
                )
                let nextRefresh = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
                let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
                completion(timeline)
            } else {
                let nextRefresh = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
                let timeline = Timeline(entries: [placeholder(in: context)], policy: .after(nextRefresh))
                completion(timeline)
            }
        }
    }
}

    
struct BitcoinClock_WidgetEntryView: View {
    var entry: Provider.Entry //fetch the latest data
    @Environment(\.widgetFamily) var family //Important
    var body: some View {
        switch family {
        case .systemSmall:
            VStack(spacing: 8) {
                            Image(systemName: "bitcoinsign.circle.fill")
                                .font(.largeTitle)
                                .foregroundStyle(.orange)
                            Text(entry.priceEUR)
                                .foregroundStyle(.white)
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
                                    .foregroundStyle(.white)
                            Text(entry.priceEUR)
                                .font(.system(size: 25, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        
                        
                        HStack(alignment: .firstTextBaseline, spacing: 2){
                            Image(systemName: "eurosign")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(.gray)
                            Text(entry.marketCap)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.gray)
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

                    Spacer()
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
                        .foregroundStyle(.white)

                    Divider()
                        .background(.gray)

                    HStack(spacing: 40) {
                        VStack {
                            Text("Market Cap")
                                .font(.caption)
                                .foregroundStyle(.gray)
                            Text(entry.marketCap)
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                        }
                        VStack {
                            Text("24h Change")
                                .font(.caption)
                                .foregroundStyle(.gray)
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
//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }

struct BitcoinClock_Widget: Widget {
    let kind: String = "BitcoinClock_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                BitcoinClock_WidgetEntryView(entry: entry)
                    .containerBackground(.black, for: .widget)
            } else {
                BitcoinClock_WidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Bitcoin Clock")
        .description("Display live Bitcoin price")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])//Important
    }
}


#Preview(as: .systemMedium) {
    BitcoinClock_Widget()
} timeline: {
    BitcoinEntry(date: .now, priceEUR: "12345.123", marketCap: "1.23 T", change24h: 3.73)

}
