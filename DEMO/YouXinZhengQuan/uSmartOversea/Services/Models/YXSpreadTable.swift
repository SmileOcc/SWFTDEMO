//
//  YXSpreadTable.swift
//  uSmartOversea
//
//  Created by ZhiYun Huang on 2019/5/10.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation

enum YXSpreadTableType : Int {
    case none = 0
    case a = 1
    case b = 3
}

//价位表
class YXSpreadTable :NSObject, Codable, NSCoding {
    
    var market :String?
    
    var priceBase : Int?
    
    var listA : [YXSpreadTableItem]?
    
    var listB :[YXSpreadTableItem]?
    
    enum CodingKeys: String, CodingKey {
        case market = "market"
        case priceBase = "price_base"
        case listA = "list_a"
        case listB = "list_b"
        
    }
    
    func encode(with aCoder: NSCoder) {
        
        if let market = self.market {
            aCoder.encode(market, forKey: "market")
        }
        
        if let priceBase = self.priceBase {
            aCoder.encode(priceBase, forKey: "priceBase")
        }
        
        aCoder.encode(listA, forKey: "listA")
        
       aCoder.encode(listB, forKey: "listB")
    }
    
    required init?(coder aDecoder: NSCoder) {
        market = aDecoder.decodeObject(forKey: "market") as? String
        priceBase = aDecoder.decodeObject(forKey: "priceBase") as? Int
        listA = aDecoder.decodeObject(forKey: "listA") as? [YXSpreadTableItem] ?? [YXSpreadTableItem]()
        listB = aDecoder.decodeObject(forKey: "listB") as? [YXSpreadTableItem] ?? [YXSpreadTableItem]()
    }
}

class YXSpreadTableItem :NSObject, Codable, NSCoding{
    var from :Int = 0
    var to :Int = 0
    var value :Int = 0
    
    enum CodingKeys: String, CodingKey {
        case from = "from"
        case to = "to"
        case value = "value"
        
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(from, forKey: "from")
        aCoder.encode(to, forKey: "to")
        aCoder.encode(value, forKey: "value")
    }
    
    required init?(coder aDecoder: NSCoder) {
        from = aDecoder.decodeObject(forKey: "from") as? Int ?? 0
        to = aDecoder.decodeObject(forKey: "to") as? Int ?? 0
        value = aDecoder.decodeObject(forKey: "value") as? Int ?? 0
    }
}
