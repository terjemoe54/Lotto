//
//  NewJackpotView.swift
//  Lotto
//
//  Created by Terje Moe on 02/02/2026.
//

import SwiftUI
import SwiftData

struct NewJackpotView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \JackPot.dato, order: .forward) private var jackpots: [JackPot]
    @Environment(\.dismiss) var dismiss
    @State private var jackpot: JackPot = JackPot(
        dato: Date(),
        nr1: 0, nr2: 0, nr3: 0, nr4: 0,
        nr5: 0, nr6: 0, nr7: 0, nr8: 0,
        weekNr: 0
    )
    
    private var intFormatter: NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .none
        return f
    }
    
    var body: some View {
        ZStack {
            Form {
                Button("Ferdig") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                VStack(alignment:.center) {
                    
                    DatePicker("Trekningsdato", selection: $jackpot.dato, displayedComponents: .date)
                        .padding(36)
                    
                    HStack {
                        Text("Nummer1: ")
                        TextField("Nr:1", value: $jackpot.nr1, formatter: intFormatter)
                            .padding(.horizontal, 16).background(
                                Capsule().fill(Color.blue.opacity(0.2)))
                    }
                    HStack {
                        Text("Nummer2: ")
                        TextField("Nr:2", value: $jackpot.nr2, formatter: intFormatter)
                            .padding(.horizontal, 16).background(
                                Capsule().fill(Color.blue.opacity(0.2)))
                    }
                    HStack {
                        Text("Nummer3: ")
                        TextField("Nr:3", value: $jackpot.nr3, formatter: intFormatter)
                            .padding(.horizontal, 16).background(
                                Capsule().fill(Color.blue.opacity(0.2)))
                    }
                    HStack {
                        Text("Nummer4: ")
                        TextField("Nr:4", value: $jackpot.nr4, formatter: intFormatter)
                            .padding(.horizontal, 16).background(
                                Capsule().fill(Color.blue.opacity(0.2)))
                    }
                    HStack {
                        Text("Nummer5: ")
                        TextField("Nr:5", value: $jackpot.nr5, formatter: intFormatter)
                            .padding(.horizontal, 16).background(
                                Capsule().fill(Color.blue.opacity(0.2)))
                    }
                    HStack {
                        Text("Nummer6: ")
                        TextField("Nr:6", value: $jackpot.nr6, formatter: intFormatter)
                            .padding(.horizontal, 16).background(
                                Capsule().fill(Color.blue.opacity(0.2)))
                    }
                    HStack {
                        Text("Nummer7: ")
                        TextField("Nr:7", value: $jackpot.nr7, formatter: intFormatter)
                            .padding(.horizontal, 16).background(
                                Capsule().fill(Color.blue.opacity(0.2)))
                    }
                    HStack {
                        Text("Nummer8: ")
                        TextField("Nr:8", value: $jackpot.nr8, formatter: intFormatter)
                            .padding(.horizontal, 16).background(
                                Capsule().fill(Color.blue.opacity(0.2)))
                    }
                    
                    Button("Save jackpot") {
                        jackpot.weekNr = getWeekNumber(from: jackpot.dato)
                        context.insert(jackpot)
                        do {
                            try context.save()
                        } catch {
                            print("Save failed:", error.localizedDescription)
                        }
                    }
                    .disabled((jackpot.nr1 < 1 || jackpot.nr2 < 1 || jackpot.nr3 < 1 || jackpot.nr4 < 1 || jackpot.nr5 < 1 || jackpot.nr6 < 1 || jackpot.nr7 < 1 || jackpot.nr8 < 1 ) || !jackpot.dato.isSaturday)
                    .buttonStyle(.borderedProminent)
                }
            }
            
        }
        .background(Color.blue)
        
    }
    
    func getWeekNumber(from date: Date) -> Int {
        // Use current calendar,, or specify for consistent results
        let calendar = Calendar.current
        // Returns 1-53
        return calendar.component(.weekOfYear, from: date)
    }
}

extension Date {
    var isSaturday: Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday], from: self)
        return components.weekday == 7  // Sunday=1, Monday=2, ..., Saturday=7
    }
}
