//
//  YXLearningViewModel.swift
//  uSmartOversea
//
//  Created by usmart on 2021/12/15.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Differentiator
import NSObject_Rx
import YXKit
import URLNavigator

class YXLearningViewModel: ServicesViewModel, HasDisposeBag {
    typealias Services = HasYXLearningService

    var navigator: NavigatorServicesType!
    
    var services: Services!
    var learningServices = YXLearningService()
    var rankServices = YXNewStockService()

    var regionNo:Int? = 3 //默认新加坡

    //自定义的数据源，网络请求回来的数据都会拼接到这个数据源中
    var dataSource: [[String: Any]]! = [[String: Any]]()
    //每个接口对应的可监听序列
    //rac构建学习模块的请求信号 包含聊天室 问股 课程
    var chatAskList: Driver<YXRecommendChatAskResModel?> {
        return YXSpecialAPI.recommendChatAsk.request().map { res in
            let model = YXRecommendChatAskResModel.yy_model(withJSON: res?.data ?? [:])
            return model
        }.asDriver(onErrorJustReturn: nil)
    }
    var recommendList: Driver<[YXSpecialArticleItem]?> {
        return YXSpecialAPI.recommend(pageNum: 1, pageSize: 20).request().map { res in
            let model = YXSpecialArticleResModel.yy_model(withJSON: res?.data ?? [:])
            return model?.items
        }.asDriver(onErrorJustReturn: nil)
    }
    
    var homerecommendRes: Driver<YXHomerecommendRes?> {
        return YXSpecialAPI.homeRecommend(pageId: 4, regionNo: self.regionNo).request().map { res in
            let model = YXHomerecommendRes.yy_model(withJSON: res?.data ?? [:])
            return model
        }.asDriver(onErrorJustReturn: nil)
    }
    
    //学习首页用到的数据是这个resultList聚合信号，包含投教首页接口和大咖接口，如果有扩充可以在这里添加
    var resultList: Driver<(YXHomerecommendRes?,YXSpecialKOLListResModel?)> {
        return Driver.combineLatest(homerecommendRes,unSubscribeInfo)
    }
    
    var unSubscribeInfo: Driver<YXSpecialKOLListResModel?> {
        return YXSpecialAPI.getSgKolRecommendList(pageNum: refreshMasterPageNum, pageSize: masterPageSize).request().map { res in
            let model = YXSpecialKOLListResModel.yy_model(withJSON: res?.data ?? [:])
            return model
        }.asDriver(onErrorJustReturn: nil)
    }
    
    //每个接口返回的数据
    var chatRoomList: Array<YXRecommendChatResModel>?
    var masterList: Array<YXSpecialKOLItem>?
    var courseList: Array<YXActivityBannerModel>?
    var askList: Array<YXRecommendAskResModel>?
    
    func follow(state: Int, subscriptId: String, index:Int?) -> Driver<(YXResponseModel?, Int?)> {
        return YXSpecialAPI.follow(state: state, subscriptId: subscriptId ).request().asDriver(onErrorJustReturn: nil).map { res in
            return (res, index)
        }.asDriver()
    }
    
    var masterPageNum = 1
    var masterPageSize = 3
    var masterTotalPage = 1
    var refreshMasterPageNum = 1
    
    func creatDataSource() ->  [[String: Any]] {
        let dataSource = [["sectionType": YXLearningSectionType.chatRoom, "list": chatRoomList ?? []],
                          ["sectionType": YXLearningSectionType.course, "list":courseList ?? []],
                          ["sectionType": YXLearningSectionType.master, "list": masterList ?? []],
                          ["sectionType": YXLearningSectionType.ask, "list": askList ?? []]]
        return dataSource
    }
    
    init() {
        self.dataSource = creatDataSource()
    }
}
