//
//  HDWebserviseManager.swift
//  HDNetWorkProject
//
//  Created by 航电 on 2020/6/15.
//  Copyright © 2020 航电. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

typealias onSuccess = () -> [String:Any];
typealias onFailure = () -> String;

public enum WebserviseStatus:Int {
    case notReachable = 0
    case unknown
    case ethernetOrWiFi
    case wwan
}

public class HDWebserviseManager: NSObject {
    
    var baseUrl = String()
    var urlArray = [String]()
    
    //MARK: 单例
    public static let sharedInstance:HDWebserviseManager = {
        let webserviceManager = HDWebserviseManager();
        webserviceManager.onListenNetWork { (status) in
            print("当前网络状态:\(status)");
        }
        return webserviceManager;
    }();
    
    //MARK: 网络状态
    public var netWorkStatus:WebserviseStatus = .notReachable;
    
    //TODO: 测试
    public func onTextGetRequest() {
        var parameters:[String:Any] = ["mobile":"ios","isRight":"no"];
        var headers:[String:String] = ["":""];   
//        self.onGetRequest(url: "http://www.pai-fms.com/app/domain/domainList", parameters: parameters);
        
        //派巡登录 Get请求
//        parameters = ["mobile":"ios","KEYDATA":"15220120452,abc123"];
//        headers = ["":""];
//        self.onRequestForGet(url: "http://www.pai-fms.com/applogin/login_login", parameters: parameters, headers: headers, success: { (dataDic) in
//            print("11");
//        }) { (errorName) in
//            print("22");
//        }
        
        //派巡获取人员管理 Get请求
//        parameters = ["mobile":"ios","pageNo":"1","userQuery":"","pageSize":"10","userNo":"6445"];
//        headers = ["Cookie":"JSESSIONID=49B377578AD8B5E6E4516EE2B1271141"];
//        self.onRequestForGet(url: "http://192.168.0.47/appUser/listPage", parameters: parameters, headers: headers, success: { (dataDic) in
//            print("11");
//        }) { (errorName) in
//            print("22");
//        }
        
        //派巡 设备年检 首页列表 GET/POST
//        parameters = ["dateTime":"20200616145049","pageNumber":"1","pageSize":"10","queryType":"1","sign":"0e73edbc4dba53855ee43b8d3dafdce6","userId":"1815"];
//        headers = ["":""];
//        self.onRequestForPost(url: "http://119.23.142.45:9066/device/getYearlyInspectionByUser", parameters: parameters, headers: headers, success: { (dataDic) in
//            print("11");
//        }) { (errorName) in
//            print("22");
//        }
        
//        //派巡 人员管理 新增用户 POST
//        parameters = ["deptNo":"35","newPasswd":"123456789","phone":"18820235843","skillLevelList":[["skillId":"372","skillLevelId":"208"],["skillId":"483","skillLevelId":"207"]]];
//        headers = ["Cookie":"00B7C0437FAB241A71BD17E4BF281F12"];
//        self.onRequestForPost(url: "http://120.76.97.63:8018/appUser/add?mobile=ios&Cookie=00B7C0437FAB241A71BD17E4BF281F12", parameters: parameters, headers: headers, success: { (dataDic) in
//            print("11");
//        }) { (errorName) in
//            print("22");
//        }
        
        //派巡 头像上传
//        let img = UIImage(named: Bundle.main.path(forResource: "/Frameworks/HDNetWorkProject.framework/device_iphone", ofType: "png") ?? "");
//        let imgArr = [img];
//        parameters = ["userno":"1815","pictures":imgArr];
//        headers = ["content-type":"multipart/form-data","Cookie":"6C4C9A3E4875E86F2822FB7583B4BA58"];
//        self.onRequestForUpdate(url: "http://120.76.97.63:8018/appperson/updateUserHeadPicture?mobile=ios&Cookie=6C4C9A3E4875E86F2822FB7583B4BA58", parameters: parameters, headers: headers, success: { (dataDic) in
//            print("11");
//        }) { (error) in
//            print("22");
//        }
        
        //下载
//        self.onRequestForDownLoad(url: "http://dldir1.qq.com/qqfile/QQforMac/QQ_V4.2.4.dmg", parameters: [:], headers: [:], success: { (dataDic) in
//            print("11");
//        }) { (error) in
//            print("22");
//        }
        
        //监听
//        self.onListenNetWork { (status) in
//            print("当前网络状态:\(status)");
//        }
    }
    
