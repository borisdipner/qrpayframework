//
//  Operation.swift
//  QRPayFramework
//
//  Created by Yekaterina Gekkel on 31.01.2018.
//  Copyright © 2018 Wooppay. All rights reserved.
//

import Foundation

@objc public class Operation: NSObject, Mappable {
    
    @objc public var id: String = ""
    @objc public var status: HistoryStatus = .Reject
    
    public convenience required init?(map: Map){
        self.init()
    }
    
    public func mapping(map: Map) {
        id <- map["operation_id"]
        var statusCode: Int = 0
        statusCode <- map["status_id"]
        if statusCode == 2  {
            status = .Accept
        } else if statusCode == 1 || statusCode == 3 {
            status = .Pending
        } else if statusCode == 4 || statusCode == 5 || statusCode == 6  {
            status = .Reject
        } else {
            status = .Pending
        }
//        status = HistoryStatus(rawValue: statusCode) ?? .Reject
    }
    
}
