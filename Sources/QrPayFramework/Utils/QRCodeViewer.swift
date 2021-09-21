//
//  QRCodeViewer.swift
//  QRPayFramework
//
//  Created by Wooppay on 26.10.2017.
//  Copyright © 2017 Wooppay. All rights reserved.
//

import UIKit
import AVFoundation

public typealias QRResultBlock = (_ str: String) -> ()
public typealias QRErrorBlock = (_ errorMessage: String) -> ()

public protocol QRCodeViewerDelegate {
    func didScanResult(_ result: String)
}

@objc public class QRCodeViewer: NSObject {
    
    @objc public static let shared: QRCodeViewer = QRCodeViewer()
    var isDesignable: Bool = true
    
    @IBOutlet weak var lightingButton: UIButton?
    var scanFrameSize: CGSize = CGSize(width: 200, height: 200)
    var scanFrame: CGRect?
    
    public var delegate: QRCodeViewerDelegate?
    
    public override init() {
        super.init()
    }
    
    
    fileprivate lazy var input: AVCaptureDeviceInput? = {
        if let device = AVCaptureDevice.default(for: AVMediaType.video) {
        do {
            var captureMetaDataInput = try AVCaptureDeviceInput(device: device)
            return captureMetaDataInput
        } catch let error as NSError {
            sendErrorBlock(message: error.localizedDescription)
            return nil
        }
        } else {
            return nil
        }
    }()
    
    
    fileprivate lazy var output: AVCaptureMetadataOutput = {
        
        var captureMetaDataOutput = AVCaptureMetadataOutput()
        let dispatchQueue = DispatchQueue(label: "com.kingiol.QRLockQueue", attributes: [])
        captureMetaDataOutput.setMetadataObjectsDelegate(self, queue: dispatchQueue)
        
        return captureMetaDataOutput
    }()
    
    fileprivate lazy var session: AVCaptureSession = AVCaptureSession()
    
