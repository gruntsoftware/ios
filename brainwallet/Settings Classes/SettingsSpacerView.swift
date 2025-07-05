//
//  SettingsSpacerView.swift
//  brainwallet
//
//  Created by Kerry Washington on 19/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct SettingsSpacerView: View {
    let rowBackgroundColor: Color

    init(rowBackgroundColor: Color? = nil) {
        self.rowBackgroundColor = rowBackgroundColor ?? BrainwalletColor.surface
    }

    var body: some View {
        NavigationStack {
            GeometryReader { _ in
                ZStack {
                    rowBackgroundColor.edgesIgnoringSafeArea(.all)
                }
            }
        }
    }
}
