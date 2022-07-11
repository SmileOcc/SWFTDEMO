//
//  YXUserAPI.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/10.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import Moya

let userProvider = MoyaProvider<YXUserAPI>(requestClosure: requestTimeoutClosure, session : YXMoyaConfig.session(), plugins: [YXNetworkLoggerPlugin(verbose: true)])

public enum YXUserAPI {
    
    case changePwd (_ oldPassword: String, password: String)
    case bindWechat (_ accessToken: String, _ openId: String)
    case bindFacebook (_ accessToken: String)
    case bindGoogle (_ accessToken: String)
    case bindApple (_ parmas: [String: Any])
    case bindLine (_ accessToken:String, _ lineID: String)
    case unBindWechat
    case unBindGoogle
    case unBindFacebook
    case unBindApple
    case unBindLine
    /*//获取手机验证码(默认用户手机号)
     type:业务类型（201 重置交易密码短信 202 更换手机号 203 设置登录密码）
     token-send-phone-captcha/v1  */
    case tokenSendCaptcha (_ type: NSInteger)
    /*校验更换手机号验证码
     verify-replace-phone/v1 */
    case verifyChangePhone (_ captcha: String, _ pwd: String)
    /*更换手机号
     replace-phone/v1 */
    case changePhone (_ captcha: String, _ phone: String, _ areaCode: String)
    /*更换邮箱
     replace-email/v1 */
    case changeEmail (_ email: String, _ pwd: String)
    /*修改用户配置信息
     modify-user-config/v1 */
    case modifyUserConfig(_ type: YXModifyUserConfigType, _ value: Int)
    /*废弃，没有使用*/
    case modifyUserConfigAllHK(_ languageHK: Int, _ lineColorHK: Int, _ quoteChartHK: Int, _ sortHk: Int)
    /* 优惠信息设定 */
    case modifyUserConfigPromot(_ phone: Bool, _ sms: Bool, _ email: Bool, _ mail: Bool)
    /*获取当前用户信息
     get-current-user/v1 */
    case getCurrentUser
    
    case feedback (_ content: String, _ areaCode: String, _ phoneNumber: String, _ email: String, _ filePath: [AnyHashable])
    /*校验交易密码
     check-trade-password/v1 */
    case checkTradePwd (_ password: String)
    case getTradeLoginStatus
    /*获取客户开户证件类型
     1.大陆身份证;2.香港身份证;3.护照;4.香港永久居民身份证
     get-customer-identify-type/v1 */
    case idType
    /* 校验身份证
     verify-identify-id/v1 */
    case checkId (_ identifyId: String)
    /*修改交易密码
     update-trade-password/v1 */
    case changeTradePwd (_ oldPassword: String, _ password: String)
    /* 校验手机验证码是否正确
     type: 业务类型（201重置交易密码短信验证202更换手机号短信验证）
     check-phone-captcha/v1 */
    case checkCaptcha (_ captcha: String, type: NSInteger)
    /*重置交易密码
     reset-trade-password/v1 */
    case resetTradePwd (_ password: String, _ captcha: String)
    /*http://admin-dev.yxzq.com/user-server/doc/doc.html
    --> 1-APP -->交易业务 --> 第一次设置交易密码
    set-trade-password/v1 */
    case setTradePwd (_ password: String, _ brokerNo: String)
    /*http://admin-dev.yxzq.com/user-server/doc/doc.html
     --> 1-APP -->交易业务 --> 交易登录
    trade-login/v1 */
    case tradePwdLogin (_ password: String)
    /*http://admin-dev.yxzq.com/user-server/doc/doc.html
    --> 1-APP -->交易业务 --> 获取用户交易密码临时认证token
    get-trade-password-token/v1 */
    case getTradePasswordToken (_ password: String)

    /*第一次绑定手机号
     GET请求
     api/bind-phone/v1  */
    case bindPhone (areaCode:String, captcha:String, password:String, phoneNumber:String)
    
