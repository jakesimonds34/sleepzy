//
//  SwiftUI+Modifiers.swift
//  OpaCouponUser
//
//  Created by SD on 04/12/2024.
//

import SwiftUI

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
    
}


extension View {
    
    /// Disable pull to refresh for all subviews.
    /// - Returns: The original `View`
    func disableRefreshable() -> some View {
        self.environment(\EnvironmentValues.refresh as! WritableKeyPath<EnvironmentValues, RefreshAction?>, nil)
    }
}




private struct ClearTextButtonViewModifier: ViewModifier {
    /// A binding towards the text that we'll monitor
    /// to determine whether or not we show the clear button.
    @Binding var text: String

    /// An optional clear handler to perform additional actions
    /// when the text is cleared.
    var onClearHandler: (() -> Void)? = nil

    public func body(content: Content) -> some View {
        HStack {
            /// References your input `Content`.
            /// Most likely the `TextField`.
            content

            /// The `ZStack` allows us to place this button
            /// on top of the input `Content`.
            HStack {
                Button {
                    /// Clear out the text using the @Binding property.
                    text.removeAll()
                    /// Call the optional clear handler to allow
                    /// for further customization.
                    onClearHandler?()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(.placeholderText))
                        .padding(.trailing, 10)
                }.buttonStyle(.plain)
            }
            /// Only show the button if there's actually text input.
            .opacity(text.isEmpty ? 0.0 : 1.0)
        }
    }
}

extension View {

    /// Adds a clear button on top of the input view. The button clears the given input
    /// text binding.
    /// - Parameters:
    ///   - text: The text binding to clear when the button is tapped.
    ///   - onClearHandler: An optional clear handler that will be called on clearance.
    func clearButton(text: Binding<String>, onClearHandler: (() -> Void)? = nil) -> some View {
        modifier(ClearTextButtonViewModifier(text: text, onClearHandler: onClearHandler))
    }
}



// Make a struct that conforms to the LabelStyle protocol,
//and return a view that has the title and icon switched in a HStack
struct TrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
            configuration.icon
        }
    }
}

extension LabelStyle where Self == TrailingIconLabelStyle {
    static var trailingIcon: TrailingIconLabelStyle {
        TrailingIconLabelStyle()
    }
}

// //Usage
// Label("Lightning", systemImage: "bolt.fill").labelStyle(TrailingIconLabelStyle())






struct SwiftUI_Modifiers_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Sample 1")
                .if(Bool.random()) { view in
                    view.strikethrough()
                }
            Text("Sample 2")
                .if(Bool.random()) { view in
                    view.strikethrough()
                }
            Text("Sample 3")
                .if(Bool.random()) { view in
                    view.strikethrough()
                }
            Text("Sample 4")
                .if(Bool.random(), transform: { $0.strikethrough() })

        }
    }
}
