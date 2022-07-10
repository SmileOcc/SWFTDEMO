//
//  HDLocalStorage.swift
//  HDDBStorageProject
//
//  Created by MountainZhu on 2020/6/15.
//  Copyright © 2020 航电. All rights reserved.
//

import UIKit

public class HDLocalStorage: NSObject {
    
    //单例
    public static let sharedInstance: HDLocalStorage = {
        let storageManager = HDLocalStorage();
        return storageManager;
    }();
    
    // userDefault 存储
    public func setObject(object: Any, key: String) {
        UserDefaults.standard.set(object, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    // userDefault 获取
    public func objectForKey(key: String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }
    
    // remove存储
    public func removeObject(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    // 磁盘存储
    public func saveData(dic: NSData) {
        let filePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let library = filePath[0] + "subName"
        var bol = Bool()
        bol = dic.write(toFile: library, atomically: true)
        if bol {
            print("储储成功")
        } else {
            print("储储失败")
        }
    }
    
    // 磁盘读取
    public func readData() -> Any {
        let filePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true);
        let library = filePath[0] + "subName"
        let fileManager = FileManager.default
        let exist = fileManager.fileExists(atPath: library)
        if exist {
            let content = fileManager.contents(atPath: library)
            let dat: Data = (content)!
            let dict = String(data: dat, encoding: String.Encoding.utf8)
            let jsonData = dict?.data(using: String.Encoding.utf8, allowLossyConversion: false) ?? Data()
            guard let json = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) else {
                return (Any).self
            }
            return json
        }
        return (Any).self
    }

}
