//
//  YXFCHotViewModel.swift
//  YouXinZhengQuan
//
//  Created by 覃明明 on 2021/6/1.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

@objc enum YXInformationFlowType: Int {
    //内容类型 1=要闻资讯 2=图文 3=直播 4=回放 5=个股讨论
    case news = 1
    case imageText = 2
    case live = 3
    case replay = 4
    case stockdiscuss = 5
    case customUrl = 6
    case chatRoom = 7
    
    var aspectRatio: Double { // 宽高比
        switch self {
        case .news, .live, .replay, .customUrl, .chatRoom:
            return 16.0/9.0
        case .imageText:
            return 4.0/3.0
        case .stockdiscuss:
            return 3.0/4.0
        default:
            return 1.0
        }
    }
}

enum YXHotViewControllerType {
    case hotFlow(flowType: YXFlowType = .news)
    case userFlow(headerHeight: CGFloat = 204)
    
    enum YXFlowType {
        case news
        case video
    }
    
    var isHideNavBar: Bool {
        switch self {
        case .hotFlow:
            return true
        case .userFlow:
            return true
        }
    }
    
    var headerHeight: CGFloat {
        switch self {
        case .hotFlow:
            return 0
        case .userFlow(let height):
            return height
        }
    }
}

@objc enum YXFCUserProType: Int {
    case normal = 1
    case level1 = 4
    case level2 = 2
    case level3 = 5
}

@objc enum YXChatRoomStatus: Int {
    case unlive = 0 // 未直播
    case pre = 1 // 预告
    case live = 2 // 直播中
    case pause = 3// 暂停
    case end = 4 // 借宿
    case takeDown = 5 // 下架
}

class YXFCHotViewModel: YXViewModel {
    
    let disposeBag = DisposeBag()
    
    var controllerType: YXHotViewControllerType = .hotFlow()
    
    var allDatas: [Any] = []
    var hotListModel = YXFCHotResModel()
    var recommendUserModel: YXFCRecommendUserListResModel?
    var userFlowInfoModel: YXFCUserFlowInfoResModel?
    var userInfoid: String?
    
    // 由于第一次请求需要插入推荐关注用户的数据,所以合并信息流接口和推荐关注用户接口,等待两个接口都返回后插入推荐关注到相应的位置
    func firstGetAlldata() -> Single<[Any]> {
        
        hotListModel = YXFCHotResModel()
        
        switch controllerType {
        case .hotFlow(let flowType):
            if flowType == .news {
                return getNewsFlowData()
            }else {
                return getVideoFlowData()
            }
            
        case .userFlow:
            return getUserFlowData()
        }
    }
    
    func getNewsFlowData() -> Single<[Any]> {
        let single = Single<[Any]>.create { [weak self] single in
            guard let `self` = self else { return Disposables.create() }
            Observable.zip(self.getHotList().asObservable(), self.getBanner().asObservable()).subscribe { [weak self](hotResModel, bannerModel) in
                guard let `self` = self else {
                    single(.success([]))
                    return
                }
                
                self.allDatas = []
                if let bannerM = bannerModel, bannerM.bannerList.count > 0 {
                    self.allDatas.insert(bannerM, at: 0)
                }
                if let hotModel = hotResModel {
                    self.allDatas = self.allDatas + hotModel.feed_list
                }
                
                single(.success(self.allDatas))
                
            } onError: { err in
                single(.error(err))
                
            }.disposed(by: self.disposeBag)

            return Disposables.create()
        }
        
        return single
    }
    
