//
//  HDPushManager.swift
//  HDBaseProject
//
//  Created by 航电 on 2020/6/18.
//  Copyright © 2020 航电. All rights reserved.
//

import UIKit


public class HDPushManager: NSObject {
    
    public static let sharedInstance:HDPushManager = {
        let manager = HDPushManager();
        
        return manager;
    }();
    
    public func pushWithInfo(dataInfo:[AnyHashable:Any]) {
        let aps:[AnyHashable:Any] = dataInfo["aps"] as! [AnyHashable : Any];
        let alert:[AnyHashable:Any] = aps["alert"] as! [AnyHashable : Any];
        let title:String = alert["title"] as! String ;
        if title.count > 0 {
            //UIApplication.shared.keyWindow?.rootViewController?.present(HDViewControllerOne(), animated: true, completion: nil);
        }
    }
}
