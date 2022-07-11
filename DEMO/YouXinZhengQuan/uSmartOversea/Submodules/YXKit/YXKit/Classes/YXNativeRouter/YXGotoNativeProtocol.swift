//
//  YXGotoNativeJSActionHandler.swift
//  YouXinZhengQuan
//
//  Created by 胡华翔 on 2018/11/20.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import Foundation

@objc public protocol YXGotoNativeProtocol: AnyObject {
    @objc func gotoNativeViewController(withUrlString urlString : String) -> Bool
}
