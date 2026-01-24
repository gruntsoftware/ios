//
//  DataScannerExampleView.swift
//  brainwallet
//
//  Created by Kerry Washington on 16/11/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI
import VisionKit
//
// struct DataScannerExampleView: View {
//    @State private var scannedText: String?
//    @State private var scannedBarcode: String?
//    @State private var isScanning = false
//    @State private var showScanner = false
//
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 20) {
//                if let text = scannedText {
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Scanned Text:")
//                            .font(.headline)
//                        Text(text)
//                            .padding()
//                            .background(Color.gray.opacity(0.1))
//                            .cornerRadius(8)
//                    }
//                    .padding()
//                }
//
//                if let barcode = scannedBarcode {
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Scanned Barcode:")
//                            .font(.headline)
//                        Text(barcode)
//                            .padding()
//                            .background(Color.gray.opacity(0.1))
//                            .cornerRadius(8)
//                    }
//                    .padding()
//                }
//
//                Button("Start Scanning") {
//                    if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
//                        showScanner = true
//                        isScanning = true
//                    }
//                }
//                .buttonStyle(.borderedProminent)
//
//                Button("Clear Results") {
//                    scannedText = nil
//                    scannedBarcode = nil
//                }
//                .buttonStyle(.bordered)
//            }
//            .navigationTitle("Data Scanner")
//            .sheet(isPresented: $showScanner) {
//                DataScannerSheet(
//                    scannedText: $scannedText,
//                    scannedBarcode: $scannedBarcode,
//                    isPresented: $showScanner
//                )
//            }
//        }
//    }
// }
