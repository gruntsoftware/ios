//
//  Scn.swift
//  brainwallet
//
//  Created by Kerry Washington on 16/11/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

// struct BarcodeScannerView: View {
//    @State private var scannedCode: String?
//    @State private var showScanner = false
//
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 20) {
//                Image(systemName: "barcode.viewfinder")
//                    .font(.system(size: 100))
//                    .foregroundColor(.blue)
//
//                if let code = scannedCode {
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Last Scanned Code:")
//                            .font(.headline)
//                        Text(code)
//                            .font(.system(.body, design: .monospaced))
//                            .padding()
//                            .background(Color.gray.opacity(0.1))
//                            .cornerRadius(8)
//                    }
//                    .padding()
//                }
//
//                Button("Scan Barcode") {
//                    showScanner = true
//                }
//                .buttonStyle(.borderedProminent)
//            }
//            .navigationTitle("Barcode Scanner")
//            .sheet(isPresented: $showScanner) {
//                BarcodeOnlyScannerSheet(scannedCode: $scannedCode, isPresented: $showScanner)
//            }
//        }
//    }
// }
