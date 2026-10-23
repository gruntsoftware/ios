//
//  SetTrustedNodeIPModalView.swift
//  brainwallet
//
//  Created by Kerry Washington on 24/09/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct SetTrustedNodeIPModalView: View {

    @Binding
    var shouldPresent: Bool

    var userPrefersDarkTheme: Bool

    @State
    private var ipAddress: String = ""

    @State
    private var port: String = ""

    private let fieldHeight: CGFloat = 66.0
    private let buttonHeight: CGFloat = 56.0

    init(shouldPresent: Binding<Bool>, userPrefersDarkTheme: Bool) {
        _shouldPresent = shouldPresent
        self.userPrefersDarkTheme = userPrefersDarkTheme
        _ipAddress = State(initialValue: UserDefaults.userTrustedNodeIpAddress ?? "")
        _port = State(initialValue: UserDefaults.userTrustedNodePort ?? "")
    }

    private var canSave: Bool {
        Self.isValidIPv4(ipAddress) && Self.isValidPort(port)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 22.0) {

            Text(String(localized: "Set trusted Litecoin node / SPV Peer"))
                .modifier(BWIPSBold(size: 22.0, lineLimit: 2))
                .foregroundColor(BrainwalletColor.modalPrimaryText(userPrefersDarkTheme: userPrefersDarkTheme))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(String(localized: "Enter the IPv4 address and port of the Litecoin node your Brainwallet should sync with."))
                .modifier(BWIPSRegular(size: 15.0, lineLimit: 3))
                .foregroundColor(BrainwalletColor.modalSecondaryText(userPrefersDarkTheme: userPrefersDarkTheme))
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(alignment: .top, spacing: 12.0) {
                OutlinedNodeField(label: String(localized: "IP address"),
                                  placeholder: "1.1.1.1",
                                  text: $ipAddress,
                                  keyboardType: .decimalPad,
                                  height: fieldHeight,
                                  userPrefersDarkTheme: userPrefersDarkTheme)
                    .frame(maxWidth: .infinity)

                OutlinedNodeField(label: String(localized: "Port"),
                                  placeholder: "9333",
                                  text: $port,
                                  keyboardType: .numberPad,
                                  height: fieldHeight,
                                  userPrefersDarkTheme: userPrefersDarkTheme)
                    .frame(width: 110.0)
            }

            Button(action: save) {
                Text(String(localized: "Save trusted node"))
                    .modifier(BWIPSSemiBold(size: 17.0))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: buttonHeight)
                    .background(
                        Capsule()
                            .fill(BentoColor.purple2.opacity(canSave ? 1.0 : 0.4))
                    )
            }
            .buttonStyle(.plain)
            .disabled(!canSave)
        }
        .padding(.horizontal, 24.0)
        .padding(.top, 28.0)
        .padding(.bottom, 20.0)
        .frame(maxWidth: .infinity, alignment: .top)
    }

    private func save() {
        guard canSave else { return }
        UserDefaults.userTrustedNodeIpAddress = ipAddress
        UserDefaults.userTrustedNodePort = port
        shouldPresent = false
    }

    private static func isValidIPv4(_ value: String) -> Bool {
        let parts = value.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count == 4 else { return false }
        return parts.allSatisfy { part in
            guard let octet = Int(part), (0 ... 255).contains(octet) else { return false }
            return String(octet) == part // rejects leading zeros / stray characters
        }
    }

    private static func isValidPort(_ value: String) -> Bool {
        guard let number = Int(value) else { return false }
        return (1 ... 65535).contains(number)
    }
}

/// A bordered text field whose label sits notched into the top border,
/// matching the outlined-field style from the Trusted Node design.
private struct OutlinedNodeField: View {
    let label: String
    let placeholder: String

    @Binding
    var text: String

    let keyboardType: UIKeyboardType
    let height: CGFloat
    let userPrefersDarkTheme: Bool

    private var borderColor: Color {
        BrainwalletColor.modalSecondaryText(userPrefersDarkTheme: userPrefersDarkTheme)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 12.0)
                .stroke(borderColor, lineWidth: 1.0)

            TextField("",
                      text: $text,
                      prompt: Text(placeholder)
                          .foregroundColor(borderColor.opacity(0.6)))
                .keyboardType(keyboardType)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .modifier(BWIPSSemiBold(size: 19.0))
                .foregroundColor(BrainwalletColor.modalPrimaryText(userPrefersDarkTheme: userPrefersDarkTheme))
                .padding(.horizontal, 14.0)
                .padding(.top, 20.0)
                .padding(.bottom, 10.0)

            Text(label)
                .modifier(BWIPSRegular(size: 13.0))
                .foregroundColor(borderColor)
                .padding(.horizontal, 4.0)
                .background(BrainwalletColor.modalBackground(userPrefersDarkTheme: userPrefersDarkTheme))
                .offset(x: 12.0, y: -9.0)
        }
        .frame(height: height)
    }
}
