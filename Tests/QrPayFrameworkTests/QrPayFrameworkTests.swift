

//
//  QRPayFrameworkTests.swift
//  QRPayFrameworkTests
//
//  Created by Wooppay on 16.10.2017.
//  Copyright © 2017 Wooppay. All rights reserved.
//

import XCTest
@testable import QrPayFramework

class QRPayFrameworkTests: XCTestCase {
    
    let cashierAuthToken = "NM1_T2RKrADr2Jl4qI7jCyXkYxLSkzKVLy2OGLHwe6zbZJywssU3EvvBiL-bcfDt"
    let clientAuthToken = "NM1_T2RKrADr2Jl4qI7jCyXkYxLSkzKVLy2OGLHwe6zbZJywssU3EvvBiL-bcfDt"
    let pointId = 212
    let cashDeskId = 6876
    let userId = 7489
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //MARK: - Cashier
    
    func testCashierLogin() {
        let timeout = 60
        let expectation = self.expectation(description: "cashier should succeed")
        var token: String?
        var userId: NSNumber?
        CashierManager().cashierLogin(login: "77058296528", password: "Wwwqqq111", onSuccess: { (t, u) in
            token = t
            userId = u
            expectation.fulfill()
        }) { (error) in
            XCTFail("\(error.localizedDescription)")
        }
        waitForExpectations(timeout: TimeInterval(timeout), handler: nil)
        XCTAssertNotNil(token)
        XCTAssertNotNil(userId)
    }
    
    func testCashierLoginFail() {
        let timeout = 60
        let expectation = self.expectation(description: "cashier should error")
        var error: NSError?
        CashierManager().cashierLogin(login: "77058296528", password: "Wwwqqq11", onSuccess: { (t, u) in
        }) { (err) in
            error = err
            expectation.fulfill()
        }
        waitForExpectations(timeout: TimeInterval(timeout), handler: nil)
        XCTAssertNotNil(error)
        XCTFail("\(error?.localizedDescription ?? "error")")
    }
    
    func testActivateCashier() {
        let timeout = 60
        let expectation = self.expectation(description: "activate cashier should succeed")
        var pointId: Int?
        var cashDeskId: Int?
        CashierManager(authToken: cashierAuthToken).activateCashier(qrCode: "https://qrpay.kz/how-to?d=eyJzZXJ2aWNlX2lkIjoiMCIsInBvaW50X2lkIjo2ODc2fQ==", onSuccess: { (point, cashDesk) in
            pointId = point
            cashDeskId = cashDesk
            expectation.fulfill()
        }) { (error) in
            XCTFail("\(error.localizedDescription)")
        }
        waitForExpectations(timeout: TimeInterval(timeout), handler: nil)
        XCTAssertNotNil(pointId)
        XCTAssertNotNil(cashDeskId)
    }
    
    func testActivateCashierFail() {
        let timeout = 60
        let expectation = self.expectation(description: "activate cashier should error")
        var error: NSError?
        CashierManager(authToken: cashierAuthToken).activateCashier(qrCode: "https://qrpay.kz/how-to?d=eyJzZXJ2aWNlX2lkIjoiMCIsInBvaW50X2lkIjo2ODc2f=", onSuccess: { (point, cashDesk) in
        }) { (err) in
            error = err
            expectation.fulfill()
        }
        waitForExpectations(timeout: TimeInterval(timeout), handler: nil)
        XCTAssertNotNil(error)
        XCTFail("\(error?.localizedDescription ?? "error")")
    }
    
    func testCashierHistory() {
        let timeout = 60
        let expectation = self.expectation(description: "history cashier should succeed")
        var history: [History]?
        CashierManager(authToken: cashierAuthToken).getHistory(pointId: NSNumber(value: pointId), cashDeskId: nil, count: 10, page: 1, onSuccess: { (hist) in
            history = hist
            expectation.fulfill()
        }) { (err) in
            
        }
        waitForExpectations(timeout: TimeInterval(timeout), handler: nil)
        XCTAssertNotNil(history)
    }
    
    func testCashierHistoryFail() {
        let timeout = 60
        let expectation = self.expectation(description: "history cashier should error")
        var error: NSError?
        CashierManager(authToken: cashierAuthToken).getHistory(pointId: NSNumber(value: 945999), cashDeskId: nil, count: 10, page: 1, onSuccess: { (history) in
            
        }) { (err) in
            error = err
            expectation.fulfill()
        }
        waitForExpectations(timeout: TimeInterval(timeout), handler: nil)
        XCTAssertNotNil(error)
        XCTFail("\(error?.localizedDescription ?? "error")")
    }
    
