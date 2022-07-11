//
//  YXProLevelUpModel.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/8/5.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXProLevelUpModel: YXResponseModel {
    @objc var popUpPicUrl: String = ""  //弹窗图片链接string
    @objc var skipUrl: String = ""  //跳转链接 string
    
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        return [
            "popUpPicUrl": "data.popUpPicUrl",
            "skipUrl" : "data.skipUrl"
        ]
    }
}
