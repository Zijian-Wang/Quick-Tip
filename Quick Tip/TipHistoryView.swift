//
//  TipHistoryView.swift
//  Quick Tip
//
//  Created by Zijian Wang on 2023.03.15.
//

import CoreData
import SwiftUI

struct TipHistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Tips.timestamp, ascending: true)],
        animation: .default
    )
    private var tips: FetchedResults<Tips>

    // A computed property that groups the tips by day
    private var tipsByDay: [String: [Tips]] {
        Dictionary(grouping: tips) { tip in
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            return dateFormatter.string(from: tip.timestamp!)
        }
    }

    private let amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()

    var body: some View {
        List {
            ForEach(Array(tipsByDay.keys).sorted().reversed(), id: \.self) { day in
                Section(header: Text(day)) {
                    HStack {
                        HStack {
                            Text("Bill: ")
                            Spacer()
                        }
                        HStack {
                            Text("Tip: ")
                            Spacer()
                        }
                    }
                    .font(.subheadline)
//                    .foregroundStyle(GradientColor())
                    .foregroundColor(.accentColor)

                    ForEach(tipsByDay[day]!, id: \.self) { tip in

                        // MARK: - Individual row

                        HStack(alignment: .firstTextBaseline) {
                            HStack {
                                Text("\(amountFormatter.string(for: tip.userInput) ?? "")")
                                Spacer()
                            }
                            HStack {
                                Text("\(amountFormatter.string(for: tip.amount) ?? "")")
                                Spacer()
                            }
                        }
                        .fontDesign(.monospaced)
                    }.onDelete(perform: deleteItems)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                EditButton()
//                    .foregroundStyle(GradientColor())
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { tips[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct TipHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        TipHistoryView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
