//
//  TextScannerView.swift
//  brainwallet
//
//  Created by Kerry Washington on 16/11/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

// struct TextScannerView: View {
//    @State private var scannedTexts: [String] = []
//    @State private var showScanner = false
//    @State private var isScanning = true
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                if scannedTexts.isEmpty {
//                    ContentUnavailableView(
//                        "No Scanned Text",
//                        systemImage: "doc.text.viewfinder",
//                        description: Text("Tap the button below to start scanning")
//                    )
//                } else {
//                    List {
//                        ForEach(scannedTexts, id: \.self) { text in
//                            Text(text)
//                        }
//                        .onDelete { indexSet in
//                            scannedTexts.remove(atOffsets: indexSet)
//                        }
//                    }
//                }
//
//                Button("Scan Text") {
//                    showScanner = true
//                }
//                .buttonStyle(.borderedProminent)
//                .padding()
//            }
//            .navigationTitle("Text Scanner")
//            .sheet(isPresented: $showScanner) {
//                TextOnlyScannerSheet(scannedTexts: $scannedTexts, isPresented: $showScanner)
//            }
//        }
//    }
// }
