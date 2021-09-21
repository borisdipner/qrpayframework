//
//  CommonResponse.swift
//  WoopPay
//
//  Created by Wooppay on 06.05.16.
//  Copyright © 2016 Wooppay. All rights reserved.
//

import UIKit

@objc public class SuccessResponse: NSObject, Mappable {
     public var success: Bool?
     public var errorCode: Int?
     public var message: String?
    
    required  public init?(map: Map){
        
    }
    
     public func mapping(map: Map) {
        success <- map["success"]
        errorCode <- map["errorCode"]
        message <- map["message"]
    }
}

@objc public class ErrorModel: NSObject, Mappable {
    public var fieldString: String?
    public var message: String?
    
    
    required public init?(map: Map){
        
    }
    
    public func mapping(map: Map) {
        fieldString <- map["field"]
        message <- map["message"]
    }
    
}

@objc public class ErrorResponse: NSObject, Mappable {
     public var code: Int?
     public var data: ExceptionData?
     @objc public var message: String = ""
     public var classError: String?
    
    required  public init?(map: Map){
        
    }
    
     public init(error: NSError) {
        code = error.code
        message = error.localizedDescription
//        data = data
        if classError == nil {
            classError = "com.wooppay.error"
        }
    }
    
     public func mapping(map: Map) {
        code <- map["code"]
        data <- map["data"]
        message <- map["message"]
        classError <- map["class"]
    }
    
    func getError() -> NSError {
        var msg = self.message
        if let _ = code {
            if let data  = data {
                if let datadata = data.data {
                    msg = "\(datadata.values.first![0])"
                } else {
                    msg = getErrorMessage(from: code!)
                }
            } else {
                msg = getErrorMessage(from: code!)
            }            
        }
        if msg.range(of: "Request:") != nil {
            msg = "Ошибка сервера. Попробуйте, пожалуйста, позже."//"\(message)"
        }
        let error = NSError(domain: "com.wooppay", code: code!, userInfo: [NSLocalizedDescriptionKey: "\(msg)"])
        return error
    }
    
    func getErrorMessage(from code: Int) -> String {
        var msg = self.message
        switch code {
        case -1001:
            msg = "Время ожидания ответа от сервера истекло. Попробуйте еще раз."
        case -1005, -1009:
            msg = "Отсутствует интернет соединение"
        case 1030:
            msg = "На Вашем счету недостаточно средств"
        case 3051:
            msg = "Ваш кошелек заблокирован из-за подозрительной активности. Обратитесь в Службу поддержки"
        case 3003:
            msg = "Неверный логин или пароль"
        case 3002:
            msg = "Данный аккаунт не зарегистрирован в системе"
        case 4002:
            msg = "Вы ввели некорректные данные"
        case 4013:
            msg = "Аккаунт указан неверно"
        case 1:
            msg = "Возникли технические неполадки, попробуйте позже"
        default:
            if message.range(of: "Request:") != nil {
                msg = "Ошибка сервера. Попробуйте, пожалуйста, позже."//"\(message)"
            }
        }
        return msg
    }
    
    func getError(from code: Int) -> NSError {
        self.code = code
        self.message = getErrorMessage(from: code)
        return getError()
    }
}

@objc  public class ExceptionData: NSObject, Mappable {
     public var skipLog: Bool?
     public var data: [String: [String]]?
     public var fields: String?
    
    required  public init?(map: Map){
        
    }
    
     public func mapping(map: Map) {
        skipLog <- map["skipLog"]
        data <- map["data"]
        fields <- map["fields"]
    }
}

public class CommonArrayResponse<T: Mappable>: Mappable {
    
     public var lastChanged: Date?
     public var data: [T]?
    
    required  public init?(map: Map){
        
    }
    
     public func mapping(map: Map) {
        var lastChangedString: Double?
        lastChangedString <- map["last_changed"]
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let str = lastChangedString {
            lastChanged = Date(timeIntervalSince1970: str)
        }
        data <- map["data"]
    }
    
}

public class CommonResponse<T: Mappable>: Mappable {
    
     public var lastChanged: Date?
     public var data: T?
    
    required  public init?(map: Map){
        
    }
    
     public func mapping(map: Map) {
        var lastChangedString: Double?
        lastChangedString <- map["last_changed"]
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let str = lastChangedString {
            lastChanged = Date(timeIntervalSince1970: str)
        }
        data <- map["data"]
    }
    
}

public class ItemsResponse<T: Mappable>: Mappable {
    
     public var count: Int?
     public var items: [T]?
    
    required  public init?(map: Map){
        
    }
    
     public func mapping(map: Map) {
        var countString: String?
        countString <- map["count"]
        if let str = countString {
            count = Int(str)
        }
        items <- map["items"]
    }
}

