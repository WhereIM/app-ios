//
//  ScannerController.swift
//  whereim
//
//  Created by Buganini Q on 10/05/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import UIKit
import AVFoundation

class ScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var videoCaptureDevice: AVCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    var device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    var output = AVCaptureMetadataOutput()
    var previewLayer: AVCaptureVideoPreviewLayer?

    var captureSession = AVCaptureSession()
    var code: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black

        let input = try? AVCaptureDeviceInput(device: videoCaptureDevice)

        if self.captureSession.canAddInput(input) {
            self.captureSession.addInput(input)
        }

        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)

        let screenSize: CGRect = UIScreen.main.bounds
        let e = min(screenSize.width, screenSize.height) * 0.75

        let cameraview = UIView()
        cameraview.translatesAutoresizingMaskIntoConstraints = false
        if let videoPreviewLayer = self.previewLayer {
            videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill


            videoPreviewLayer.frame = CGRect(x: 0, y: 0, width: e, height: e)
            cameraview.layer.addSublayer(videoPreviewLayer)
        }
        self.view.addSubview(cameraview)
        cameraview.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        cameraview.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        cameraview.widthAnchor.constraint(equalToConstant: e).isActive = true
        cameraview.heightAnchor.constraint(equalToConstant: e).isActive = true

        let metadataOutput = AVCaptureMetadataOutput()
        if self.captureSession.canAddOutput(metadataOutput) {
            self.captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code]
        } else {
            print("Could not add metadata output")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession.isRunning == false) {
            captureSession.startRunning();
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession.isRunning == true) {
            captureSession.stopRunning();
        }
    }

    var matched = false
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
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
                        let sublink = nslink.substring(with: match.rangeAt(1))
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
