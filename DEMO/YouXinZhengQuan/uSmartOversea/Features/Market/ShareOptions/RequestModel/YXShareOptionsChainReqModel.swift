//
//  YXShareOptionsChainReqModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/11/24.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXShareOptionsChainReqModel: YXHZBaseRequestModel {
    
    //http://szshowdoc.youxin.com/web/#/23?page_id=2041
    
    @objc var market = "us"
    @objc var code = ""
    //到期日，如：20181224000000000
    @objc var maturityDate = ""
    //起始行权价，如：100
    @objc var nextPageBegin: Double = 0
    @objc var count = 100
    //方向，0：行权价正序，1：行权价逆序，2：按行权价上下取
    @objc var direction = 0
    
    override func yx_requestUrl() -> String {
        return "/quotes-dataservice-app/api/v1/optionchain"
    }
    
    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }
    
    override func yx_responseModelClass() -> AnyClass {
        return YXResponseModel.self
    }
}
