//
//  YXLoginAPI.swift
//  uSmartOversea
//
//  Created by mac on 2019/3/26.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import Moya

let loginProvider = MoyaProvider<YXLoginAPI>(requestClosure: requestTimeoutClosure, session : YXMoyaConfig.session(), plugins: [YXNetworkLoggerPlugin(verbose: true)])

//type 验证码类型
public enum YXSendCaptchaType:Int {
    case type101 = 101  //101注册
    case type102 = 102  //102重置密码
    case type103 = 103  //103更换手机号
    case type104 = 104  //104绑定手机号
    case type105 = 105  //105新设备登录校验
    case type106 = 106  //106短信登录
    case type10001 = 10001 //10001邮箱注册
    case type1     = 1     //1邮箱重交易密码
    case type2     = 2    //2邮箱重置登录交易
    case type10004   = 10004  //10004 第三方登录发送邮箱验证码 绑定
    case type10005   = 10005 //10005 修改邮箱
    case type20001   = 20001 //20001 获取IB账户信息
}

public enum YXLoginAPI {
    /*验证手机号是否注册
     check-phone/v1 */
    case checkPhone(_ areaCode: String, _ phoneNumber: String)
    /*获取手机验证码(用户输入手机号)
     type 验证码类型 101注册 102重置密码 103更换手机号 104绑定手机号 105新设备登录校验 106短信登录
     send-phone-captcha/v1 */
    case sendUserInputCaptcha(_ areaCode: String, _ phoneNumber: String, _ type: YXSendCaptchaType)
    /*校验手机验证码是否正确（用户输入手机号）
     type 业务类型（101用户注册102重置密码）
     check-captcha-with-phone/v1 */
    case checkUserInputCaptcha (_ areaCode: String, _ phoneNumber: String, _ captcha: String, _ type: NSInteger)
    
    case guests
    case refreshToken
    case loginOut
    case checkOrgAccount(_ areaCode: String, _ phoneNumber: String, _ type: Int,  _ email: String)
    
    case sendEmailInputCaptcha(_ email: String, _ type: YXSendCaptchaType)
    
    case orgResetPwd (_ areaCode: String, _ phoneNumber: String, _ email: String, _ captcha: String, _ password: String, _ verifyLoginType: String)
    /*海外版1.0.0新增 通过邮箱重置登陆密码
     reset-login-password-by-email/v1 */
    case emailResetPwd(_ email:String, _ emailCaptcha:String,_ password:String)
    /*通过手机号重新设置登录密码
     reset-login-password/v1 */
    case resetPwd (_ areaCode: String, _ phoneNumber: String, _ captcha: String, _ password: String)
    /*校验org的注册机构码*/
    case checkOrgRegistNumber (_ registNumber: String)
    
    /*验证账号是否注册 邮箱不需要传code*/
    case checkAccountRegistNumber (_ registNumber: String, _ areaCode: String)
    
    
}

extension YXLoginAPI: YXTargetType {
    
    public var path: String {
        switch self {
            /*验证手机号是否注册
             check-phone/v1 */
        case .checkPhone:
            return servicePath + "check-phone/v1"
            /*校验手机验证码是否正确（用户输入手机号）
             type 业务类型（101用户注册102重置密码）
             check-captcha-with-phone/v1 */
        case .checkUserInputCaptcha:
            return servicePath + "check-captcha-with-phone/v1"
            /*获取手机验证码(用户输入手机号)
             send-phone-captcha/v1 */
        case .sendUserInputCaptcha:
            return servicePath + "send-phone-captcha/v1"
        case .resetPwd:
            return servicePath + "reset-login-password/v1"
        case .guests:
            return servicePath + "guests/v1"
        case .refreshToken:
            return servicePath + "tokens/v1"
        case .loginOut:
            return servicePath + "logout/v1"
        case .checkOrgAccount:
            return servicePath + "org-user-verify-login/v1"
        case .sendEmailInputCaptcha:
            return servicePath + "send-email-captcha/v1"
        case .orgResetPwd:
            return servicePath + "org-user-reset-login-password/v1"
        case .emailResetPwd:
            return servicePath + "reset-login-password-by-email/v1"
        case .checkOrgRegistNumber:
            return "user-account-server-sg/api/" + "verify-org-regist-number/v1"
        case .checkAccountRegistNumber:
            return "user-server-sg/api/" + "check-account/v1"
        }
    }
    
