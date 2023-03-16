//
//  CalculateView.swift
//  Quick Tip
//
//  Created by Zijian Wang on 2023.03.15.
//

import CoreData
import SwiftUI

struct CalculateView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var userInput: String = ""
    @State private var selectedTipIndex: Int = 0
    @State private var customTipValue: String = ""
    @FocusState private var defaultFocusInput: Bool

    private let tipPercentages = [10, 15, 20, 25]
    private let customTipPlaceholder = "Custom"

    private var selectedTipPercent: Int {
        if selectedTipIndex < tipPercentages.count {
            return tipPercentages[selectedTipIndex]
        } else {
            return Int(customTipValue) ?? 0
        }
    }

    private var tipAmount: Float {
        let input = Float(userInput) ?? 0
        return input * Float(selectedTipPercent) / 100.0
    }

    private func resetValues() {
        userInput = ""
        selectedTipIndex = 0
        customTipValue = ""
    }

    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = Locale.current.currencySymbol ?? "$"
        return formatter
    }()

    // MARK: - UI

    var body: some View {
        VStack {
            // MARK: - Bill Amount

            VStack(alignment: .leading) {
                Text("Bill Amount: ")
                    .foregroundColor(.accentColor).fontWeight(.medium)
//                    .fontDesign(.monospaced)
                TextField("Enter the bill amount", text: $userInput)
                    .keyboardType(.decimalPad)
                    .font(.largeTitle)
                    .textFieldStyle(TextFieldUnderlined())
                    .focused($defaultFocusInput, equals: true)
                    .onAppear{
                        self.defaultFocusInput = true
                    }
            }.padding(.vertical)

            // MARK: - Tip Percentage Picker

            VStack(alignment: .leading) {
                Text("Tip Percentage: ")
                    .foregroundColor(.accentColor).fontWeight(.medium)
//                    .fontDesign(.monospaced)
                Picker(selection: $selectedTipIndex, label: Text("Select tip percentage")) {
                    ForEach(0 ..< tipPercentages.count, id: \.self) { index in
                        Text("\(tipPercentages[index])%")
                    }
                    Text(customTipPlaceholder)
                        .tag(tipPercentages.count)
                }
                .pickerStyle(.segmented)

                if selectedTipIndex == tipPercentages.count {
                    TextField("Enter custom tip percentage", text: $customTipValue)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .padding(.trailing, 8)
                        .textFieldStyle(TextFieldEndWith(suffix: "%"))
                        .font(.callout)
                }
            }.padding(.vertical)

            Spacer()

            // MARK: - Bottom

            Divider()
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text("Tip amount: ")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("\(Self.currencyFormatter.string(for: tipAmount)!)")
                        .font(.largeTitle)
                        .foregroundColor(.accentColor)
                        .fontWeight(.bold)
                }

                Spacer()

                Button {
                    saveNewTip(
                        userInput: Float(userInput)!,
                        tipPercent: selectedTipPercent,
                        tipAmount: tipAmount
                    )
                    resetValues()
                } label: {
                    HStack {
                        Text("Record Tip")
                        Image(systemName: "plus.circle.fill").font(.body)
                    }
                }
                .buttonStyle(ButtonStyleBorder(cornerRadius: 8, strokeColor: .secondary, lineWidth: 1, isDisabled: userInput == ""))
//                .disabled(infoNotFilled)
            }
        }
        .padding()
        .navigationBarTitle("Quick Tip")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    TipHistoryView()
                } label: {
                    Image(systemName: "calendar")
                        .foregroundColor(.accentColor)
                }
            }
        }
    }

    private func saveNewTip(userInput: Float, tipPercent: Int, tipAmount: Float) {
        let newTip = Tips(context: viewContext)
        newTip.userInput = userInput
        newTip.timestamp = .now
        newTip.tipPercent = Int16(tipPercent)
        newTip.amount = tipAmount

        do {
            try viewContext.save()
        } catch {
            print("Error saving tip: \(error.localizedDescription)")
        }

        // Navigagte to TipHistoryView
    }
}

struct CalculateView_Previews: PreviewProvider {
    static var previews: some View {
        CalculateView()
    }
}