    /* 设置登陆密码 post
     set-login-password/v1  */
    case setLoginPwd(captcha:String, password:String)
    /* 设置登陆密码 post
     first-set-login-password/v1  */
    case setFirstLoginPwd(password:String)
    
    /*更新用户基本信息
     update-base-user-info/v1 */
    case updateUserInfo(avatar:String?, nickname:String?)
    // 交易退出登录
    case tradeLogout
    //用户同意暗盘风披 hidden-risk-autograph/v1
    case hiddenRiskAuthgraph
    //美股打新风险提示签名
    case verifySignature(agreementName: String, agreementUrl: String, autograph: String, riskTips: String, stockId: String, stockName: String)
    /*http://szshowdoc.youxin.com/web/#/23?page_id=791 -> news-configserver
     -> 文案管理V2(香港+大陆) -> v2/query/copywriting  */
    case queryCopyWriting
    case unBindWechatPushSingal
    /*更换邮箱 要验证码
     replace-email/v2 */
    case verifyChangeEmail (_ email: String, _ captcha:String,_ pwd: String)
    /*绑定邮箱
     /api/bind-user-email/v1*/
    case bindEmail (_ email: String, _ captcha:String,_ pwd: String)
    /* 获取邮箱验证码
     token-send-email-captcha/v1   业务类型（1. 重置交易密码 ）
     */
  //  case tokenSendEmailCaptcha (_ type: YXSendCaptchaType)
    
    /* 校验邮箱验证码是否正确
     type: 业务类型（1重置交易密码短信验证）
     check-email-captcha/v1 */
    case checkEmailCaptcha (_ captcha: String, type: YXSendCaptchaType, email:String)
    
    /* 校验邮箱验证码是否正确 (邮箱注册）
     type: 业务类型（1重置交易密码短信验证）
     check-email-captcha/v2 */
    case registerCheckEmailCaptcha (_ captcha: String, type: YXSendCaptchaType, email:String)
    
    /*
     获取是否设置过交易密码
     get-user-is-set-trade-password/v1
     */
    case getIsSetTradePwd
    
    /*?
     检查用户是否开户
     ib-get-user-is-open-account/v1
     */
    case checkOpenAccount
    /*?
     检查IB用户原始账号信息
     ib-get-dolphin-id-and-original-password/v1
     */
    case getIBAccountInfo(_ captha:String)
   /*
     api/send-email-captcha/v1  10001-注册 1-重置交易密码 2-重置登陆密码 20001-
     */
    case sendEmailInputCaptcha(_ email: String, _ type: YXSendCaptchaType)
    
}

extension YXUserAPI: YXTargetType {
    
