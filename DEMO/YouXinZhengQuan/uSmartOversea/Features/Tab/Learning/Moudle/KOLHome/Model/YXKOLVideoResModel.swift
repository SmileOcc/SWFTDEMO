//
//  YXKOLVideoResModel.swift
//  uSmartEducation
//
//  Created by usmart on 2022/2/18.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import Foundation

class YXKOLVideoResModel: YXModel {
    @objc var videoIdStr : String? //关联课程Id
    @objc var videoUrl : String? //关联课时Id
    @objc var videoTitle : String? //关联类型 0-无 1-课程 2-课时
    @objc var videoDesc : String? //短发布者ID
    @objc var nickName : String? //上架地区 1：大陆，2：香港，3：新加坡
    @objc var releaseId : String? //更新时间
    @objc var updateTime : String? //付费类型 0、免费 1、收费
    @objc var videoDuration : String?  //主播信息
    @objc var videoCover : String? //标题
}
