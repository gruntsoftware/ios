//
//  NewCameraScannerView.swift
//  brainwallet
//
//  Created by Kerry Washington on 18/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI
import AVFoundation

struct NewCameraScannerView: UIViewControllerRepresentable {
    var onCodeScanned: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onCodeScanned: onCodeScanned)
    }

    func makeUIViewController(context: Context) -> NewScannerViewController {
        let scannerVC = NewScannerViewController()
        scannerVC.delegate = context.coordinator
        return scannerVC
    }

    func updateUIViewController(_ uiViewController: NewScannerViewController, context: Context) {
        // No-op
    }

    class Coordinator: NSObject, NewScannerViewControllerDelegate {
       
        var onCodeScanned: (String) -> Void

        init(onCodeScanned: @escaping (String) -> Void) {
            self.onCodeScanned = onCodeScanned
        }

        func newScannerViewController(_ controller: NewScannerViewController, didScan code: String) {
            onCodeScanned(code)
        }
    }
}
struct CameraPermission {
    static func checkCameraAuthorization(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
}
