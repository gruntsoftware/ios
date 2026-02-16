//
//  BackgroundRectangle.swift
//  brainwallet
//
//  Created by Kerry Washington on 14/02/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct BackgroundRectangle: View {
    @Binding
    var userPrefersDarkTheme: Bool
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(userPrefersDarkTheme ? .white : BentoColor.grayBorder , lineWidth: 1)
            .frame(height: 60)
    }
}
