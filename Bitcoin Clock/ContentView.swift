//
//  ContentView.swift
//  Bitcoin Clock
//
//  Created by nightguarder on 24.03.26.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var store = BitcoinStore()

    var body: some View {
        TabView {
            PriceView(store: store)
            MarketCapView(store: store)
            SupplyView(store: store)
        }
        .tabViewStyle(.page)
        .task {
            await store.fetchAll()
            for await connected in NetworkMonitor.shared.$isConnected.values {
                guard connected,
                      store.errorMessage != nil || store.isUsingCachedData else { continue }
                await store.fetchAll(forceRefresh: true)
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
