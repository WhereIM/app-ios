//
//  ScannerController.swift
//  whereim
//
//  Created by Buganini Q on 10/05/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import AVFoundation
import UIKit
import SDCAlertView

class ScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    let cameraview = UIView()
    var viewWindowSize: CGFloat?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black

        let screenSize: CGRect = UIScreen.main.bounds
        viewWindowSize = min(screenSize.width, screenSize.height) * 0.75

        cameraview.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(cameraview)
        cameraview.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        cameraview.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        cameraview.widthAnchor.constraint(equalToConstant: viewWindowSize!).isActive = true
        cameraview.heightAnchor.constraint(equalToConstant: viewWindowSize!).isActive = true

        checkCamera()
    }

    func checkCamera() {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) != AVAuthorizationStatus.authorized {
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                if response {
                    self.setupCamera()
                } else {
                    self.alertNoPermission()
                }
            }
        } else {
            setupCamera()
        }
    }

    func alertNoPermission() {
        let alert = AlertController(title: "scan_qr_code".localized, message: "NSCameraUsageDescription".localized, preferredStyle: .alert)
        alert.addAction(AlertAction(title: "cancel".localized, style: .normal, handler: nil))
        let action = AlertAction(title: "settings".localized, style: .preferred){ _ in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    var videoCaptureDevice: AVCaptureDevice?
    var device: AVCaptureDevice?
    var output: AVCaptureMetadataOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var captureSession: AVCaptureSession?

    func setupCamera() {
        videoCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        device = AVCaptureDevice.default(for: AVMediaType.video)
        output = AVCaptureMetadataOutput()
        captureSession = AVCaptureSession()

        let input = try? AVCaptureDeviceInput(device: videoCaptureDevice!)

        if self.captureSession!.canAddInput(input!) {
            self.captureSession!.addInput(input!)
        }

        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)

        if let videoPreviewLayer = self.previewLayer {
            videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill

            videoPreviewLayer.frame = CGRect(x: 0, y: 0, width: viewWindowSize!, height: viewWindowSize!)
            cameraview.layer.addSublayer(videoPreviewLayer)
        }

        let metadataOutput = AVCaptureMetadataOutput()
        if self.captureSession!.canAddOutput(metadataOutput) {
            self.captureSession!.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr, AVMetadataObject.ObjectType.ean13]
        } else {
            print("Could not add metadata output")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let session = captureSession {
            if (session.isRunning == false) {
                session.startRunning();
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let session = captureSession {
            if (session.isRunning == true) {
                session.stopRunning();
            }
        }
    }

    var matched = false
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if matched {
            return
        }
        for metadata in metadataObjects {
            let readableObject = metadata as! AVMetadataMachineReadableCodeObject
            if let link = readableObject.stringValue {
                do {
                    let pattern_channel = try NSRegularExpression(pattern: "^.*where.im/(channel/[a-f0-9]{32})$", options: [])

                    let nslink = link as NSString
                    if let match = pattern_channel.firstMatch(in: link, options: [], range: NSMakeRange(0, nslink.length)) {
                        if matched {
                            return
                        }
                        matched = true
                        let sublink = nslink.substring(with: match.range(at: 1))
                        let service = CoreService.bind()
                        service.processLink(sublink)
                    }
                } catch {
                    print("Error in parsing scanned string")
                }
            }
        }
    }
}
