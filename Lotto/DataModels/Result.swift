//
//  JackPot.swift
//  Lotto
//
//  Created by Terje Moe on 04/02/2026.
//
import SwiftUI
import SwiftData

@Model
class Result {
    var dato: Date
    var nr1: Int
    var nr2: Int
    var nr3: Int
    var nr4: Int
    var nr5: Int
    var nr6: Int
    var nr7: Int
    var weekNr: Int = 0
    
    init(
        dato: Date = .now,
        nr1: Int = 0,
        nr2: Int = 0,
        nr3: Int = 0,
        nr4: Int = 0,
        nr5: Int = 0,
        nr6: Int = 0,
        nr7: Int = 0,
        weekNr: Int = 0
    ) {
        self.dato = dato
        self.nr1 = nr1
        self.nr2 = nr2
        self.nr3 = nr3
        self.nr4 = nr4
        self.nr5 = nr5
        self.nr6 = nr6
        self.nr7 = nr7
        self.weekNr = weekNr
    }
}

