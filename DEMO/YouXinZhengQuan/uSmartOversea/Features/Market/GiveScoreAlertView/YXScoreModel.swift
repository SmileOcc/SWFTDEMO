//
//  YXScoreModel.swift
//  YouXinZhengQuan
//
//  Created by suntao on 2021/7/4.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXScoreModel: YXModel {
    
    static let ScoreRecodeMapKey = "ScoreRecodeMapKey"
    
    @objc var launchAppCount:Int = 0  //登录状态下启动app的次数
    @objc var launchAppDate:String = "" //有效启动的日期
    @objc var isHoldShare:Bool = false  //持仓分享数据
    
    
    @objc class func saveKey() ->String {
        let saveKey:String = "usmart_appStore_comment_saveKey"
        return saveKey
        
    }
    
    @objc class func saveData(model:YXScoreModel ) {
        
        let saveKey:String = YXScoreModel.saveKey()
        if saveKey.count == 0 {
            return
        }
        guard let json = model.yxModelToJSONObject() else {
            return
        }
        if let data = try? JSONSerialization.data(withJSONObject: json, options: []){
            MMKV.default().set(data, forKey: saveKey)
        }
    }

    
    @objc class func getCacheData() -> YXScoreModel? {
        let saveKey:String = YXScoreModel.saveKey()
        if saveKey.count == 0 {
            return nil
        }
        if let tempData = MMKV.default().data(forKey: saveKey),
            let jsonObject = try? JSONSerialization.jsonObject(with: tempData, options: []) {
                    if let model = YXScoreModel(json: jsonObject) {
                        return model
                }
        }
        return nil
    }
    
    //季度展示保存
    class func saveShow(month:Int){
        let t = YXScoreModel.mapMonth(month)
        if let recodeMap:NSMutableDictionary = MMKV.default().object(of: NSMutableDictionary.self, forKey: YXScoreModel.ScoreRecodeMapKey) as? NSMutableDictionary {
            recodeMap["year"] = Date().year()
            recodeMap[t] = "1"
            MMKV.default().set(recodeMap, forKey:YXScoreModel.ScoreRecodeMapKey)
        }else {
            let recodeMap = YXScoreModel.initRecodeMap()
            recodeMap[t] = "1"
            MMKV.default().set(recodeMap, forKey:YXScoreModel.ScoreRecodeMapKey)
        }
    }
    //自然是否季度展示
    class func isShowed(month:Int)->Bool{
        let t = YXScoreModel.mapMonth(month)
        if let recodeMap:NSMutableDictionary = MMKV.default().object(of: NSMutableDictionary.self, forKey: YXScoreModel.ScoreRecodeMapKey) as? NSMutableDictionary,let year = recodeMap["year"] as? String,let isShowed = recodeMap[t] as? String {
            if year == Date().year(){
                if isShowed == "1"{
                    return true
                }
            }else {
                let recodeMap = YXScoreModel.initRecodeMap()
                MMKV.default().set(recodeMap, forKey:YXScoreModel.ScoreRecodeMapKey)
                return false
            }
        }else {
              resetRrecodeMap()
        }
        return false
    }
    
    class func resetRrecodeMap(){
        let recodeMap = YXScoreModel.initRecodeMap()
        MMKV.default().set(recodeMap, forKey:YXScoreModel.ScoreRecodeMapKey)
    }
    
    //0为未展示 1为展示
    private class func initRecodeMap() ->NSMutableDictionary{
       
        let recodeMap = NSMutableDictionary()
        recodeMap["year"] = Date().year()
        recodeMap["0"] = "0"
        recodeMap["1"] = "0"
        recodeMap["2"] = "0"
        recodeMap["3"] = "0"
        return recodeMap
    }
    //月份转季度
    private class func mapMonth(_ month:Int)->String{
        var t = month / 3
        if month % 3 == 0{
            t = t - 1
        }
        return String(t)
    }
    
}

extension Date{
    static func curentyyyyMMdd()->String{
        let formatter = DateFormatter.en_US_POSIX()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    func year() -> String {
        String(getElement(.year) ?? 1970)
    }
    func month() -> Int{
        getElement(.month) ?? 1
    }
    func day() -> Int{
        getElement(.day) ?? 1
    }
    
    func getElement(_ componet:Calendar.Component) ->Int?{
        let calendar =  Calendar.current
        let dataComonent = calendar.dateComponents([componet], from: self)
        switch componet {
        case .day:
          return  dataComonent.day
        case .month:
          return  dataComonent.month
        case .year:
           return dataComonent.year
        default:
           return dataComonent.year
        }
    }
    
    static func getDay(from:String ,to:String)->Int{
        let formatter = DateFormatter.en_US_POSIX()
       formatter.dateFormat = "yyyy-MM-dd"
       let calendar =  Calendar.current
       if let fromDate = formatter.date(from: from),let toDate = formatter.date(from: to){
           let day = calendar.dateComponents([.day], from:fromDate, to: toDate).day
           return day ?? 0
       }
      return 0
    }
}
