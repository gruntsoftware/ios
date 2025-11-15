//
//  BarcodeOnlyScannerSheet.swift
//  brainwallet
//
//  Created by Kerry Washington on 16/11/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

// struct BarcodeOnlyScannerSheet: View {
//    @Binding var scannedCode: String?
//    @Binding var isPresented: Bool
//    @State private var isScanning = true
//
//    var body: some View {
//        NavigationView {
//            DataScannerView(
//                scannedBarcode: $scannedCode,
//                isScanning: $isScanning,
//                recognizedDataTypes: [.barcode(symbologies: [.qr, .ean13, .code128])],
//                recognizesMultipleItems: false
//            ) { _ in
//                isPresented = false
//            }
//            .navigationTitle("Scan Barcode")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") {
//                        isPresented = false
//                    }
//                }
//            }
//        }
//    }
// }
