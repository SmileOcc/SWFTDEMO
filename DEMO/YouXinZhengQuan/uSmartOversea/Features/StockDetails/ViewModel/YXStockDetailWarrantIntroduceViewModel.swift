//
//  YXStockDetailWarrantIntroduceViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/12/15.
//  Copyright © 2019 RenRenDai. All rights reserved.
//
import UIKit
import RxSwift
import RxCocoa
import URLNavigator

class YXStockDetailWarrantIntroduceViewModel: HUDServicesViewModel {

    typealias Services = YXQuotesDataService
    var services: YXQuotesDataService! = YXQuotesDataService()
    var disposeBag = DisposeBag.init()
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    var navigator: NavigatorServicesType!

    var market: String = ""
    var symbol: String = ""
    var name: String = ""

    var relatedName: String = ""
    var relatedSymbol: String = ""
    var relatedMarket: String = ""

    var stockType: YXStockDetailStockType = .hkStock

    var hkwarrantResponse: YXResultResponse<YXHkwarrantListModel>?
    var stockHkwarrantDataSubject = PublishSubject<YXHkwarrantModel?>()

    var hkwarrantModel: YXHkwarrantModel?

    //MARK: 用户权限
    var level: QuoteLevel {

        let status = YXUserManager.userLevel(YXMarketType.HK.rawValue)
        switch status {
        case .hkDelay:
            return .delay
        case .hkBMP:
            return .bmp
        case .hkLevel1:
            return .level1
        case .hkLevel2, .hkWorldLevel2:
            return .level2
        default:
            return .delay
        }
    }

    var briefParameters: [YXStockDetailBasicType] {
        if self.stockType == .stInlineWarrant {
            return [ .secuCode, .name, .stock, .issuer, .upperStrike, .lowerStrike, .ent_ratio, .issue_vol, .listed_date, .maturity_date, .days_remain ]
        }
        return [ .secuCode, .name, .stock, .issuer, .stockNature, .calculation, .exercise_price, .ent_ratio, .issue_vol, .listed_date, .last_trade_day, .maturity_date, .days_remain ]
    }

    init() {


        //簡況
        hkwarrantResponse = {[weak self] (response) in
            switch response {
                case .success(let result, let code):
                    if code == .success {
                        guard let arr = result.data?.list, arr.count > 0 else { return }
                        self?.hkwarrantModel = arr[0]
                        self?.stockHkwarrantDataSubject.onNext(arr[0])
                    } else {
                        self?.stockHkwarrantDataSubject.onNext(nil)
                    }
                    break
                case .failed(_):
                    self?.stockHkwarrantDataSubject.onNext(nil)
                    break

            }
        }
    }
}