    func testCashierSaveHistoryReceipt() {
        let timeout = 60
        let expectation = self.expectation(description: "history receipt cashier should succeed")
        var path: URL?
        var fileName: String?
        CashierManager(authToken: cashierAuthToken).saveCheckListFromHistory(operationId: 9088, onSuccess: { (p, file) in
            path = p
            fileName = file
            expectation.fulfill()
        }) { (err) in
        }
        waitForExpectations(timeout: TimeInterval(timeout), handler: nil)
        XCTAssertNotNil(path)
        XCTAssertNotNil(fileName)
    }
    
    func testCashierSaveHistoryReceiptFail() {
        let timeout = 60
        let expectation = self.expectation(description: "history receipt cashier should error")
        var error: NSError?
        CashierManager(authToken: cashierAuthToken).saveCheckListFromHistory(operationId: 6876, onSuccess: { (path, fileName) in
            
        }) { (err) in
            error = err
            expectation.fulfill()
        }
        waitForExpectations(timeout: TimeInterval(timeout), handler: nil)
        XCTAssertNotNil(error)
        XCTFail("\(error?.localizedDescription ?? "error")")
    }
    
    func testCashierGetPointList() {
        let timeout = 60
        let expectation = self.expectation(description: "points cashier should succeed")
        var points: [QRPoint]?
        CashierManager(authToken: cashierAuthToken).getCashierPoints(userId: NSNumber(value: userId), count: 10, page: 1, onSuccess: { (p) in
            points = p
            expectation.fulfill()
        }, onError: { (err) in
            
        })
        waitForExpectations(timeout: TimeInterval(timeout), handler: nil)
        XCTAssertNotNil(points)
    }
    
    func testCashierGetPointListFail() {
        let timeout = 60
        let expectation = self.expectation(description: "points cashier should error")
        var error: NSError?
        CashierManager(authToken: cashierAuthToken).getCashierPoints(userId: NSNumber(value: 7), count: 10, page: 1, onSuccess: { (p) in
        }, onError: { (err) in
            error = err
            expectation.fulfill()
        })
        waitForExpectations(timeout: TimeInterval(timeout), handler: nil)
        XCTAssertNotNil(error)
        XCTFail("\(error?.localizedDescription ?? "error")")
    }
    
    //MARK: - Client
    
    func testClientLogin() {
        let timeout = 60
        let expectation = self.expectation(description: "login client should succeed")
        ClientManager().clientLogin(login: "77059796123", onSuccess: {
            expectation.fulfill()
        }) { (err) in
            
        }
        waitForExpectations(timeout: TimeInterval(timeout), handler: nil)
    }
    
    func testClientLoginFail() {
        let timeout = 60
        let expectation = self.expectation(description: "login client should error")
        var error: NSError?
        ClientManager(authToken: clientAuthToken).clientLogin(login: "77059796123", onSuccess: {
            expectation.fulfill()
        }) { (err) in
            error = err
            expectation.fulfill()
        }
        waitForExpectations(timeout: TimeInterval(timeout), handler: nil)
        XCTAssertNotNil(error)
        XCTFail("\(error?.localizedDescription ?? "error")")
    }
    
    func testClientCheckSMS() {
        let timeout = 60
        let expectation = self.expectation(description: "login sms client should succeed")
        var token: String?
        ClientManager(authToken: clientAuthToken).checkSMS(login: "77059796123", code: "1234", onSuccess: { (t) in
            token = t
            expectation.fulfill()
        }) { (error) in
            XCTFail("\(error.localizedDescription)")
        }
        waitForExpectations(timeout: TimeInterval(timeout), handler: nil)
        XCTAssertNotNil(token)
        waitForExpectations(timeout: TimeInterval(timeout), handler: nil)
    }
    
    func testClientCheckSMSFail() {
        let timeout = 60
        let expectation = self.expectation(description: "login sms client should error")
        var error: NSError?
        ClientManager(authToken: clientAuthToken).checkSMS(login: "77059796123", code: "1234", onSuccess: { (t) in
        }) { (err) in
            error = err
            expectation.fulfill()
        }
        waitForExpectations(timeout: TimeInterval(timeout), handler: nil)
        XCTAssertNotNil(error)
        XCTFail("\(error?.localizedDescription ?? "error")")
    }
    
    func testClientGetFields() {
        let timeout = 60
        let expectation = self.expectation(description: "client fields should succeed")
        var fields: [ServiceField]?
        ClientManager(authToken: clientAuthToken).getFields(qrCode: "https://qrpay.kz/how-to?d=eyJzZXJ2aWNlX2lkIjoiMCIsInBvaW50X2lkIjo2ODc2fQ==", onSuccess: { (f) in
            fields = f.fields
            expectation.fulfill()
        }, onError: { (err) in
            
        })
        waitForExpectations(timeout: TimeInterval(timeout), handler: nil)
        XCTAssertNotNil(fields)
    }
    
