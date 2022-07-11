//
//  SearchPostModel.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/4.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

@objc enum SearchPostType: Int {
    case article = 2
    case stockDiscussion = 5
}

/// 帖子
@objcMembers class SearchPostModel: YXModel {
    var postId = ""  // 帖子ID
    var title = "" // 帖子标题
    var content = "" // 帖子内容
    var createTime = "" // 创建帖子的时间
    var creatorUid = "" // 作者ID
    var creatorAvatar = "" // 作者头像
    var creatorNick = "" // 作者昵称
    var postType: SearchPostType = .article // 帖子类型：2：文章类型，5：个股讨论
    var authUser = false
    var userRoleType: SearchUserRoleType = .normal // 用户角色：1-普通账户, 2-高级账户-PRO2, 4-高级账户-PRO1, 5-高级账户-PRO3
}
