//
//  YXAreaCodeManager.swift
//  Alamofire
//
//  Created by Mac on 2019/11/12.
//

import UIKit


@objcMembers public class YXAreaCodeModel: NSObject {
    @objc public var title: String = ""
    @objc public var sectionArr = [Country]()
    
    @objc public init(with title: String, sectionArr: [Country]) {
        self.title = title
        self.sectionArr = sectionArr
    }
}


/// 区号的语言类型定义
///
/// - CN: 简体
/// - HK: 繁体
/// - EN: 英文
@objc public enum YXCodeLanguageType: Int, Codable {
    case CN = 0x01
    case HK = 0x02
    case EN = 0x03
    case ML = 0x04
    case TH = 0x05
}


@objc public class YXAreaCodeManager: NSObject {
    
    /*
     返回按照大写英文字母的顺序的[YXAreaCodeModel]数组
     */
    @objc public class func sortAreaCodeArr(with originArr: [Country], curLangType:YXCodeLanguageType) -> [YXAreaCodeModel] {
        
        let sortedArr: [Country] = originArr.sorted(by: { (area1, area2) -> Bool in
            var name1: String = area1.hk ?? ""
            var name2: String = area2.hk ?? ""
            switch curLangType {
            case .CN, .HK:
                name1 = area1.cnPinyin ?? ""
                name2 = area2.cnPinyin ?? ""
            case .EN:
                name1 = area1.en ?? ""
                name2 = area2.en ?? ""
            case .ML:
                name1 = area1.my ?? ""
                name2 = area2.my ?? ""
            case .TH:
                name1 = area1.th ?? ""
                name2 = area2.th ?? ""
            default:
                break
            }
            return name1 < name2
        })
        
        var arr = [YXAreaCodeModel]()
        
        for i  in 0 ..< 26 {
             let word = String( Character(UnicodeScalar(i + 65)!) ) //大写字母
            
            var sectionArr = [Country]()    //section的model数组
            
            for j in 0 ..< sortedArr.count {
                let model: Country = sortedArr[j]
                var name: String = model.hk ?? ""
                switch curLangType {
                case .CN:
                    name = model.cnPinyin ?? ""
                case .EN, .HK:
                    name = model.en ?? ""
                case .ML:
                    name = model.my ?? ""
                case .TH:
                    name = model.th ?? ""
                default:
                    break
                }
                if name.uppercased().hasPrefix(word) {  //大写字母
                    sectionArr.append(model)
                }
            }
            if sectionArr.count > 0 {
                let codeModel = YXAreaCodeModel(with: word, sectionArr: sectionArr)
                arr.append(codeModel)
            }
            
        }
        return arr
    }
    
    /*
     searchedArr: 搜索结果 [YXAreaCodeModel] 数组
     返回索引字母数组
     */
    @objc public class func getAreaCodeTitleArr(from searchedArr: [YXAreaCodeModel]) -> [String] {
        return searchedArr.map { (codeModel) -> String in
            return codeModel.title
        }
    }
    
    /*
     text: 搜索字符串
     sortedArr: 按字母顺序排序好 YXAreaCodeModel 数组
     返回搜索出来的 YXAreaCodeModel 数组
     */
   @objc public class func matchAreaCodeArr(with text: String, curLangType:YXCodeLanguageType, sortedArr:[YXAreaCodeModel]?) -> [YXAreaCodeModel] {
        
        guard let sortedCodeArr: [YXAreaCodeModel] = sortedArr ,sortedCodeArr.count > 0 else {
            return [YXAreaCodeModel]()
        }
        var searchedArr = [YXAreaCodeModel]()
        
        if text.count > 0 {
            let isNumber: Bool = Int(text) != nil
            
            for i in 0 ..< sortedCodeArr.count {
                let codeModel = sortedCodeArr[i]
                
                //匹配到的Country数组
                let matchArr = codeModel.sectionArr.filter { (secModel) -> Bool in
                    
                    if Int(text) != nil {
                        //先移除+号，再匹配
                        if let area = secModel.area?.replacingOccurrences(of: "+", with: "") {
                            return area.range(of: text, options: .caseInsensitive) != nil
                        }
                    } else {
                        switch curLangType {
                        case .CN, .HK:
                            var name = secModel.cnPinyin ?? ""  //简体：拼音，繁体：英文匹配
                            var chineseWord = secModel.cn ?? "" //(简繁体)中文匹配
                            if curLangType == .HK {
                                name = secModel.en ?? ""
                                 chineseWord = secModel.hk ?? ""
                            }
                            
                            let noSpaceName = name.replacingOccurrences(of: " ", with: "") //没有空格的拼音
                            
                            var isMatched = false
                            if name.range(of: text, options: .caseInsensitive) != nil {
                                isMatched = true
                            }
                            if noSpaceName.range(of: text, options: .caseInsensitive) != nil {
                                isMatched = true
                            }
                            if chineseWord.range(of: text) != nil {
                                isMatched = true
                            }
                            return isMatched
                        
                        case .EN:
                            let name = secModel.en ?? ""    //英文匹配
                            return (name.range(of: text, options: .caseInsensitive) != nil)
                        case .ML:
                            let name = secModel.my ?? ""    //匹配
                            return (name.range(of: text, options: .caseInsensitive) != nil)
                        case .TH:
                            let name = secModel.th ?? ""    //匹配
                            return (name.range(of: text, options: .caseInsensitive) != nil)
                        default:
                            break
                        }
                        
                    }
                    return false
                }

                if matchArr.count > 0 {
                    var matchCodeModel = YXAreaCodeModel(with: codeModel.title, sectionArr: matchArr)//匹配的YXAreaCodeModel
                    searchedArr.append(matchCodeModel)
                }
            }
            
        } else {
            searchedArr = sortedCodeArr
        }
        return searchedArr
    }
    
}




