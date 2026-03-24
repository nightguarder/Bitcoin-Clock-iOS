//
//  PriceView.swift
//  Bitcoin Clock
//
//  Created by nightguarder on 23.03.26.
//

import Foundation
import SwiftUI
import UIKit

struct PriceView: View {
    var store: BitcoinStore

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "bitcoinsign.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.orange)

                Text("BTC / EUR")
                    .font(.title2)
                    .foregroundStyle(.orange)

                Text(store.priceEUR)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
    }
}
