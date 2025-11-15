//
//  T.swift
//  brainwallet
//
//  Created by Kerry Washington on 16/11/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

// struct TextOnlyScannerSheet: View {
//    @Binding var scannedTexts: [String]
//    @Binding var isPresented: Bool
//    @State private var currentText: String?
//    @State private var isScanning = true
//
//    var body: some View {
//        NavigationView {
//            DataScannerView(
//                scannedText: $currentText,
//                isScanning: $isScanning,
//                recognizedDataTypes: [.text()],
//                recognizesMultipleItems: true
//            ) { item in
//                if case .text(let text) = item {
//                    scannedTexts.append(text.transcript)
//                    isPresented = false
//                }
//            }
//            .navigationTitle("Scan Text")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Done") {
//                        isPresented = false
//                    }
//                }
//            }
//        }
//    }
// }
