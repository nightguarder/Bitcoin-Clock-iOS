# Bitcoin Clock

A minimal SwiftUI app that turns your iPhone into a Bitcoin ticker: price, market cap, and circulating supply — plus a home screen widget.

<!-- TODO: add screenshots
## Screenshots
| Price | Market Cap | Supply | Widget |
|-------|-----------|--------|--------|
|       |           |        |        |
-->

## Features

- **Three swipeable pages**
  - **Price** — current BTC price in EUR with relative "updated X ago" timestamp
  - **Market Cap** — total market cap in trillions of EUR
  - **Supply** — circulating supply in BTC
- **Home screen widget** (small & medium) showing price, market cap, and 24 h change, refreshed hourly
- **Pull-to-refresh** on every page — bypasses the rate-limit cache for a forced update
- **Smart caching** — data is cached locally (30 s debounce) and shown instantly on launch; cached data is displayed dimmed when the API is unreachable
- **Rate-limit aware** — handles CoinGecko HTTP 429 responses gracefully and falls back to cached data
- **Light & Dark mode** support

## Requirements

- iOS 15.2+ (app), iOS 15.6+ (widget)
- Xcode 15+
- Swift 5 / SwiftUI
- No third-party dependencies

## Getting Started

1. Clone the repository:
   ```sh
   git clone https://github.com/nightguarder/Bitcoin-Clock.git
   cd Bitcoin-Clock
   ```
2. Open `Bitcoin Clock.xcodeproj` in Xcode.
3. Select the **Bitcoin Clock** target → *Signing & Capabilities* → choose your development team.
4. Repeat for the **BitcoinClock WidgetExtension** target.
5. Run the **Bitcoin Clock** scheme on a device or simulator.

To also place the widget on your home screen, run once on a physical device, then long-press your home screen → **+** → search for *Bitcoin Clock*.

## Project Structure

```
Bitcoin Clock/
├── Bitcoin Clock/            # Main app target
│   ├── Bitcoin_ClockApp.swift
│   ├── ContentView.swift     # Paged TabView (Price / Market Cap / Supply)
│   ├── Models/
│   │   ├── BitcoinData.swift # Data models + cache encoding
│   │   └── BitcoinStore.swift# ObservableObject app state
│   ├── Screens/              # PriceView, MarketCapView, SupplyView
│   ├── Services/
│   │   ├── ApiService.swift  # CoinGecko networking
│   │   └── CacheManager.swift# UserDefaults cache + 30 s debounce
│   └── Assets.xcassets
├── BitcoinClock Widget/      # WidgetKit extension (small & medium)
└── Bitcoin Clock.xcodeproj
```

## Data Source

Market data comes from the free [CoinGecko API](https://www.coingecko.com/en/api) (`/api/v3/coins/markets`, EUR). The free tier is rate-limited, which is why the app caches responses, debounces fetches, and supports forced refresh via pull-to-refresh.

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
