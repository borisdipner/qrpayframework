//
//  String+Filtered.swift
//  WoopPay
//
//  Created by Wooppay on 02.06.16.
//  Copyright © 2016 Wooppay. All rights reserved.
//

import Foundation

extension String {
    
    subscript(integerIndex: Int) -> Character {
        let index = self.index(self.startIndex, offsetBy: integerIndex)
        return self[index]
    }
    
    subscript(integerRange: Range<Int>) -> String {
        let start = self.index(self.startIndex, offsetBy: integerRange.lowerBound)
        let end = self.index(self.startIndex, offsetBy: integerRange.upperBound)
        let range = start..<end
        return String(self[range])
    }
    
    func sliceFrom(_ start: String, to: String) -> String? {
        return (self.range(of: start)?.upperBound).flatMap { sInd in
            (self.range(of: to, options: String.CompareOptions.literal, range: sInd..<endIndex, locale: nil)?.lowerBound).map { eInd in
                self.substring(with: sInd..<eInd)
            }
        }
    }
    
    func sliceAfter(_ after: String, to: String) -> String {
        return self.range(of: after).flatMap {
            self.range(of: to, options: String.CompareOptions.literal, range: $0.upperBound..<endIndex, locale: nil).map {
                substring(to: $0.upperBound)
            }
            } ?? self
    }
    
//    func fromBase64() -> String? {
//        guard let data = Data(base64Encoded: self) else {
//            return nil
//        }
//
//        return String(data: data, encoding: .utf8)
//    }
//
//    func toBase64() -> String {
//        return Data(self.utf8).base64EncodedString()
//    }
}
