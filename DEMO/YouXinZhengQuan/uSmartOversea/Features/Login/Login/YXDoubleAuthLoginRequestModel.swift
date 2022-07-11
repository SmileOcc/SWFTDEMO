//
//  YXDoubleAuthLoginRequestModel.swift
//  uSmartOversea
//
//  Created by ysx on 2022/2/16.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
//双重验证专用
class YXLoginSendEmailCaptchaRequestModel: YXJYBaseRequestModel {
   
    @objc var email = ""
    @objc var type = 107
    var token = ""
    override func yx_requestUrl() -> String {
        "/user-server-dolphin/api/send-email-captcha/v1"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.POST
    }

    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        ["Authorization": token]
    }
}

class YXLoginSendPhoneCaptchaRequestModel: YXJYBaseRequestModel {
    @objc var areaCode = ""
    @objc var phoneNumber = "" //要加密
    @objc var type = 107
    var token = ""
    override func yx_requestUrl() -> String {
        "/user-server-dolphin/api/send-phone-captcha/v1"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.POST
    }

    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        ["Authorization": token]
    }
}

class YXLoginCheckPhoneCaptchaRequestModel: YXJYBaseRequestModel {
    @objc var captcha = ""
    @objc var type = 107
    var token = ""
    override func yx_requestUrl() -> String {
        "/user-server-sg/api/check-phone-captcha/v1"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        ["Authorization": token,"Content-Type":"application/x-www-form-urlencoded"]
    }
}

class YXLoginCheckEmailCaptchaRequestModel: YXJYBaseRequestModel {
    @objc var captcha = ""
    @objc var email = ""
    @objc var type = 107
    var token = ""

    override func yx_requestUrl() -> String {
        "/user-server-sg/api/check-email-captcha/v1"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
        YXResponseModel.self
    }
    func yx_requestHeaderFieldValueDictionary() -> [String : String] {
        ["Authorization": token,"Content-Type":"application/x-www-form-urlencoded"]
    }
}


