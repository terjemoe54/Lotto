//
//  FindWinnerView.swift
//  Lotto
//
//  Created by Terje Moe on 06/02/2026.
//

import SwiftUI
import SwiftData

struct FindWinnerView: View {
    // Selected date for which to compare results with jackpot
    @State private var selectedDate: Date = .now
    // Computed comparisons for the selected date
    @State private var comparisons: [ResultComparison] = []
    // Loading and error states
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            Form {
                Section("Select date") {
                    DatePicker("Date", selection: $selectedDate, displayedComponents: [.date])
                        .datePickerStyle(.compact)
                }

                Section {
                    Button {
                        Task { await runComparison() }
                    } label: {
                        HStack {
                            if isLoading { ProgressView().padding(.trailing, 4) }
                            Text("Compare with Jackpot")
                        }
                    }
                    .disabled(isLoading)
                }

                if let errorMessage {
                    Section("Error") {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }

                Section("Matches") {
                    if comparisons.isEmpty {
                        Text("No comparisons yet. Choose a date and tap Compare.")
                            .foregroundStyle(.secondary)
                    } else {
                        List(comparisons) { item in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("Result ID: \(item.result.id)")
                                    Spacer()
                                    Text("Matches: \(item.matchCount)")
                                        .bold()
                                }
                                Text(item.result.date, style: .date)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                HStack(alignment: .top, spacing: 12) {
                                    NumberCountView(title: "Result numbers", numbers: item.result.numbers)
                                    NumberCountView(title: "Jackpot numbers", numbers: item.jackpot.numbers)
                                }
                                if !item.matchedNumbers.isEmpty {
                                    Text("Matched: \(item.matchedNumbers.sorted().map(String.init).joined(separator: ", "))")
                                        .font(.footnote)
                                        .foregroundStyle(.green)
                                }
                            }
                        }
                        .listStyle(.plain)
                        .frame(minHeight: 260)
                    }
                }
            }
            .navigationTitle("Find Winner")
        }
    }
}

// MARK: - Models

/// Represents a single result row (e.g., a user's post) containing numbers for a drawing date.
struct ResultRow: Identifiable, Hashable {
    let id: String
    let date: Date
    let numbers: [Int]
}

/// Represents the winning jackpot row for a given date.
struct JackpotRow: Hashable {
    let date: Date
    let numbers: [Int]
}

/// Represents a comparison between a result and the jackpot.
struct ResultComparison: Identifiable, Hashable {
    let id: String
    let result: ResultRow
    let jackpot: JackpotRow
    let matchedNumbers: [Int]

    var matchCount: Int { matchedNumbers.count }
}

// MARK: - Data Access Placeholders
extension FindWinnerView {
    /// Fetch all results for the given date from the SwiftData model.
    func fetchResults(for date: Date) async throws -> [ResultRow] {
        let dayStart = normalize(date)
        // Build a date range [startOfDay, nextDay)
        guard let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: dayStart) else {
            return []
        }
        // Query SwiftData for Result rows on that date (between start and next day)
        let descriptor = FetchDescriptor<Result>(
            predicate: #Predicate { $0.dato >= dayStart && $0.dato < nextDay },
            sortBy: [SortDescriptor(\.dato)]
        )
        let results = try modelContext.fetch(descriptor)
        // Map to lightweight view model
        return results.enumerated().map { idx, r in
            ResultRow(
                id: String(r.persistentModelID.hashValue),
                date: normalize(r.dato),
                numbers: [r.nr1, r.nr2, r.nr3, r.nr4, r.nr5, r.nr6, r.nr7]
            )
        }
    }

    /// Fetch the jackpot row for the given date from the SwiftData model.
    func fetchJackpot(for date: Date) async throws -> JackpotRow? {
        let dayStart = normalize(date)
        guard let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: dayStart) else {
            return nil
        }
        // Query SwiftData for JackPot on that date (unique per date per your model)
        let descriptor = FetchDescriptor<JackPot>(
            predicate: #Predicate { $0.dato >= dayStart && $0.dato < nextDay },
            sortBy: [SortDescriptor(\.dato)]
        )
        let jackpots = try modelContext.fetch(descriptor)
        guard let j = jackpots.first else { return nil }
        // Map to lightweight view model (include the first 7 numbers, ignore nr8 if it's an extra number)
        return JackpotRow(
            date: normalize(j.dato),
            numbers: [j.nr1, j.nr2, j.nr3, j.nr4, j.nr5, j.nr6, j.nr7]
        )
    }
}

// MARK: - Logic
extension FindWinnerView {
    /// Normalizes a date to year-month-day (removing time) for reliable equality.
    func normalize(_ date: Date) -> Date {
        let comps = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return Calendar.current.date(from: comps) ?? date
    }

    /// Runs the comparison for the selected date using the SwiftData fetch.
    func runComparison() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            comparisons = []
        }

        do {
            let date = normalize(selectedDate)
            async let resultsTask = fetchResults(for: date)
            async let jackpotTask = fetchJackpot(for: date)

            let (results, jackpotOpt) = try await (resultsTask, jackpotTask)

            guard let jackpot = jackpotOpt else {
                await MainActor.run {
                    errorMessage = "No jackpot found for selected date."
                    isLoading = false
                }
                return
            }

            let comps: [ResultComparison] = results.map { result in
                let matched = Set(result.numbers).intersection(Set(jackpot.numbers)).sorted()
                return ResultComparison(
                    id: "\(result.id)-\(jackpot.date.timeIntervalSince1970)",
                    result: result,
                    jackpot: jackpot,
                    matchedNumbers: matched
                )
            }

            await MainActor.run {
                comparisons = comps.sorted { $0.matchCount > $1.matchCount }
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

struct NumberCountView: View {
    let title: String
    let numbers: [Int]

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(numbers.sorted().map(String.init).joined(separator: ", "))
                .font(.system(size: 12, weight: .semibold))
            // .font(.callout)
        }
    }
}

#Preview {
    FindWinnerView()
}
