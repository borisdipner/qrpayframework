//
//  File.swift
//  QRPayFramework
//
//  Created by Wooppay on 16.10.2017.
//  Copyright © 2017 Wooppay. All rights reserved.
//

import Foundation

@objc public class CashierManager: NSObject {
    
    let parsingError = NSError(domain: "com.wooppay", code: 1000, userInfo: [NSLocalizedDescriptionKey: "Incorrect answer from server"])
    
    var authToken = "" {
        didSet {
            Router.authToken = authToken
        }
        
    }
    var clientPhone = "" {
        didSet {
            Router.clientPhone = clientPhone
        }
        
    }
    
    private let manager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        let m = SessionManager(configuration: configuration)
        return m
    }()
    
    var baseUrl: String = URL_BASE {
        didSet {
            Router.baseUrl = baseUrl
        }
        
    }
    
    //MARK: - Init
    
    @objc public override init() {}
    
    @objc public class var sharedInstance: CashierManager {
        struct Singleton {
            static let instance : CashierManager = CashierManager()
        }
        return Singleton.instance
    }
    
    
    @objc public init(authToken: String) {  
        self.authToken = authToken
        self.baseUrl = URL_BASE
        Router.baseUrl = baseUrl
        Router.authToken = authToken
    }
    
    @objc public init(clientPhone: String) {
        self.clientPhone = clientPhone
        self.baseUrl = URL_BASE//(mode == .release) ? URL_BASE_RELEASE : URL_BASE_DEBUG
        Router.baseUrl = baseUrl
        Router.clientPhone = clientPhone
    }
    
    @objc public init(authToken: String, clientPhone: String) {
        self.clientPhone = clientPhone
        self.baseUrl = URL_BASE//(mode == .release) ? URL_BASE_RELEASE : URL_BASE_DEBUG
        Router.baseUrl = baseUrl
        Router.clientPhone = clientPhone
        self.authToken = authToken
        Router.authToken = authToken
    }
    
    //MARK: - Login
    
    @objc public func cashierLogin(login: String, password: String, onSuccess: ((String, NSNumber?) -> Void)? = nil, onError: ((NSError) -> Void)? = nil) {
        let parameters: [String: Any] = [
            "login": login,
            "password" : password
        ]
        
        request(Router.loginCashier(parameters)).responseJSON { (response) in
            self.debugPrintResponse(response: response)
            switch response.result {
            case .success:
                guard let statusCode = response.response?.statusCode else { return }
                guard let value = response.result.value else { return }
                ResponseHelper().checkResponse(statusCode: statusCode, value: value, onSuccess: {
                    var token: String = ""
                    if let t = response.response!.allHeaderFields["Authorization"] as? String {
                        token = t
                    } else {
                        let t = (value as! [String : Any])["Authorization"]
                        token = "\(t ?? "")"
                    }
                    let userId = (value as! [String : Any])["id"]
                    print(token)
                    onSuccess?(token, NSNumber(value: Int("\(userId ?? "0")")!))
                }, onError: { (error) in
                    onError?(error)
                })
            case .failure(let error):
                guard let statusCode = response.response?.statusCode else {
                    onError?(ErrorResponse(error: error as NSError).getError())
                    return
                }
                if statusCode >= 200 && statusCode <= 300 {
                    var token: String = ""
                    if let t = response.response!.allHeaderFields["Authorization"] as? String {
                        token = t
                    } 
                    print(token)
                    onSuccess?(token, nil)
                } else {
                    print("Request failed with error: \(error)")
                    onError?(ErrorResponse(error: error as NSError).getError())
                }
            }
        }
    }
    
    @objc public func activateCashier(qrCode: String, onSuccess: ((_ pointId: Int, _ cashDeskId: Int) -> Void)? = nil, onError: ((NSError) -> Void)? = nil) {
        let parameters: [String: Any] = [
            "qr_code": qrCode
        ]
        
        request(Router.cashierActivate(parameters)).responseJSON { (response) in
            self.debugPrintResponse(response: response)
            switch response.result {
            case .success:
                guard let statusCode = response.response?.statusCode else { return }
                guard let value = response.result.value else { return }
                ResponseHelper().checkResponse(statusCode: statusCode, value: value, onSuccess: {
                    let pointId = "\((value as! [String: Any])["point_id"] ?? 0)"
                    let cashDeskId = "\((value as! [String: Any])["cash_desk_id"] ?? 0)"
                    
                    onSuccess?(Int(pointId) ?? 0, Int(cashDeskId) ?? 0)
                }, onError: { (error) in
                    onError?(error)
                })
            case .failure(let error):
                print("Request failed with error: \(error)")
                onError?(ErrorResponse(error: error as NSError).getError())
            }
        }
    }
    
    //MARK: - Password restore
    
    @objc public func cashierChangePasswordRequest(login: String, merchantLogin: String, onSuccess: ((String) -> Void)? = nil, onError: ((NSError) -> Void)? = nil) {
        let parameters: [String: Any] = [
            "phone": login,
            "merchant_phone" : merchantLogin
        ]
        
        request(Router.cashierChangePasswordRequest(parameters)).responseJSON { (response) in
            self.debugPrintResponse(response: response)
            switch response.result {
            case .success:
                guard let statusCode = response.response?.statusCode else { return }
                guard let value = response.result.value else { return }
                ResponseHelper().checkResponse(statusCode: statusCode, value: value, onSuccess: {
                    var token: String = ""
                    if let t = response.response!.allHeaderFields["Authorization"] as? String {
                        token = t
                    } else {
                        let t = (value as! [String : Any])["Authorization"]
                        token = "\(t ?? "")"
                    }
                    print(token)
                    onSuccess?(token)
                }, onError: { (error) in
                    onError?(error)
                })
            case .failure(let error):
                guard let statusCode = response.response?.statusCode else {
                    onError?(ErrorResponse(error: error as NSError).getError())
                    return
                }
                if statusCode >= 200 && statusCode <= 300 {
                    var token: String = ""
                    if let t = response.response!.allHeaderFields["Authorization"] as? String {
                        token = t
                    }
                    print(token)
                    onSuccess?(token)
                } else {
                    print("Request failed with error: \(error)")
                    onError?(ErrorResponse(error: error as NSError).getError())
                }
            }
        }
    }
    
    @objc public func cashierChangePasswordConfirm(password: String, onSuccess: (() -> Void)? = nil, onError: ((NSError) -> Void)? = nil) {
        let parameters: [String: Any] = [
            "password": password
        ]
        
        request(Router.cashierChangePasswordConfirm(parameters)).responseJSON { (response) in
            self.debugPrintResponse(response: response)
            switch response.result {
            case .success:
                guard let statusCode = response.response?.statusCode else { return }
                guard let value = response.result.value else { return }
                ResponseHelper().checkResponse(statusCode: statusCode, value: value, onSuccess: {
                    onSuccess?()
                }, onError: { (error) in
                    onError?(error)
                })
            case .failure(let error):
                print("Request failed with error: \(error)")
                onError?(ErrorResponse(error: error as NSError).getError())
            }
        }
    }
    
    //MARK: - History
    
    @objc public func getHistory(pointId: NSNumber?, cashDeskId: NSNumber?, count: NSNumber? = 99999999, page: NSNumber? = 1, onSuccess: (([History]) -> Void)? = nil, onError: ((NSError) -> Void)? = nil) {
        
        var parameters: [String: Any] = [:]
        parameters["per-page"] = count
        parameters["page"] = page
        if pointId != nil { parameters["point_id"] = pointId }
        if cashDeskId != nil { parameters["cash_desk_id"] = cashDeskId }
        manager.request(Router.getCashierHistory(parameters)).responseJSON { (response) in
            self.debugPrintResponse(response: response)
            switch response.result {
            case .success:
                var pageCount = response.response?.allHeaderFields["X-Pagination-Page-Count"]
                if pageCount == nil {
                    pageCount = response.response?.allHeaderFields["x-pagination-page-count"]
                }
                let pageCountInt = Int("\(pageCount ?? "0")")
                if (pageCountInt ?? 1) < (page?.intValue ?? 1) {
                    onSuccess?([])
                } else {
                    guard let statusCode = response.response?.statusCode else { return }
                    guard let value = response.result.value else { return }
                    ResponseHelper().checkResponse(statusCode: statusCode, value: value, onSuccess: {
                        if let data = Mapper<History>().mapArray(JSONObject: value as? [[String: Any]]) {
                            onSuccess?(data)
                        }
                    }, onError: { (error) in
                        onError?(error)
                    })
                }
            case .failure(let error):
                guard let statusCode = response.response?.statusCode else {
                    onError?(ErrorResponse(error: error as NSError).getError())
                    return
                }
                if statusCode >= 200 && statusCode <= 300 {
                    onSuccess?([])
                } else {
                    print("Request failed with error: \(error)")
                    onError?(ErrorResponse(error: error as NSError).getError())
                }
            }
        }
    }
    
    @objc public func saveCheckListFromHistory(operationId: Int, onSuccess: ((URL, String) -> Void)? = nil, onError: ((NSError) -> Void)? = nil) {
//        let url = URL(string: "\(URL_BASE)history/receipt?id=\(operationId)")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue(authToken, forHTTPHeaderField: "Authorization")
//
        var fileName: String?
        var finalPath: URL?
        
        download(Router.getChecklist(["id": operationId]), to: { (temporaryURL, response) in
            var directoryURL: URL?
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            if urls.count > 0 {
                 directoryURL = urls[0]
            }
                fileName = "\(operationId).pdf"
            if directoryURL != nil {
                finalPath = directoryURL?.appendingPathComponent(fileName!)
                return (finalPath!, [.createIntermediateDirectories, .removePreviousFile])
            }
            return (temporaryURL, [.createIntermediateDirectories, .removePreviousFile])
        }).responseJSON { response in
            
            
            let error = NSError(domain: "com.wooppay", code: -1, userInfo: [NSLocalizedDescriptionKey: "Во время сохранения файла произошла ошибка"])
            let statusCode = response.response?.statusCode ?? 200
            if statusCode >= 200 && statusCode <= 300 {
                if let finalPath = finalPath {
                    onSuccess?(finalPath, fileName ?? "qr")
                } else {
                    
                    onError?(error)
                }
                return
            }
            guard let data = response.result.value else {
                onError?(error)
                return
            }
            ResponseHelper().checkResponse(statusCode: statusCode, value: data, onSuccess: {
                if let finalPath = finalPath {
                    onSuccess?(finalPath, fileName ?? "qr")
                } else {
                    
                    onError?(error)
                }
            }, onError: { (error) in
                onError?(error)
            })
            
        }
    }
    
    //MARK: - Point list
    
    @objc public func getCashierPoints(userId: NSNumber? = nil, count: NSNumber? = 99999999, page: NSNumber? = 1, onSuccess: (([QRPoint]) -> Void)? = nil, onError: ((NSError) -> Void)? = nil) {
        
        var parameters: [String: Any] = [:]
        parameters["expand"] = "point"
        if userId != nil { parameters["user_id"] = userId }
        manager.request(Router.getCashierPointList(parameters)).responseJSON { (response) in
            self.debugPrintResponse(response: response)
            switch response.result {
            case .success:
                guard let statusCode = response.response?.statusCode else { return }
                guard let value = response.result.value else { return }
                ResponseHelper().checkResponse(statusCode: statusCode, value: value, onSuccess: {
                    if let data = Mapper<QRPointModel>().mapArray(JSONObject: value as? [[String: Any]]) {
                        var points: [QRPoint] = []
                        data.forEach {
                            if let point = $0.point {
                                points.append(point)
                            }
                        }
                        onSuccess?(points)
                    }
                }, onError: { (error) in
                    onError?(error)
                })
            case .failure(let error):
                guard let statusCode = response.response?.statusCode else {
                    onError?(ErrorResponse(error: error as NSError).getError())
                    return
                }
                if statusCode >= 200 && statusCode <= 300 {
                    onSuccess?([])
                } else {
                    print("Request failed with error: \(error)")
                    onError?(ErrorResponse(error: error as NSError).getError())
                }
            }
        }
    }
    
    //MARK: - Push
    
    @objc public func registerPush(token: String, onSuccess: (() -> Void)? = nil, onError: ((NSError) -> Void)? = nil) {
        let parameters: [String: Any] = [
            "token": token
        ]
        
        request(Router.registerPush(parameters)).responseJSON { (response) in
            self.debugPrintResponse(response: response)
            switch response.result {
            case .success:
                guard let statusCode = response.response?.statusCode else { return }
                guard let value = response.result.value else { return }
                ResponseHelper().checkResponse(statusCode: statusCode, value: value, onSuccess: {
                    
                    onSuccess?()
                }, onError: { (error) in
                    onError?(error)
                })
            case .failure(let error):
                print("Request failed with error: \(error)")
                onError?(ErrorResponse(error: error as NSError).getError())
            }
        }
    }
    
    func debugPrintResponse(response: DataResponse<Any>) {
        debugPrint(response.request?.url?.absoluteString ?? "")
        debugPrint(response.request?.httpMethod ?? "")
        debugPrint(response.request?.allHTTPHeaderFields ?? "")
        if let httpBody = response.request?.httpBody {
            debugPrint(String(data: httpBody, encoding: String.Encoding.utf8) ?? "")
        }
        
        guard let resultValue = response.result.value else {
            NSLog("Result value in response is nil")
            return
        }
        let responseJSON = JSON(resultValue)
        debugPrint(responseJSON)
    }
}

