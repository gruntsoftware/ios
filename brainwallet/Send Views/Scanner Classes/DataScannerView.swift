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
//
// struct DataScannerView: UIViewControllerRepresentable {
//
//    @Binding var scannedText: String
//    @Binding var scannedBarcode: String
//    @Binding var isScanning: Bool
//    
//    var recognizedDataTypes: Set<DataScannerViewController.RecognizedDataType>
//    var recognizesMultipleItems: Bool
//    var onTapItem: ((RecognizedItem) -> Void)?
//
//    init(
//        scannedText: Binding<String> = "",
//        scannedBarcode: Binding<String> = "",
//        isScanning: Binding<Bool> = .constant(true),
//        recognizedDataTypes: Set<DataScannerViewController.RecognizedDataType> = [.text(), .barcode()],
//        recognizesMultipleItems: Bool = true,
//        onTapItem: ((RecognizedItem) -> Void)? = nil
//    ) {
//        self._scannedText = scannedText
//        self._scannedBarcode = scannedBarcode
//        self._isScanning = isScanning
//        self.recognizedDataTypes = recognizedDataTypes
//        self.recognizesMultipleItems = recognizesMultipleItems
//        self.onTapItem = onTapItem
//    }
//
//    func makeUIViewController(context: Context) -> DataScannerViewController {
//        let scanner = DataScannerViewController(
//            recognizedDataTypes: recognizedDataTypes,
//            qualityLevel: .balanced,
//            recognizesMultipleItems: recognizesMultipleItems,
//            isHighFrameRateTrackingEnabled: true,
//            isPinchToZoomEnabled: true,
//            isGuidanceEnabled: true,
//            isHighlightingEnabled: true
//        )
//
//        scanner.delegate = context.coordinator
//        return scanner
//    }
//
//    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
//        if isScanning {
//            try? uiViewController.startScanning()
//        } else {
//            uiViewController.stopScanning()
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
//        uiViewController.stopScanning()
//    }
//
//    // MARK: - Coordinator
//
//    class Coordinator: NSObject, DataScannerViewControllerDelegate {
//        var parent: DataScannerView
//
//        init(_ parent: DataScannerView) {
//            self.parent = parent
//        }
//
//        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
//            switch item {
//            case .text(let text):
//                parent.scannedText = text.transcript
//
//            case .barcode(let barcode):
//                parent.scannedBarcode = barcode.payloadStringValue
//
//            @unknown default:
//                break
//            }
//
//            parent.onTapItem?(item)
//        }
//
//        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
//            // Optionally handle added items
//        }
//
//        func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
//            // Optionally handle removed items
//        }
//
//        func dataScanner(_ dataScanner: DataScannerViewController, becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {
//            print("Scanner unavailable: \(error.localizedDescription)")
//            parent.isScanning = false
//        }
//    }
// }
//
//
//

struct DataScannerView: UIViewControllerRepresentable {
    @Binding var scannedText: String
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> DataScannerViewController {
        // Configure what types of data to recognize
        let recognizedDataTypes: Set<DataScannerViewController.RecognizedDataType> = [
            .text(), .barcode(symbologies: [.qr])
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
//        
//               let scanOverlayView = ScanOverlayDataView(scannedText: $scannedText)
//                scanOverlayView.translatesAutoresizingMaskIntoConstraints = false
//                scanner.view.addSubview(scanOverlayView)

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

        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text):
                scannedText = text.transcript.isValidAddress ? text.transcript : "Invalid Address"
                isPresented = false

            case .barcode(let barcode):
                if let payload = barcode.payloadStringValue {
                    var processedPayload: String = ""
                    if payload.prefix(8) == "litecoin" {
                        processedPayload = payload.components(separatedBy: ":").last ?? ""
                    } else {
                        processedPayload = payload
                    }
                    scannedText = processedPayload.isValidAddress ? processedPayload : "Invalid Address"
                    isPresented = false
                }

            @unknown default:
                break
            }
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {

            let firstItem = allItems.first

            switch firstItem {
            case .barcode(let stringValue):
                let rawAddress: String = (stringValue.payloadStringValue ?? "").components(separatedBy: " ").last ?? " "
                scannedText = rawAddress.isValidAddress ? rawAddress : "Invalid Address"
                isPresented = false
            case .text(let stringValue):
                let rawAddress: String = stringValue.transcript
                scannedText = rawAddress.isValidAddress ? rawAddress : "Invalid Address"
                isPresented = false

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
