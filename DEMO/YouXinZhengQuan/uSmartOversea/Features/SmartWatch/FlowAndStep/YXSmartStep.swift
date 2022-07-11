//
//  YXSmartStep.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2019/4/10.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxFlow

enum YXSmartStep: Step {
    
    //智能盯盘
    case smartWatchIsRequired
    
    // 持仓推送设置
    case smartSettingsIsRequired(smartType: Int)
    
    //智能盯盘
    case searchIsRequired(type: YXSearchType)
    
    // 页面显示完成，退出当前页面
    case showControllerIsCompelted
}
