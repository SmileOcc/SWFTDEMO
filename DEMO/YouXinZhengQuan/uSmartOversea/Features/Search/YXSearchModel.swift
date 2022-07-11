//
//  YXSearchModel.swift
//  uSmartOversea
//
//  Created by ZhiYun Huang on 2019/4/19.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import YXKit

enum SearchLanguageKey : String {
    case placeholder = "search_placeholder"
    case cancel = "search_cancel"
    case result_title = "search_result_title"
    case history_title = "search_history_title"
    case history_empty = "search_history_empty"
    case result_empty = "search_result_empty"
    case favorite_remove = "search_remove_from_favorite"
    case favorite_add = "search_add_to_favorite"
}

enum YXSearchType :String, CaseIterable {
    case us = "us"
    case hk = "hk"
    case cryptos = "cryptos"
    case sg = "sg"
}

struct YXSearchParam {
    var q :String?
    var markets :[String]?
    var type1 :[String]?
    var type2 :[String]?
    var type3 :[String]?
    var size :Int?
    var dailyMargin: Int?

    func toDictionary() -> [String:Any] {
        
        var result = [String:Any]()
        
        if let q = self.q {
            result["q"] = q
        }
        
        if let markets = self.markets {
            result["mkts"] = markets.joined(separator: ",")
        }
        
        if let type1 = self.type1 {
            result["type1"] = type1.joined(separator: ",")
        }
        
        if let type2 = self.type2 {
            result["type2"] = type2.joined(separator: ",")
        }
        
        if let type3 = self.type3 {
            result["type3"] = type3.joined(separator: ",")
        }
        
        if let size = self.size {
            result["size"] = size
        }
        
        if let dailyMargin = self.dailyMargin {
            result["dailyMargin"] = dailyMargin
        }
        
        return result
        
    }
    
}

@objcMembers class YXSearchItem : NSObject,Codable,NSCoding, YXSecuIDProtocol {
    func secuId() -> YXSecuID {
        YXSecuID(market: self.market, symbol: self.symbol)
    }
    
    var name : String?
    var market : String
    var symbol : String
    var type1 : Int32?
    var type2 : Int32?
    var type3 : Int32?
    var displayedSymbol: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case market = "market"
        case symbol = "symbol"
        case type1 = "type1"
        case type2 = "type2"
        case type3 = "type3"
        case displayedSymbol = "displayedSymbol"
        
    }
    
    class func getJsonData(dataModel:YXSearchItem) -> String? {
        do {
            let encoder = JSONEncoder()
    //        if #available(iOS 13.0, *) {
    //            /// 设置json格式
    //            encoder.outputFormatting = .withoutEscapingSlashes
    //        } else {
    //            encoder.outputFormatting = .prettyPrinted
    //        }
            let data = try encoder.encode(dataModel)
            if let str = String(data: data, encoding: .utf8) {
                return str
            }
        } catch {
            debugPrint("error == \(error)")
        }
        return nil
    }
    
    func encode(with aCoder: NSCoder) {
        
        if let name = self.name {
            aCoder.encode(name, forKey: "name")
        }
        
        aCoder.encode(self.market, forKey: "market")
        
        aCoder.encode(self.symbol, forKey: "symbol")
        
        if let type1 = self.type1 {
            aCoder.encode(type1, forKey: "type1")
        }
        
        if let type2 = self.type2 {
            aCoder.encode(type2, forKey: "type2")
        }
        
        if let type3 = self.type3 {
            aCoder.encode(type3, forKey: "type3")
        }
        
        if let displayedSymbol = self.displayedSymbol {
            aCoder.encode(displayedSymbol, forKey: "displayedSymbol")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "name") as? String
        market = aDecoder.decodeObject(forKey: "market") as? String ?? ""
        symbol = aDecoder.decodeObject(forKey: "symbol") as? String ?? ""
        type1 = aDecoder.decodeInt32(forKey: "type1")
        type2 = aDecoder.decodeInt32(forKey: "type2")
        type3 = aDecoder.decodeInt32(forKey: "type3")
        displayedSymbol = aDecoder.decodeObject(forKey: "displayedSymbol") as? String
        
    }
    
    init(name: String? = nil, market: String, symbol: String) {
        self.name = name
        self.market = market
        self.symbol = symbol
    }
    
    static func == (lhs: YXSearchItem, rhs: YXSearchItem) -> Bool {
        lhs.market == rhs.market && lhs.symbol == rhs.symbol
    }
    
    func attributedName(with keyword:String?) -> NSAttributedString? {
        attributeString(for: name, keyword: keyword, normalColor: QMUITheme().textColorLevel3(),highlightedColor: QMUITheme().mainThemeColor(),fontSize: 12)
    }
    
    func attributedSymobl(with keyword:String?) -> NSAttributedString? {
        attributeString(for: symbol, keyword: keyword, normalColor: QMUITheme().textColorLevel1(),highlightedColor: QMUITheme().mainThemeColor(),fontSize: 16)
    }
    
    private func attributeString (for ori:String? ,keyword:String?, normalColor:UIColor,highlightedColor:UIColor,fontSize:CGFloat) -> NSAttributedString? {
        if let ori = ori as NSString? {
            
            let str = NSMutableAttributedString(string: ori as String)
            
            str.addAttribute(NSAttributedString.Key.foregroundColor, value: normalColor, range: NSRange.init(location: 0, length: ori.length))
            
            if let keyword = keyword {
                let range = (ori.lowercased as NSString).range(of: keyword.lowercased())
                
                if range.location != NSNotFound {
                    
                    str.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: fontSize), range: NSRange.init(location: 0, length: ori.length))
                    
                    str.addAttribute(NSAttributedString.Key.foregroundColor, value:highlightedColor , range: range)
                }
            }
            
            return str

        }
        
        return nil
    }
}

