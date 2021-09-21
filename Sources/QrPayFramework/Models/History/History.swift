//
//  CashierHistory.swift
//
//
//  Created by Wooppay on 27.10.2017.
//

import Foundation

@objc public class History: NSObject, Mappable {
    
    @objc public var id: Int = 0
    @objc public var amount: Double = 0.0
    @objc public var status: Int = 0
    @objc public var title: String?
    @objc public var dateOper: Date?
    @objc public var dateDone: Date?
    @objc public var dateModify: Date?
    @objc public var paymentSystemId: Int = 0
    @objc public var cashDeskId: Int = 0
    @objc public var ext_id_ps: String?
    @objc public var ext_id_m: String?
    @objc public var cashier_id: Int = 0
    @objc public var subjectNumber: String? = ""
    
    public var paymentStatus: HistoryStatus? {
        get {
            if status == 2  {
                return .Accept
            } else if status == 1 || status == 3 {
                return .Pending
            } else if status == 4 || status == 5 || status == 6  {
                return .Reject
            } else {
                return .Pending
            }
        }
        set {
            
        }
    }
    
    required convenience public init?(map: Map){
        self.init()
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        var amountString: Any?
        amountString <- map["amount"]
        let str = "\(amountString ?? "")"
        amount = Double(str) ?? 0
        status <- map["status_id"]
        title <- map["merchant.brand_name"]
        paymentSystemId <- map["payment_system_id"]
        cashDeskId <- map["cash_desk_id"]
        ext_id_ps <- map["ext_id_ps"]
        ext_id_m <- map["ext_id_m"]
        cashier_id <- map["cashier_id"]
        subjectNumber <- map["subject_number"]
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormat.timeZone = TimeZone(secondsFromGMT: 0)
        var dateString: String?
        dateString <- map["create_date"]
        if let str = dateString {
            dateOper = dateFormat.date(from: str)
        }
        
        dateString <- map["done_date"]
        if let str = dateString {
            dateDone = dateFormat.date(from: str)
        }
        
    }
    
}


@objc  public enum HistoryStatus: Int {
    case Accept = 0,
    Pending,
    Reject
}

@objc  public enum PaymentType: Int {
    case incoming = 0,
    outcoming = 1,
    external = 2
}

