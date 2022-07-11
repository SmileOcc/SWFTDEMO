//
//  YXAreaCodeViewModel.swift
//  uSmartOversea
//
//  Created by Mac on 2019/10/24.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator

import YXKit



class YXAreaCodeViewModel: HUDServicesViewModel {
    
    typealias Services = HasYXInformationService & HasYXNewsService & HasYXQuotesDataService
    
    var disposeBag = DisposeBag.init()

    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    var navigator: NavigatorServicesType!
    
    let didSelectSubject = PublishSubject<String>()
    

    var wordArray: [String] {
        YXAreaCodeManager.getAreaCodeTitleArr(from: self.searchedArr)
    }
    
    //搜索结果
    lazy var searchedArr: [YXAreaCodeModel] = {
        self.areaCodeArr
    }()
    
    lazy var curLangType = YXCodeLanguageType(rawValue: YXUserManager.curLanguage().rawValue) ?? .EN    //当前语言
    //排序好的结果
    lazy var areaCodeArr: [YXAreaCodeModel] = {
        
        let tempOther: [Country] = (YXGlobalConfigManager.shareInstance.countryAreaModel?.othersCountry ?? [Country]() ) + (YXGlobalConfigManager.shareInstance.countryAreaModel?.commonCountry ?? [Country]())
        
        
        return YXAreaCodeManager.sortAreaCodeArr(with: tempOther, curLangType: curLangType)
    }()
    
    var services: Services! {
    didSet {
        
        }
    }
    
    func matchingCodeArr(with text: String) {
        self.searchedArr = YXAreaCodeManager.matchAreaCodeArr(with: text, curLangType: self.curLangType, sortedArr: self.areaCodeArr)
    }
    
}
