//
//  YXOpenAccountGuideViewModel.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/4/15.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import QMUIKit
import RxSwift

import RxCocoa
import RxDataSources
import NSObject_Rx
import URLNavigator

class YXOpenAccountGuideViewModel: YXWebViewModel, HasDisposeBag {
    static let openAccountGuideViewAd = "openAccountGuideViewAd"

    var adResponse: YXResultResponse<YXUserBanner>?
    
    let adListRelay = BehaviorRelay<[BannerList]>(value: [])
    
   override var services: Services! {
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
    
    func requestOptionalOtherAdData() {
        let oldTime = MMKV.default().double(forKey: YXOpenAccountGuideViewModel.openAccountGuideViewAd, defaultValue: 0)
        let nowTime = Double(NSDate.beginOfToday().timeIntervalSince1970)
        if nowTime - oldTime > Double(24 * 60 * 60) {
            services.newsService.request(.userBannerV2(id: .account), response: adResponse).disposed(by: disposeBag)
        } else {
            adListRelay.accept([])
        }
    }
    
    func closeOtherAd() {
        MMKV.default().set(Double(NSDate.beginOfToday().timeIntervalSince1970), forKey: YXOpenAccountGuideViewModel.openAccountGuideViewAd)
    }
}
