//
//  DataScannerSheet.swift
//  brainwallet
//
//  Created by Kerry Washington on 16/11/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI
//
// struct DataScannerSheet: View {
//    @Binding var scannedText: String?
//    @Binding var scannedBarcode: String?
//    @Binding var isPresented: Bool
//
//    @State private var isScanning = true
//
//    var body: some View {
//        NavigationView {
//            DataScannerView(
//                scannedText: $scannedText,
//                scannedBarcode: $scannedBarcode,
//                isScanning: $isScanning,
//                recognizedDataTypes: [.text(), .barcode()],
//                recognizesMultipleItems: true
//            ) { _ in
//                // Handle tap - dismiss after scanning
//                isPresented = false
//            }
//            .navigationTitle("Scan")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") {
//                        isPresented = false
//                    }
//                }
//
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(isScanning ? "Pause" : "Resume") {
//                        isScanning.toggle()
//                    }
//                }
//            }
//        }
//    }
// }
