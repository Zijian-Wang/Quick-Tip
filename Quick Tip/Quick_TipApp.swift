//
//  Quick_TipApp.swift
//  Quick Tip
//
//  Created by Zijian Wang on 2023.03.15.
//

import SwiftUI

@main
struct Quick_TipApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
