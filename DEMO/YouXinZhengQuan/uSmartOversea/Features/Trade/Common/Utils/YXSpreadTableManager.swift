//
//  YXSpreadtableManager.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/4/2.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXSpreadTableManager: NSObject {
    
    @objc public static let shared = YXSpreadTableManager()
    
    struct SpreadTable {
        var from: Double
        var to: Double
        var value: String
    }
    
    private var spreadTableDict: [Int64: [SpreadTable]]?
    
    func updateHkSpeadTable() {
        var dict: NSDictionary?
        if let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let filePath = documentPath + "/spreadtableV2.plist"
            dict = NSDictionary(contentsOfFile: filePath)
        }
        
        if dict == nil {
            if let path = Bundle.main.path(forResource: "spreadtableV2", ofType: "plist") {
                dict = NSDictionary(contentsOfFile: path)
            }
        }
        
        parserSpreadTable(dict)
        requestSpreadTable()
    }
    
    func spreadTable(with market: String?, stc: Int64?, spreadTab: String? = nil, condition: Bool = false) -> [SpreadTable] {
        switch market {
        case kYXMarketHK:
            if stc == 0 {
                return hkSpreadTable(1)
            }
            return hkSpreadTable(stc ?? 1)
        case kYXMarketUS:
            return usSpreadTable(condition)
        case kYXMarketChinaSH,
             kYXMarketChinaSZ:
            return cnSpreadTable()
        case kYXMarketUsOption:
            return usOptionSpreadTable()
        case kYXMarketSG:
            return sgSreadTable(spreadTab)
        default:
            return []
        }
    }
    
    private func requestSpreadTable() {
        let requestModel = YXSpreadtableRequestModel()
        requestModel.market = kYXMarketHK;
        let request = YXRequest(request: requestModel);
        request.startWithBlock { [weak self] (responseModel) in
            if responseModel.code == .success, let data = responseModel.data {
                if let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
                    let filePath = documentPath + "/spreadtableV2.plist"
                    let dict = ["data": data] as NSDictionary
                    dict.write(toFile: filePath, atomically: true)
                    self?.parserSpreadTable(dict)
                }
            }
        } failure: { (_) in
            
        }
    }
    
    private func parserSpreadTable(_ tableDict: NSDictionary?) {
        let dict = tableDict?["data"] as? NSDictionary
        guard let priceBase = dict?["priceBase"] as? NSNumber, let spreadTabe = dict?["spreadTabe"] as? [NSDictionary] else { return }
        
        let powValue = pow(10.0, priceBase.doubleValue)
        var table: [Int64: [SpreadTable]] = [:]
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = ""
        numberFormatter.maximumFractionDigits = 3
        numberFormatter.locale = Locale(identifier: "zh")
        spreadTabe.forEach { (dict) in
            if let stc = dict["stc"] as? NSNumber, let data = dict["data"] as? [NSDictionary] {
                let list = data.map { (item) -> SpreadTable in
                    let from = ((item["from"] as? NSNumber)?.doubleValue ?? 0)/powValue
                    let to = ((item["to"] as? NSNumber)?.doubleValue ?? 0)/powValue
                    let value = ((item["value"] as? NSNumber)?.doubleValue ?? 0)/powValue
                    let valueString = numberFormatter.string(from: NSNumber(value: value)) ?? ""
                    return SpreadTable(from: from, to: to, value: valueString)
                }
                table[stc.int64Value] = list
            }
        }
        spreadTableDict = table
    }
    
    private func hkSpreadTable(_ stc: Int64) -> [SpreadTable] {
        return spreadTableDict?[stc] ?? []
    }
    
    private func usSpreadTable(_ condition: Bool = false) -> [SpreadTable] {
        if condition {
            return [SpreadTable(from: 0, to: 1, value: "0.001"), SpreadTable(from: 1, to: 9999999, value: "0.01")]
        }
        return [SpreadTable(from: 0, to: 1, value: "0.0001"), SpreadTable(from: 1, to: 9999999, value: "0.01")]
    }
    
    private func cnSpreadTable() -> [SpreadTable] {
        return [SpreadTable(from: 0, to: 9999999, value: "0.01")]
    }
    
    private func usOptionSpreadTable() -> [SpreadTable] {
        return [SpreadTable(from: 0, to: 3, value: "0.01"), SpreadTable(from: 3, to: 9999999, value: "0.05")]
    }
    
    private func sgSreadTable(_ spreadTab: String? = nil) -> [SpreadTable] {
        if let array = spreadTab?.split(separator: " ").map({ String($0) }) {
            var from: Double = 0
            var value: String = "0"
            var to: Double = 0
            var tables:[YXSpreadTableManager.SpreadTable] = []
            
            var finished = false
            for index in 0..<array.count {
                if index%2 == 0 {
                    value = array[index]
                    finished = false
                } else if index%2 == 1 {
                    finished = true
                    to = (Double(value) ?? 0) + (Double(array[index]) ?? 0)
                    tables.append(SpreadTable(from: from, to: to, value: value))
                    from = to
                }
            }
            if finished == false {
                tables.append(SpreadTable(from: from, to: 9999999, value: value))
            }
            return tables
        }
       
        return []
    }
}
