//
//  ContentView.swift
//  Lotto
//
//  Created by Terje Moe on 30/01/2026.
//

import SwiftUI
import SwiftData

struct FirstView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \JackPot.dato, order: .forward) private var jackpots: [JackPot]
    @State private var showListRows = false
    
    var body: some View {
       NavigationStack {
           VStack {
              Button("List Alle Poster") {
               showListRows = true
              }
              .buttonStyle(.borderedProminent)
           }
        }
        .task {  // Load Jackpot rows from lotto.json file if Swiftdata is empty
            if self.jackpots.isEmpty {
                let jackpots = loadJackpots()
                for jackpot in jackpots {
                    context.insert(jackpot)
                    jackpot.weekNr = getWeekNumber(from: jackpot.dato)
                }
            }
        }
        .sheet(isPresented: $showListRows) {
        ListRowsView()
        }
    }
    
    func loadJackpots() -> [JackPot] {
        guard let url = Bundle.main.url(forResource: "lotto", withExtension: "json") else {
            print ("Could not find lotto.json in bundle")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let jackpots = try decoder.decode([JackPot].self, from: data)
            return jackpots
        } catch  {
            print("Failed to decode lotto.json: \(error)")
            return []
        }
    }
  
    func getWeekNumber(from date: Date) -> Int {
        // Use current calendar,, or specify for consistent results
        let calendar = Calendar.current
        // Returns 1-53
        return calendar.component(.weekOfYear, from: date)
    }
    
}
   

#Preview {
    FirstView()
        .modelContainer(for: JackPot.self, inMemory: true)
}

