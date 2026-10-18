//
//  PriceChartView.swift
//  Bitcoin Clock
//

import SwiftUI

struct PriceChartView: View {
    let points: [PricePoint]
    let range: ChartRange
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        if points.count < 2 {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.08))
                .frame(height: 160)
                .overlay(
                    Text("Loading chart…")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                )
        } else {
            chartContent
        }
    }

    private var chartContent: some View {
        VStack(spacing: 6) {
            GeometryReader { geo in
                let size = geo.size
                let coords = chartCoordinates(in: size)

                ZStack {
                    fillPath(coords: coords, size: size)
                        .fill(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.35), Color.orange.opacity(0.0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    linePath(coords: coords)
                        .stroke(Color.orange, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

                    if let minLabel = minMaxLabels(coords: coords).min,
                       let maxLabel = minMaxLabels(coords: coords).max {
                        Text(minLabel.text)
                            .font(.caption2.bold())
                            .foregroundStyle(.red)
                            .position(minLabel.position)
                        Text(maxLabel.text)
                            .font(.caption2.bold())
                            .foregroundStyle(.green)
                            .position(maxLabel.position)
                    }
                }
            }
            .frame(height: 160)

            HStack {
                Text(labelDate(points.first?.date))
                Spacer()
                Text(labelDate(points[points.count / 2].date))
                Spacer()
                Text(labelDate(points.last?.date))
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
    }

    private func chartCoordinates(in size: CGSize) -> [CGPoint] {
        let prices = points.map(\.price)
        let minPrice = prices.min() ?? 0
        let maxPrice = prices.max() ?? 1
        let padding: CGFloat = 12
        let range_ = max(maxPrice - minPrice, 1)

        return points.enumerated().map { index, point in
            let x = points.count > 1
                ? CGFloat(index) / CGFloat(points.count - 1) * size.width
                : 0
            let y = (1 - CGFloat((point.price - minPrice) / range_)) * (size.height - padding * 2) + padding
            return CGPoint(x: x, y: y)
        }
    }

    private func linePath(coords: [CGPoint]) -> Path {
        var path = Path()
        guard let first = coords.first else { return path }
        path.move(to: first)
        coords.dropFirst().forEach { path.addLine(to: $0) }
        return path
    }

    private func fillPath(coords: [CGPoint], size: CGSize) -> Path {
        var path = linePath(coords: coords)
        guard let last = coords.last, let first = coords.first else { return path }
        path.addLine(to: CGPoint(x: last.x, y: size.height))
        path.addLine(to: CGPoint(x: first.x, y: size.height))
        path.closeSubpath()
        return path
    }

    private func minMaxLabels(coords: [CGPoint]) -> (min: (text: String, position: CGPoint)?, max: (text: String, position: CGPoint)?) {
        guard let minIndex = points.minIndexByPrice(),
              let maxIndex = points.maxIndexByPrice(),
              coords.indices.contains(minIndex),
              coords.indices.contains(maxIndex) else { return (nil, nil) }

        let minText = formatPrice(points[minIndex].price)
        let maxText = formatPrice(points[maxIndex].price)

        let minPos = CGPoint(
            x: coords[minIndex].x,
            y: min(coords[minIndex].y + 14, 150)
        )
        let maxPos = CGPoint(
            x: coords[maxIndex].x,
            y: max(coords[maxIndex].y - 12, 10)
        )

        return ((minText, minPos), (maxText, maxPos))
    }

    private func formatPrice(_ price: Double) -> String {
        if price >= 1000 {
            return String(format: "€%.0fK", price / 1000)
        }
        return String(format: "€%.0f", price)
    }

    private func labelDate(_ date: Date?) -> String {
        guard let date else { return "" }
        let formatter = DateFormatter()
        switch range {
        case .day:
            formatter.dateFormat = "HH:mm"
        case .week, .month:
            formatter.dateFormat = "dd.MM"
        case .quarter, .year:
            formatter.dateFormat = "MMM"
        }
        return formatter.string(from: date)
    }
}

private extension Array where Element == PricePoint {
    func minIndexByPrice() -> Int? {
        indices.min { self[$0].price < self[$1].price }
    }

    func maxIndexByPrice() -> Int? {
        indices.max { self[$0].price < self[$1].price }
    }
}
