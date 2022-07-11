//
//  YXDebugJSEntranceModel.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/1/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YYModel

class YXDebugJSEntranceModel: NSObject, NSCoding {
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        self.yy_modelInit(with: aDecoder)
    }
    
    @objc var date: String?
    @objc var name: String?
    @objc var url: String?
    @objc var showCloseBtn: Bool = false
    
    func encode(with aCoder: NSCoder) {
        self.yy_modelEncode(with: aCoder)
    }
    
    class func getSavePath() -> String{
        let docPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as NSString
        let path = (docPath as String) + "/entranceList.plist"
        return path
    }
    
    class func saveEntranceModel(entranceArray: [YXDebugJSEntranceModel]) {
        let path = getSavePath()
        NSKeyedArchiver.archiveRootObject(entranceArray, toFile: path)
    }
    
    class func entrancesModelFromDisk() -> [YXDebugJSEntranceModel]? {
        let entranceArray = NSKeyedUnarchiver.unarchiveObject(withFile: getSavePath())
        return entranceArray as? [YXDebugJSEntranceModel]
    }
}