    public var path: String {
        switch self {
       
        case .changePwd:
             return servicePath + "update-login-password/v1"
        case .bindWechat:
             return servicePath + "wechat-bind/v1"
        case .bindFacebook:
            return servicePath + "facebook-bind/v1"
        case .bindApple:
            return servicePath + "apple-bind/v1"
        case .bindGoogle:
            return servicePath + "google-bind/v1"
        case .bindLine:
            return servicePath + "line-bind/v1"
        case .unBindWechat:
            return servicePath + "wechat-unbind/v1"
        case .unBindGoogle:
            return servicePath + "google-unbind/v1"
        case .unBindFacebook:
            return servicePath + "facebook-unbind/v1"
        case .unBindApple:
            return servicePath + "apple-unbind/v1"
        case .unBindLine:
            return servicePath + "line-unbind/v1"
            /*//获取手机验证码(默认用户手机号)
             type:业务类型（201 重置交易密码短信 202 更换手机号 203 设置登录密码）
             token-send-phone-captcha/v1  */
        case .tokenSendCaptcha:
            return servicePath + "token-send-phone-captcha/v1"
            /*校验更换手机号验证码
             verify-replace-phone/v1 */
        case .verifyChangePhone:
            return servicePath + "verify-replace-phone/v1"
            /*更换手机号
             replace-phone/v1 */
        case .changePhone:
            return servicePath + "replace-phone/v1"
            /*更换邮箱
             replace-email/v1 */
        case .changeEmail:
            return servicePath + "replace-email/v1"
        case .modifyUserConfig:
            return servicePath + "modify-user-config/v1"
        /*废弃，没有使用*/
        case .modifyUserConfigAllHK:
            return servicePath + "modify-user-config/v1"
        /* 优惠信息设定 */
        case .modifyUserConfigPromot:
            return servicePath + "modify-user-config/v1"
        /*获取当前用户信息
         get-current-user/v1 */
        case .getCurrentUser:
            return servicePath + "get-current-user/v1"
        case .feedback:
            return servicePath + "add-feedback/v1"
            /*校验交易密码
             check-trade-password/v1 */
        case .checkTradePwd:
            return servicePath + "check-trade-password/v1"
            /*获取客户开户证件类型
             1.大陆身份证;2.香港身份证;3.护照;4.香港永久居民身份证
             get-customer-identify-type/v1 */
        case .idType:
            return servicePath + "get-customer-identify-type/v1"
            /* 校验身份证
             verify-identify-id/v1 */
        case .checkId:
            return servicePath + "verify-identify-id/v1"
            /*修改交易密码
             update-trade-password/v1 */
        case .changeTradePwd:
            return servicePath + "update-trade-password/v1"
            /* 校验手机验证码是否正确
             type: 业务类型（201重置交易密码短信验证202更换手机号短信验证）
             check-phone-captcha/v1 */
        case .checkCaptcha:
            return servicePath + "check-phone-captcha/v1"
            /*重置交易密码
             reset-trade-password/v1 */
        case .resetTradePwd:
            return servicePath + "reset-trade-password/v1"
        case .setTradePwd:
            /*http://admin-dev.yxzq.com/user-server/doc/doc.html
            --> 1-APP -->交易业务 --> 第一次设置交易密码
            set-trade-password/v1 */
            return servicePath + "set-trade-password/v1"
        case .tradePwdLogin:
            /*http://admin-dev.yxzq.com/user-server/doc/doc.html
             --> 1-APP -->交易业务 --> 交易登录
             trade-login/v1 */
            return servicePath + "trade-login/v2"
        case .getTradePasswordToken:
            /*http://admin-dev.yxzq.com/user-server/doc/doc.html
             --> 1-APP -->交易业务 --> 获取用户交易密码临时认证token
             get-trade-password-token/v1 */
            return servicePath + "get-trade-password-token/v1"
            /*第一次绑定手机号
             GET请求
             api/bind-phone/v1  */
        case .bindPhone:
            return servicePath + "bind-phone/v1"
            /* 设置登陆密码 post
             set-login-password/v1  */
        case .setLoginPwd:
            return servicePath + "set-login-password/v1"
            /*更新用户基本信息 put
             update-base-user-info/v1 */
        case .setFirstLoginPwd:
            return servicePath + "first-set-login-password/v1"
        case .updateUserInfo:
            return servicePath + "update-base-user-info/v1"
        case .getTradeLoginStatus:
            return servicePath + "get-trade-status/v1"
        case .tradeLogout:
            return servicePath + "trade-logout/v1"
        //用户同意暗盘风披 hidden-risk-autograph/v1
        case .hiddenRiskAuthgraph:
            return servicePath + "hidden-risk-autograph/v1"
        case .verifySignature:
            return servicePath + "new-stock-risk-autograph/v1"
        case .queryCopyWriting:
            /*http://szshowdoc.youxin.com/web/#/23?page_id=791 -> news-configserver
            -> 文案管理V2(香港+大陆) -> v2/query/copywriting  */
            return servicePath + "query/copywriting"
        case .unBindWechatPushSingal:
            return servicePath + "push/setting"
            /*
               验证码方式修改邮箱 */
        case .verifyChangeEmail:
            return servicePath + "replace-email/v2"
            
        case .bindEmail:
            return servicePath + "bind-user-email/v1"
            
//        case .tokenSendEmailCaptcha:
//            return servicePath + "token-send-email-captcha/v1"
            
        case .checkEmailCaptcha:
            return servicePath + "check-email-captcha/v1"
        case .registerCheckEmailCaptcha:
            return servicePath + "check-email-captcha/v2"
        case .getIsSetTradePwd:
            return servicePath + "get-user-is-set-trade-password/v1"
            
        case .checkOpenAccount:
            return servicePath + "ib-get-user-is-open-account/v1"
        case .getIBAccountInfo:
            return servicePath + "ib-get-dolphin-id-and-original-password/v1"
        case .sendEmailInputCaptcha:
            return servicePath + "send-email-captcha/v1"
        }
    }
    
