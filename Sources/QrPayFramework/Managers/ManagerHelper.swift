//
//  ManagerHelper.swift
//  QrPayFramework
//
//  Created by Wooppay on 06.05.16.
//  Copyright © 2016 Wooppay. All rights reserved.
//

import Foundation

class ManagerHelper<T: Mappable> {
    
    init() {}
    
    func parseResponseToMappableModel(response: Any, onSuccess: (((Date?, T)) -> Void)? = nil, onError: ((NSError) -> Void)? = nil) {
        let respMap = Mapper<CommonResponse<T>>().map(JSON: response as! [String : Any])
        if respMap!.data != nil {
            onSuccess?((respMap?.lastChanged, (respMap?.data)!))
        } else {
            let errorResp = Mapper<ErrorResponse>().map(JSON: response as! [String : Any])
            if  errorResp?.code != nil {
                onError?(errorResp!.getError())
            } else {
                if let data = respMap?.data {
                    onSuccess?((nil, data))
                }
            }
        }
    }
    
    func parseArrayResponseToMappableModel(response: Any, onSuccess: (((Date?, [T])) -> Void)? = nil, onError: ((NSError) -> Void)? = nil) {
        let respMap = Mapper<CommonArrayResponse<T>>().map(JSON: response as! [String : Any])
        if let data = respMap?.data {
            if data.count > 0 {
                onSuccess?((respMap?.lastChanged, (respMap?.data)!))
            } else {
                let errorResp = Mapper<ErrorResponse>().map(JSON: response as! [String : Any])
                if  errorResp?.code != nil {
                    onError?(errorResp!.getError())
                } else {
                    let data: [T] = []
                    onSuccess?((nil ,data))
                }
            }
        } else {
            let errorResp = Mapper<ErrorResponse>().map(JSON: response as! [String : Any])
            if  errorResp?.code != nil {
                onError?(errorResp!.getError())
            } else {
                let data: [T] = []
                onSuccess?((nil ,data))
            }
        }
    }
    
    func parseItemsResponseToMappableModel(response: Any, onSuccess: (([T]) -> Void)? = nil, onError: ((NSError) -> Void)? = nil) {
        
        let respMap = Mapper<ItemsResponse<T>>().map(JSON: response as! [String : Any])
        if let data = respMap?.items {
            if data.count > 0 {
                onSuccess?((respMap?.items)!)
            } else {
                let errorResp = Mapper<ErrorResponse>().map(JSON: response as! [String : Any])
                if  errorResp?.code != nil {
                    onError?(errorResp!.getError())
                } else {
                    let data: [T] = []
                    onSuccess?(data)
                }
            }
        } else {
            let errorResp = Mapper<ErrorResponse>().map(JSON: response as! [String : Any])
            if  errorResp?.code != nil {
                onError?(errorResp!.getError())
            } else {
                let data: [T] = []
                onSuccess?(data)
            }
        }
    }
    
    func parseModel(response: Any, onSuccess: ((T) -> Void)? = nil, onError: ((NSError) -> Void)? = nil) {
        let errorResp = Mapper<ErrorResponse>().map(JSON: response as! [String : Any])
        if  errorResp?.code != nil {
            onError?(errorResp!.getError())
        } else {
            let respMap = Mapper<T>().map(JSON: response as! [String : Any])
            onSuccess?(respMap!)
        }
    }
}

public class ResponseHelper {
    
    public func checkResponse(statusCode: Int, value: Any, onSuccess: (() -> Void)? = nil, onError: ((NSError) -> Void)? = nil) {
        switch(statusCode) {
        case 200..<300:
            onSuccess?()
        case 422:
            if let array = value as? [[String : Any]] {
                let data = Mapper<ErrorModel>().mapArray(JSONArray: array)
                if data.count > 0 {
                    let error = NSError(domain: "com.wooppay", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "\(data[0].message ?? "Произошла ошибка, попробуйте позже!")"])
                    onError?(error)
                } else {
                    let error = NSError(domain: "com.wooppay", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Произошла ошибка, попробуйте позже!"])
                    onError?(error)
                }
            } else {
                let error = NSError(domain: "com.wooppay", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Произошла ошибка, попробуйте позже!"])
                onError?(error)
            }
        case 500:
            if let data = Mapper<ErrorResponse>().map(JSON: (value as! [String : Any])) {
                onError?(data.getError())
            }
        default:
            if let error = Mapper<ErrorResponse>().map(JSON: value as! [String : Any]) {
                error.code = statusCode
                onError?(error.getError())
            } else {
                onError?(ErrorResponse(error: NSError()).getError(from: statusCode))
            }
        }
    }
}
