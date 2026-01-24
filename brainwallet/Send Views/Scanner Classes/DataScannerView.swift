//
//  DataScannerViewController.swift
//  brainwallet
//
//  Created by Kerry Washington on 15/11/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI
import VisionKit

// MARK: - DataScanner SwiftUI Wrapper

struct DataScannerView: UIViewControllerRepresentable {
    @Binding var scannedText: String
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> DataScannerViewController {
        // Configure what types of data to recognize
        let recognizedDataTypes: Set<DataScannerViewController.RecognizedDataType> = [
            .barcode(symbologies: [.qr])
        ]

        let scanner = DataScannerViewController(
            recognizedDataTypes: recognizedDataTypes,
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: true,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )

        scanner.delegate = context.coordinator

                let scanOverlayView = ScanOverlayView()
                scanOverlayView.translatesAutoresizingMaskIntoConstraints = false
                scanner.view.addSubview(scanOverlayView)

                NSLayoutConstraint.activate([
                    scanOverlayView.topAnchor.constraint(equalTo: scanner.view.topAnchor),
                    scanOverlayView.bottomAnchor.constraint(equalTo: scanner.view.bottomAnchor),
                    scanOverlayView.leadingAnchor.constraint(equalTo: scanner.view.leadingAnchor),
                    scanOverlayView.trailingAnchor.constraint(equalTo: scanner.view.trailingAnchor)
                ])

        try? scanner.startScanning()

        return scanner
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(scannedText: $scannedText, isPresented: $isPresented)
    }

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        @Binding var scannedText: String
        @Binding var isPresented: Bool

        init(scannedText: Binding<String>, isPresented: Binding<Bool>) {
            self._scannedText = scannedText
            self._isPresented = isPresented

        }

        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {

            let firstItem = allItems.first

            switch firstItem {
            case .barcode(let stringValue):
                var rawAddressString: String = (stringValue.payloadStringValue ?? "").components(separatedBy: ":").last ?? " "

                if rawAddressString.contains("?label=") {/// Litecoin Core v0.21.4  with label
                    rawAddressString = rawAddressString.components(separatedBy: "?").first ?? " "
                }
                scannedText = rawAddressString.isValidAddress ? rawAddressString : "Invalid Address"
                isPresented = false
            case .none, .text: /// The Litecoin Core QR code is lockedup with text and
                               /// this causes an error when scanning
                               /// removed the option. Users can type or copypasta.
                break
            @unknown default:
                break
            }
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            isPresented = false
        }

        func dataScanner(_ dataScanner: DataScannerViewController, becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {
            print("Scanner became unavailable: \(error.localizedDescription)")
        }
    }
}
