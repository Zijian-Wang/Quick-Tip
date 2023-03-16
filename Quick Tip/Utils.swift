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

func GradientColor() -> LinearGradient {
    return LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
}

struct ButtonStyleBorder: ButtonStyle {
    var cornerRadius: CGFloat = 8
    var strokeColor: Color = .secondary
    var lineWidth: CGFloat = 2
    var animation: Bool = true
    var isDisabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(
//                BoarderedRectangle(radius: cornerRadius, lineWidth: lineWidth)
                RoundedRectangle(cornerRadius: cornerRadius).strokeBorder(style: StrokeStyle(lineWidth: lineWidth))
                    .foregroundColor(.accentColor)
            )
            .scaleEffect(animation && configuration.isPressed ? 0.95 : 1.0)
            .opacity(isDisabled ? 0.5 : 1)
    }
}

struct BoarderedRectangle: View {
    var radius: CGFloat
    var lineWidth: CGFloat
    @State var animateGradient: Bool = false
    var speed: Double = 5

    var body: some View {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
            .strokeBorder(GradientColor(), style: StrokeStyle(lineWidth: lineWidth))
            .hueRotation(.degrees(animateGradient ? 45 : 0))
            .onAppear {
                withAnimation(.easeInOut(duration: speed).repeatForever()) {
                    animateGradient.toggle()
                }
            }
    }
}
