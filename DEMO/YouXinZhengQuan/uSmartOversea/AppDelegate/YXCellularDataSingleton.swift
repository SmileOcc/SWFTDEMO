//
//  YXCellularDataSingleton.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/7/12.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import CoreTelephony

class YXCellularDataSingleton : NSObject {
    
    @objc static let shared = YXCellularDataSingleton()
    
    let cellularData = CTCellularData()
    
    public static let CELLULAR_DATA_RESTRICTION_DID_UPDATE_NOTIFIER = Notification.Name(rawValue: "cellularDataRestrictionDidUpdateNotifier")
    
    
    private override init() {
        cellularData.cellularDataRestrictionDidUpdateNotifier = { (state) in
            log(.verbose, tag: kOther, content: "cellularDataRestrictionDidUpdateNotifier \(state.rawValue)")
            NotificationCenter.default.post(name: YXCellularDataSingleton.CELLULAR_DATA_RESTRICTION_DID_UPDATE_NOTIFIER, object: state, userInfo: nil)
        }
    }
    
    override func copy() -> Any {
        self
    }
    
    override func mutableCopy() -> Any {
        self
    }
    
    // Optional
    func reset() -> Void {
        // Reset all properties to default value
    }
}
