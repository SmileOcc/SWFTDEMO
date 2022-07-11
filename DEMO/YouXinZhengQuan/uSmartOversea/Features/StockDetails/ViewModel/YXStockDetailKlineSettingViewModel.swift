//
//  YXStockDetailKlineSettingViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/12/17.
//  Copyright © 2019 RenRenDai. All rights reserved.
//
import UIKit
import RxSwift
import RxCocoa
import URLNavigator

class YXStockDetailKlineSettingViewModel: HUDServicesViewModel {

    typealias Services = YXNewStockService
    var navigator: NavigatorServicesType!

    var market: String = YXMarketType.HK.rawValue

    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    let alertSubject = PublishSubject<Bool>()
    var services: Services! = YXNewStockService()

    lazy var userLevel: QuoteLevel = {

        YXUserManager.shared().getLevel(with: self.market)
    }()

    var dataSource: NSMutableArray = [YXKLineConfigManager.shareInstance().mainSettingTitleArr, YXKLineConfigManager.shareInstance().subSettingTitleArr]


}


