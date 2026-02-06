//
//  TextFieldFormView.swift
//  DiwanV2
//
//  Created by Khaled on 24/07/2024.
//  Copyright © 2024 Master Team. All rights reserved.
//

import SwiftUI

struct TextFieldFormView: View {
    let title: LocalizedStringKey?
    let placeholder: LocalizedStringKey
    var leadingImage: ImageResource? = nil
    var trailingImage: ImageResource? = nil
    @Binding var value: String
    let isMandatory: Bool
    var error: Binding<LocalizedStringKey?>?
    var type: FieldType = .text
    var showTitle: Bool = true
    
    @State private var isShowPassword = false
    @State private var _error: LocalizedStringKey?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title section
            if let title, showTitle {
                Text(title)
                    .font(.appRegular(size: 11))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.white)
            }
            
            // Main input field
            VStack(spacing: 6) {
                HStack(spacing: 12) {
                    // Optional leading image
                    if let leadingImage {
                        Image(leadingImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 24, maxHeight: 24)
                            .foregroundStyle(Color.white.opacity(value.isEmpty ? 0.5 : 1))
                    }
                    
                    // Dynamic input field with modifiers
                    let field = inputField
                        .lineLimit(type == .textView ? 8...12 : 1...1)
                        .keyboardType(type.keyboardType)
                        .font(.appRegular(size: 22))
                        .foregroundStyle(.white)
                        .placeholder(when: value.isEmpty) {
                            Text(placeholder)
                                .foregroundColor(.white.opacity(0.5))
                        }
                    
                    // Apply onChange depending on iOS version
                    if #available(iOS 17.0, *) {
                        field
                            .onChange(of: $value.wrappedValue) { oldValue, newValue in
                                handleInputChange(newValue)
                                validateField(newValue)
                            }
                    } else {
                        field
                            .onChange(of: value) { newValue in
                                handleInputChange(newValue)
                                validateField(newValue)
                            }
                    }
                    
                    if let trailingImage {
                        Image(trailingImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 24, maxHeight: 24)
                            .foregroundStyle(Color.white.opacity(value.isEmpty ? 0.5 : 1))
                    }
                }
                .padding(.vertical, 5)
                // .padding(.horizontal, 20)
                .frame(minHeight: 30)
                .background(Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                // .borderView(cornerRadius: 8, color: .stroke)
                
                Divider()
                    .background(.white)
            }
            // Error message display
            // ErrorField(error: error?.wrappedValue ?? _error)
        }
//        .environment(\.colorScheme, .light)
    }
    
    private func handleInputChange(_ newValue: String) {
        switch type {
        case .number, .percent, .currency:
            // Restrict input to integers for number/percent/currency fields
            $value.wrappedValue = newValue.onlyInteger()
        default:
            break
        }
    }
    
    private func validateField(_ newValue: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            withAnimation {
                if isMandatory, newValue.isEmpty {
                    _error = "This field is required"
                } else {
                    _error = nil
                }
                error?.wrappedValue = _error
            }
        }
    }
    
    @ViewBuilder
    private var inputField: some View {
        switch type {
        case .password:
            HStack {
                if isShowPassword {
                    TextField(placeholder, text: $value, axis: type.axis)
                } else {
                    SecureField(placeholder, text: $value)
                }
                // Add the eye button only for password fields
                Button(action: { isShowPassword.toggle() }) {
                    Image(systemName: (isShowPassword ? "eye.slash.fill" : "eye.fill"))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color.white.opacity(value.isEmpty ? 0.3 : 0.5))
                }
            }
        case .textView:
            TextField(placeholder, text: $value, axis: type.axis)
                .onSubmit(of: .text) { value += "\n" }
        default:
            TextField(placeholder, text: $value, axis: type.axis)
        }
    }
    
    enum FieldType {
        case text, textView, number, percent, currency, email, phone, password
        
        var axis: Axis {
            switch self {
            case .textView:
                return .vertical
            default:
                return .horizontal
            }
        }
        
        var keyboardType: UIKeyboardType {
            switch self {
            case .currency, .number, .percent, .phone:
                return .asciiCapableNumberPad
            case .email:
                return .emailAddress
            default:
                return .default
            }
        }
    }
}

struct TextFieldFormView_Previews: PreviewProvider {
    @State static var text = ""
    static var previews: some View {
        VStack(spacing: 50) {
            TextFieldFormView(
                title: "Testing Title",
                placeholder: "Title",
                value: $text,
                isMandatory: true,
                type: .text
            )
            TextFieldFormView(
                title: "Testing Password",
                placeholder: "Password",
                value: $text,
                isMandatory: true,
                type: .password
            )
            TextFieldFormView(
                title: "Testing TextField",
                placeholder: "TextField",
                value: $text,
                isMandatory: true,
                type: .textView
            )
        }
        .padding()
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            if shouldShow {
                placeholder()
                    .font(.appRegular(size: 22))
            }
            self
        }
    }
}