    //MARK: 网络监听
    public func onListenNetWork(netWorkStatus:@escaping(_ webserviseStatus:WebserviseStatus) -> Void ) {
        let reachabilityManager = NetworkReachabilityManager(host: "www.baidu.com");
        reachabilityManager?.startListening();
        reachabilityManager?.listener = { [weak self] reachabilityStatus in
            guard let weakSelf = self else {
                return;
            };
            if reachabilityManager?.isReachable ?? false  {
                switch reachabilityStatus {
                case .notReachable:
                    weakSelf.netWorkStatus = .notReachable;
                    break;
                case .unknown:
                    weakSelf.netWorkStatus = .unknown;
                    break;
                case .reachable(.wwan):
                    weakSelf.netWorkStatus = .wwan;
                    break;
                case .reachable(.ethernetOrWiFi):
                    weakSelf.netWorkStatus = .ethernetOrWiFi;
                    break;
                    
                }
            } else {
                weakSelf.netWorkStatus = .notReachable;
            }
            
            netWorkStatus(weakSelf.netWorkStatus);
        };
    }
    
    //MARK: 网络选择
    public func loadWebUrl() {
        let parameters = ["" : ""]
        let headers = ["" : ""]

        self.urlArray.append(HDWebServiceAddressManager.sharedInstance.testingLoginEnvironmentURL)
        self.urlArray.append(HDWebServiceAddressManager.sharedInstance.testingLouyuEnvironmentURL)
//        self.urlArray.append(HDWebServiceAddressManager.sharedInstance.testingSuperAppEnvironmentURL)
    }
    
    public func selectWebUrl(index: Int) {
        self.baseUrl = self.urlArray[index]
    }
    
    //MARK: Get请求
    public func onRequestForGet(url:String, parameters:[String:Any], success:@escaping(_ response:[String:AnyObject])  ->(), failure:@escaping(_ errorMsg:String) ->()) {
        let user = HDUserManager.sharedInstance
        let token = user.token
        var headers = ["" : ""]
        if token != nil && token != "<null>" {
            headers = ["JSESSION" : user.token!]
        }
        Alamofire.request(self.baseUrl + url, method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: headers).responseJSON { (response) in
            
            switch response.result {
            case .success:
                if let jsonDic = response.result.value as? [AnyHashable: Any] {
                    success(jsonDic as! [String : AnyObject])
                }
            case .failure(let error):
                failure(error.localizedDescription);
            }
        }
    }
    
    //MARK: Post请求
    public func onRequestForPost(url:String, parameters:[String:Any], success:@escaping(_ response:[String:AnyObject])  ->(), failure:@escaping(_ errorMsg:String) ->()) {

        let user = HDUserManager.sharedInstance
        let token = user.token
        var headers = ["" : ""]
        if token != nil && token != "<null>" {
            headers = ["JSESSION" : user.token!]
        }
        
        if url.contains("/user/") ||
        url.hasPrefix("/organization/") {
            //用户相关接口(登录、登出、个人信息)和组织项目相关接口
            self.selectWebUrl(index: 0);
        } else {
            self.selectWebUrl(index: 1);
        }

        Alamofire.request(self.baseUrl + url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            
            switch response.result {
            case .success:
                if let jsonDic = response.result.value as? [AnyHashable: Any] {
                    success(jsonDic as! [String : AnyObject])
                }
            case .failure(let error):
                failure(error.localizedDescription);
            }
        }
    }
    
