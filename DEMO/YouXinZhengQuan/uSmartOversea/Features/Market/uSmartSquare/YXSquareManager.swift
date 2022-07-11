//
//  YXSquareManager.swift
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/5/6.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

@objc enum SquareSectionIndex: Int {
    case entrance
    case hotDiscussion
}

extension SquareSectionIndex {
    
    static var allValue: [SquareSectionIndex] {
        
        return [.entrance, .hotDiscussion]
    }
}


class YXSquareManager: NSObject {

    @objc static func getDefaultArr() -> ([Any]) {
        
        var indexArr = [Any]()
        for i in SquareSectionIndex.allValue {            
            switch i {
            case .entrance:
                indexArr.append(NSNumber.init(value: 0))
            case .hotDiscussion:
                indexArr.append(NSObject.init())
            default:
                break
            }
        }
        
        return indexArr
        
    }
    static func getTopService() -> NavigatorServices? {
        
        guard let appdelegate = UIApplication.shared.delegate as? YXAppDelegate else { return nil }        
        return appdelegate.navigator
    }

}


