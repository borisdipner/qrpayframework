//
//  Value.swift
//  WoopPay
//
//  Created by Wooppay on 16.06.16.
//  Copyright © 2016 Wooppay. All rights reserved.
//
import Foundation

@objc public class Value: NSObject, Mappable {

   @objc public var key: String?
   @objc public var value: String?
    
    required convenience public init?(map: Map) {
        self.init()
    }
    
    public func mapping(map: Map) {
        var k: AnyObject?
        k <- map["key"]
        if let _ = k {
            key = "\(k!)"
        } else {
            key = ""
        }
        value <- map["value"]
    }
    
    
}

