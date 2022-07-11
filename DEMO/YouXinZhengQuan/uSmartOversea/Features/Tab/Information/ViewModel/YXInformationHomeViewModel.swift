//
//  YXNewsHomeViewModel.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/9/6.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator

class YXInformationHomeViewModel: HUDServicesViewModel {

    typealias Services = HasYXInformationService & HasYXNewsService & HasYXQuotesDataService & HasYXWebService

//    var disposeBag = DisposeBag.init()
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    var navigator: NavigatorServicesType!
    
    var sepcialColumnSubject = PublishSubject<YXSpecialColumnListModel?>()
    var sepcialColumnResponse: YXResultResponse<YXSpecialColumnListModel>?
    
    var sepcialColumnList: [YXSpecialColumnModel]?
    
    var services: Services! {
        
        didSet {
            
            sepcialColumnResponse = {[weak self] (response) in
                switch response {
                case .success(let result, _):
                    self?.sepcialColumnList = result.data?.newsList
                    break
                case .failed(_):
                    break
                }
            }
            
        }
    }
}
