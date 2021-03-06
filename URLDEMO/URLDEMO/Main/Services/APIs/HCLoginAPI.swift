//
//  HCLoginAPI.swift
//  URLDEMO
//
//  Created by odd on 7/3/22.
//

import Foundation
import Moya

let loginProvider = MoyaProvider<HCLoginAPI>(requestClosure: requestTimeoutClosure, session : HCMoyaConfig.session(), plugins: [HCNetworkLoggerPlugin(verbose: true)])

//type 验证码类型
public enum HCSendCaptchaType:Int {
    case type101 = 101  //101注册
    case type102 = 102  //102重置密码
    case type103 = 103  //103更换手机号
    case type104 = 104  //104绑定手机号
    case type105 = 105  //105新设备登录校验
    case type106 = 106  //106短信登录
    case type10001 = 10001 //10001邮箱注册
    case type1     = 1     //1邮箱重交易密码
    case type2     = 2    //2邮箱重置登录交易
}

public enum HCLoginAPI {
    /*验证手机号是否注册
     check-phone/v1 */
    case checkPhone(_ areaCode: String, _ phoneNumber: String)
    /*获取手机验证码(用户输入手机号)
     type 验证码类型 101注册 102重置密码 103更换手机号 104绑定手机号 105新设备登录校验 106短信登录
     send-phone-captcha/v1 */
    case sendUserInputCaptcha(_ areaCode: String, _ phoneNumber: String, _ type: HCSendCaptchaType)
    case testRequest(_ is_debug: String)
    
}


extension HCLoginAPI: HCTargetType {
    
    public var path: String {
        switch self {
            /*验证手机号是否注册
             check-phone/v1 */
        case .checkPhone:
            return servicePath + "check-phone/v1"
            
        case .sendUserInputCaptcha:
            return servicePath + "send-phone-captcha/v1"
        case .testRequest:
            return "/v1_20/banner/list"
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
            
        case .sendUserInputCaptcha(let areaCode, let phoneNumber, let type):
            /*获取手机验证码(用户输入手机号)
             send-phone-captcha/v1 */
            params["areaCode"] = areaCode
            params["phoneNumber"] = phoneNumber
            params["type"] = NSNumber(integerLiteral: type.rawValue)
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .testRequest(let is_debug):
           /**
            参数:{
                adgroup = "";
                "channel_id" = 1;
                commparam = "ver=2.0.0";
                currency = USD;
                "is_debug" = true;
                lang = en;
                page = 1;
                "page_size" = 20;
                sex = 1;
            }
            */
        
            params["is_debug"] = "true"
            params["adgroup"] = ""
            params["channel_id"] = "1"
            params["commparam"] = "ver=2.0.0"
            params["currency"] = "USD"
            params["lang"] = "en"
            params["page"] = "1"
            params["page_size"] = "20"
            params["sex"] = "1"

//            var headers: [String: String] = ["Accept-Language":"en;q=1","User-Agent":"Vivaia/2.0.0 (iPhone; iOS 15.2; Scale/3.00)","onesite":"true","adw-pf":"ios","adw-deviceid":HCConstant.deviceUUID]

//            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)

        default:
            return .requestPlain
        }
    }
    
    public var baseURL: URL {
        URL(string: HCUrlRouterConstant.zxBaseUrl())!
    }
    
    public var requestType: HCRequestType {
        return .hzRequest
    }
    
    public var servicePath: String {
        "/user-server/api/"
    }
    
    public var method: Moya.Method {
        switch self {
        case .checkPhone:
            return .get
        default:
            return .post
        }
    }
    
    public var headers: [String : String]? {
        switch self {
        case .checkPhone:
            var header = hc_headers
            //header["Authorization"] = HCUserManager.shared().deprecatedToken
            return header
        default:
            return hc_headers
        }
    }
    
    public var contentType: String? {
        switch self {
        case .checkPhone :
            return "application/x-www-form-urlencoded"
        case .sendUserInputCaptcha, .testRequest:
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
