//
//  YXAboutViewModel.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/13.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import URLNavigator

class YXAboutViewModel: HUDServicesViewModel  {

 
    typealias Services = HasYXUserService
    var navigator: NavigatorServicesType!
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    var services: Services! {
        didSet {
            
        }
    }
    
    var introduces = [
        ["image":"shareholder","title":YXLanguageUtility.kLang(key: "mine_about_shareholder_title"),"desc":YXLanguageUtility.kLang(key: "mine_about_shareholder_desc")],
        ["image":"mine_about_st","title":YXLanguageUtility.kLang(key: "mine_about_st_title"),"desc":YXLanguageUtility.kLang(key: "mine_about_st_desc")],
        ["image":"mine_about_fees","title":YXLanguageUtility.kLang(key: "mine_about_fees_title"),"desc":YXLanguageUtility.kLang(key: "mine_about_fees_desc")],
        ["image":"mine_about_com","title":YXLanguageUtility.kLang(key: "mine_about_com_title"),"desc":YXLanguageUtility.kLang(key: "mine_about_com_desc")],
        ["image":"mine_about_mas","title":YXLanguageUtility.kLang(key: "mine_about_mas_title"),"desc":YXLanguageUtility.kLang(key: "mine_about_mas_desc")],
        ["image":"mine_about_learn","title":YXLanguageUtility.kLang(key: "mine_about_learn_title"),"desc":YXLanguageUtility.kLang(key: "mine_about_learn_desc")],
    ]
    
    var introducesTip = YXLanguageUtility.kLang(key: "mine_about_introduce_tip")

}
