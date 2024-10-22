//
//  ViewController.swift
//  SequreSDK
//
//  Created by IceQwen on 27/09/24.
//

import Accelerate
import AVFoundation
import Foundation
import SwiftUI
import TensorFlowLiteTaskVision
import UIKit

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    /// permission status
    private var permissionGranted = false
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    
    /// define device screen rect
    var screenRect: CGRect! = nil
    
    /// define camera capture session
    private let captureSession = AVCaptureSession()
    private var previewLayer = AVCaptureVideoPreviewLayer()
    
    private var isOptimal: Bool = false
    
    /// tensorflow qr detector
    private let qrDetectionHelper = QRDetectionHelper()
    @ObservedObject var detectedObjectData: DetectedObjectModel
    
    /// camera overlay
    /// initialize qr bounding box view (corner indicator && border around detected object)
    private let boundingBoxView: BoundingBoxView
    
    /// initialize camera QR overlay
    private let scanQROverlay = ScanQROverlay()
    
    /// initialize label information (too far / too close / hold steady / etc)
    private let labeloverlay = LabelOverlay()
    
    /// initialize object distance calculation functino
    private let distanceDetector = DistanceDetector()
    
    /// controll flash
    @Binding var hasFlash: Bool
    @Binding var isFlashActive: Bool
    
    @Binding var imageSource: UIImage?
    
    /// detect if uploading to api in ongoing
    @Binding var isCapturing: Bool
    
    @Binding var distanceResult: DistanceResult
    
    /// required to draw bounding box
    /// give padding to border around detected object in boundingBoxView
    private let edgeOffset: CGFloat = 5.0
    
    /// define font type
    private let displayFont = UIFont.systemFont(ofSize: 14.0, weight: .medium)
    private let colors = [
        UIColor.red,
        UIColor(
            displayP3Red: 90.0 / 255.0,
            green: 200.0 / 255.0,
            blue: 250.0 / 255.0,
            alpha: 1.0
        ),
        UIColor.green,
        UIColor.orange,
        UIColor.blue,
        UIColor.purple,
        UIColor.magenta,
        UIColor.yellow,
        UIColor.cyan,
        UIColor.brown,
    ]
    
    /// initialize required value
    init(
        detectedObjectData: DetectedObjectModel,
        imageSource: Binding<UIImage?>,
        hasFlash: Binding<Bool>,
        isFlashActive: Binding<Bool>,
        isCapturing: Binding<Bool>,
        distanceResult: Binding<DistanceResult>,
        isDebugLayout: Bool
    ) {
        self._imageSource = imageSource
        self.detectedObjectData = detectedObjectData
        self._hasFlash = hasFlash
        self._isFlashActive = isFlashActive
        self._isCapturing = isCapturing
        self._distanceResult = distanceResult
        self.boundingBoxView = BoundingBoxView(isDebugLayout: isDebugLayout)
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// called after view is loaded / shown
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        checkPermission()
        
        boundingBoxView.clearsContextBeforeDrawing = true
        
        /// start async session
        sessionQueue.async { [unowned self] in
            guard permissionGranted else { return }
            self.setupCaptureSession()
            self.captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isFlashActive {
            toggleFlash(on: false)
        }
        
        stopSession()
    }
    
    private func setupUI() {
        /// register scanQROverlay to view
        scanQROverlay.frame = view.bounds
        scanQROverlay.backgroundColor = .clear
        view.addSubview(scanQROverlay)
        
        /// register boundingBoxView to view
        boundingBoxView.frame = view.bounds
        boundingBoxView.backgroundColor = .clear
        view.addSubview(boundingBoxView)
        
        /// register labelOverlay to view
        labeloverlay.frame = view.bounds
        labeloverlay.backgroundColor = .clear
        view.addSubview(labeloverlay)
        
        // tap to focus point
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapToFocus(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    /// handle focus point based on tap coordinate
    @objc private func handleTapToFocus(_ gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: view)
        
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        let focusPoint = CGPoint(x: location.y / view.bounds.height, y: 1.0 - location.x / view.bounds.width)
        
        do {
            try device.lockForConfiguration()
            
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = focusPoint
                device.focusMode = .autoFocus
            }
            
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = .continuousAutoExposure
            }
            
            device.unlockForConfiguration()
            
        } catch {
            print("Error setting focus point of interest: \(error.localizedDescription)")
        }
    }
    
    func setupCaptureSession() {
        /// get default back camera
        guard let videoDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        ) else { return }
       
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
       
        /// add video input to session thread
        guard captureSession.canAddInput(videoDeviceInput) else { return }
        captureSession.addInput(videoDeviceInput)
       
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [String(kCVPixelBufferPixelFormatTypeKey): kCMPixelFormat_32BGRA]
       
        /**
         /// Adjust Zoom Factor
         /// Must call lockForConfiguration before and unlockForConfiguration after
         /// lockForConfiguration prevent other part of the app or other system to make changes
         /// unlockForConfiguration allow other part of the app or other system to make changes
         /// this prevent configuration conflic
         */
        do {
            try videoDeviceInput.device.lockForConfiguration()
       
            /// 3x zoom
            if videoDeviceInput.device.maxAvailableVideoZoomFactor > 3 {
                videoDeviceInput.device.videoZoomFactor = 3
            }
       
            videoDeviceInput.device.unlockForConfiguration()
        } catch {
            print("\(error.localizedDescription)")
        }
        /**
         /// End of Adjust Zoom Factor
         */
       
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
            videoOutput.connection(with: .video)?.videoOrientation = .portrait
        } else { return }
       
        /// set screen rect based on device screen
        screenRect = UIScreen.main.bounds
       
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRect(
            x: screenRect.origin.x,
            y: screenRect.origin.x,
            width: screenRect.size.width,
            height: screenRect.size.height
        )
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
       
        DispatchQueue.main.async { [weak self] in
            self!.view.layer.addSublayer(self!.previewLayer)
            self!.view.bringSubviewToFront(self!.scanQROverlay)
            self!.view.bringSubviewToFront(self!.boundingBoxView)
            self!.view.bringSubviewToFront(self!.labeloverlay)
        }
    }
    
    /// check camera permission
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionGranted = true
            
        case .notDetermined:
            requestPermission()
            
        default:
            permissionGranted = false
        }
    }
    
    /// prompt user camera permission
    func requestPermission() {
        /// prevent AVCaptureDevice to run
        sessionQueue.suspend()
        
        /// prompt user permission
        AVCaptureDevice.requestAccess(
            for: .video,
            completionHandler: { [unowned self] granted in
                self.permissionGranted = granted
            
                /// continue
                self.sessionQueue.resume()
            }
        )
    }
    
    /// camera output feed
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        /// convert image buffer to UIIMage
        let pixelBuffer: CVPixelBuffer? = CMSampleBufferGetImageBuffer(sampleBuffer)
        guard let imagePixelBuffer = pixelBuffer else { return }
        let ciImage = CIImage(cvPixelBuffer: imagePixelBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
        imageSource = UIImage(cgImage: cgImage)
        
        /// perform object detection
        if let result = qrDetectionHelper.detectObject(frame: imagePixelBuffer) {
            DispatchQueue.main.async {
                /// update detectedObject using the one from object detection helper
                self.detectedObjectData.detectedObjects = result.detections
                
                /// get image size
                let width = CVPixelBufferGetWidth(imagePixelBuffer)
                let height = CVPixelBufferGetHeight(imagePixelBuffer)
                
                /// update bounding boxes based on detection result
                self.drawBoundingBoxs(
                    onDecetions: result.detections,
                    withImageSize: CGSize(
                        width: CGFloat(width),
                        height: CGFloat(height)
                    ),
                    onDistanceResult: self.distanceResult
                )
                
                self.drawQROverlayLabel(onDistanceResult: self.distanceResult)
            }
            
        } else {
            print("No objects detected or error occurred")
        }
    }
    
    /// turn flash on / off
    func toggleFlash(on: Bool) {
        /// check if device flash availablity
        guard let device = AVCaptureDevice.default(for: .video) else {
            print("error set flash")
            return
        }
        
        if !device.hasTorch {
            print("has't tourch")
            return
        }
        
        // Check if the current state matches the desired state
        if (on && device.torchMode == .on) || (!on && device.torchMode == .off) {
            return
        }
        
        do {
            /// prevent other part of app or system to make changes
            try device.lockForConfiguration()
            
            /// toggle flash mode
            device.torchMode = on ? .on : .off
            
            /// unlock configuration making other system able to make changes
            device.unlockForConfiguration()
        } catch {
            print("Error configuring torch: \(error.localizedDescription)")
        }
    }
    
    /// change zoom level
    func changeZoomLevel(zoomLevel: CGFloat) {
        /// prevent zoom less than 1
        if zoomLevel < 1 { return }
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        
        /// prevent over zooming more than supported device
        if zoomLevel > videoDevice.activeFormat.videoMaxZoomFactor { return }
            
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        
        do {
            try videoDeviceInput.device.lockForConfiguration()
            
            videoDeviceInput.device.videoZoomFactor = zoomLevel
            
            videoDeviceInput.device.unlockForConfiguration()
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    
    /// handle auto focus
    func doAutoFocus() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        let focusPoint = CGPoint(x: view.bounds.height / 2, y: view.bounds.width / 2)
        
        do {
            try device.lockForConfiguration()
            
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = focusPoint
                device.focusMode = .autoFocus
            }
            
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = .continuousAutoExposure
            }
            
            device.unlockForConfiguration()
            
        } catch {
            print("Error setting focus point of interest: \(error.localizedDescription)")
        }
    }
    
    func startSession() {
        sessionQueue.async {
            [weak self] in
            guard let self = self, self.permissionGranted else { return }
            
            self.captureSession.startRunning()
        }
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }
    
    func drawBoundingBoxs(
        onDecetions detections: [Detection],
        withImageSize imageSize: CGSize,
        onDistanceResult distanceResult: DistanceResult
    ) {
        boundingBoxView.objectOverlays = []
        boundingBoxView.setNeedsDisplay()
        
        guard !detections.isEmpty else { return }
        
        var objectOverlays: [ObjectOverlayBounding] = []
        
        for detection in detections {
            guard let category = detection.categories.first else { return }
            
            var convertedRect = detection.boundingBox.applying(
                CGAffineTransform(
                    scaleX: boundingBoxView.bounds.size.width / imageSize.width,
                    y: boundingBoxView.bounds.size.height / imageSize.height
                )
            )
            
            if convertedRect.origin.x < 0 {
                convertedRect.origin.x = edgeOffset
            }
            
            if convertedRect.origin.y < 0 {
                convertedRect.origin.y = edgeOffset
            }
            
            if convertedRect.maxY > boundingBoxView.bounds.maxY {
                convertedRect.size.height =
                    boundingBoxView.bounds.maxY - convertedRect.origin.y - edgeOffset
            }
            
            if convertedRect.maxX > boundingBoxView.bounds.maxX {
                convertedRect.size.width =
                    boundingBoxView.bounds.maxX - convertedRect.origin.x - edgeOffset
            }
            
            let objectDescription = String(format: "\(category.label ?? "unknwon") (%.2f)", category.score)
            
            let displayColor = colors[category.index % colors.count]
            
            let size = objectDescription.size(withAttributes: [.font: displayFont])
            
            let objectOverlay = ObjectOverlayBounding(
                isCapturing: distanceResult == DistanceResult.optimal,
                borderRect: convertedRect,
                name: objectDescription,
                nameStringSize: size,
                color: displayColor,
                font: displayFont
            )
            
            objectOverlays.append(objectOverlay)
        }
        
        draw(objectOverlays: objectOverlays)
    }
    
    /// draw the bounding box
    func draw(objectOverlays: [ObjectOverlayBounding]) {
        boundingBoxView.objectOverlays = objectOverlays
        boundingBoxView.setNeedsDisplay()
    }
    
    /// draw label information based on object distance
    func drawQROverlayLabel(onDistanceResult distanceResult: DistanceResult) {
        labeloverlay.qrDistanceResult = distanceResult
        labeloverlay.setNeedsDisplay()
    }
}
