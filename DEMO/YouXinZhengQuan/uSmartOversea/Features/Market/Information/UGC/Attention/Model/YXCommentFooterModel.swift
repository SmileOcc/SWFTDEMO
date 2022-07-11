//
//  YXCommentFooterModel.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/8/18.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXCommentFooterModel: NSObject {
    @objc var comment_count: Int64 = 0
    @objc var likeCount: Int64 = 0
    @objc var post_id: String = ""
    
    @objc var showMoreReply: Bool = false
    @objc var like_flag: Bool = false
    
    @objc var post_type: YXInformationFlowType = .stockdiscuss
}