    func testClientGetFieldsFail() {
        let timeout = 60
        let expectation = self.expectation(description: "client fields should error")
        var error: NSError?
        ClientManager(authToken: clientAuthToken).getFields(qrCode: "", onSuccess: { (f) in
        }, onError: { (err) in
            error = err
            expectation.fulfill()
        })
        waitForExpectations(timeout: TimeInterval(timeout), handler: nil)
        XCTAssertNotNil(error)
        XCTFail("\(error?.localizedDescription ?? "error")")
    }
    
    func testClientCheckFields() {
        let timeout = 60
        let expectation = self.expectation(description: "client check fields should succeed")
        var fields: [String: Any]?
        ClientManager(authToken: clientAuthToken).checkFields(qrCode: "https://qrpay.kz/how-to?d=eyJzZXJ2aWNlX2lkIjoiMCIsInBvaW50X2lkIjo2ODc2fQ==", fields: ["amount": 10], onSuccess: { (f,_) in
            fields = f
            expectation.fulfill()
        }, onError: { (err) in
            
        })
        waitForExpectations(timeout: TimeInterval(timeout), handler: nil)
        XCTAssertNotNil(fields)
    }
    
    func testClientCheckFieldsFail() {
        let timeout = 60
        let expectation = self.expectation(description: "client check fields should error")
        var error: NSError?
        ClientManager(authToken: clientAuthToken).checkFields(qrCode: "", fields: ["amount": 10], onSuccess: { f,_ in
        }, onError: { (err) in
            error = err
            expectation.fulfill()
        })
        waitForExpectations(timeout: TimeInterval(timeout), handler: nil)
        XCTAssertNotNil(error)
        XCTFail("\(error?.localizedDescription ?? "error")")
    }
    
    func testClientPayFail() {
        let timeout = 60
        let expectation = self.expectation(description: "client pay should error")
        var error: NSError?
        ClientManager(authToken: clientAuthToken).pay(qrCode: "", fields: ["amount": 10], onSuccess: { (operationId) in
        }, onError: { (err) in
            error = err
            expectation.fulfill()
        })
        waitForExpectations(timeout: TimeInterval(timeout), handler: nil)
        XCTAssertNotNil(error)
        XCTFail("\(error?.localizedDescription ?? "error")")
    }
    
    func testClientHistory() {
        let timeout = 60
        let expectation = self.expectation(description: "history should succeed")
        var history: [History]?
        ClientManager(authToken: cashierAuthToken).getHistory(count: 10, page: 1, onSuccess: { (hist) in
            history = hist
            expectation.fulfill()
        }) { (err) in
            
        }
        waitForExpectations(timeout: TimeInterval(timeout), handler: nil)
        XCTAssertNotNil(history)
    }
    
    func testClientHistoryFail() {
        let timeout = 60
        let expectation = self.expectation(description: "history should error")
        var error: NSError?
        ClientManager(authToken: cashierAuthToken).getHistory(count: 10, page: 1, onSuccess: { (history) in
            
        }) { (err) in
            error = err
            expectation.fulfill()
        }
        waitForExpectations(timeout: TimeInterval(timeout), handler: nil)
        XCTAssertNotNil(error)
        XCTFail("\(error?.localizedDescription ?? "error")")
    }
    
    func testClientSaveHistoryReceipt() {
        let timeout = 60
        let expectation = self.expectation(description: "history receipt should succeed")
        var path: URL?
        var fileName: String?
        ClientManager(authToken: cashierAuthToken).saveCheckListFromHistory(operationId: 9088, onSuccess: { (p, file) in
            path = p
            fileName = file
            expectation.fulfill()
        }) { (err) in
        }
        waitForExpectations(timeout: TimeInterval(timeout), handler: nil)
        XCTAssertNotNil(path)
        XCTAssertNotNil(fileName)
    }
    
    func testClientSaveHistoryReceiptFail() {
        let timeout = 60
        let expectation = self.expectation(description: "history receipt should error")
        var error: NSError?
        ClientManager(authToken: cashierAuthToken).saveCheckListFromHistory(operationId: 6876, onSuccess: { (path, fileName) in
            
        }) { (err) in
            error = err
            expectation.fulfill()
        }
        waitForExpectations(timeout: TimeInterval(timeout), handler: nil)
        XCTAssertNotNil(error)
        XCTFail("\(error?.localizedDescription ?? "error")")
    }
}
