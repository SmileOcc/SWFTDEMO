//
//  YXUserPurchasedResModel.swift
//  uSmartEducation
//
//  Created by usmart on 2021/11/18.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation

class YXUserPurchasedResModel: YXModel {
    /// 是否作者
    @objc var isAuthor: Bool = false
    ///是否免费课
    @objc var isFreeCourse: Bool = false
    ///是否购买
    @objc var isPurchased: Bool = false
    /// 是否游客
    @objc var isVisitor: Bool = false
}

