//
//  YXAggregationAPI.swift
//  uSmartOversea
//
//  Created by mac on 2019/3/27.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import Moya

let aggregationProvider = MoyaProvider<YXAggregationAPI>(requestClosure: requestTimeoutClosure, session : YXMoyaConfig.session(), plugins: [YXNetworkLoggerPlugin(verbose: true)])

public enum YXAggregationAPI {
    /* 登录聚合接口
     login-aggregation/v1 */
    case login (_ areaCodes: String, _ phoneNumber: String, _ password: String)
    /* 第三方登录+注册
     wechat-login-aggregation/v1    微信登录聚合接口
     facebook-login-aggregation/v1  facebook登录聚合接口
     google-login-aggregation/v1    google登录聚合接口
     */
    case thirdLogin (_ accessToken: String, _ openId: String, _ appleParams: [String: Any]?, _ type: YXThirdLoginType)
    /* 短信验证码登录聚合接口
     captcha-login-aggregation/v1 */
    case captchaLogin (_ areaCodes: String, _ phoneNumber: String, _ captcha: String)
    case updateUserInfo(_ activateToken: Bool)
    /* 短信验证码注册登陆聚合接口
     captcha-register-aggregation/v1 */
    case captchaRegister (_ areaCode: String, _ captcha: String, _ phoneNumber: String, _ forceRegister:Bool, _ recommendCode: String, _ proPhone: Bool, _ proSms: Bool, _ proEmail: Bool, _ proMail: Bool)
    /* 短信验证码+证件号激活登陆聚合接口 POST请求
     captcha-activate-login-aggregation/v1 */
    case captchaActivateLoginAggreV1(areaCode: String, captcha: String, phoneNumber: String, identifyCode:String)
    /*三方登录绑定手机号码聚合接口
     three-login-tel-aggregation/v1 */
    case thirdLoginTelAggreV1(_ password:String,_ areaCode:String, _ captcha:String, _ phoneNumber:String, _ thirdLoginType:Int, _ accessToken:String, _ openId:String?, _ appleUserId: String?,_ lineUserID : String?, _ recommendCode: String, _ proPhone: Bool, _ proSms: Bool, _ proEmail: Bool, _ proMail: Bool)
    /* 三方登录预注册手机号码激活聚合接口
     three-login-guest-activate-aggregation/v1  */
    case thirdLoginActivateAggreV1(_ areaCode:String, _ captcha:String, _ phoneNumber:String, _ thirdLoginType:Int, _ accessToken:String,_ identifyCode:String, _ openId:String?)
    /* 机构户短信验证码登录聚合接口
     captcha-login-aggregation/v1 */
    case orgCaptchaLogin(_ areaCodes: String, _ phoneNumber: String, _ captcha: String)
    case orgEmailPwdLogin(_ email: String, _ pwd: String)
    case orgPhoneLogin(_ areaCodes: String, _ phoneNumber: String, _ pwd: String)
    case orgDouableCheckLogin(_ areaCodes: String, _ phoneNumber: String, _ email: String, _ captcha: String, _ verifyLoginType: String)
    case orgActiviteLogin(_ areaCodes: String, _ phoneNumber: String, _ email: String, _ captcha: String, _ verifyLoginType: String ,_ registNumber: String, _ pwd: String)
    /*邮箱注册
     /email-captcha-password-register-aggregation/v1 */
    case emailRegister(_ captcha: String, _ email:String, _ pwd:String?, _ recommendCode:String)
    /*手机号注册
    phone-captcha-password-register-aggregation/v1 */
    case mobileRegister(_ areaCodes: String, _ phoneNumber: String, _ captcha: String, _ pwd:String, _ recommendCode:String)
    /*手机号 验证码注册
     aggregation-server-sg/api/sign-aggregation/v1 */
    case mobileCodeRegister(_ areaCodes: String, _ phoneNumber: String, _ pwd:String?, _ captcha: String, _ recommendCode:String)
  
    /* 第三登录方邮箱绑定
     three-login-email-bind-aggregation/v1
     */
    case thirdLoginEmailBind(_ password:String,_ captcha:String, _ email:String, _ thirdLoginType:Int, _ accessToken:String, _ openId:String?, _ appleUserId: String?,lineId:String)
    
