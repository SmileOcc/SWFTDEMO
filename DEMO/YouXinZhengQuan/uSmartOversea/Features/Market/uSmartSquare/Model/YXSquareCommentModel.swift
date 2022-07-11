//
//  YXSquareCommentModel.swift
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/5/11.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit


class YXSquareCommentUserModel: NSObject {
    
    @objc var avatar: String?
}

class YXSquareCommentModel: NSObject {

    
    @objc var market = ""
    @objc var symbol = ""
    @objc var post_id: String?
    @objc var content: String?
    
    @objc var creator_user: YXSquareCommentUserModel?
    
    @objc var pictures: [String]?
    
}
