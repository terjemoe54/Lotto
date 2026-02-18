//
//  ListMyCupons.swift
//  Lotto
//
//  Created by Terje Moe on 06/02/2026.
//

import SwiftUI
import SwiftData

/// Shows all submitted rows and lets the user delete them.
struct ListLotteryView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    @Query(sort: \Result.dato, order: .reverse) private var results: [Result]
    @State private var rowToDelete: Result? = nil
    @State private var showConfirmation = false
    
    var body: some View {
        
        Button("Ferdig") {
            dismiss()
        }
        .buttonStyle(.borderedProminent)
        
        Text("Antall Rekker: \(results.count)")
        ZStack {
            List(results) { result in
                VStack(alignment: .leading) {
                    Text(formattedDate(result.dato))
                    Text("Uke: \(result.weekNr)")
                        .font(.headline)
                    HStack {
                        Text("\(result.nr1)")
                        Text("\(result.nr2)")
                        Text("\(result.nr3)")
                        Text("\(result.nr4)")
                        Text("\(result.nr5)")
                        Text("\(result.nr6)")
                        Text("\(result.nr7)")
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        rowToDelete = result
                        showConfirmation.toggle()
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
    ListLotteryView()
}