    func getVideoFlowData() -> Single<[Any]> {
        let single = Single<[Any]>.create { [weak self] single in
            guard let `self` = self else { return Disposables.create() }
            Observable.zip(self.getHotList().asObservable(), self.getRecommendUserList().asObservable()).subscribe { [weak self](hotResModel, recommendUserResModel) in
                guard let `self` = self else {
                    single(.success([]))
                    return
                }
                
                self.allDatas = []
                
                if let hotModel = hotResModel {
                    self.allDatas = self.allDatas + hotModel.feed_list
                }
                if let userModel = recommendUserResModel, userModel.list.count > 0 {
                    if userModel.position <= self.allDatas.count {
                        var index = 0
                        if userModel.position > 0 {
                            index = userModel.position - 1
                        }
                        self.allDatas.insert(userModel, at: index)
                    }else {
                        self.allDatas.append(userModel)
                    }
                }
                
                single(.success(self.allDatas))
                
            } onError: { err in
                single(.error(err))
                
            }.disposed(by: self.disposeBag)

            return Disposables.create()
        }
        
        return single
    }
    
    func getUserFlowData() -> Single<[Any]> {
        let single = Single<[Any]>.create { [weak self] single in
            guard let `self` = self else { return Disposables.create() }
            Observable.zip(self.getHotList().asObservable(), self.getUserInfo().asObservable()).subscribe { [weak self](hotResModel, userInfoModel) in
                guard let `self` = self else {
                    single(.success([]))
                    return
                }
                self.allDatas = []
                if let hotModel = hotResModel {
                    self.allDatas = self.allDatas + hotModel.feed_list
                }
                
                single(.success(self.allDatas))
                
            } onError: { err in
                single(.error(err))
                
            }.disposed(by: self.disposeBag)

            return Disposables.create()
        }
        
        return single
    }
    
    func loadMoreData() -> Single<YXFCHotResModel?> {
        let single = Single<YXFCHotResModel?>.create { [weak self] single in
            guard let `self` = self else { return Disposables.create() }
            self.getHotList().subscribe { [weak self] hotModel in
                guard let `self` = self else {
                    single(.success(nil))
                    return
                }
                self.hotListModel.feed_list = self.hotListModel.feed_list + (hotModel?.feed_list ?? [])
                
                self.allDatas = self.allDatas + (hotModel?.feed_list ?? [])
                
                single(.success(hotModel))
                
            } onError: { err in
                single(.error(err))
                
            }.disposed(by: self.disposeBag)

            return Disposables.create()
        }
        
        return single
    }
    
    func refreshRecommendUserList()-> Single<YXFCRecommendUserListResModel?> {
        let single = Single<YXFCRecommendUserListResModel?>.create { [weak self] single in
            guard let `self` = self else { return Disposables.create() }
            self.getRecommendUserList().subscribe { [weak self] userModel in
                guard let `self` = self else {
                    single(.success(nil))
                    return
                }
                self.recommendUserModel = userModel
                
                if let m = userModel, m.list.count > 0 {
                    for (index, item) in self.allDatas.enumerated() {
                        if item is YXFCRecommendUserListResModel { // 如果全部数据源里已经被插入了推荐关注用户的数据,则需要更新
                            self.allDatas[index] = m
                            
                            break
                        }
                    }
                }
                single(.success(userModel))
            } onError: { err in
                single(.error(err))
            }.disposed(by: self.disposeBag)

            return Disposables.create()
        }
        
        return single
    }
    
    private func getHotList() -> Single<YXFCHotResModel?> {
        let single = Single<YXFCHotResModel?>.create { [weak self] single in
            guard let `self` = self else { return Disposables.create() }
            let requestModel = YXFCHotReqModel()
            requestModel.query_token = self.hotListModel.query_token ?? ""
            switch self.controllerType {
            case .hotFlow(let flowType):
                if flowType == .news {
                    requestModel.flowType = 0
                }else {
                    requestModel.flowType = 1
                }
                
            case .userFlow:
                requestModel.flowType = 2
                if let id = self.userInfoid {
                    requestModel.person_uid = id
                }
            }
            
            let request = YXRequest.init(request: requestModel)
        
            request.startWithBlock(success: { [weak self] (response) in
                guard let `self` = self else {
                    single(.success(nil))
                    return
                }
                if response.code == YXResponseStatusCode.success, let data = response.data {
                    let model = YXFCHotResModel.yy_model(withJSON: data)
                    for item in model?.feed_list ?? [] {
                        item.itemSizeInfo = self.caculateItemHeight(model: item)
                    }
                    self.hotListModel.query_token = model?.query_token
                    single(.success(model))
                    
                }else {
                    single(.success(nil))
                }
                
            }, failure: { (request) in
                single(.success(nil))
//                single(.error(request.error ?? NSError.init(domain: "", code: -1, userInfo: nil)))
            })
            return Disposables.create()
        }
        
        return single
    }
    