    fileprivate lazy var previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.session)
    
    
    fileprivate var resultBlock: QRResultBlock?
    fileprivate var errorBlock: QRErrorBlock?
    
    var flashLightButtonColor: UIColor = UIColor(red: 55/255.0, green: 192/255.0, blue: 198/255.0, alpha: 1.0)
    
    @objc public func startScan(inView: UIView, scanFrameSize: CGSize, isDesignable: Bool = true, result: ((String) -> ())? = nil) {
        DispatchQueue.main.async {
            let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            if authStatus == .authorized || authStatus == .notDetermined {
                self.resultBlock = result
                self.isDesignable = isDesignable
                self.setUpCamera()
                self.scanFrameSize = scanFrameSize
                
                let scanSize = scanFrameSize
                let contentW = inView.frame.size.width
                let contentH = inView.frame.size.height
                let centerRect = CGRect(x: (contentW-scanSize.width)/2.0, y: (contentH-scanSize.height)/2.0, width: scanSize.width, height: scanSize.height)
                self.scanFrame = centerRect
                self.output.metadataObjectTypes = self.output.availableMetadataObjectTypes
                self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
                self.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                
                let view = self.setUpQRMask(inView: inView)
                self.previewLayer.frame = view.frame;
                
                self.setOriginRectOfInterest(inView)
                view.layer.insertSublayer(self.previewLayer, at: 0)
                inView.sendSubviewToBack(view)
                self.session.startRunning()
            } else {
                self.sendErrorBlock(message: "Нет доступа к камере")
            }
        }
    }
    
    @objc public func startScan(inView: UIView, scanFrame: CGRect, isDesignable: Bool = true, result: ((String) -> ())? = nil) {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if authStatus == .authorized || authStatus == .notDetermined {
            resultBlock = result
            
            self.isDesignable = isDesignable
            setUpCamera()
            self.scanFrame = scanFrame
            self.scanFrameSize = CGSize(width: scanFrame.width, height: scanFrame.height)
            output.metadataObjectTypes = output.availableMetadataObjectTypes
            let view = setUpQRMask(inView: inView)
            setOriginRectOfInterest(inView)
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            
            previewLayer.frame = view.frame;
            view.layer.insertSublayer(previewLayer, at: 0)
            inView.sendSubviewToBack(view)
            session.startRunning()
        } else {
            sendErrorBlock(message: "Нет доступа к камере")
        }
        
    }
    
    @objc public func detectQRCode(_ image: UIImage?) -> [CIFeature]? {
        if let image = image, let ciImage = CIImage.init(image: image){
            var options: [String: Any]
            let context = CIContext()
            options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
            let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
            if ciImage.properties.keys.contains((kCGImagePropertyOrientation as String)){
                options = [CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
            } else {
                options = [CIDetectorImageOrientation: 1]
            }
            let features = qrDetector?.features(in: ciImage, options: options)
            return features
            
        }
        return nil
    }
    
    @objc public func stopScan() {
        session.stopRunning()
    }
    
    func setOriginRectOfInterest(_ inView: UIView) {
        let scanSize = CGSize(width: scanFrameSize.width, height: scanFrameSize.height)
        let contentW = inView.frame.size.width
        let contentH = inView.frame.size.height
        var scanRect = self.scanFrame ?? CGRect(x: (contentW-scanSize.width)/2.0, y: (contentH-scanSize.height)/2.0, width: scanSize.width, height: scanSize.height)
        scanRect = CGRect(x: scanRect.minY/contentH, y: scanRect.minX/contentW, width: scanRect.height/contentH, height: scanRect.width/contentW)
        output.rectOfInterest = scanRect
    }
    
    func setUpCamera() {
        if checkCameraAvaliable() {
            if checkCameraAuthorise() {
                
                session.sessionPreset = AVCaptureSession.Preset.high
                if input != nil {
                    if session.canAddInput(input!) {
                    session.addInput(input!)
                }
                }
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }
                
                
            }
        } else {
            sendErrorBlock(message: "Нет доступа к камере")
            print("Нет доступа к камере")
        }
    }
    
    func setUpQRMask(inView: UIView) -> UIView {
        let view = inView
        DispatchQueue.main.async {
            let scanSize = CGSize(width: self.scanFrameSize.width, height: self.scanFrameSize.height)
            let contentW = inView.frame.size.width
            let contentH = inView.frame.size.height
            let centerRect = CGRect(x: (contentW-scanSize.width)/2.0, y: (contentH-scanSize.height)/2.0, width: scanSize.width, height: scanSize.height)
        
            
            let path = UIBezierPath(rect: inView.bounds)
            let centerPath = UIBezierPath(rect: self.scanFrame ?? centerRect)
            
            path.append(centerPath)
            path.usesEvenOddFillRule = true
            
            let fillLayer = CAShapeLayer()
            fillLayer.path = path.cgPath
            fillLayer.fillRule = CAShapeLayerFillRule.evenOdd
            fillLayer.fillColor = UIColor.black.withAlphaComponent(0).cgColor
         
            fillLayer.name = "fillLayer"
            view.layer.sublayers?.forEach {
                if $0.name == "fillLayer" {
                $0.removeFromSuperlayer()
                }
                }
            view.layer.addSublayer(fillLayer)
            
            if self.isDesignable == true {
            let qrScanLabel = UILabel(frame: CGRect(x: 10, y: (contentH-scanSize.height)/2.0 - 60, width: contentW - 20, height: 40))
            qrScanLabel.textAlignment = .center
            qrScanLabel.font = UIFont.systemFont(ofSize: 17)
            qrScanLabel.textColor = .white
            qrScanLabel.text = "Наведите камеру на QR-код"
            qrScanLabel.numberOfLines = 0
            view.addSubview(qrScanLabel)
            
            let titleLabel = UILabel(frame: CGRect(x: 10, y: qrScanLabel.frame.minY - 60, width: contentW - 20, height: 40))
            titleLabel.textAlignment = .center
            titleLabel.font = UIFont.systemFont(ofSize: 24)
            titleLabel.textColor = .white
            titleLabel.text = "Сканируй и Оплачивай"
            titleLabel.numberOfLines = 0
            view.addSubview(titleLabel)
            
            let lightingButton = UIButton(frame: CGRect(x: contentW - 70, y: contentH - 120, width: 50, height: 50))
            
            lightingButton.backgroundColor = self.flashLightButtonColor
            lightingButton.layer.cornerRadius = 25
            let frameworkBundle = Bundle(for: QRCodeViewer.self)
            let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("QRPayResources.bundle")
            let resourceBundle = Bundle(url: bundleURL!)
            let image = UIImage(named: "lighting", in: resourceBundle, compatibleWith: nil)
            lightingButton.setImage(image, for: .normal)
            lightingButton.addTarget(self, action: #selector(QRCodeViewer.lightingButtonAction(_:)), for: .touchUpInside)
            self.lightingButton = lightingButton
            view.addSubview(lightingButton)
            
            let v = UIView(frame: CGRect(x: 0, y: contentH - 15 - 25, width: contentW, height: 40))
            v.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
            view.addSubview(v)
            
    //        let visaImageView = UIImageView(frame: CGRect(x: contentW/2.0 - 60, y: contentH - 15 - 15, width: 60, height: 25))
    //        visaImageView.image = UIImage(named: "visa", in: resourceBundle, compatibleWith: nil)
    //        visaImageView.contentMode = .scaleAspectFit
    //        view.addSubview(visaImageView)
            
            let qrImageView = UIImageView(frame: CGRect(x: contentW/2.0 - 30, y: contentH - 15 - 15, width: 60, height: 25))
            qrImageView.image = UIImage(named: "qr", in: resourceBundle, compatibleWith: nil)
            qrImageView.contentMode = .scaleAspectFit
            view.addSubview(qrImageView)
            }
        }
        return view
    }
    
    @objc func lightingButtonAction(_ sender: UIButton!) {
        if let device = AVCaptureDevice.default(for: AVMediaType.video) {
        if (device.hasTorch) {
            do {
                try device.lockForConfiguration()
                if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                    let frameworkBundle = Bundle(for: QRCodeViewer.self)
                    let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("QRPayResources.bundle")
                    let resourceBundle = Bundle(url: bundleURL!)
                    let image = UIImage(named: "lighting", in: resourceBundle, compatibleWith: nil)
                    lightingButton?.setImage(image, for: .normal)
                    device.torchMode = AVCaptureDevice.TorchMode.off
                } else {
                    do {
                        let frameworkBundle = Bundle(for: QRCodeViewer.self)
                        let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("QRPayResources.bundle")
                        let resourceBundle = Bundle(url: bundleURL!)
                        let image = UIImage(named: "lighting_on", in: resourceBundle, compatibleWith: nil)
                        lightingButton?.setImage(image, for: .normal)
                        try device.setTorchModeOn(level: 1.0)
                    } catch {
                        print(error)
                    }
                }
                device.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
        }
    }
    
    @objc public func lightingAction(_ sender: UIButton!) {
        if let device = AVCaptureDevice.default(for: AVMediaType.video) {
        if (device.hasTorch) {
            do {
                try device.lockForConfiguration()
                if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                    let image = UIImage(named: "lighting")
                    sender.setImage(image, for: .normal)
                    device.torchMode = AVCaptureDevice.TorchMode.off
                } else {
                    do {
                        let image = UIImage(named: "lighting_on")
                        sender.setImage(image, for: .normal)
                        try device.setTorchModeOn(level: 1.0)
                    } catch {
                        print(error)
                    }
                }
                device.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
        }
    }
    
    func checkCameraAvaliable() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera);
    }
    
    func checkCameraAuthorise() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if status == .restricted || status == .denied {
            
            let alertActionController = UIAlertController(title: "", message: nil, preferredStyle: .alert)
            
            let message: String
            
            switch UIDevice.current.systemVersion.compare("8.0.0", options: NSString.CompareOptions.numeric) {
            case .orderedSame, .orderedDescending:
                message = "Разрешить доступ к камере?"
                alertActionController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                alertActionController.addAction(UIAlertAction(title: "Ок", style: .default, handler: { _ -> Void in
                    UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                }))
            case .orderedAscending:
                // Do Nothing
                message = "Разрешите доступ приложения к камере"
                alertActionController.addAction(UIAlertAction(title: "Ок", style: UIAlertAction.Style.cancel, handler: nil))
            }
            
            alertActionController.message = message
            
            if let topController = UIApplication.topViewController() {
                topController.present(alertActionController, animated: true, completion: nil)
            }
            
            return false
        }
        return true
    }
    
    func sendErrorBlock(message: String) {
        if errorBlock != nil {
            errorBlock!(message)
            stopScan()
        }
    }
    
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension QRCodeViewer: AVCaptureMetadataOutputObjectsDelegate {
    @objc public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        var result: String = ""
        
        for metadataObject in metadataObjects {
                        
            let codeObj = previewLayer.transformedMetadataObject(for: metadataObject)
            
            guard let resultCodeObject = codeObj as? AVMetadataMachineReadableCodeObject else { continue }
            if metadataObject.type == AVMetadataObject.ObjectType.qr {
                result = resultCodeObject.stringValue ?? ""
            }
        }
        
        print(result)
        delegate?.didScanResult(result)
        
        if resultBlock != nil {
            resultBlock!(result)
        }
    }
}
