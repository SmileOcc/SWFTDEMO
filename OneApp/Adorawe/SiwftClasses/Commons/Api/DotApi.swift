//
//  DotApi.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/8/4.
//  Copyright © 2021 starlink. All rights reserved.
//

import Foundation


/// 打点日志
class DotApi:NSObject{
    
    static func uploadToDot(event:String){
        
        let userId = OSSVAccountsManager.shared().userId()
        let deviceIds = (UIDevice.current.identifierForVendor?.uuidString ?? "").components(separatedBy: "-")
        let deviceToken = deviceIds.joined(separator: "")

        let params = [
            "brand_id":STLWebsitesGroupManager.currentCountrySiteCode().localizedLowercase,
             "brand_platform":"ios",
             "uuid":"\(deviceToken)-\(userId)",
             "version": String.kAppVersion,
             "event":event
         ]
        
        if let req = try? AFHTTPRequestSerializer().request(withMethod: "GET", urlString: OSSVLocaslHosstManager.appDotCloudUrl(), parameters: params){
            let dataTask = URLSession.shared.dataTask(with: req as URLRequest)
            dataTask.resume()
        }
    }
    
    @objc public static func appStart(){
        uploadToDot(event: "AppStart")
    }
    
    @objc public static func webView(){
        uploadToDot(event: "WebView")
    }
    
    @objc public static func signUp(){
        uploadToDot(event: "SignUp")
    }
    
    @objc public static func signIn(){
        uploadToDot(event: "SignIn")
    }
    
    @objc public static func productDetailPage(){
        uploadToDot(event: "ProductDetailPage")
    }
    
    @objc public static func addToCart(){
        uploadToDot(event: "AddToCart")
    }
    
    @objc public static func checkOutPage(){
        uploadToDot(event: "CheckOutPage")
    }
    
    @objc public static func placeOrder(){
        uploadToDot(event: "PlaceOrder")
    }
    
    @objc public static func payOrder(){
        uploadToDot(event: "PayOrder")
    }
    
    
}
