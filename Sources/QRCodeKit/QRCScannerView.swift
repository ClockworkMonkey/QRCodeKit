//
//  QRCScannerView.swift
//  QRCodeKit
//
//  Created by Clockwork Monkey Stutdios on 2020/9/8.
//  Copyright © 2020 Clockwork Monkey Stutdios. All rights reserved.
//

import AVFoundation
import UIKit

public protocol QRCScannerViewDelegate: AnyObject {
    
    func scannerView(_ scannerView: QRCScannerView, didFinishWithMessage message: String)
    
    func scannerView(_ scannerView: QRCScannerView, didFailWithError error: Error)
    
}

public class QRCScannerView: UIView {
    private weak var delegate: QRCScannerViewDelegate?
    private let captureSession = AVCaptureSession()
    private var captureMetadataOutput = AVCaptureMetadataOutput()
    private let captureMetadataOutputObjectsQueue = DispatchQueue(label: "QRC.Queue.Capture.Session.Metadata")
    private var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer?
    private let captureVideoDeviceAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    private let viewfinderImageView = UIImageView()
    
    public func setupScanner(delegate: QRCScannerViewDelegate) {
        self.delegate = delegate
        configureCaptureSession()
        addCaptureVideoPreviewLayer()
        addViewfinderImageView()
    }
    
    public func startScanning() {
        guard captureVideoDeviceAuthorizationStatus == .authorized else { return }
        guard !captureSession.isRunning else { return }
        captureMetadataOutputObjectsQueue.async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    public func stopScanning() {
        guard captureSession.isRunning else { return }
        captureMetadataOutputObjectsQueue.async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }
    
    deinit {
        viewfinderImageView.removeFromSuperview()
        captureSession.inputs.forEach { captureSession.removeInput($0) }
        captureSession.outputs.forEach { captureSession.removeOutput($0) }
        captureVideoPreviewLayer?.removeFromSuperlayer()
    }
    
}

extension QRCScannerView {
    
    private func configureCaptureSession() {
        guard let captureVideoDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        guard let captureVideoDeviceInput = try? AVCaptureDeviceInput.init(device: captureVideoDevice), captureSession.canAddInput(captureVideoDeviceInput) else {
            return
        }
        
        guard captureSession.canAddOutput(captureMetadataOutput) else {
            return
        }
        
        captureSession.beginConfiguration()
        captureSession.addInput(captureVideoDeviceInput)
        captureSession.addOutput(captureMetadataOutput)
        captureSession.commitConfiguration()
        
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: captureMetadataOutputObjectsQueue)
        
        if captureVideoDeviceAuthorizationStatus == .notDetermined {
            captureMetadataOutputObjectsQueue.async { [weak self] in
                self?.captureSession.startRunning()
            }
        }
    }
    
    private func addCaptureVideoPreviewLayer() {
        let captureVideoPreviewLayer = AVCaptureVideoPreviewLayer.init(session: captureSession)
        captureVideoPreviewLayer.videoGravity = .resizeAspectFill
        captureVideoPreviewLayer.frame = self.bounds
        layer.addSublayer(captureVideoPreviewLayer)
        self.captureVideoPreviewLayer = captureVideoPreviewLayer
    }
    
    private func addViewfinderImageView() {
        // SF Symbol Image
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 15.0, weight: .ultraLight, scale: .large)
        let image = UIImage(systemName: "viewfinder", withConfiguration: symbolConfiguration)
        // ImageView Frame
        let width: CGFloat = 250.0
        let x = (self.bounds.width - width) / 2.0
        let y = (self.bounds.height - width) / 2.0
        viewfinderImageView.frame = CGRect(x: x, y: y, width: width, height: width)
        viewfinderImageView.image = image
        viewfinderImageView.contentMode = .scaleAspectFill
        viewfinderImageView.tintColor = .white
        self.addSubview(viewfinderImageView)
    }
    
}

extension QRCScannerView {
    
    private func didFail(_ error: Error) {
        delegate?.scannerView(self, didFailWithError: error)
    }

    private func didFinish(_ message: String) {
        delegate?.scannerView(self, didFinishWithMessage: message)
    }
    
}

extension QRCScannerView: AVCaptureMetadataOutputObjectsDelegate {
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = captureVideoPreviewLayer?.transformedMetadataObject(for: metadataObject) as? AVMetadataMachineReadableCodeObject, metadataObject.type == .qr else { return }
            guard let message = readableObject.stringValue else { return }
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.didFinish(message)
                strongSelf.stopScanning()
            }
        }
    }
    
}