    private func getBanner() -> Single<YXBannerActivityModel?> {
        let single = Single<YXBannerActivityModel?>.create { single in
            let requestModel = YXBannerAdvertisementRequestModel()
            requestModel.show_page = 33
            let request = YXRequest.init(request: requestModel)
            
            request.startWithBlock(success: { (response) in
                if response.code == YXResponseStatusCode.success, let data = response.data {
                    let model = YXBannerActivityModel.yy_model(withJSON: data)
                    single(.success(model))
                }else {
                    single(.success(nil))
                }
                
            }, failure: { (request) in
                single(.success(nil))
//                single(.error(request.error ?? NSError.init(domain: "", code: -1, userInfo: nil)))
            })
            return Disposables.create()
        }
        
        return single
    }
    
    private func getRecommendUserList() -> Single<YXFCRecommendUserListResModel?> {
        let single = Single<YXFCRecommendUserListResModel?>.create { single in
            
            single(.success(nil))
            return Disposables.create()
//            let requestModel = YXFCRecommendUserListReqModel()
//            requestModel.query_token = self.recommendUserModel?.query_token ?? ""
//
//            let request = YXRequest.init(request: requestModel)
//
//            request.startWithBlock(success: { (response) in
//                if response.code == YXResponseStatusCode.success, let data = response.data {
//                    self.recommendUserModel = YXFCRecommendUserListResModel.yy_model(withJSON: data)
//                    single(.success(self.recommendUserModel))
//
//                }else {
//                    single(.success(nil))
//                }
//
//            }, failure: { (request) in
//                single(.success(nil))
////                single(.error(request.error ?? NSError.init(domain: "", code: -1, userInfo: nil)))
//            })
//            return Disposables.create()
        }
        
        return single
    }
    
    func getUserInfo() -> Single<YXFCUserFlowInfoResModel?> {
        let single = Single<YXFCUserFlowInfoResModel?>.create { [weak self] single in
            guard let `self` = self else { return Disposables.create() }
            let requestModel = YXFCUserFlowInfoReqModel()
            
            requestModel.person_uid = self.userInfoid ?? String(YXUserManager.userUUID())
            
            let request = YXRequest.init(request: requestModel)
            
            request.startWithBlock(success: { [weak self] (response) in
                guard let `self` = self else {
                    single(.success(nil))
                    return
                }
                if response.code == YXResponseStatusCode.success, let data = response.data {
                    let model = YXFCUserFlowInfoResModel.yy_model(withJSON: data)
                
                    var height: CGFloat = 204
                    if let text = model?.profile, text.count > 0 {
                        let profile = text.replacingOccurrences(of: "\n", with: " ")
                        height = 184 + ceil(profile.height(UIFont.systemFont(ofSize: 12), limitWidth: YXConstant.screenWidth - 30))
                    }
                    self.controllerType = .userFlow(headerHeight: height)
                    
                    self.userFlowInfoModel = model
                    single(.success(self.userFlowInfoModel))
                    
                }else {
                    single(.success(nil))
                }
                
            }, failure: { (request) in
                single(.success(nil))
//                single(.error(request.error ?? NSError.init(domain: "", code: -1, userInfo: nil)))
            })
            return Disposables.create()
        }
        
        return single
    }
    
    func isSelf(uid: String) -> Bool {
        return uid == String(YXUserManager.userUUID())
    }
    