    //MARK: Update请求 上传图片、文件等资源
    public func onRequestForUpdate(url:String, parameters:[String:Any], headers:[String:String], success:@escaping(_ response:[String:AnyObject])  ->(), failure:@escaping(_ errorMsg:String) ->()) {
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            if (parameters.keys.contains("pictures")) {
                var userId = "2020";
                if parameters.keys.contains("userId") {
                    userId = String(parameters["userId"] as! Int)
                }
                
                //上传参数
//                let userno = parameters["userno"] as! String;
//                multipartFormData.append(userno.data(using: String.Encoding.utf8)!, withName: "userno");
                
                let picture:Array = parameters["pictures"] as! [UIImage];
                for i in 0 ..< picture.count {
                    var img:UIImage = picture[i];

                    let fileName:String = userId+"-"+"\(Int(NSDate().timeIntervalSince1970))"+"-"+"\(i)"+".jpg";
                    
                    var maxcont = 10;
                    let limit = 50;
                    var imgData:Data = img.jpegData(compressionQuality: 1)!;
                    repeat {
                        imgData = (img.jpegData(compressionQuality: 0.1) as Data?)!;
                        guard Int(imgData.count/1024) > limit else {
                            break;
                        }
                        img = img.imageWithNewSize(size: CGSize(width: img.size.width*2/3, height: img.size.height*2/3)) ?? img;
                        maxcont -= 1;
                        
                    } while maxcont > 0;
                    
                    guard imgData.count > 0 else {
                        return;
                    }
                    multipartFormData.append(imgData, withName: "file", fileName: fileName, mimeType: "image/jpeg");
                }
            }
            
        }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold,
           to: self.baseUrl + url,
           method: .post,
           headers: headers) { (result) in
            
            switch result {
            case .success(let updateData, _, _):
                
                updateData.responseJSON { (response) in
                    if let jsonDic = response.result.value as? [AnyHashable: Any] {
                        success(jsonDic as! [String : AnyObject])
                    } else {
                        failure("上传失败!");
                    }
                }
                
            case .failure(let error):
                failure(error.localizedDescription);
            }
        }
    }
    
    //MARK: DowmLoad请求 下载文件
    public func onRequestForDownLoad(url:String, parameters:[String:Any], headers:[String:String], success:@escaping(_ response:[String:AnyObject])  ->(), failure:@escaping(_ errorMsg:String) ->()) {
        
        Alamofire.download(self.baseUrl + url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers) { (filePath, response) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
            
            let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let urlPathComponet = response.url?.absoluteString.components(separatedBy: "/").last;
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(urlPathComponet!);
            print(destinationUrl)
            
            return (destinationUrl,[.removePreviousFile,.createIntermediateDirectories]);
        }
        .downloadProgress(queue: DispatchQueue.global()) { (progress) in
            print("进度:\(progress)");
        }
        .responseData { (downData) in
            if downData.result.value != nil {
                
                success(["path":downData.destinationURL?.absoluteString as AnyObject]);
            } else {
                failure("下载失败");
            }
        }
    }
    
    //MARK: 数据埋点
    public func dataEmbeddingPoint(parameters: NSDictionary) {
        let headers = ["" : ""]
        self.onRequestForPost(url: "/app-superapp/buried/points/create", parameters: parameters as! [String : Any], success: { (dataDic) in
            let code = dataDic["code"] as! Int
            if code != -1 {
                
            }
        }) { (errorName) in
            
        }
    }
}

extension HDWebserviseManager {
    //添加具体页面请求
    
}

extension UIImage {
    //图片压缩-图片重绘制
    public func imageWithNewSize(size: CGSize) -> UIImage? {
    
        if self.size.height > size.height {
            
            let width = size.height / self.size.height * self.size.width
            
            let newImgSize = CGSize(width: width, height: size.height)
            
            UIGraphicsBeginImageContext(newImgSize)
            
            self.draw(in: CGRect(x: 0, y: 0, width: newImgSize.width, height: newImgSize.height))
            
            let theImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            guard let newImg = theImage else { return  nil}
            
            return newImg
            
        } else {
            
            let newImgSize = CGSize(width: size.width, height: size.height)
            
            UIGraphicsBeginImageContext(newImgSize)
            
            self.draw(in: CGRect(x: 0, y: 0, width: newImgSize.width, height: newImgSize.height))
            
            let theImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            guard let newImg = theImage else { return  nil}
            
            return newImg
        }
    
    }
}
