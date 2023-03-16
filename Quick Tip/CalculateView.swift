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
    @FocusState private var defaultFocusInput: focusArea?
    @State private var animateGradient: Bool = true
    @State private var showCopyNotifyToast: Bool = false
    private var showCopyNotifySpeed: CGFloat = 0.2
    private var showCopyNotifyTime: CGFloat = 0.8

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

    private enum focusArea {
        case billAmount, customTipAmount
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
            // MARK: - Tip Amount

            ZStack {
                BoarderedRectangle(radius: 15, lineWidth: 4, animateGradient: true)

                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Spacer()
                        NavigationLink(destination: TipHistoryView()) {
                            Image(systemName: "calendar.badge.clock.rtl")
                        }
                    }.font(.title)

                    Spacer()

                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .firstTextBaseline) {
                            Text("Tip: ")
                                .fontWeight(.medium)
                                .font(.title2)
                            
                            Spacer()
                            
                            Text("Copied!")
                                .font(.callout)
                                .scaleEffect(showCopyNotifyToast ? 1 : 0.2)
                                .opacity(showCopyNotifyToast ? 1 : 0)
                                .animation(.easeIn(duration: showCopyNotifySpeed), value: showCopyNotifyToast)
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Spacer()
                            Text("\(Self.currencyFormatter.string(for: tipAmount)!)")
                                .font(.system(size: 68, weight: .bold, design: .monospaced))
                                .multilineTextAlignment(.trailing)
//                                .frame(maxWidth: .infinity)
                        }
                        .onTapGesture {
                            // Copy tip amount
                            UIPasteboard.general.string = String(tipAmount)
                            showCopyNotifyToast = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + showCopyNotifyTime) {
                                showCopyNotifyToast = false
                            }
                        }
                    }
                }
                .foregroundStyle(GradientColor())
                .padding(25)
            }
            .onTapGesture {
                defaultFocusInput = nil
            }

            Spacer()

            // MARK: - Tip Percentage Picker

            VStack(alignment: .leading) {
                HStack {
                    Text("Tip Percentage: ")
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundStyle(GradientColor())

                    if selectedTipIndex == tipPercentages.count {
                        TextField("Enter custom tip percentage", text: $customTipValue)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .padding(.trailing, 8)
                            .textFieldStyle(TextFieldEndWith(suffix: "%"))
                            .font(.callout)
                            .frame(height: 16)
                            .focused($defaultFocusInput, equals: .customTipAmount)
                            .onAppear {
                                defaultFocusInput = .customTipAmount
                            }
                    }
                }

                Picker(selection: $selectedTipIndex, label: Text("Select tip percentage")) {
                    ForEach(0 ..< tipPercentages.count, id: \.self) { index in
                        Text("\(tipPercentages[index])%")
                    }
                    Text(customTipPlaceholder)
                        .tag(tipPercentages.count)
                }
                .pickerStyle(.segmented)

            }.padding(.vertical)

            HStack(alignment: .center) {
                // MARK: - Bill Amount

                VStack(alignment: .leading) {
                    Text("Bill Amount:")
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundStyle(GradientColor())

                    TextField("Enter Here", text: $userInput)
                        .keyboardType(.decimalPad)
                        .font(.title3)
                        .textFieldStyle(TextFieldUnderlined())
                        .focused($defaultFocusInput, equals: .billAmount)
                        .onAppear {
                            self.defaultFocusInput = .billAmount
                        }
                }

                Spacer()

                // MARK: - Button -> record tip

                Button {
                    saveNewTip(
                        userInput: Float(userInput)!,
                        tipPercent: selectedTipPercent,
                        tipAmount: tipAmount
                    )
                    resetValues()
                    defaultFocusInput = nil
                } label: {
                    HStack {
                        Text("Record Tip")
                        Image(systemName: "plus.circle.fill").font(.body)
                    }
                    .foregroundColor(.accentColor)
                }
                .buttonStyle(ButtonStyleBorder(isDisabled: userInput == ""))
            }
        }
        .padding()
        .navigationBarTitle("Quick Tip")
        .navigationBarTitleDisplayMode(.inline)
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
    }
}

struct CalculateView_Previews: PreviewProvider {
    static var previews: some View {
        CalculateView()
    }
}