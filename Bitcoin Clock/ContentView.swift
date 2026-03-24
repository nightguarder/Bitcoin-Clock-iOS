//
//  ContentView.swift
//  Bitcoin Clock
//
//  Created by nightguarder on 24.03.26.
//

import SwiftUI

struct ContentView: View {
    @State private var store = BitcoinStore()

    var body: some View {
        TabView {
            PriceView(store: store)
            MarketCapView(store: store)
            FearGreedView(store: store)
        }
        .tabViewStyle(.page)
        .task {
            await store.fetchAll()
        }
    }
}


#Preview {
    ContentView()
}
