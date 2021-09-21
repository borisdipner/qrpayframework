//
//  Card.swift
//  QRPayFramework
//
//  Created by Yekaterina Gekkel on 07.03.2018.
//  Copyright © 2018 Wooppay. All rights reserved.
//

import Foundation

@objc public class Card: NSObject, Mappable {
    
    @objc public var id: Int = 0
    @objc public var mask: String = ""
    @objc public var bankName: String = ""
    
    public convenience required init?(map: Map){
        self.init()
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        mask <- map["mask"]
        bankName <- map["bank_name"]        
    }
    
}
