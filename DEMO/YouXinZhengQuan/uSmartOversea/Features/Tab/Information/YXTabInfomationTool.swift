//
//  YXTabInfomationTool.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/9/11.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

// 缓存的key
let tabar_info_recommend_key = "tabar_info_recommend_key"
let tabar_info_column_key = "tabar_info_column_key"
let tabar_info_my_group_key = "tabar_info_my_group_key"
let tabar_info_all_day_key = "tabar_info_all_day_key"
let tabar_info_read_status_key = "tabar_info_read_status_key"

let tabar_info_course_classify_key = "tabar_info_course_classify_key" //课程类型列表
let tabar_info_my_course_key = "tabar_info_my_course_key" //我的课程
let tabar_info_course_list_key = "tabar_info_course_list_key" //全部课程的 课程列表

// 海外版默认是简体+英文0  1 是纯英文
var info_language: Int = 1

// 新接口 语言参数 0 1 3 对应 全部 中文 英文
var news_selected_language: Int = 1

public enum YXArticleInfoAPILangType: Int {
    case ALL = 0
    case CN = 1
    case EN = 3
    
    public var articleInfoAPILangTypeName: String {
        switch self {
        case .ALL:
            return YXLanguageUtility.kLang(key: "news_change_tab_ALL")
        case .CN:
            return YXLanguageUtility.kLang(key: "news_change_tab_CN")
        case .EN:
            return YXLanguageUtility.kLang(key: "news_change_tab_EN")
        }
    }

}

class YXTabInfomationTool: NSObject {
    
    // 需要初始化一次
    static var infoReadDic = [String: Bool]()

    static func saveReadStatus(with key: String) {
        infoReadDic[key] = true
        let data = try? JSONEncoder().encode(self.infoReadDic)
        if let data = data {
            MMKV.default().set(data, forKey: tabar_info_read_status_key)
        }
    }
    
    static func saveRecommendData(with model:YXInfomationModelListModel?) {
        let data = try? JSONEncoder().encode(model)
        if let data = data {
            MMKV.default().set(data, forKey: tabar_info_recommend_key)
        }
    }
    
    static func saveColumnData(with model:YXSpecialColumnListModel?) {
        let data = try? JSONEncoder().encode(model)
        if let data = data {
            MMKV.default().set(data, forKey: tabar_info_column_key)
        }
    }
    
    static func saveMyGroupData(with model:YXInfomationModelListModel?) {
        let data = try? JSONEncoder().encode(model)
        if let data = data {
            MMKV.default().set(data, forKey: tabar_info_my_group_key)
        }
    }
    
    static func saveAllDayData(with model:YXAllDayInfoListModel?) {
        let data = try? JSONEncoder().encode(model)
        if let data = data {
            MMKV.default().set(data, forKey: tabar_info_all_day_key)
        }
    }
    //保存 课程类型列表 数据
    static func saveCourseClassifyData(with model:YXInfoCourseClassifyModel?) {
        let data = try? JSONEncoder().encode(model)
        if let data = data {
            MMKV.default().set(data, forKey: tabar_info_course_classify_key)
        }
    }
    //保存 我的课程 数据
    static func saveMyCourseData(with model:YXInfoCourseListModel?) {
        let data = try? JSONEncoder().encode(model)
        if let data = data {
            MMKV.default().set(data, forKey: tabar_info_my_course_key)
        }
    }
    //保存 全部课程的课程列表页  数据
    static func saveCourseListData(with model:YXInfoCourseListModel?) {
        let data = try? JSONEncoder().encode(model)
        if let data = data {
            MMKV.default().set(data, forKey: tabar_info_course_list_key)
        }
    }
    
    static func getRecommendDataFromCache() -> YXInfomationModelListModel? {
        
        let data = MMKV.default().object(of: NSData.self, forKey: tabar_info_recommend_key)
        if let data = data as? Data {
            let model = try? JSONDecoder().decode(YXInfomationModelListModel.self, from: data)
            return model
        }
        return nil
    }
    
    static func getColumnDataFromCache() -> YXSpecialColumnListModel? {
        
        let data = MMKV.default().object(of: NSData.self, forKey: tabar_info_column_key)
        if let data = data as? Data {
            let model = try? JSONDecoder().decode(YXSpecialColumnListModel.self, from: data)
            return model
        }
        return nil
    }
    
    static func getMyGroupDataFromCache() -> YXInfomationModelListModel? {
        
        let data = MMKV.default().object(of: NSData.self, forKey: tabar_info_my_group_key)
        if let data = data as? Data {
            let model = try? JSONDecoder().decode(YXInfomationModelListModel.self, from: data)
            return model
        }
        return nil
    }
    
    static func getAllDayDataFromCache() -> YXAllDayInfoListModel? {
        
        let data = MMKV.default().object(of: NSData.self, forKey: tabar_info_all_day_key)
        if let data = data as? Data {
            let model = try? JSONDecoder().decode(YXAllDayInfoListModel.self, from: data)
            return model
        }
        return nil
    }
    
    //从缓存获取 课程类型列表 数据
    static func getCourseClassifyFromCache() -> YXInfoCourseClassifyModel? {
        
        let data = MMKV.default().object(of: NSData.self, forKey: tabar_info_course_classify_key)
        if let data = data as? Data {
            let model = try? JSONDecoder().decode(YXInfoCourseClassifyModel.self, from: data)
            return model
        }
        return nil
    }
    //从缓存获取 我的课程 数据
    static func getMyCourseFromCache() -> YXInfoCourseListModel? {
        
        let data = MMKV.default().object(of: NSData.self, forKey: tabar_info_my_course_key)
        if let data = data as? Data {
            let model = try? JSONDecoder().decode(YXInfoCourseListModel.self, from: data)
            return model
        }
        return nil
    }
    //从缓存获取 课程类型列表 数据
    static func getCourseListFromCache() -> YXInfoCourseListModel? {
        
        let data = MMKV.default().object(of: NSData.self, forKey: tabar_info_course_list_key)
        if let data = data as? Data {
            let model = try? JSONDecoder().decode(YXInfoCourseListModel.self, from: data)
            return model
        }
        return nil
    }
    
    
    static func initReadStatusDic() {
        self.infoReadDic = [String: Bool]()
        let data = MMKV.default().object(of: NSData.self, forKey: tabar_info_read_status_key)
        if let data = data as? Data {
            if let dic = try? JSONDecoder().decode([String: Bool].self, from: data) {
                self.infoReadDic = dic
            }
        }
    }
}
