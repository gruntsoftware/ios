//
//  BentoSendStyle.swift
//  brainwallet
//
//  Created by Kerry Washington on 10/01/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct BentoSendTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .font(.ibmPlexSansRegular(size: 16.0))
            .frame(height: 24, alignment: .leading)
            .controlSize(.regular)
            .textFieldStyle(.plain)
            .background(.clear)
            .padding(.bottom, 4)
            .padding(.leading, 16)
    }
}

// Source - https://stackoverflow.com/a
// Posted by Valerika
// Retrieved 2026-01-10, License - CC BY-SA 4.0

struct SendTextModalTitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.ibmPlexSansLight(size: 13.0))
            .frame(height: 22, alignment: .topLeading)
            .padding(.leading, 16)
    }
}

struct SendTextModalSubTitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.ibmPlexSansLight(size: 12.0))
            .frame(height: 22, alignment: .topLeading)
            .padding(.leading, 16)
    }
}

struct SendTextModalFooterModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.ibmPlexSansLight(size: 11.0))
            .frame(height: 15, alignment: .leading)
    }
}

struct SendTextLeaderModifier<T>: ViewModifier {

    @Binding
    var userPrefersDarkTheme: Bool

    @Binding
    var dataValue: T

    func body(content: Content) -> some View {
        content
.font(.ibmPlexSansLight(size: 14.0))
            .foregroundColor(userPrefersDarkTheme ? .white : .black)
            .frame(height: 15, alignment: .leading)
        LeaderEllipseView(userPrefersDarkTheme: $userPrefersDarkTheme)
        Text(formatDataValue(dataValue))
            .font(.ibmPlexSansBold(size: 14.0))
            .foregroundColor(userPrefersDarkTheme ? .white : .black)
            .frame(height: 15, alignment: .leading)
    }

    // Format the value based on its type
    private func formatDataValue(_ value: T) -> String {
        switch value {
        case let litecoinValue as Litecoin:
            return "\(litecoinValue.rawValue) ŁTC"
        case let uint64Value as UInt64:
            return "\(uint64Value)"
        case let intValue as Int:
            return "\(intValue)"
        case let doubleValue as Double:
            return String(format: "%6.6f", doubleValue)
        case let stringValue as String:
            return "\(stringValue)"
        case let boolValue as Bool:
            return "\(boolValue ? "YES" : "NO")"
        default:
            return "Default value: \(value)"
        }
    }
}

struct SendFiatAmountLeaderModifier: ViewModifier {

    @Binding
    var userPrefersDarkTheme: Bool

    @Binding
    var fiatValue: Double

    @Binding
    var currencyCode: GlobalCurrency

    func body(content: Content) -> some View {
        content
            .font(.ibmPlexSansLight(size: 14.0))
            .foregroundColor(userPrefersDarkTheme ? .white : .black)
            .frame(height: 15, alignment: .leading)
        LeaderEllipseView(userPrefersDarkTheme: $userPrefersDarkTheme)
        Text(formattedDataValue(fiatValue))
            .font(.ibmPlexSansBold(size: 14.0))
            .foregroundColor(userPrefersDarkTheme ? .white : .black)
            .frame(height: 15, alignment: .leading)
    }

    // Format the value based on its type
    private func formattedDataValue(_ value: Double) -> String {
        let code = currencyCode.code
        return "\(String(format: "%6.3f", value)) \(code)"
    }
}

struct SendTextPrepTitleModifier: ViewModifier {

    @Binding
    var userPrefersDarkTheme: Bool

    func body(content: Content) -> some View {
        content
            .font(.ibmPlexSansSemiBold(size: 15.0))
            .foregroundColor(userPrefersDarkTheme ? .white : .black)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SendTextPrepDataModifier: ViewModifier {

    @Binding
    var userPrefersDarkTheme: Bool

    func body(content: Content) -> some View {
        content
            .font(.ibmPlexSansThin(size: 14.0))
            .foregroundColor(userPrefersDarkTheme ? .white : .black)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SendCompletedTitleModifier: ViewModifier {

    @Binding
    var userPrefersDarkTheme: Bool

    func body(content: Content) -> some View {
        content
            .font(.ibmPlexSansBold(size: 24.0))
            .lineLimit(1)
            .minimumScaleFactor(0.9)
            .foregroundColor(userPrefersDarkTheme ? .white : .black)
    }
}

struct SendCompletedSubTitleModifier: ViewModifier {

    @Binding
    var userPrefersDarkTheme: Bool

    func body(content: Content) -> some View {
        content
            .font(.ibmPlexSansThin(size: 15.0))
            .foregroundColor(userPrefersDarkTheme ? .white : .black)
            .frame(maxWidth: .infinity, alignment: .center)
            .kerning(2.0)
            .padding([.top, .bottom], 10)
            .padding([.leading, .trailing], 15)
    }
}

// Source - https://stackoverflow.com/a
// Posted by Dad, modified by community. See post 'Timeline' for change history
// Retrieved 2026-01-10, License - CC BY-SA 4.0

extension Image {
    func ltcIconImageModifier() -> some View {
        self
            .resizable()
            .renderingMode(.template)
            .frame(width: 28.0, height: 28.0)
   }
    func sendButtonImageModifier() -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.black)
            .frame(width: 14.0, height: 14.0)
   }
}
