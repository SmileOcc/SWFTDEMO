//
//  YXKindlyReminderSelectRequestModel.swift
//  YouXinZhengQuan
//
//  Created by Mac on 2020/4/20.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXKindlyReminderSelectRequestModel: YXJYBaseRequestModel {
    @objc var sceneType: Int = 1    //应用场景 1-月供股 2-IPO 3-入金 4-出金 5-货币兑换 6-转股 7-公司行动
    /*
     * http://10.60.6.90:1029/doc.html --> 配置管理-面向APP --> 温馨提示接口 -->
     * APP查询温馨提示 --> /config-manager/api/kindly-reminder-select/v1
     */
    override func yx_requestUrl() -> String {
        "/config-manager-sg/api/kindly-reminder-select/v1"
    }
    
    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }
}
