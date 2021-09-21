//
//  Service.swift
//  QRPayFramework
//
//  Created by Yekaterina Gekkel on 25.01.2018.
//  Copyright © 2018 Wooppay. All rights reserved.
//

import UIKit

@objc public class Service: NSObject, Mappable {
    
    @objc public var merchantName: String?
    @objc public var fields: [ServiceField]?
    @objc public var payButtons: [Value]?
    
    public convenience required init?(map: Map){
        self.init()
    }
    
    public func mapping(map: Map) {
        fields <- map["fields"]
        merchantName <- map["merchant_name"]
        payButtons <- map["pay_btns"]
        
        
    }
    
}
