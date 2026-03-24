//
//  PriceView.swift
//  Bitcoin Clock
//
//  Created by nightguarder on 23.03.26.
//

import SwiftUI

struct PriceView: View {
    @ObservedObject var store: BitcoinStore
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color.black : Color.white).ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "bitcoinsign.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.orange)

                Text("BTC / EUR")
                    .font(.title2)
                    .foregroundStyle(.orange)

                Text(store.priceEUR)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
            }
        }
    }
}
