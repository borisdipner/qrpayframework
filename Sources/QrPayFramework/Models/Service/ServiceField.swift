//
//  ServiceField.swift
//  WoopPay
//
//  Created by Wooppay on 03.06.16.
//  Copyright © 2016 Wooppay. All rights reserved.
//
import Foundation

@objc public class ServiceField: NSObject, Mappable {
    
    @objc public var name: String?
    
    @objc public var title: String?
    
    public var typeField: FieldType? {
        get {
            if let typeField = type {
                if let fieldType = FieldType(rawValue: typeField) {
                    return fieldType
                } else {
                    return FieldType.Unknown
                }
            } else {
                return FieldType.Unknown
            }
        }
        set {
            type = newValue!.rawValue
        }
    }
    @objc public var type: String?
    
    @objc public var mask: String?
    @objc public var value: String?
    @objc public var isNeedSend: Bool = false
    @objc public var hidden: Bool = false
    @objc public var readonly: Bool = false
    
    @objc public var maxLength: NSNumber?
    @objc public var minLength: NSNumber?
    
    @objc public var values: [Value]?
    
    @objc public var desc = ""
    
    required convenience public init?(map: Map)  {
        self.init()
    }
    
    
    public override init() {}
    
    public func mapping(map: Map) {
        name <- map["name"]
        title <- map["title"]
        type <- map["type"]
        mask <- map["mask"]
        hidden <- map["hidden"]
        readonly <- map["readonly"]
        
        var v: AnyObject?
        v <- map["value"]
        if let vS = v {
            value = "\(vS)"
        }
        values <- map["values"]
        maxLength <- map["max_length"]
        minLength <- map["min_length"]
        
        isNeedSend <- map["is_need_send"]
    }
    
}

public enum FieldType: String {
    case Unknown = "unknown",
    String = "string",
    Number = "number",
    Label = "label",
    SelectOne = "select_one",
    Captcha = "captcha",
    Recaptcha = "recaptcha",
    Button = "button",
    Amount = "amount",
    FixSum = "fixSum",
    Invoice = "invoice"
}


