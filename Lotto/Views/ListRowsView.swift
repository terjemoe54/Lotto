//
//  ListRows.swift
//  Lotto
//
//  Created by Terje Moe on 02/02/2026.
//

import SwiftUI
import SwiftData

/// Shows all registered draws (JackPot) and lets the user delete them.
struct ListRowsView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    @Query(sort: \JackPot.dato, order: .reverse) private var jackpots: [JackPot]
    @State private var rowToDelete: JackPot? = nil
    @State private var showConfirmation = false
    
    var body: some View {
        Button("Ferdig") {
            dismiss()
        }
        .buttonStyle(.borderedProminent)
        
        Text("Antall Trekninger: \(jackpots.count)")
        ZStack {
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
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    
                    Button(role: .destructive) {
                        rowToDelete = jackpot
                        showConfirmation.toggle()
                        
                        // context.delete(jackpot)
                    }
                }
            }
        }
        .confirmationDialog(
            "Slett",
            isPresented: $showConfirmation,
            titleVisibility: .visible,
            presenting: rowToDelete ,
            actions: { item in
                Button(role: .destructive) {
                    withAnimation {
                        context.delete(item)
                        try? context.save()
                    }
                } label: {
                    Text("Slett")
                }
                Button(role: .confirm) {
                    
                } label: {
                    Text("Avbryt")
                }
            },
            message: { item in
                Text("Er du sikker på at du vil slette trekningen \(formattedDate(item.dato))?")
            })
        
    }
    /// Formats date to the app's display format (dd.MM.yyyy).
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