    func caculateItemHeight(model: YXFCHotFeedListItem) -> (imageHeight: CGFloat, cellHeight: CGFloat, cellWidth: CGFloat) {
        let titleLabelTop = 8.0 // 标题距离图片底部距离
        let titleLabelBottom = 44.0 // 标题距离父视图底部距离
        let leftRightMargin = 12.0
        let interitemSpacing = 12.0
        
        var itemWidth = 0.0
        
        switch controllerType {
        case .userFlow:
            itemWidth = (Double(YXConstant.screenWidth) - 2 * leftRightMargin - interitemSpacing) / 2.0
        case .hotFlow:
            itemWidth = Double(YXConstant.screenWidth)/2.0 - 18.0
        }
        
        var imageHeight = 0.0
        
        var titleLabelHeight: CGFloat = 0.0
        if let title = model.title {
            titleLabelHeight = YXToolUtility.getStringSize(with: title, andFont: UIFont.systemFont(ofSize: 14), andlimitWidth: (Float(itemWidth)-16.0), andLineHeight: 20).height
            if titleLabelHeight > 40 {
                titleLabelHeight = 40
            }
        }
        
        switch model.content_type {
        case .news, .live, .replay, .customUrl, .chatRoom:
            imageHeight = itemWidth / model.content_type.aspectRatio
            
        case .imageText:
            imageHeight = itemWidth / model.content_type.aspectRatio
            if let w = model.cover_images?.cover_width, let h = model.cover_images?.cover_height, w.count > 0, h.count > 0 {
                if let fw = Double(w), let fh = Double(h), fw != 0 {
                    imageHeight = itemWidth * fh / fw
                }
            }
        case .stockdiscuss:
            
            if let url = model.cover_images?.cover_images, url.count > 0 {
                let defaultImageHeight = itemWidth / model.content_type.aspectRatio
                
                if let w = model.cover_images?.cover_width, let h = model.cover_images?.cover_height, w.count > 0, h.count > 0 {
                    if let fw = Double(w), let fh = Double(h), fw != 0 {
                        imageHeight = itemWidth * fh / fw
                    }
                }else {
                    // 如果字段里没有返回宽高,则从链接上面取
                    let size = YXToolUtility.findStockDiscussImageSize(withUrl: url)
                    if  size.width != 0 {
                        imageHeight = itemWidth * Double(size.height) / Double(size.width)
                    }
                }
                
                if imageHeight > defaultImageHeight {
                    imageHeight = defaultImageHeight
                }
            }
            var titleHeight: CGFloat = 0.0
            model.stockDiscussLayout = nil
            if let title = model.title, title.count > 0 {
                let contentNoHtml: String = YXToolUtility.reverseTransformHtmlString(title) ?? ""
                
                let contentAttr = NSMutableAttributedString.init(string: contentNoHtml, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1()])
                
                let textParser = YXReportTextParser()
                textParser.font = UIFont.systemFont(ofSize: 14)
                textParser.parseText(contentAttr, selectedRange: nil)
                
                let modifier = YXTextLinePositionModifier()
                modifier.font = UIFont.systemFont(ofSize: 14)
                modifier.lineHeightMultiple = 1.5
                
                let container: YYTextContainer = YYTextContainer.init(size: CGSize(width: CGFloat(itemWidth-16), height: CGFloat.greatestFiniteMagnitude))
                container.linePositionModifier = modifier
                container.maximumNumberOfRows = 6
                container.truncationType = .end
                container.truncationToken = NSAttributedString(string: "...", attributes: [.foregroundColor: QMUITheme().textColorLevel1(), .font: UIFont.systemFont(ofSize: 14)])
                
                let layout = YYTextLayout.init(container: container, text: contentAttr)
                model.stockDiscussLayout = layout
                titleHeight = 3 + (layout?.textBoundingRect.maxY ?? 0)
            }
            
            
            let cellHeight = CGFloat(imageHeight + titleLabelTop + titleLabelBottom) + titleHeight
            
            return (CGFloat(imageHeight), cellHeight, CGFloat(itemWidth))
            
        default:
            break
        }
        
        let cellHeight = CGFloat(imageHeight + titleLabelTop + titleLabelBottom) + titleLabelHeight
        
        return (CGFloat(imageHeight), cellHeight, CGFloat(itemWidth))
    }
    
}