//struct YXSearchResult :Codable {
//    var list :[YXSearchItem]
//}

class YXSearchList :NSObject, Codable, NSCoding {

    var list = [YXSearchItem]()
    
    var param :YXSearchParam?
    
    let lock = NSRecursiveLock()
    
    var maxNumber = 50
    
    enum CodingKeys: String, CodingKey {
        case list = "list"
    }
    
    func set(list :[YXSearchItem]) {
        lock.lock()
        self.list = list
        lock.unlock()
    }
    
    func add(item : YXSearchItem) {
        
        lock.lock()
        
        list.removeAll { (innerItem) -> Bool in
            item == innerItem
        }
        
        list.insert(item, at: list.startIndex)
        
        if list.count > maxNumber {
            list.removeLast()
        }
        
        lock.unlock()
    }
    
    func remove(item : YXSearchItem) {
        
        lock.lock()
        
        list.removeAll { (innerItem) -> Bool in
            item == innerItem
        }
        
        lock.unlock()
    }
    
    func forEach(_  body : (YXSearchItem) -> Void) {
        lock.lock()

        list.forEach(body)
        
        lock.unlock()
    }
    
    func removeAll() {
        
        lock.lock()
        
        list.removeAll()
        
        lock.unlock()
    }
    
    func count() -> Int {
        list.count
    }
    
    func item(at :Int) -> YXSearchItem? {
        
        lock.lock()
        
        if at < 0 || at >= list.count {
            return nil
        }
        
        let item = list[at]
        
        lock.unlock()
        
        return item
    }
    
    override init() {
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        
        if list.count > 0 {
            aCoder.encode(list, forKey: "list")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        if let l = aDecoder.decodeObject(forKey: "list") as? [YXSearchItem] {
            list = l
        } else {
            list = [YXSearchItem]()
        }
        
    }
}

struct YXRecommendModel: Codable {
    let list: [YXRecommend]?
}

struct YXRecommend: Codable {
    let title, subTitle: String?
    let items: [YXRecommendItem]?
}

struct YXRecommendItem: Codable {
    let icon: String?
    let title, subTitle: String?
    let jumpType: Int?
    let jumpURL: String?

    enum CodingKeys: String, CodingKey {
        case icon, title, subTitle, jumpType
        case jumpURL = "jumpUrl"
    }
}


struct  YXH5CallSearchModel: Codable{
    let showHistory:Bool?  // 显示搜索历史

    let showPopular:Bool?  // 显示搜索推荐

    let showLike:Bool? // 显示关注按钮

    let market:[String]? // 搜索特定市场的股票,不传表示搜所有

    let excludeMarkets:[String]?  // 排除市场

    let type1s:[Int]? // 指定类型1

    let type2s:[Int]? // 指定类型2

    let type3s:[Int]? // 指定类型3

    let excludeType1s:[Int]? // 排除类型1

    let excludeType2s:[Int]? // 排除类型2

    let excludeType3s:[Int]? // 排除类型3
}
