//
//  LottoApp.swift
//  Lotto
//
//  Created by Terje Moe on 30/01/2026.
//

import SwiftUI
import SwiftData

@main
struct StartApp: App {
    var body: some Scene {
        WindowGroup {
            FirstView()
        }
        .modelContainer(for: JackPot.self)
    }
    init() {
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }
}
