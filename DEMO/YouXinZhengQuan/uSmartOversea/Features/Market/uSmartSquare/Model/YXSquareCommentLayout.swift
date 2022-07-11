//
//  YXSquareCommentLayout.swift
//  YouXinZhengQuan
//
//  Created by suntao on 2021/5/8.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit


class YXSquareCommentLayout: NSObject {
    
    @objc var post_list:[YXSquareStockPostListLayout] = []
}

class YXSquareStockPostListLayout : NSObject {
    @objc var headerLayout: YXSquareCommentHeaderFooterLayout?
    @objc var comment_list: [YXSquareCommentHeaderFooterLayout] = []
}

class YXSquareCommentHeaderFooterLayout : NSObject {
    var userHeight: CGFloat = 0
    var titleContentLayout:YYTextLayout?
    var contentlayout: YYTextLayout?
    var subContentLayout:YYTextLayout?
    var imageHeight: CGFloat = 0
    var replayLayout: YYTextLayout?   //回复
    
    var toolBarHeight: CGFloat = 0
    
    var singleImageSize:CGSize = CGSize.init(width: 0, height: 0) //单张图片时的宽度
  
}


