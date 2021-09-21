//
//  PayFromCardModel.swift
//  QRPayFramework
//
//  Created by Yekaterina Gekkel on 13.02.2018.
//  Copyright © 2018 Wooppay. All rights reserved.
//

import Foundation

@objc public class PaymentModel: NSObject, Mappable {
    
    @objc public var iframeUrl: String?
    @objc public var cookies: String?
    @objc public var operation: Operation?
    
    
    public convenience required init?(map: Map){
        self.init()
    }
    
    public func mapping(map: Map) {
        operation <- map["operation"]
        iframeUrl <- map["iframe"]
        cookies <- map["cookies"]
    }
    
}
