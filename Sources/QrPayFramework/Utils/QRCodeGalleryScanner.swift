//
//  QRCodeGalleryScanner.swift
//  QRPayFramework
//
//  Created by Yekaterina Ignatyeva on 6/9/20.
//  Copyright © 2020 Wooppay. All rights reserved.
//

import UIKit
import AVFoundation
 
@objc public class QRCodeGalleryScanner: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public var delegate: QRCodeViewerDelegate?
    var imagePicker = UIImagePickerController()
    
    fileprivate var resultBlock: QRResultBlock?
    fileprivate var errorBlock: QRErrorBlock?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){

            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            openPicker()
        }
    }
    
    private func openPicker() {
        present(imagePicker, animated: true, completion: nil)
    }
 
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("pick pick pick")
        if let qrcodeImg = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage {
            let detector: CIDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
            let ciImage: CIImage = CIImage(image:qrcodeImg)!
            var result = ""
  
            let features = detector.features(in: ciImage)
            for feature in features as! [CIQRCodeFeature] {
                result += feature.messageString!
            }
            

            print(result)
            
//            if resultBlock != nil {

                self.dismiss(animated: true, completion: {
                    self.delegate?.didScanResult(result)
                    self.resultBlock?(result)
                
                })
//            }
        }
        else{
           sendErrorBlock(message: "Не удалось распознать изображение")
        }
       self.dismiss(animated: true, completion: nil)
      }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: {
            self.delegate?.didScanResult("cancel")
            self.resultBlock?("cancel")
        
        })
        self.dismiss(animated: true, completion: nil)
    }
    
    func sendErrorBlock(message: String) {
        if errorBlock != nil {
            errorBlock!(message)
        }
    }
}
