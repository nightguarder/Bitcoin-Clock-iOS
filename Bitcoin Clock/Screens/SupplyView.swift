//
//  SupplyView.swift
//  Bitcoin Clock
//
//  Created by nightguarder on 24.03.26.
//

import SwiftUI

struct SupplyView: View {
    @ObservedObject var store: BitcoinStore
    @Environment(\.colorScheme) var colorScheme
    
    private let maxSupply: Double = 21_000_000
    
    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color.black : Color.white).ignoresSafeArea()
            
            VStack {
                Text("Updated \(store.lastUpdated, style: .relative)")
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                    .padding(.top)
                
                StatusBannerView(store: store)
                
                ScrollView {
                    VStack(spacing: 30) {
                        Spacer()
                        
                        Image(systemName: "bitcoinsign.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.orange)
                        
                        Text("Bitcoin Supply")
                            .font(.title2)
                            .foregroundStyle(.orange)
                        
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 20)
                                .frame(width: 200, height: 200)
                            
                            Circle()
                                .trim(from: 0, to: min(store.circulatingSupply / maxSupply, 1.0))
                                .stroke(Color.orange, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                                .frame(width: 200, height: 200)
                                .rotationEffect(.degrees(-90))
                            
                            VStack(spacing: 4) {
                                Text(formatNumber(store.circulatingSupply))
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                Text("BTC")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("Mined")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(Int((store.circulatingSupply / maxSupply) * 100))%")
                                    .fontWeight(.bold)
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                            }
                            
                            HStack {
                                Text("Remaining")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(formatNumber(maxSupply - store.circulatingSupply))
                                    .fontWeight(.bold)
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                            }
                            
                            HStack {
                                Text("Max Supply")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(formatNumber(maxSupply))
                                    .fontWeight(.bold)
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                            }
                        }
                        .font(.body)
                        .padding(.horizontal, 40)
                        
                        Spacer()
                    }
                    .frame(maxHeight: .infinity)
                }
                .refreshable {
                    await store.fetchAll(forceRefresh: true)
                }
            }
        }
    }
    
    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    private func formatNumber(_ number: Double) -> String {
        Self.numberFormatter.string(from: NSNumber(value: number)) ?? "\(Int(number))"
    }
}
