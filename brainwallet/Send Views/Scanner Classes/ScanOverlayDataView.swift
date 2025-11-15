//
//  ScanOverlayDataView.swift
//  brainwallet
//
//  Created by Kerry Washington on 16/11/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct ScanOverlayDataView: View {
    @Binding var scannedText: String

    init(scannedText: Binding<String>) {
        _scannedText = scannedText
    }
        var body: some View {

            Text("Scanned Text: \(scannedText)")
         }
    }
