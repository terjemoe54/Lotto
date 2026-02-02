//
//  Model.swift
//  Lotto
//
//  Created by Terje Moe on 31/01/2026.
//
import SwiftUI
import SwiftData

@Model
class JackPot: Decodable {
    @Attribute(.unique) var dato: Date
    var nr1: Int
    var nr2: Int
    var nr3: Int
    var nr4: Int
    var nr5: Int
    var nr6: Int
    var nr7: Int
    var nr8: Int
    var weekNr: Int = 0
    
    private enum CodingKeys: String, CodingKey {
        case dato = "dato"
        case nr1, nr2, nr3, nr4, nr5, nr6, nr7, nr8
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // 1. Decode the date as a String first
        let dateString = try container.decode(String.self, forKey: .dato)
        
        // 2. Set up a formatter to match "02.01.2016"
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
         
        // 3. Convert string to Date
        if let date = formatter.date(from: dateString) {
            self.dato = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .dato, in: container, debugDescription: "Date string does not match format dd.MM.yyyy")
        }
        
        // Decode integers as normal
        self.nr1 = try container.decode(Int.self, forKey: .nr1)
        self.nr2 = try container.decode(Int.self, forKey: .nr2)
        self.nr3 = try container.decode(Int.self, forKey: .nr3)
        self.nr4 = try container.decode(Int.self, forKey: .nr4)
        self.nr5 = try container.decode(Int.self, forKey: .nr5)
        self.nr6 = try container.decode(Int.self, forKey: .nr6)
        self.nr7 = try container.decode(Int.self, forKey: .nr7)
        self.nr8 = try container.decode(Int.self, forKey: .nr8)
    }
    
}
