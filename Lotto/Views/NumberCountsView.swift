//
//  StatView.swift
//  Lotto
//
//  Created by Terje Moe on 03/02/2026.
//

import SwiftUI
import SwiftData


struct NumberCountsView: View {
    @Environment(\.modelContext) private var context
    @State private var counts: [Int: Int] = [:]
    @State private var averageDaysBetween: [Int: Double] = [:]
    @State private var lastDatePerNumber: [Int: Date] = [:]
    @State private var nextDatePerNumber: [Int: Date] = [:]
    
    var body: some View {
        let sortedCounts = counts
            .map { ($0.key, $0.value) }
            .sorted { lhs, rhs in
                if lhs.1 == rhs.1 {
                    return lhs.0 < rhs.0 // tie-breaker by number ascending
                }
                return lhs.1 > rhs.1 // highest count first
            }
        
        List {
            ForEach(sortedCounts, id: \.0) { number, count in
                HStack {
                    Text("Number \(number)")
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Count: \(count)")
                        if let avg = averageDaysBetween[number] {
                            Text(String(format: "Avg: %.1f days", avg))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Avg: -")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        if let next = nextDatePerNumber[number] {
                            Text("Next: \(next, style: .date)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Next: -")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            
        }
        .onAppear(perform: loadCounts)
        .navigationTitle("Number counts")
    }
    
    func frequencyForNumbers1to34(in numbers: [Int]) -> [Int: Int] {
        var counts: [Int: Int] = [:]
        for number in numbers {
            if (1...34).contains(number) {
                counts[number, default: 0] += 1
            }
        }
        return counts
    }
    
    func averageDayGapsPerNumber(from jackpots: [JackPot]) -> [Int: Double] {
        // Build a map of number -> [Date] appearances
        var appearances: [Int: [Date]] = [:]
        for jackpot in jackpots {
            // Assuming JackPot has a `date` property of type Date
            let date = jackpot.dato
            let nums = [jackpot.nr1, jackpot.nr2, jackpot.nr3, jackpot.nr4,
                        jackpot.nr5, jackpot.nr6, jackpot.nr7, jackpot.nr8]
            for n in nums where (1...34).contains(n) {
                appearances[n, default: []].append(date)
            }
        }
        // For each number, sort dates and compute average gap in days
        var result: [Int: Double] = [:]
        let calendar = Calendar.current
        for (number, dates) in appearances {
            let sorted = dates.sorted()
            guard sorted.count >= 2 else { continue }
            var gaps: [Double] = []
            for i in 1..<sorted.count {
                let d1 = sorted[i-1]
                let d2 = sorted[i]
                if let days = calendar.dateComponents([.day], from: d1, to: d2).day {
                    gaps.append(Double(days))
                }
            }
            if !gaps.isEmpty {
                let avg = gaps.reduce(0, +) / Double(gaps.count)
                result[number] = avg
            }
        }
        return result
    }
    
    func statsPerNumber(from jackpots: [JackPot]) -> (
        avgGaps: [Int: Double],
        lastDates: [Int: Date]
    ) {
        var appearances: [Int: [Date]] = [:]
        
        for jackpot in jackpots {
            let date = jackpot.dato
            let nums = [jackpot.nr1, jackpot.nr2, jackpot.nr3, jackpot.nr4,
                        jackpot.nr5, jackpot.nr6, jackpot.nr7, jackpot.nr8]
            for n in nums where (1...34).contains(n) {
                appearances[n, default: []].append(date)
            }
        }
        
        var avgGaps: [Int: Double] = [:]
        var lastDates: [Int: Date] = [:]
        let calendar = Calendar.current
        
        for (number, dates) in appearances {
            let sorted = dates.sorted()
            lastDates[number] = sorted.last
            
            guard sorted.count >= 2 else { continue }
            
            var gaps: [Double] = []
            for i in 1..<sorted.count {
                let d1 = sorted[i-1]
                let d2 = sorted[i]
                if let days = calendar.dateComponents([.day], from: d1, to: d2).day {
                    gaps.append(Double(days))
                }
            }
            if !gaps.isEmpty {
                let avg = gaps.reduce(0, +) / Double(gaps.count)
                avgGaps[number] = avg
            }
        }
        
        return (avgGaps, lastDates)
    }
    
    private func loadCounts() {
        do {
            let descriptor = FetchDescriptor<JackPot>()
            let jackpots = try context.fetch(descriptor)
            
            let stats = statsPerNumber(from: jackpots)
            self.averageDaysBetween = stats.avgGaps
            self.lastDatePerNumber = stats.lastDates
            
            // compute predicted next date = lastDate + avgDays
            var predicted: [Int: Date] = [:]
            let calendar = Calendar.current
            for (number, lastDate) in stats.lastDates {
                if let avgDays = stats.avgGaps[number] {
                    if let nextDate = calendar.date(byAdding: .day,
                                                    value: Int(avgDays.rounded()),
                                                    to: lastDate) {
                        predicted[number] = nextDate
                    }
                }
            }
            self.nextDatePerNumber = predicted
            let numbers = jackpots.flatMap { jackpot in
                [jackpot.nr1, jackpot.nr2, jackpot.nr3, jackpot.nr4,
                 jackpot.nr5, jackpot.nr6, jackpot.nr7, jackpot.nr8]
            }
            counts = frequencyForNumbers1to34(in: numbers)
        } catch {
            print("Failed to load counts: \(error)")
        }
    }
}

#Preview {
    NumberCountsView()
        .modelContainer(for: JackPot.self, inMemory: true)
}
