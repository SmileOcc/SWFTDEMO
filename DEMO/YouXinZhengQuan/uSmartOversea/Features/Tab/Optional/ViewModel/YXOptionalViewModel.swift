//
//  YXOptionalViewModel.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/4/19.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources
import YXKit
import NSObject_Rx
import URLNavigator

//@objc enum YXYXStockRankSortType: Int {
//    case roc = 0
//    case change = 1
//    case volume = 2
//    case amount = 3
//    case usOutPrice = 4
//}

class YXOptionalViewModel: ServicesViewModel, HasDisposeBag  {
    
    static let optionalOtherAd = "optionalOtherAd"
    
    typealias Services = HasYXV2QuoteService & HasYXMessageCenterService & HasYXGlobalConfigService & HasYXNewsService

    var navigator: NavigatorServicesType!
    
    lazy var titles: Driver<[String]> = {
        let observable = Observable<[String]>.create { [weak self] observer -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            
            return YXSecuGroupManager.shareInstance().rx.observeWeakly([YXSecuGroup].self, "allGroupsForShow").subscribe(onNext: { (secuGroupList) in
                var titles = [String]()
//                let ids: [YXDefaultGroupID] = [.idAll, .IDHK, .IDUS, .IDCHINA, .IDHOLD];
//                var list = [YXSecuGroup]()
//                ids.forEach({ (gid) in
//                    for secuGroup in secuGroupList ?? [] {
//                        if let groupId = YXDefaultGroupID(rawValue: secuGroup.id), groupId == gid {
//                            list.append(secuGroup)
//                        }
//                    }
//                })
//
                secuGroupList?.forEach({ (secuGroup) in
                    guard let groupId = YXDefaultGroupID(rawValue: secuGroup.id) else { return }
//                    if groupId == .idAll || groupId == .IDHK || groupId == .IDUS || groupId == .IDHOLD || groupId == .IDCHINA {
                        var title: String = ""
                        switch groupId {
                        case .idAll:
                            title = YXLanguageUtility.kLang(key: "common_all")
                        case .IDHK:
                            title = YXLanguageUtility.kLang(key: "community_hk_stock")
                        case .IDUS:
                            title = YXLanguageUtility.kLang(key: "community_us_stock")
                        case .IDCHINA:
                            title = YXLanguageUtility.kLang(key: "community_cn_stock")
                        case .IDHOLD:
                            title = YXLanguageUtility.kLang(key: "hold_holds")
                        case .IDLATEST:
                            title = YXLanguageUtility.kLang(key: "hold_recent_trading")
                        case .IDUSOPTION:
                            title = YXLanguageUtility.kLang(key: "options_options")
                        default:
                            title = secuGroup.name
                        }
                        titles.append(title)
//                    }
                })
                
                observer.onNext(titles)
            })
        }
        
        return observable.asDriver(onErrorJustReturn: [])
    }()
    
