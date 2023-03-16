//
//  Utils.swift
//  Quick Tip
//
//  Created by Zijian Wang on 2023.03.15.
//

import Foundation
import SwiftUI

struct TextFieldEndWith: TextFieldStyle {
    var suffix: String
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack(spacing: 3) {
            configuration
            Text(suffix)
        }
    }
}

struct TextFieldUnderlined: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        VStack(spacing: 3) {
            configuration
            Divider()
        }
    }
}

struct ButtonStyleBorder: ButtonStyle {
    var cornerRadius: CGFloat = 5
    var strokeColor: Color = .secondary
    var lineWidth: CGFloat = 2
    var animation: Bool = true
    var isDisabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(strokeColor, lineWidth: lineWidth)
            )
            .scaleEffect(animation && configuration.isPressed ? 0.95 : 1.0)
            .opacity(isDisabled ? 0.5 : 1)
    }
}