    //Line 登录
    case lineLogin (_ accessToken: String, _ openId: String)
}

extension YXAggregationAPI: YXTargetType {
    
    public var path: String {
        switch self {
            /* 登录聚合接口
         account-number-password-login-aggregation/v1 */
        case .login:
            return servicePath + "account-number-password-login-aggregation/v1"
            /* 第三方登录+注册
             wechat-login-aggregation/v1    微信登录聚合接口
             facebook-login-aggregation/v1  facebook登录聚合接口
             google-login-aggregation/v1    google登录聚合接口 */
        case .thirdLogin(_, _, _, let type):
            if type == .weChat {
                return servicePath + "wechat-login-aggregation/v1"     //"hk-wechat-login-aggregation/v1"
            } else if type == .faceBook {
                return servicePath + "facebook-login-aggregation/v1"
            } else if type == .google {
                return servicePath + "google-login-aggregation/v1"
            } else if type == .apple {
                return servicePath + "apple-login-aggregation/v1"
            }
            
            return ""
            /* 短信验证码登录聚合接口
             captcha-login-aggregation/v1 */
        case .captchaLogin:
            return servicePath + "captcha-login-aggregation/v1"
        case .updateUserInfo://获取用户信息
            return servicePath + "user-info-aggregation/v1"
            /* 短信验证码注册登陆聚合接口
             captcha-register-aggregation/v1 */
        case .captchaRegister:
            return servicePath + "captcha-register-aggregation/v1"
            /* 短信验证码+证件号激活登陆聚合接口 POST请求
             captcha-activate-login-aggregation/v1 */
        case .captchaActivateLoginAggreV1:
            return servicePath + "captcha-activate-login-aggregation/v1"
        /*三方登录绑定手机号码聚合接口
         three-login-tel-aggregation/v1 */
        case .thirdLoginTelAggreV1:
            return servicePath + "three-login-tel-aggregation/v1"
            
        /* 三方登录预注册手机号码激活聚合接口
         three-login-guest-activate-aggregation/v1  */
        case .thirdLoginActivateAggreV1:
            return servicePath + "three-login-guest-activate-aggregation/v1"
            
        case .orgCaptchaLogin:
            return servicePath + "org-user-phone-captcha-login-aggregation/v1"
        case .orgEmailPwdLogin:
            return servicePath + "org-user-email-password-login-aggregation/v1"
        case .orgPhoneLogin:
            return servicePath + "org-user-phone-password-login-aggregation/v1"
        case .orgDouableCheckLogin:
            return servicePath + "org-user-device-captcha-login-aggregation/v1"
        case .orgActiviteLogin:
            return servicePath + "org-user-login-activate-aggregation/v1"
         
        //手机、邮箱密码注册
        case .emailRegister:
            return servicePath + "email-captcha-password-register-aggregation/v1"
        case .mobileRegister:
            return servicePath + "phone-captcha-password-register-aggregation/v1"
        case .mobileCodeRegister:
            return servicePath + "sign-aggregation/v1"
        case .thirdLoginEmailBind:
            return servicePath + "three-login-email-bind-aggregation/v1"
            
        case .lineLogin:
            return servicePath + "line-login/v1"
        }
    }
    
