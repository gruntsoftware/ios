import AVFoundation
import UIKit

typealias ScanCompletion = (PaymentRequest?) -> Void
typealias KeyScanCompletion = (String) -> Void

class ScanViewController: UIViewController, Trackable {
    // TODO: Add a storyboard
    @IBOutlet var cameraOverlayView: UIView!
    @IBOutlet var toolbarView: UIView!
    @IBOutlet var overlayViewTitleLabel: UILabel!

    @IBOutlet var closeButton: UIButton!
    @IBOutlet var flashButton: UIButton!

    static func presentCameraUnavailableAlert(fromRoot: UIViewController) {
        let alertController = UIAlertController(title:  String(localized: "Brainwallet is not allowed to access the camera") , message:  String(localized: "Go to Settings to allow camera access."), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title:   String(localized: "Cancel") , style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title:  String(localized: "Settings") , style: .default, handler: { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        }))
        fromRoot.present(alertController, animated: true, completion: nil)
    }

    static var isCameraAllowed: Bool {
        return AVCaptureDevice.authorizationStatus(for: AVMediaType.video) != .denied
    }

    let completion: ScanCompletion?
    let scanKeyCompletion: KeyScanCompletion?
    let isValidURI: (String) -> Bool

    fileprivate let guide = CameraGuideView()
    fileprivate let session = AVCaptureSession()
    private let toolbar = UIView()
    private let close = UIButton.close
    private let flash = UIButton.icon(image: UIImage(named: "flashIcon")!, accessibilityLabel:  String(localized: "Camera Flash"))
    fileprivate var currentUri = ""

    init(completion: @escaping ScanCompletion, isValidURI: @escaping (String) -> Bool) {
        self.completion = completion
        scanKeyCompletion = nil
        self.isValidURI = isValidURI
        super.init(nibName: nil, bundle: nil)
    }

    init(scanKeyCompletion: @escaping KeyScanCompletion, isValidURI: @escaping (String) -> Bool) {
        self.scanKeyCompletion = scanKeyCompletion
        completion = nil
        self.isValidURI = isValidURI
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        view.backgroundColor = .black
        toolbar.backgroundColor = BrainwalletUIColor.background

        view.addSubview(toolbar)
        toolbar.addSubview(close)
        toolbar.addSubview(flash)
        view.addSubview(guide)

        toolbar.constrainBottomCorners(sidePadding: 0, bottomPadding: 0)
        if E.isIPhoneX {
            toolbar.constrain([toolbar.constraint(.height, constant: 60.0)])

            close.constrain([
                close.constraint(.leading, toView: toolbar),
                close.constraint(.top, toView: toolbar, constant: 2.0),
                close.constraint(.width, constant: 50.0),
                close.constraint(.height, constant: 50.0)
            ])

            flash.constrain([
                flash.constraint(.trailing, toView: toolbar),
                flash.constraint(.top, toView: toolbar, constant: 2.0),
                flash.constraint(.width, constant: 50.0),
                flash.constraint(.height, constant: 50.0)
            ])
        } else {
            toolbar.constrain([toolbar.constraint(.height, constant: 60.0)])

            close.constrain([
                close.constraint(.leading, toView: toolbar, constant: 10.0),
                close.constraint(.top, toView: toolbar, constant: 2.0),
                close.constraint(.bottom, toView: toolbar, constant: -2.0),
                close.constraint(.width, constant: 50.0)
            ])

            flash.constrain([
                flash.constraint(.trailing, toView: toolbar, constant: -10.0),
                flash.constraint(.top, toView: toolbar, constant: 2.0),
                flash.constraint(.bottom, toView: toolbar, constant: -2.0),
                flash.constraint(.width, constant: 50.0)
            ])
        }

        guide.constrain([
            guide.constraint(.leading, toView: view, constant: C.padding[6]),
            guide.constraint(.trailing, toView: view, constant: -C.padding[6]),
            guide.constraint(.centerY, toView: view),
            NSLayoutConstraint(item: guide, attribute: .width, relatedBy: .equal, toItem: guide, attribute: .height, multiplier: 1.0, constant: 0.0)
        ])
        guide.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)

        close.tap = { [weak self] in
            self?.saveEvent("scan.dismiss")
            self?.dismiss(animated: true, completion: {
                self?.completion?(nil)
            })
        }

        addCameraPreview()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.spring(0.8, animations: {
            self.guide.transform = .identity
        }, completion: { _ in })
    }

    private func addCameraPreview() {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: device) else { return }
        session.addInput(input)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)

        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: .main)
        session.addOutput(output)

        if output.availableMetadataObjectTypes.contains(where: { objectType in
            objectType == AVMetadataObject.ObjectType.qr
        }) {
            output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        } else {
            debugPrint(":::no qr code support")
        }

        DispatchQueue(label: "qrscanner").async {
            self.session.startRunning()
        }

        if device.hasTorch {
            flash.tap = { [weak self] in
                do {
                    try device.lockForConfiguration()
                    device.torchMode = device.torchMode == .on ? .off : .on
                    device.unlockForConfiguration()
                    if device.torchMode == .on {
                        self?.saveEvent("scan.torchOn")
                    } else {
                        self?.saveEvent("scan.torchOn")
                    }
                } catch {
                    debugPrint(":::Camera Torch error: \(error)")
                }
            }
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from _: AVCaptureConnection) {
        if let data = metadataObjects as? [AVMetadataMachineReadableCodeObject] {
            if data.isEmpty {
                guide.state = .normal
            } else {
                for data in data {
                    guard let uri = data.stringValue
                    else {
                        NSLog("ERROR: URI String not found")
                        continue
                    }
                    if completion != nil, guide.state != .positive {
                        handleURI(uri)
                    } else if scanKeyCompletion != nil, guide.state != .positive {
                        handleKey(uri)
                    }
                }
            }
        } else {
            NSLog("ERROR: data metadata objects not accessed")
        }
    }

    func handleURI(_ uri: String) {
        if currentUri != uri {
            currentUri = uri
            if let paymentRequest = PaymentRequest(string: uri) {
                saveEvent("scan.litecoinUri")
                guide.state = .positive
                // Add a small delay so the green guide will be seen
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.dismiss(animated: true, completion: {
                        self.completion?(paymentRequest)
                    })
                }
            } else {
                guide.state = .negative
            }
        }
    }

    func handleKey(_ keyString: String) {
        if isValidURI(keyString) {
            saveEvent("scan.privateKey")
            guide.state = .positive
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.dismiss(animated: true, completion: {
                    self.scanKeyCompletion?(keyString)
                })
            }
        } else {
            guide.state = .negative
        }
    }
}
