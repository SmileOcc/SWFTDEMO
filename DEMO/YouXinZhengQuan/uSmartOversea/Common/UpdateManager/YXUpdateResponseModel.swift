//
//  YXUpdateResponseModel.swift
//  uSmartOversea
//
//  Created by ellison on 2019/2/23.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXUpdateResponseModel: YXResponseModel {
    @objc var update: Bool = false
    @objc var filePath: String = ""
    @objc var versionNo: String = ""
    @objc var updateMode: Int32 = 0
    @objc var times: Int32 = 0
    @objc var systemTime: Int64 = 0
    @objc var seconds: Int32 = 0
    @objc var title: String = ""
    @objc var content: String = ""
    @objc var md5: String = ""
    @objc var fileUrl: String = ""
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        return ["update": "data.update",
                "filePath": "data.filePath",
                "versionNo": "data.versionNo",
                "updateMode": "data.updateMode",
                "times": "data.times",
                "systemTime": "data.systemTime",
                "seconds": "data.seconds",
                "title": "data.title",
                "content": "data.content",
                "md5": "data.md5",
                "fileUrl": "data.fileUrl"];
    }
}