    public var task: Task {
        var params: [String: Any] = [:]
        switch self {
      
        case .login(let areaCodes, let accountNumber, let password):
            /* 登录聚合接口   密码登录
             login-aggregation/v1 */
            params["areaCode"] = areaCodes
            params["source"] = "2"
            let quoteChartHk = YXUserManager.curQuoteChartHk(judgeIsLogin: true).rawValue
            let sortHk = YXSecuGroupManager.shareInstance().sortflag//YXUserManager.curSortHK(judgeIsLogin: true).rawValue
            let languageHk = YXUserManager.curLanguage().rawValue
            let lineColorHk = YXUserManager.curColor(judgeIsLogin: true).rawValue
             
             params["accountNumber"] = accountNumber
             params["password"] = password
             params["modifyUserConfigParam"] = ["quoteChartHk":quoteChartHk,
                                                "sortHk":sortHk,
                                                "languageHk":languageHk,
                                                "lineColorHk":lineColorHk]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .thirdLogin(let accessToken, let openId, let appleParams, let type):
            /* 第三方登录+注册
             wechat-login-aggregation/v1    微信登录聚合接口
             facebook-login-aggregation/v1  facebook登录聚合接口
             google-login-aggregation/v1    google登录聚合接口 */
            if type == .apple {
                params = appleParams ?? [:]
            } else if type == .weChat {
                params["accessToken"] = accessToken
                params["openId"] = openId
            }else {
                params["accessToken"] = accessToken
            }
            params["mustBindMobile"] = true //1.2之前的不填，新版本必填，传Ture
            params["quoteChartHk"] = YXUserManager.curQuoteChartHk(judgeIsLogin: true).rawValue
            params["sortHk"] = YXSecuGroupManager.shareInstance().sortflag//YXUserManager.curSortHK(judgeIsLogin: true).rawValue
            params["languageHk"] = YXUserManager.curLanguage().rawValue
            params["lineColorHk"] = YXUserManager.curColor(judgeIsLogin: true).rawValue
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .captchaLogin(let areaCodes, let phoneNumber, let captcha):
            /* 短信验证码登录聚合接口    使用的地方：双重验证
             captcha-login-aggregation/v1 */
            params["areaCode"] = areaCodes
            params["phoneNumber"] = phoneNumber
            params["captcha"] = captcha
            params["source"] = "2"
            params["quoteChartHk"] = YXUserManager.curQuoteChartHk(judgeIsLogin: true).rawValue
            params["sortHk"] = YXSecuGroupManager.shareInstance().sortflag//YXUserManager.curSortHK(judgeIsLogin: true).rawValue
            params["languageHk"] = YXUserManager.curLanguage().rawValue
            params["lineColorHk"] = YXUserManager.curColor(judgeIsLogin: true).rawValue
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .updateUserInfo(let activateToken):
            params["activateToken"] = activateToken
            return .requestParameters(parameters: params, encoding: URLEncoding.default)//get,formdate
        case .captchaRegister(let areaCode, let captcha, let phoneNumber, let forceRegister, let recommendCode, let proPhone, let proSms, let proEmail, let proMail):
            /*短信验证码注册登陆聚合接口 POST请求  短信登录注册
             forceRegister  强制注册(true是 false否)
             captcha-register-aggregation/v1   */
            params["areaCode"] = areaCode
            params["captcha"] = captcha
            params["phoneNumber"] = phoneNumber
            params["forceRegister"] = forceRegister
            params["recommendCode"] = recommendCode
            params["source"] = "2"   //来源(1.android 2.ios)
            params["quoteChartHk"] = YXUserManager.curQuoteChartHk(judgeIsLogin: true).rawValue
            params["sortHk"] = YXSecuGroupManager.shareInstance().sortflag//YXUserManager.curSortHK(judgeIsLogin: true).rawValue
            params["languageHk"] = YXUserManager.curLanguage().rawValue
            params["lineColorHk"] = YXUserManager.curColor(judgeIsLogin: true).rawValue
            params["phoneSet"] = proPhone ? 1 : 0
            params["smsSet"] = proSms ? 1 : 0
            params["emailSet"] = proEmail ? 1 : 0
            params["mailSet"] = proMail ? 1 : 0
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .captchaActivateLoginAggreV1(let areaCode, let captcha, let phoneNumber, let identifyCode):
            /* 短信验证码+证件号激活登陆聚合接口 POST请求     激活登录
             captcha-activate-login-aggregation/v1 */
            params["areaCode"] = areaCode
            params["captcha"] = captcha
            params["phoneNumber"] = phoneNumber
            params["identifyCode"] = identifyCode
            params["source"] = "2"
            params["quoteChartHk"] = YXUserManager.curQuoteChartHk(judgeIsLogin: true).rawValue
            params["sortHk"] = YXSecuGroupManager.shareInstance().sortflag//YXUserManager.curSortHK(judgeIsLogin: true).rawValue
            params["languageHk"] = YXUserManager.curLanguage().rawValue
            params["lineColorHk"] = YXUserManager.curColor(judgeIsLogin: true).rawValue
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .thirdLoginTelAggreV1(let password,let areaCode, let captcha, let phoneNumber, let thirdLoginType, let accessToken, let openId, let appleUserId, let lineUserId,let recommendCode, let proPhone, let proSms, let proEmail, let proMail):
            /*三方登录绑定手机号码聚合接口
             three-login-tel-aggregation/v1 */
            params["password"] = password
            params["areaCode"] = areaCode
            params["captcha"] = captcha
            params["phoneNumber"] = phoneNumber
            params["thirdLoginType"] = thirdLoginType
            params["accessToken"] = accessToken
            params["openId"] = openId
            params["appleUserId"] = appleUserId
            params["recommendCode"] = recommendCode
            params["validCaptcha"] = true
            params["phoneSet"] = proPhone ? 1 : 0
            params["smsSet"] = proSms ? 1 : 0
            params["emailSet"] = proEmail ? 1 : 0
            params["mailSet"] = proMail ? 1 : 0
            params["lineId"] = lineUserId
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
            /* 三方登录预注册手机号码激活聚合接口
             three-login-guest-activate-aggregation/v1  */
        case .thirdLoginActivateAggreV1(let areaCode, let captcha, let phoneNumber, let thirdLoginType,let accessToken,let identifyCode, let openId):
                params["areaCode"] = areaCode
                params["captcha"] = captcha
                params["phoneNumber"] = phoneNumber
                params["thirdLoginType"] = thirdLoginType
                params["accessToken"] = accessToken
                params["identifyCode"] = identifyCode
                params["openId"] = openId
                params["validCaptcha"] = true
                return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .orgCaptchaLogin(let areaCodes, let phoneNumber, let captcha):
                         
            params["areaCode"] = areaCodes
            params["phoneNumber"] = phoneNumber
            params["captcha"] = captcha
            params["source"] = "2"
            params["languageCn"] = 1
//            params["quoteChartHk"] = YXUserManager.curQuoteChartHk(judgeIsLogin: true).rawValue
//            params["sortHk"] = YXSecuGroupManager.shareInstance().sortflag//YXUserManager.curSortHK(judgeIsLogin: true).rawValue
//            params["languageHk"] = YXUserManager.curLanguage().rawValue
//            params["lineColorHk"] = YXUserManager.curColor(judgeIsLogin: true).rawValue
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .orgEmailPwdLogin(let email, let pwd):
            params["email"] = email
            params["password"] = pwd
            params["source"] = "2"
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .orgPhoneLogin(let areaCode, let phoneNumber, let pwd):
            params["areaCode"] = areaCode
            params["phoneNumber"] = phoneNumber
            params["password"] = pwd
            params["source"] = "2"
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .orgDouableCheckLogin(let areaCodes, let phoneNumber, let email, let captcha, let verifyLoginType):
            params["areaCode"] = areaCodes
            params["phoneNumber"] = phoneNumber
            params["captcha"] = captcha
            params["email"] = email
            params["source"] = "2"
            params["verifyLoginType"] = verifyLoginType
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .orgActiviteLogin(let areaCodes, let phoneNumber, let email, let captcha, let verifyLoginType, let registNumber, let pwd):
            params["areaCode"] = areaCodes
            params["phoneNumber"] = phoneNumber
            params["captcha"] = captcha
            params["email"] = email
            params["verifyLoginType"] = verifyLoginType
            params["registNumber"] = registNumber
            params["password"] = pwd
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .mobileRegister(let areaCodes, let phoneNumber, let captcha, let password, let recommendCode):
            params["areaCode"] = areaCodes
            params["phoneNumber"] = phoneNumber
            params["password"] = password
            params["captcha"] = captcha
            params["source"] = "2"
            params["quoteChartHk"] = YXUserManager.curQuoteChartHk(judgeIsLogin: true).rawValue
            params["sortHk"] = YXSecuGroupManager.shareInstance().sortflag
            params["languageHk"] = YXUserManager.curLanguage().rawValue
            params["lineColorHk"] = YXUserManager.curColor(judgeIsLogin: true).rawValue
            params["phoneSet"] =  1
            params["smsSet"] = 1
            params["emailSet"] = 1
            params["mailSet"] =  1
            params["recommendCode"] =  recommendCode
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .emailRegister(let captcha, let email, let pwd, let recommendCode):
            params["email"] = email
            params["password"] = pwd
            params["captcha"] = captcha
            params["source"] = "2"
            params["quoteChartHk"] = YXUserManager.curQuoteChartHk(judgeIsLogin: true).rawValue
            params["sortHk"] = YXSecuGroupManager.shareInstance().sortflag
            params["languageHk"] = YXUserManager.curLanguage().rawValue
            params["lineColorHk"] = YXUserManager.curColor(judgeIsLogin: true).rawValue
            params["phoneSet"] =  1
            params["smsSet"] = 1
            params["emailSet"] = 1
            params["mailSet"] =  1
            params["recommendCode"] =  recommendCode

            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        
        case .mobileCodeRegister(let areaCodes, let phoneNumber, let pwd, let captcha, let recommendCode):
            params["areaCode"] = areaCodes
            params["phoneNumber"] = phoneNumber
            params["password"] = pwd
            params["captcha"] = captcha
            params["source"] = "2"
            params["quoteChartHk"] = YXUserManager.curQuoteChartHk(judgeIsLogin: true).rawValue
            params["sortHk"] = YXSecuGroupManager.shareInstance().sortflag
            params["languageHk"] = YXUserManager.curLanguage().rawValue
            params["lineColorHk"] = YXUserManager.curColor(judgeIsLogin: true).rawValue
            params["phoneSet"] =  1
            params["smsSet"] = 1
            params["emailSet"] = 1
            params["mailSet"] =  1
            params["recommendCode"] =  recommendCode
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .thirdLoginEmailBind(let password,let captcha, let email, let thirdLoginType, let accessToken, let openId, let appleUserId,let lineId):
            /*三方登录绑定手机号码聚合接口
             three-login-email-bind-aggregation/v1 */
            params["password"] = password
            params["captcha"] = captcha
            params["email"] = email
            params["thirdLoginType"] = thirdLoginType
            params["accessToken"] = accessToken
            params["openId"] = openId
            params["appleUserId"] = appleUserId
            params["validCaptcha"] = true
            params["lineId"] = lineId
            
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .lineLogin(let accessToken, let uid):
            params["lineId"] = uid
            params["accessToken"] = accessToken
            params["mustBindMobile"] = true //1.2之前的不填，新版本必填，传Ture
            params["quoteChartHk"] = YXUserManager.curQuoteChartHk(judgeIsLogin: true).rawValue
            params["sortHk"] = YXSecuGroupManager.shareInstance().sortflag//YXUserManager.curSortHK(judgeIsLogin: true).rawValue
            params["languageHk"] = YXUserManager.curLanguage().rawValue
            params["lineColorHk"] = YXUserManager.curColor(judgeIsLogin: true).rawValue
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }
    
    public var baseURL: URL {
        URL(string: YXUrlRouterConstant.jyBaseUrl())!
    }
    
    public var requestType: YXRequestType {
        return .jyRequest
    }
    
    public var servicePath: String {
        switch self {
        case .lineLogin:
            return "/user-server-dolphin/api/"
        default:
            return "/aggregation-server-dolphin/api/"
        }
        
    }
    
    public var method: Moya.Method {
        switch self {
        case .updateUserInfo:
            return .get
        default:
            return .post
        }
    }
    
    public var headers: [String : String]? {
        yx_headers
    }
    
    public var contentType: String? {
        switch self {
        case .updateUserInfo:
             return "application/x-www-form-urlencoded"
        case .thirdLogin,
             .lineLogin:
            return "application/json"
        default:
            return nil
        }
    }
    
    public var sampleData: Data {
        switch self {
        default:
            return Data()
        }
    }
}


public enum YXThirdLoginType: Int {
    case weChat = 1
    case weibo = 2
    case google = 3
    case faceBook = 4
    case apple = 6
    case line = 7
}