    public var task: Task {
        var params: [String: Any] = [:]
        switch self {
        
        case .changePwd(let oldPassword, let password):
            params["oldPassword"] = oldPassword
            params["password"] = password
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .bindWechat(let accessToken, let openId):
            params["accessToken"] = accessToken
            params["openId"] = openId
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .bindFacebook(let accessToken):
            params["accessToken"] = accessToken
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .bindGoogle(let accessToken):
            params["accessToken"] = accessToken
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .bindApple(let appleParams):
            params = appleParams
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .bindLine(let accessToken,let lineID):
            params["lineId"] = lineID
            params["accessToken"] = accessToken
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .unBindWechat,
             .unBindGoogle,
             .unBindFacebook,
             .unBindApple,
             .unBindLine:
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .tokenSendCaptcha(let type):
            /*//获取手机验证码(默认用户手机号)
             type:业务类型（201 重置交易密码短信 202 更换手机号 203 设置登录密码）
             token-send-phone-captcha/v1  */
            params["type"] = NSNumber(integerLiteral: type)
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .verifyChangePhone(let captcha, let pwd):
            /*校验更换手机号验证码
             verify-replace-phone/v1 */
            params["captcha"] = captcha
            params["password"] = pwd
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .changePhone(let captcha, let phone, let areaCode):
            /*更换手机号
             replace-phone/v1 */
            params["captcha"] = captcha
            params["phoneNumber"] = phone
            params["areaCode"] = areaCode
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .changeEmail(let email, let pwd):
            /*更换邮箱
             replace-email/v1 */
            params["password"] = pwd
            params["email"] = email
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .modifyUserConfig(let type, let value):
            switch type {
            case .languageHk:
                params["languageHk"] = NSNumber(integerLiteral: value)
            case .lineColorHk:
                params["lineColorHk"] = NSNumber(integerLiteral: value)
            case .quoteChartHk:
                params["quoteChartHk"] = NSNumber(integerLiteral: value)
            case .sortHk:
                params["sortHk"] = NSNumber(integerLiteral: value)
            case .languageCn:
                params["languageCn"] = NSNumber(integerLiteral: value)
            default: //none
                print("none")
            }
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        /*废弃，没有使用*/
        case .modifyUserConfigAllHK(let languageHK, let lineColorHK, let quoteChartHK, let sortHk):
            params["languageHk"] = languageHK
            params["lineColorHk"] = lineColorHK
            params["quoteChartHk"] = quoteChartHK
            params["sortHk"] = sortHk
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        
        /* 优惠信息设定 */
        case .modifyUserConfigPromot(let phone, let sms, let email, let mail):
            params["languageHk"] = YXUserManager.curLanguage().rawValue
            params["phoneSet"] = phone ? 1 : 0
            params["smsSet"] = sms ? 1 : 0
            params["emailSet"] = email ? 1 : 0
            params["mailSet"] = mail ? 1 : 0
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        /*获取当前用户信息
         get-current-user/v1 */
        case .getCurrentUser:
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
            
        case .feedback(let content, let areaCode, let phoneNumber, let email, let filePath):
            params["content"] = content
            params["phoneNumber"] = phoneNumber
            params["filePath"] = filePath
            params["areaCode"] = areaCode
            params["email"] = email
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .checkTradePwd(let password):
            /*校验交易密码
             check-trade-password/v1 */
            params["password"] = password
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .idType:
            /*获取客户开户证件类型
             1.大陆身份证;2.香港身份证;3.护照;4.香港永久居民身份证
             get-customer-identify-type/v1 */
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .checkId(let identifyId):
            /* 校验身份证
             verify-identify-id/v1 */
            params["identifyId"] = identifyId
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .changeTradePwd(let oldPassword, let password):
            /*修改交易密码
             update-trade-password/v1 */
            params["oldPassword"] = oldPassword
            params["password"] = password
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .checkCaptcha(let captcha, let type):
            /* 校验手机验证码是否正确
             type: 业务类型（201重置交易密码短信验证202更换手机号短信验证）
             check-phone-captcha/v1 */
            params["captcha"] = captcha
            params["type"] = type
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .resetTradePwd (let password, let captcha):
            /*重置交易密码 captchaType 2- 邮箱 1手机
             reset-trade-password/v1 */
            params["captcha"] = captcha
            params["password"] = password
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .setTradePwd (let password,_):
            params["password"] = password
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .tradePwdLogin(let password):
            params["password"] = password
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .getTradePasswordToken(let password):
            params["password"] = password
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .bindPhone(let areaCode, let captcha, let password, let phoneNumber):
            /*第一次绑定手机号
             GET请求
             api/bind-phone/v1  */
            params["areaCode"] = areaCode
            params["captcha"] = captcha
            params["password"] = password
            params["phoneNumber"] = phoneNumber
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .setLoginPwd(let captcha, let password):
            /* 设置登陆密码 post
             set-login-password/v1  */
            params["phoneCaptcha"] = captcha
            params["password"] = password
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .setFirstLoginPwd(let password):
            params["password"] = password
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .updateUserInfo(let avatar, let nickname):
            /*更新用户基本信息 put
             update-base-user-info/v1 */
            if !(avatar?.isEmpty ?? true) {//avatar?.count ?? 0 > 0
                params["avatar"] = avatar
            }
            if !(nickname?.isEmpty ?? true) {//nickname?.count ?? 0 > 0
                params["nickname"] = nickname
            }
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .tradeLogout:
            return .requestParameters(parameters: [:], encoding: URLEncoding.default)
        //用户同意暗盘风披 hidden-risk-autograph/v1
        case .hiddenRiskAuthgraph:
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case let .verifySignature(agreementName: agreementName, agreementUrl: agreementUrl, autograph: autograph, riskTips: riskTips, stockId: stockId, stockName: stockName):
            params["agreementName"] = agreementName
            params["agreementUrl"] = agreementUrl
            params["autograph"] = autograph
            params["riskTips"] = riskTips
            params["stockId"] = stockId
            params["stockName"] = stockName
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .queryCopyWriting:
            /*http://szshowdoc.youxin.com/web/#/23?page_id=791 -> news-configserver
            -> 文案管理V2(香港+大陆) -> v2/query/copywriting  */
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .unBindWechatPushSingal:
            params["type"] = 4
            params["list"] = [["status" : 0, "identifier" : ""]]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .verifyChangeEmail(let email, let captcha, let pwd):
            params["captcha"] = captcha
            params["email"] = email
            params["password"] = pwd
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .bindEmail(let email, let captcha, let pwd):
            params["captcha"] = captcha
            params["email"] = email
            params["password"] = pwd
            params["type"] = 10004
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
//        case .tokenSendEmailCaptcha(let type):
//            /*//获取邮箱验证码(默认用户邮箱)
//             type:业务类型（业务类型（1. 重置交易密码））
//              */
//            params["type"] = NSNumber(integerLiteral: type.rawValue)
//            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .checkEmailCaptcha(let captcha, let type, let email):
            params["captcha"] = captcha
            params["type"] = NSNumber(integerLiteral: type.rawValue)
            params["email"] = email
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .registerCheckEmailCaptcha(let captcha, let type, let email):
            params["captcha"] = captcha
            params["type"] = NSNumber(integerLiteral: type.rawValue)
            params["email"] = email
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .getIBAccountInfo(let captch):
            params["captcha"] = captch
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .sendEmailInputCaptcha(let email,let type):
            params["email"] = email
            params["type"] = NSNumber(integerLiteral: type.rawValue)
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    public var baseURL: URL {
        switch self {
        case .queryCopyWriting, .unBindWechatPushSingal:
            return URL(string: YXUrlRouterConstant.hzBaseUrl())!
        default:
            return URL(string: YXUrlRouterConstant.jyBaseUrl())!
        }
    }
    
    public var requestType: YXRequestType {
        switch self {
        case .queryCopyWriting, .unBindWechatPushSingal:
            return .hzRequest
        default:
            return .jyRequest
        }
    }
    
    public var servicePath: String {
        switch self {
        case .bindFacebook,
             .bindGoogle,
             .unBindGoogle,
             .unBindFacebook:
            return "user-oversea-server-dolphin/api/"
        case .queryCopyWriting:
            return "/news-configserver/api/v2/"
        case .unBindWechatPushSingal:
            return "/quotes-smart/api/v2/"
        case .changeTradePwd,
             .resetTradePwd,
             .setTradePwd,
             .checkTradePwd,
             .checkId,
             .tradePwdLogin,
             .idType,
             .getTradePasswordToken,
             .getTradeLoginStatus,
             .tradeLogout,
             .getIsSetTradePwd,
             .checkOpenAccount,
             .getIBAccountInfo:
//             .tokenSendEmailCaptcha:
            return "/user-account-server-dolphin/api/"
        case
            .sendEmailInputCaptcha,
            .setFirstLoginPwd:
            return "/user-server-sg/api/"
        default:
            return "/user-server-dolphin/api/"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .checkTradePwd,
             .idType,
             .checkId,
             .checkCaptcha,
             .tokenSendCaptcha,
             .getTradeLoginStatus,
             .getTradePasswordToken,
             .tradeLogout,
             .bindPhone,
             .getCurrentUser,
             .queryCopyWriting,
//             .tokenSendEmailCaptcha,
             .checkEmailCaptcha,
             .registerCheckEmailCaptcha,
             .getIsSetTradePwd,
             .checkOpenAccount:
            return .get
        case .changePhone,
             .verifyChangePhone,
             .changeTradePwd,
             .resetTradePwd,
             .changeEmail,
             .updateUserInfo,
             .verifyChangeEmail:
            return .put
        case .unBindWechat,
             .unBindGoogle,
             .unBindFacebook,
             .unBindApple,
             .unBindLine:
            return .delete
        default:
            return .post
        }
    }
    
    public var headers: [String : String]? {
        var headers = yx_headers
        if let contentType = contentType {
            headers["Content-Type"] = contentType
        }
        
        if let brokerNo = xBrokerNo {
            headers["X-BrokerNo"] = brokerNo
        }
        
        return headers
    }
    
    public var contentType: String? {
        switch self {
        case .unBindWechat,
             .unBindGoogle,
             .unBindFacebook,
             .unBindApple,
             .unBindLine,
             .tokenSendCaptcha,
             .changeEmail,
             .idType,
             .checkId,
             .checkCaptcha,
             .checkTradePwd,
             .getTradeLoginStatus,
             .getTradePasswordToken,
             .tradeLogout,
             .bindPhone,
             .getCurrentUser,
             .getIsSetTradePwd,
//             .tokenSendEmailCaptcha,
             .checkOpenAccount,
             .checkEmailCaptcha,
             .registerCheckEmailCaptcha:
            return "application/x-www-form-urlencoded"
        case .modifyUserConfigPromot,
             .tradePwdLogin:
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

    public var xBrokerNo: String? {
        switch self {
        case .setTradePwd(_, let brokerNo):
            return brokerNo
        default:
            return nil
        }
    }
}
