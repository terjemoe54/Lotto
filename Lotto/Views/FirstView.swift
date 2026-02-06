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
    @State private var showRegisterView = false
    @State private var showNumberCountView = false
    @State private var showMyLotteryView = false
    @State private var showListLotteryView = false
    @State private var showFindWinnerView = false
    
    var body: some View {
        NavigationStack {
            ZStack{
                Image("LotteryBackground")
                    .resizable()
                    .scaledToFill()
                    .opacity(0.2)
                    .ignoresSafeArea()
                VStack {
                    Text("LOTTO")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, 20)
                    
                    Spacer()
                    HStack {
                        Spacer()
                        VStack {
                            Button(action: {
                                showMyLotteryView = true
                            }) {
                                Image(systemName: "bitcoinsign.ring.dashed")   // Replace with your asset name
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(.borderedProminent)
                            .padding()
                            Text("Levere")
                        }
                        
                        VStack {
                            Button(action: {
                                showListLotteryView = true
                            }) {
                                Image(systemName: "pencil.and.list.clipboard")   // Replace with your asset name
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(.borderedProminent)
                            .padding()
                            Text("Liste")
                        }
                        Spacer()
                    }
                    Text("Spill")
                        .padding()
                        .font(.largeTitle)
                        .bold()
                    Rectangle()
                        .frame(height: 4)
                        .foregroundStyle(.black)
                    Spacer()
                    
                    HStack {
                        Spacer()
                        VStack {
                            Button(action: {
                                showRegisterView = true
                            }) {
                                Image(systemName: "list.bullet.circle.fill")   // Replace with your asset name
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Text("Registrer Ny")
                            
                        }
                        .padding()
                        
                        VStack {
                            Button(action: {
                                showListRows = true
                            }) {
                                Image(systemName: "pencil.and.list.clipboard")   // Replace with your asset name
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(.borderedProminent)
                            Text("Liste Alle")
                        }
                        .padding()
                        Spacer()
                    }
                    
                    Text("Trekninger" )
                        .padding(.top,10)
                        .font(.largeTitle)
                        .bold()
                    
                    // Spacer()
                    Rectangle()
                        .frame(height: 4)
                        .foregroundStyle(.black)
                    
                    
                    HStack{
                        VStack {
                            Button(action: {
                                showNumberCountView = true
                            }) {
                                Image(systemName: "function")   // Replace with your asset name
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Text("Statistikk")
                        }
                        .padding()
                        
                        VStack {
                            Button(action: {
                                showFindWinnerView = true
                            }) {
                                Image(systemName: "flag.2.crossed")   // Replace with your asset name
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(.borderedProminent)
                            Text("Sjekk Vinner")
                        }
                        .padding()
                        
                    }
                    
                    
                    Spacer()
                }
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
        .sheet(isPresented: $showMyLotteryView) {
            MyLotteryView()
        }
        .sheet(isPresented: $showListLotteryView) {
            ListLotteryView()
        }
        .sheet(isPresented: $showListRows) {
            ListRowsView()
        }
        .sheet(isPresented: $showRegisterView) {
            NewJackpotView()
        }
        .sheet(isPresented: $showNumberCountView) {
            NumberCountsView()
        }
        .sheet(isPresented: $showFindWinnerView) {
            FindWinnerView()
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

