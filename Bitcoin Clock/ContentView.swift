//
//  ContentView.swift
//  Bitcoin Clock
//
//  Created by nightguarder on 24.03.26.
//

import SwiftUI

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
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