    lazy var viewControllers: Driver<[UIViewController]> = {
        let observable = Observable<[UIViewController]>.create { [weak self] observer -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            
            return YXSecuGroupManager.shareInstance().rx.observeWeakly([YXSecuGroup].self, "allGroupsForShow").subscribe(onNext: { (secuGroupList) in
                var viewControllers = [YXOptionalListViewController]()
                
                if strongSelf.groupPool.count != 0 {
                    if let viewController = strongSelf.groupPool.values.first {
                        let viewModel = viewController.viewModel!
                        if let secuGuoup = viewModel.secuGroup.value ,
                           let targetSecuGroupIndex = secuGroupList?.firstIndex(where: { $0.id == secuGuoup.id }),
                           let targetSecuGroup = secuGroupList?[targetSecuGroupIndex] {
                            viewModel.secuGroup.accept(targetSecuGroup)
                            //
                            strongSelf.groupPool.removeAll()
                            strongSelf.groupPool[targetSecuGroup.id] = viewController
                        }
                    }
                    return
                }
               
                if let secuGroup = secuGroupList?.first {
                    let viewModel = YXOptionalListViewModel()
                    if secuGroup.id == YXDefaultGroupID.IDHOLD.rawValue {
                        viewModel.secuGroup.accept(YXSecuGroupManager.shareInstance().holdSecuGroup)
                    } else if secuGroup.id == YXDefaultGroupID.IDLATEST.rawValue {
                        viewModel.secuGroup.accept(YXSecuGroupManager.shareInstance().latestSecuGroup)
                    } else {
                        viewModel.secuGroup.accept(secuGroup)
                    }
                    viewModel.navigator = strongSelf.navigator
                    let viewController = YXOptionalListViewController.instantiate(withViewModel: viewModel, andServices: strongSelf.services, andNavigator: viewModel.navigator)
                    strongSelf.groupPool[secuGroup.id] = viewController
                    viewControllers.append(viewController)
                }

                observer.onNext(viewControllers)
            })
        }
        
        return observable.asDriver(onErrorJustReturn: [])
    }()
    
    //let quoteType = BehaviorRelay<YXStockRankSortType>(value:.now)
    
    var groupPool: [UInt: YXOptionalListViewController] = [:]
    
    var adResponse: YXResultResponse<YXUserBanner>?
    
    let adListRelay = BehaviorRelay<[BannerList]>(value: [])
    
    
    //是否已经请求过卡券banner
    var isLoadYXCouponBannerReq:Bool = false
    var freeCardListModel: YXCouponBannerResModel?
    let freeCardListRelay = BehaviorRelay<YXCouponBannerResModel?>(value: nil)
    
    var services: Services! {
        didSet {
            adResponse = { [weak self] (response) in
                guard let strongSelf = self else { return }
                
                switch response {
                case .success(let result, let code):
                    switch code {
                    case .success?:
                        if let adList = result.data?.dataList, adList.count > 0 {
                            strongSelf.adListRelay.accept(adList)
                        } else {
                            strongSelf.adListRelay.accept([])
                        }
                    default:
                        strongSelf.adListRelay.accept([])
                        break
                    }
                case .failed(_):
                    strongSelf.adListRelay.accept([])
                    break
                }
            }
        }
    }
    
    init() {
        
    }
    
    func requestOptionalOtherAdData() {
        let oldTime = MMKV.default().double(forKey: YXOptionalViewModel.optionalOtherAd, defaultValue: 0)
        let nowTime = Double(NSDate.beginOfToday().timeIntervalSince1970)
        if nowTime - oldTime > Double(24 * 60 * 60) {
            services.newsService.request(.userBannerV2(id: .selfStock), response: adResponse).disposed(by: disposeBag)
        } else {
            adListRelay.accept([])
        }
    }
    
    func closeOtherAd() {
        MMKV.default().set(Double(NSDate.beginOfToday().timeIntervalSince1970), forKey: YXOptionalViewModel.optionalOtherAd)
    }
    
    //需求是引流卡券广告比banner轮播的优先级高，以这个接口为主，这个有数据则不展示轮播banner数据
    func loadfreeCardData() {
//        guard isLoadYXCouponBannerReq == false else {
//            self.freeCardListRelay.accept(self.freeCardListModel)
//            return
//        }
        let requestModel = YXCouponBannerReq.init()
        let request = YXRequest.init(request: requestModel)
        request.startWithBlock { [weak self] responseModel in
            self?.isLoadYXCouponBannerReq = true
            self?.freeCardListModel = responseModel as? YXCouponBannerResModel
            if responseModel.code == .success,let model = responseModel as? YXCouponBannerResModel {
                self?.freeCardListRelay.accept(model)
            } else {
                self?.freeCardListRelay.accept(self?.freeCardListModel)
            }
        } failure: { request in
            self.isLoadYXCouponBannerReq = false
            self.freeCardListRelay.accept(nil)

        }
    }
}
