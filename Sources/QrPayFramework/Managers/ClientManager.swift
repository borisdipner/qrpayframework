//
//  File.swift
//  QRPayFramework
//
//  Created by Wooppay on 16.10.2017.
//  Copyright © 2017 Wooppay. All rights reserved.
//

import UIKit

@objc open class ClientManager: NSObject {
    
    let parsingError = NSError(domain: "com.wooppay", code: 1000, userInfo: [NSLocalizedDescriptionKey: "Во время запроса произошла ошибка, попробуйте еще раз."])
    
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
    
    var partnerLogin = "" {
        didSet {
            Router.partnerLogin = partnerLogin
        }
    }
    
    private let manager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        let m = SessionManager.default//SessionManager(configuration: configuration)
        return m
    }()
    
    var baseUrl: String = URL_BASE {
        didSet {
            Router.baseUrl = baseUrl
        }
        
    }
    
    //MARK: - Init
    
    @objc public override init() {}
    
    @objc open class var sharedInstance: ClientManager {
        struct Singleton {
            static let instance : ClientManager = ClientManager()
        }
        return Singleton.instance
    }
    
    
    @objc public init(authToken: String) {
        self.authToken = authToken
        self.baseUrl = URL_BASE//(mode == .release) ? URL_BASE_RELEASE : URL_BASE_DEBUG
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
    
    @objc public init(authToken: String, partnerLogin: String) {
        self.partnerLogin = partnerLogin
        Router.partnerLogin = partnerLogin
        self.authToken = authToken
        self.baseUrl = URL_BASE//(mode == .release) ? URL_BASE_RELEASE : URL_BASE_DEBUG
        Router.baseUrl = baseUrl
        Router.authToken = authToken
    }
    
    @objc public init(clientPhone: String, partnerLogin: String) {
        self.partnerLogin = partnerLogin
        Router.partnerLogin = partnerLogin
        self.clientPhone = clientPhone
        self.baseUrl = URL_BASE//(mode == .release) ? URL_BASE_RELEASE : URL_BASE_DEBUG
        Router.baseUrl = baseUrl
        Router.clientPhone = clientPhone
    }
    
    @objc public init(authToken: String, clientPhone: String, partnerLogin: String) {
        self.partnerLogin = partnerLogin
        Router.partnerLogin = partnerLogin
        self.clientPhone = clientPhone
        self.baseUrl = URL_BASE//(mode == .release) ? URL_BASE_RELEASE : URL_BASE_DEBUG
        Router.baseUrl = baseUrl
        Router.clientPhone = clientPhone
        self.authToken = authToken
        Router.authToken = authToken
    }
    
    //MARK: - Login
    
    @objc open func clientLogin(login: String, partnerLogin: String? = "partner_c", onSuccess: (() -> Void)? = nil, onError: ((NSError) -> Void)? = nil) {
        var parameters: [String: Any] = [
            "login": login
        ]
        parameters["partner_login"] = partnerLogin
        manager.request(Router.sendSmsCodeForRegistration(parameters)).responseJSON { (response) in
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
    
    @objc open func checkSMS(login: String, code: String, partnerLogin: String? = "partner_c", onSuccess: ((String) -> Void)? = nil, onError: ((NSError) -> Void)? = nil) {
        var parameters: [String: Any] = [
            "login": login,
            "code": code
        ]
        parameters["partner_login"] = partnerLogin
        request(Router.checkSmsCodeForRegistration(parameters)).responseJSON { (response) in
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
    
    @objc open func getClientQR(onSuccess: ((UIImage?) -> Void)? = nil, onError: ((NSError) -> Void)? = nil) {
        
        let error = NSError(domain: "com.wooppay", code: -1, userInfo: [NSLocalizedDescriptionKey: "Во время запроса произошла ошибка"])
        request(Router.getClientQR([:])).responseData { (response) in
            
            debugPrint(response.request?.url?.absoluteString ?? "")
            debugPrint(response.request?.httpMethod ?? "")
            debugPrint(response.request?.allHTTPHeaderFields ?? "")
            if let httpBody = response.request?.httpBody {
                debugPrint(String(data: httpBody, encoding: String.Encoding.utf8) ?? "")
            }
            
            guard response.result.value != nil else {
                onError?(ErrorResponse(error: error as NSError).getError())
                return
            }
            
            switch response.result {
            case .success:
                guard let statusCode = response.response?.statusCode else {
                    
                    onError?(ErrorResponse(error: error as NSError).getError())
                    return
                }
                if statusCode >= 200 && statusCode < 300 {
                    if let data = response.data {
                        onSuccess?(UIImage(data: data))
                    } else {
                        onError?(ErrorResponse(error: error as NSError).getError())
                    }
                } else {
                    if let data = response.data {
                        do {
                            if let todoJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                ResponseHelper().checkResponse(statusCode: statusCode, value: todoJSON, onSuccess: {
                                    
                                }, onError: { (error) in
                                    onError?(error)
                                })
                            } else {
                                onError?(ErrorResponse(error: error as NSError).getError())
                            }
                        } catch {
                            onError?(ErrorResponse(error: error as NSError).getError())
                            return
                        }
                    }
                }
            case .failure(let error):
                onError?(ErrorResponse(error: error as NSError).getError())
            }
        }
        
    }
    
        //MARK: - Payment
    
    @objc open func getFields(qrCode: String?, onSuccess: ((Service) -> Void)? = nil, onError: ((NSError) -> Void)? = nil) {
        var fields: [String: Any] = [:]
        fields["qr_code"] = qrCode
        
        request(Router.getFields(fields)).responseJSON(completionHandler: { (response) in
            self.debugPrintResponse(response: response)
            switch response.result {
            case .success:
                guard let statusCode = response.response?.statusCode else { return }
                guard let value = response.result.value else { return }
                ResponseHelper().checkResponse(statusCode: statusCode, value: value, onSuccess: {
                    if let data = Mapper<Service>().map(JSONObject: (value as! [String: Any])) {
                        onSuccess?(data)
                    }
                }, onError: { (error) in
                    onError?(error)
                })
            case .failure(let error):
                print("Request failed with error: \(error)")
                onError?(ErrorResponse(error: error as NSError).getError())
            }
        })
    }
    
    @objc open func checkFields(qrCode: String, fields: [String: Any], onSuccess: (([String: Any], [ServiceField]?) -> Void)? = nil, onError: ((NSError) -> Void)? = nil) {
        var fieldsData: [String: Any] = [:]
        fieldsData["fields"] = fields
        fieldsData["qr_code"] = qrCode
        
        request(Router.checkFields(fieldsData)).responseJSON(completionHandler: { (response) in
            self.debugPrintResponse(response: response)
            switch response.result {
            case .success:
                guard let statusCode = response.response?.statusCode else { return }
                guard let value = response.result.value else { return }
                ResponseHelper().checkResponse(statusCode: statusCode, value: value, onSuccess: {
                    var addFields: [ServiceField] = []
                    if let data = Mapper<ServiceField>().mapArray(JSONObject: (value as! [String: Any])["additional_fields"] as? [[String : Any]]) {
                        addFields = data
                    }
                    onSuccess?((value as! [String: Any])["fields"] as! [String : Any], addFields)
                }, onError: { (error) in
                    onError?(error)
                })
            case .failure(let error):
                print("Request failed with error: \(error)")
                onError?(ErrorResponse(error: error as NSError).getError())
            }
        })
    }
    
    @objc open func pay(paymentType: NSNumber? = 1, qrCode: String?, fields: [String: Any]?, partnerLogin: String? = "partner_c", cardId: NSNumber? = nil, onSuccess: ((PaymentModel) -> Void)? = nil, onError: ((NSError) -> Void)? = nil) {
        var fieldsData: [String: Any] = [:]
        fieldsData["fields"] = fields
        fieldsData["partner_login"] = partnerLogin
        fieldsData["qr_code"] = qrCode
        fieldsData["payment_type"] = paymentType
        if cardId != nil {
            fieldsData["card_id"] = cardId
         }
        
        request(Router.pay(fieldsData)).responseJSON(completionHandler: { (response) in
            self.debugPrintResponse(response: response)
            switch response.result {
            case .success:
                guard let statusCode = response.response?.statusCode else { return }
                guard let value = response.result.value else { return }
                ResponseHelper().checkResponse(statusCode: statusCode, value: value, onSuccess: {
                    if let operation = Mapper<PaymentModel>().map(JSONObject: (value as! [String: Any])) {
                        onSuccess?(operation)
                    } else {
                        onError?(self.parsingError)
                    }
                }, onError: { (error) in
                    onError?(error)
                })
            case .failure(let error):
                print("Request failed with error: \(error)")
                onError?(ErrorResponse(error: error as NSError).getError())
            }
        })
    }
    
    @objc open func payByBalance(qrCode: String?, fields: [String: Any]?, partnerLogin: String? = "partner_c", onSuccess: ((NSNumber, HistoryStatus) -> Void)? = nil, onError: ((NSError) -> Void)? = nil) {
        var fieldsData: [String: Any] = [:]
        fieldsData["fields"] = fields
        fieldsData["partner_login"] = partnerLogin
        fieldsData["qr_code"] = qrCode
        
        request(Router.payByBalance(fieldsData)).responseJSON(completionHandler: { (response) in
            self.debugPrintResponse(response: response)
            switch response.result {
            case .success:
                guard let statusCode = response.response?.statusCode else { return }
                guard let value = response.result.value else { return }
                ResponseHelper().checkResponse(statusCode: statusCode, value: value, onSuccess: {
                    let operationId = Int("\(((value as! [String: Any])["operation"] as! [String: Any])["operation_id"] ?? 0)") ?? 0
                    let statusCode = Int("\(((value as! [String: Any])["operation"] as! [String: Any])["status_id"] ?? 0)") ?? 0
                    var status: HistoryStatus?
                    if statusCode == 2  {
                        status = .Accept
                    } else if statusCode == 1 || statusCode == 3 {
                        status = .Pending
                    } else if statusCode == 4 || statusCode == 5 || statusCode == 6  {
                        status = .Reject
                    } else {
                        status = .Pending
                    }
                    onSuccess?(NSNumber(value: operationId), status ?? .Reject)
                }, onError: { (error) in
                    onError?(error)
                })
            case .failure(let error):
                print("Request failed with error: \(error)")
                onError?(ErrorResponse(error: error as NSError).getError())
            }
        })
    }
    
    
    //MARK: - History
    
    @objc open func getHistory(count: NSNumber? = 99999999, page: NSNumber? = 1, onSuccess: (([History]) -> Void)? = nil, onError: ((NSError) -> Void)? = nil) {
        
        var parameters: [String: Any] = [:]
                parameters["per-page"] = count
                parameters["page"] = page
        manager.request(Router.getClientHistory(parameters)).responseJSON { (response) in
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
    
    @objc open func saveCheckListFromHistory(operationId: Int, onSuccess: ((URL, String) -> Void)? = nil, onError: ((NSError) -> Void)? = nil) {
//        let url = URL(string: "\(URL_BASE)history/receipt?id=\(operationId)")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue(authToken, forHTTPHeaderField: "Authorization")
//        request.setValue(self.partnerLogin, forHTTPHeaderField: "partner-login")
//        request.setValue(self.clientPhone, forHTTPHeaderField: "client-phone")
//        request.setValue("4", forHTTPHeaderField: "Version")
//        request.setValue("ru", forHTTPHeaderField: "language")
        
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
    
    //MARK: - Card
    
    @objc open func getLinkedCards(onSuccess: (([Card]) -> Void)? = nil, onError: ((NSError) -> Void)? = nil) {
        
        let parameters: [String: Any] = [:]
        manager.request(Router.getClientLinkedCards(parameters)).responseJSON { (response) in
            self.debugPrintResponse(response: response)
            switch response.result {
            case .success:
                    guard let statusCode = response.response?.statusCode else { return }
                    guard let value = response.result.value else { return }
                    ResponseHelper().checkResponse(statusCode: statusCode, value: value, onSuccess: {
                        if let data = Mapper<Card>().mapArray(JSONObject: value as? [[String: Any]]) {
                            onSuccess?(data)
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
    
    @objc open func linkCard(onSuccess: ((PaymentModel) -> Void)? = nil, onError: ((NSError) -> Void)? = nil) {
        let fieldsData: [String: Any] = [:]
        
        request(Router.clientLinkCard(fieldsData)).responseJSON(completionHandler: { (response) in
            self.debugPrintResponse(response: response)
            switch response.result {
            case .success:
                guard let statusCode = response.response?.statusCode else { return }
                guard let value = response.result.value else { return }
                ResponseHelper().checkResponse(statusCode: statusCode, value: value, onSuccess: {
                    if let operation = Mapper<PaymentModel>().map(JSONObject: (value as! [String: Any])) {
                        onSuccess?(operation)
                    } else {
                        onError?(self.parsingError)
                    }
                }, onError: { (error) in
                    onError?(error)
                })
            case .failure(let error):
                print("Request failed with error: \(error)")
                onError?(ErrorResponse(error: error as NSError).getError())
            }
        })
    }
    
    @objc open func deleteLinkedCard(cardId: Int, onSuccess: (() -> Void)? = nil, onError: ((NSError) -> Void)? = nil) {
        let parameters: [String: Any] = [
            "card_id": cardId
        ]
        request(Router.clientDeleteLinkedCard(parameters)).responseJSON { (response) in
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
    
    
    
    @objc open func getServiceName(qrCode: String?, onSuccess: ((String) -> Void)? = nil, onError: ((NSError) -> Void)? = nil) {
        var fields: [String: Any] = [:]
        fields["qr_code"] = qrCode
        
        request(Router.getServiceName(fields)).responseJSON(completionHandler: { (response) in
            self.debugPrintResponse(response: response)
            switch response.result {
            case .success:
                guard let statusCode = response.response?.statusCode else { return }
                guard let value = response.result.value else { return }
                ResponseHelper().checkResponse(statusCode: statusCode, value: value, onSuccess: {
                    if let data = (value as? [[String: Any]]) {
                        if data.count > 0 {
                            if let name: String = (data[0] as! [String: Any])["name"] as? String {
                                onSuccess?(name)
                            } else {
                                onError?(self.parsingError)
                            }
                        } else {
                            onError?(self.parsingError)
                        }
                    } else {
                        onError?(self.parsingError)
                    }
                }, onError: { (error) in
                    onError?(error)
                })
            case .failure(let error):
                print("Request failed with error: \(error)")
                onError?(ErrorResponse(error: error as NSError).getError())
            }
        })
    }
    
    
    func debugPrintResponse(response: DataResponse<Any>) {
        debugPrint(response.request?.url?.absoluteString ?? "")
        debugPrint(response.request?.httpMethod ?? "")
        debugPrint(response.request?.allHTTPHeaderFields ?? "")
        if let httpBody = response.request?.httpBody {
            debugPrint(String(data: httpBody, encoding: String.Encoding.utf8) ?? "")
        }
        
        debugPrint(response.response?.statusCode ?? "")
        guard let resultValue = response.result.value else {
            NSLog("Result value in response is nil")
            return
        }
        let responseJSON = JSON(resultValue)
        debugPrint(responseJSON)
    }
}
