//
//  YXCommentDetailHeaderModel.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/25.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXCommentDetailHeaderModel: YXModel {
    @objc var channel_id: Int32 = 0
    @objc var comment_count: Int64 = 0
    @objc var comment_list: [YXCommentDetailCommentModel] = []
    @objc var content: String = ""
    @objc var create_time:String = ""
    @objc var creator_user: YXCreateUserModel?
    @objc var likeCount: Int64 = 0
    @objc var like_flag: Bool = false
    @objc var pictures: [String] = []
    @objc var post_id: String = ""
    @objc var status: Int32 = 0
    
    @objc var postHeaderLayout: YXSquareCommentHeaderFooterLayout?   //正文的布局
}

extension YXCommentDetailHeaderModel: ListDiffable {

    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return isEqual(object)
    }
}