    public var task: Task {
        var params: [String: Any] = [:]
        switch self {
        case .checkPhone(let areaCode, let phoneNumber):
            /*验证手机号是否注册
             check-phone/v1 */
            params["areaCode"] = areaCode
            params["phoneNumber"] = phoneNumber
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
            
        case .checkUserInputCaptcha(let areaCode, let phoneNumber, let captcha, let type):
            /*校验手机验证码是否正确（用户输入手机号）
             type 业务类型（101用户注册102重置密码）
             check-captcha-with-phone/v1 */
            params["areaCode"] = areaCode
            params["phoneNumber"] = phoneNumber
            params["captcha"] = captcha
            params["type"] = NSNumber(integerLiteral: type)
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
            
        case .sendUserInputCaptcha(let areaCode, let phoneNumber, let type):
            /*获取手机验证码(用户输入手机号)
             send-phone-captcha/v1 */
            params["areaCode"] = areaCode
            params["phoneNumber"] = phoneNumber
            params["type"] = NSNumber(integerLiteral: type.rawValue)
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .resetPwd(let areaCode, let phoneNumber, let captcha, let password):
            params["areaCode"] = areaCode
            params["phoneNumber"] = phoneNumber
            params["phoneCaptcha"] = captcha
            params["password"] = password
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .guests:
            params["source"] = "2"
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .loginOut:
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .checkOrgAccount(let areaCode, let phoneNumber, let type, let email):
            // 校验登录的类型；1：手机号码登录；2：邮箱登录
            params["areaCode"] = areaCode
            params["phoneNumber"] = phoneNumber
            params["email"] = email
            params["verifyLoginType"] = NSNumber(integerLiteral: type)
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .sendEmailInputCaptcha(let email, let type):
            params["email"] = email
            params["type"] = NSNumber(integerLiteral: type.rawValue)
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .orgResetPwd(let areaCode, let phoneNumber, let email, let captcha, let password, let verifyLoginType):
            params["areaCode"] = areaCode
            params["phoneNumber"] = phoneNumber
            params["captcha"] = captcha
            params["password"] = password
            params["verifyLoginType"] = verifyLoginType
            params["email"] = email
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .emailResetPwd(let email, let emailCaptcha, let password):
            params["emailCaptchaType"] = NSNumber(integerLiteral: YXSendCaptchaType.type2.rawValue)
            params["email"] = email
            params["emailCaptcha"] = emailCaptcha
            params["password"] = password
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .checkOrgRegistNumber(let registNumber):
            params["registNumber"] = registNumber
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .checkAccountRegistNumber(let registerNumber, let areaCode):
            params["accountNumber"] = registerNumber
            params["areaCode"] = areaCode
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    public var baseURL: URL {
        URL(string: YXUrlRouterConstant.jyBaseUrl())!
    }
    
    public var requestType: YXRequestType {
        return .jyRequest
    }
    
    public var servicePath: String {
        "/user-server-dolphin/api/"
    }
    
    public var method: Moya.Method {
        switch self {
        case .checkPhone,
             .loginOut,
             .checkUserInputCaptcha,
             .checkOrgRegistNumber:
            return .get
        case .resetPwd:
            return .post
        default:
            return .post
        }
    }
    
    public var headers: [String : String]? {
        switch self {
        case .loginOut:
            var header = yx_headers
            header["Authorization"] = YXUserManager.shared().deprecatedToken
            return header
        default:
            return yx_headers
        }
    }
    
    public var contentType: String? {
        switch self {
        case .checkPhone,
             .loginOut,
             .checkUserInputCaptcha,
             .checkOrgRegistNumber:
            return "application/x-www-form-urlencoded"
        case .checkAccountRegistNumber:
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
