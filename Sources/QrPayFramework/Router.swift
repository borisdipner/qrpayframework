//
//  Router.swift
//  demoApp
//
//  Created by Wooppay on 04.05.16.
//  Copyright © 2016 Wooppay. All rights reserved.
//

import UIKit

public typealias JSONDictionary = [String: AnyObject]
typealias APIParams = [String : AnyObject]?

//protocol APIConfiguration {
//    var method: Alamofire.Method { get }
//    var encoding: Alamofire.ParameterEncoding? { get }
//    var path: String { get }
//    var parameters: APIParams { get }
//    var baseUrl: String { get }
//}

enum Router: URLRequestConvertible {


    static var baseUrl: String? = URL_BASE
    static var authToken = ""
    static var clientPhone = ""
    static var partnerLogin = ""
    
    case sendSmsCodeForRegistration([String: Any])
    case checkSmsCodeForRegistration([String: Any])
    case getFields([String: Any])
    case checkFields([String: Any])
    case pay([String: Any])
    case payByBalance([String: Any])
    
    case loginCashier([String: Any])
    
    case registerPush([String: Any])
    
    case getClientHistory([String: Any])
    case getHistoryOperationInfo([String: Any])
    case getCashierHistory([String: Any])
    case getCashierPointList([String: Any])
    case cashierActivate([String: Any])
    case cashierChangePasswordRequest([String: Any])
    case cashierChangePasswordConfirm([String: Any])
    case getClientQR([String: Any])
    
    case getClientLinkedCards([String: Any])
    case clientLinkCard([String: Any])
    case clientDeleteLinkedCard([String: Any])
    
    case getServiceName([String: Any])
    case getChecklist([String: Any])
    
    var method: HTTPMethod {
        switch self {
        case
        .getClientHistory,
        .getHistoryOperationInfo,
        .getCashierHistory,
        .getCashierPointList,
        .getFields,
        .getClientQR,
        .getClientLinkedCards,
        .clientLinkCard,
        .getServiceName,
        .getChecklist:
            return .get
        case
        .sendSmsCodeForRegistration,
        .checkSmsCodeForRegistration,
        .pay,
        .payByBalance,
        .checkFields,
        .loginCashier,
        .cashierActivate,
        .cashierChangePasswordConfirm,
        .cashierChangePasswordRequest,
        .registerPush,
        .clientDeleteLinkedCard:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .sendSmsCodeForRegistration:
            return "auth-client/register"
        case .checkSmsCodeForRegistration:
            return "auth-client/entrance"
        case .pay:
            return "payment/pay"
        case .payByBalance:
            return "payment/pay-by-balance"
        case .checkFields:
            return "payment/check-fields"
        case .getFields:
            return "payment/get-fields"
        case .getClientLinkedCards:
            return "card/get-linked-cards"
        case .clientDeleteLinkedCard:
            return "card/remove-card"
        case .clientLinkCard:
            return "card/card-linking"
            
        case .getClientHistory:
            return "history"
        case .getHistoryOperationInfo:
            return "history/get-operation-info"
        case .getCashierHistory:
            return "history"
            
        case .loginCashier:
            return "auth"
        case .getCashierPointList:
            return "user-point"
        case .cashierActivate:
            return "cash-desk/activate"
            
        case .cashierChangePasswordRequest:
            return "auth/restore-password/request"
        case .cashierChangePasswordConfirm:
            return "auth/restore-password/confirm"
            
        case .getClientQR:
            return "qr-code/generate"
            
        case .registerPush:
            return "cashier/set-device-token"
            
        case .getServiceName:
            return "payment/get-service-name"
            
        case .getChecklist:
            return "history/receipt"
        }
    }

    
    func asURLRequest() throws -> URLRequest {
        let url = URL(string: Router.baseUrl ?? "")!
        
        var mutableURLRequest = URLRequest(url: URL(string: path, relativeTo: url)!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 45)
        mutableURLRequest.httpMethod = method.rawValue
        mutableURLRequest.setValue("4", forHTTPHeaderField: "Version")
        mutableURLRequest.setValue("ru", forHTTPHeaderField: "language")
        mutableURLRequest.timeoutInterval = 75
        mutableURLRequest.cachePolicy = .reloadIgnoringCacheData
        if Router.clientPhone != "" {
        mutableURLRequest.setValue(Router.clientPhone, forHTTPHeaderField: "client-phone")
        }
        if Router.partnerLogin != "" {
        mutableURLRequest.setValue(Router.partnerLogin, forHTTPHeaderField: "partner-login")
        }
        
        
        switch self {
        case .sendSmsCodeForRegistration(let parameters),
             .checkSmsCodeForRegistration(let parameters),
             .loginCashier(let parameters),
             .cashierChangePasswordRequest(let parameters):
            return try JSONEncoding.default.encode(mutableURLRequest, with: parameters)
            
        case .pay(let parameters),
             .payByBalance(let parameters),
             .checkFields(let parameters),
             .cashierActivate(let parameters),
             .cashierChangePasswordConfirm(let parameters),
             .registerPush(let parameters),
             .clientDeleteLinkedCard(let parameters):
            mutableURLRequest.setValue(Router.authToken, forHTTPHeaderField: "Authorization")
            return try JSONEncoding.default.encode(mutableURLRequest, with: parameters)
            
        case .getClientHistory(let parameters),
             .getHistoryOperationInfo(let parameters),
             .getCashierHistory(let parameters),
             .getCashierPointList(let parameters),
             .getFields(let parameters),
             .getClientQR(let parameters),
             .getClientLinkedCards(let parameters),
             .clientLinkCard(let parameters),
             .getChecklist(let parameters):
            mutableURLRequest.setValue(Router.authToken, forHTTPHeaderField: "Authorization")
            return try URLEncoding.default.encode(mutableURLRequest, with: parameters)
            
        case .getServiceName(let parameters):
            return try URLEncoding.default.encode(mutableURLRequest, with: parameters)
            
            
//        default:
//            return mutableURLRequest
        }
    }
}
