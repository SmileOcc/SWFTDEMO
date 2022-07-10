//
//  HDWebServiceAddressManager.swift
//  HDNetWorkProject
//
//  Created by 航电 on 2020/7/27.
//  Copyright © 2020 航电. All rights reserved.
//

import UIKit

public class HDWebServiceAddressManager: NSObject {
    public static let sharedInstance = HDWebServiceAddressManager.init();
    

    //本地环境
//    public let testingLoginEnvironmentURL:String = "http://192.168.0.243:6388";//用户相关
//    public let testingLouyuEnvironmentURL:String = "http://192.168.0.243:6399";//楼宇
//    public let testingSuperAppEnvironmentURL:String = "http://192.168.0.243:7004";//设备相关
    
//    //线上环境
    public let testingLoginEnvironmentURL:String = "http://120.79.162.38:6388";//用户相关
    public let testingLouyuEnvironmentURL:String = "http://120.79.162.38:6399";//楼宇
//    public let testingSuperAppEnvironmentURL:String = "http://39.108.179.76:7004";//设备相关

    
    //线上环境
//    public let testingEnvironmentURL:String = "http://120.79.162.38:6388";
    
    override init() {
        super.init();
    }
}
