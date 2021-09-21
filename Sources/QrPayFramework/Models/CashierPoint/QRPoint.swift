//
//  QRPoint.swift
//  QRPayFramework
//
//  Created by Wooppay on 27.10.2017.
//  Copyright © 2017 Wooppay. All rights reserved.
//

import Foundation

@objc public class QRPointModel: NSObject, Mappable {
    
    @objc public var point: QRPoint?
    
    public convenience required init?(map: Map){
        self.init()
    }
    
    public func mapping(map: Map) {
        point <- map["point"]
        
        
    }
    
}

@objc public class QRPoint: NSObject, Mappable {
    
     @objc public var id: Int = 0
     @objc public var merchantId: Int = 0
     @objc public var name: String?
     @objc public var address: String?
     @objc public var createTime: Date?
     @objc public var status: Int = 0
    
    public convenience required init?(map: Map){
        self.init()
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        status <- map["status"]
        merchantId <- map["merchant_id"]
        name <- map["name"]
        address <- map["address"]
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormat.timeZone = TimeZone(secondsFromGMT: 0)
        var dateString: String?
        dateString <- map["create_time"]
        if let str = dateString {
            createTime = dateFormat.date(from: str)
        }
        
        
    }
    
}
