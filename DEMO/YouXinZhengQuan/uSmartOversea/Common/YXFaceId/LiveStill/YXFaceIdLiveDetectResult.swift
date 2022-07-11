//
//  YXFaceIdLiveDetectResult.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/1/2.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import MGFaceIDLiveDetect

class YXFaceIdLiveDetectResult: NSObject {
#if targetEnvironment(simulator)
#else
    @objc var error: MGFaceIDLiveDetectError?
#endif
    @objc var deltaData: Data?
    
    @objc var bizTokenStr: String?
    
    @objc var extraOutDataDict: Dictionary<AnyHashable, Any>?
}
