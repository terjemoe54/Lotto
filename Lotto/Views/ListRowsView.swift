//
//  ListRows.swift
//  Lotto
//
//  Created by Terje Moe on 02/02/2026.
//

import SwiftUI
import SwiftData

struct ListRowsView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    @Query(sort: \JackPot.dato, order: .reverse) private var jackpots: [JackPot]
    
    var body: some View {
        Button("Ferdig") {
            dismiss()
        }
        .buttonStyle(.borderedProminent)
        
        Text("Antall Trekninger: \(jackpots.count)")
        
        List(jackpots) { jackpot in
            VStack(alignment: .leading) {
                Text(formattedDate(jackpot.dato))
                Text("Uke: \(jackpot.weekNr)")
                    .font(.headline)
                HStack {
                    Text("\(jackpot.nr1)")
                    Text("\(jackpot.nr2)")
                    Text("\(jackpot.nr3)")
                    Text("\(jackpot.nr4)")
                    Text("\(jackpot.nr5)")
                    Text("\(jackpot.nr6)")
                    Text("\(jackpot.nr7)")
                    Text("\(jackpot.nr8)")
                }
            }
        }
    }
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "nb_NO")
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
    
    
    
}

#Preview {
    ListRowsView()
}
