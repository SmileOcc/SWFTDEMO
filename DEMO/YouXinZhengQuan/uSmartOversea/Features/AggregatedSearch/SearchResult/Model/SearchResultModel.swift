//
//  SearchResultModel.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/2/28.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

@objcMembers class SearchResultModel: YXResponseModel {

    var secuList: [SearchSecuModel] = []
    var strategyList: [SearchStrategyModel] = []
    var newsList: [SearchNewsModel] = []
    var beeRichMasterList: [SearchBeeRichMasterModel] = []
    var beeRichCourseList: [SearchBeeRichCourseModel] = []
    var postList: [SearchPostModel] = []
    var helpList: [SearchHelpModel] = []

    @objc class func modelCustomPropertyMapper() -> [String : Any]? {
        return [
            "secuList": "data.symbol.list",
            "strategyList": "data.strategy.list",
            "newsList": "data.news.list",
            "postList": "data.post.list",
            "beeRichMasterList": "data.beeRichMaster.list",
            "beeRichCourseList": "data.beeRichCourse.list",
            "helpList": "data.help.list"
        ]
    }

    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [
            "secuList": SearchSecuModel.self,
            "strategyList": SearchStrategyModel.self,
            "newsList": SearchNewsModel.self,
            "postList": SearchPostModel.self,
            "beeRichCourseList": SearchBeeRichCourseModel.self,
            "beeRichMasterList": SearchBeeRichMasterModel.self,
            "helpList": SearchHelpModel.self
        ]
    }
    
}
