//
//  YXYGCCommentManager.swift
//  YouXinZhengQuan
//
//  Created by suntao on 2021/5/6.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

@objc enum CommentRefreshDataType:Int {
    case refreshDataReplace   //替换数据更新数据源
    case deleteData    //直接删除数据
    
    case refreshDataDelete //删除项来更新数据源
    case refreshDataAddMore //加载更多
    case refreshDataOnly // 刷新数据
    case refreshDataAttentionStatus //刷新关注状态
}

@objc enum CommentButtonType: Int {
    case share = 0   //分享
    case comment = 1  //评论帖子
    case like = 2 //点赞
    case delete = 3 //删除
    case report = 4 //举报
    case replyComment = 5  // 回复评论
    case postIsDeleted = 6 //帖子已删除
    
    case replyCommentReply = 7 //回复评论里面的回复
    

}

class YXSquareCommentManager: NSObject {
    
    //广场页股票精选讨论
    @objc static func queryFeaturedHotList(page:Int, pageSize:Int, query_token: String, local:Bool,completion: ((_ model: YXSquareHotCommentV2Model?) -> Void)?) {
        
        let requestModel: YXQueryFeaturedPostModel = YXQueryFeaturedPostModel()
        requestModel.page = page
        requestModel.limit = pageSize
        requestModel.query_token = query_token
        requestModel.local = local
        
        let request: YXRequest = YXRequest.init(request: requestModel)
        request.startWithBlock {  (model) in
            guard let modeData = model as? YXSquareHotCommentV2Model else {
                return
            }
            let comentLayout: YXSquareCommentLayout = YXSquareCommentManager.transformCommentLayout(list: modeData.post_list)
            
            if comentLayout.post_list.count > 0 && comentLayout.post_list.count == modeData.post_list.count {
                for (index, layout) in comentLayout.post_list.enumerated() {
                    let model:YXSquareStockPostListModel = modeData.post_list[index]
                    model.layout = layout
                }
            }
            completion?(modeData)

        } failure: { (request) in
            completion?(nil)
        }
        
    }
    
    //点取消赞
    @objc static func queryLikeOpration(itemType: Int, itemId: String, opration: Int, completion: ((_ success: Bool, _ likeCount:String, _ isDelete:Bool) -> Void)?) {
        let requestModel: YXQueryLikeOperationModel = YXQueryLikeOperationModel()
        requestModel.item_type = itemType
        requestModel.like_item_id = itemId
        requestModel.operation = opration
    
        let request: YXRequest = YXRequest.init(request: requestModel)
        request.startWithBlock { (response) in
            if response.code == .success {
                var likeCountStr: String = ""
                if let likeCount = response.data?["like_count"] as? String {
                    likeCountStr = likeCount
                }
               
                completion?(true, likeCountStr, false)
            }else{
                if CommentButtonType.init(rawValue:Int(response.code.rawValue)) == .postIsDeleted  {  //帖子已经被删除
                    YXProgressHUD.showMessage(response.msg)
                    completion?(false, "", true)
                }else{
                    completion?(false, "", false)
                }
            }
        } failure: { (request) in
            print("%@",request)
        }
        
    }
    
    //删除或举报 post 帖子
    @objc static func queryUpdatePostStatus(ignorePush: Bool, ignoreWhiteList: Bool, postId: String, status:Int, completion: ((_ success: Bool, _ isDelete:Bool) -> Void)?) {
        let requestModel: YXQueryUpdatePostStatus = YXQueryUpdatePostStatus()
//        requestModel.ignore_push = ignorePush
//        requestModel.ignore_white_list = ignoreWhiteList
        requestModel.post_id = postId
        requestModel.status = status
    
        let request: YXRequest = YXRequest.init(request: requestModel)
        request.startWithBlock { (response) in
            if response.code == .success {
                completion?(true, false)
            }else{
                if CommentButtonType.init(rawValue:Int(response.code.rawValue)) == .postIsDeleted  {  //帖子已经被删除

                    completion?(false, true)
                    YXProgressHUD.showMessage(response.msg)
                }else{
                    completion?(false, false)
                }
            }
        } failure: { (request) in
            print("%@",request)
        }
        
    }
    
    @objc static func querySinglePostData(postId:String, sourceType:String, completion: ((_ model: YXSquareStockPostListModel?) -> Void)?) {
        let requestModel: YXQuerySinglePostData = YXQuerySinglePostData()
        requestModel.post_id = postId
        requestModel.source_type = sourceType
        let request: YXRequest = YXRequest.init(request: requestModel)
        request.startWithBlock { (model) in
            guard let modeData = model as? YXSquareSingleCommentModel else {
                return
            }
            if let post = modeData.post {
                let layout: YXSquareStockPostListLayout = YXSquareCommentManager.transformSingleCommentLayout(model: post)
                post.layout = layout
                completion?(post )
            }else{
                completion?(nil)
            }
        } failure: { (request) in
            print("%@",request)
        }
    }
    
    //获取股票讨论列表
    @objc static func queryStockCommentList(page: Int, pageSize: Int, offset: Int, stockId: String, local:Bool, completion: ((_ model: YXSquareHotCommentModel?) -> Void)? ) {
        let requestModel: YXQueryStockCommentListModel = YXQueryStockCommentListModel()
        //requestModel.post_id = ""
        requestModel.query_token = ["page":page, "page_size":pageSize, "offset": offset]
        requestModel.stock_id = stockId
        requestModel.local = local

        let request: YXRequest = YXRequest.init(request: requestModel)
        request.startWithBlock { (model) in
            guard let modeData = model as? YXSquareHotCommentModel else {
                return
            }

            let comentLayout: YXSquareCommentLayout = YXSquareCommentManager.transformCommentLayout(list: modeData.post_list)
            
            if comentLayout.post_list.count > 0 && comentLayout.post_list.count == modeData.post_list.count {
                for (index, layout) in comentLayout.post_list.enumerated() {
                    let model:YXSquareStockPostListModel = modeData.post_list[index]
                    model.layout = layout
                }
            }
            completion?(modeData)
        } failure: { (request) in
           completion?(nil)
        }
    }
    
    
    //MARK:讨论详情页接口
    //获取讨论详情
    @objc static func queryPostDetailData(postId:String, limit:Int, offset:Int, completion: ((_ model: YXCommentDetailPostModel?) -> Void)? ) {
        if postId.count == 0 {
            return
        }
        let requestModel: YXQueryPostDetailData = YXQueryPostDetailData()
        requestModel.post_id = postId
        requestModel.offset = offset
        let request: YXRequest = YXRequest.init(request: requestModel)
        request.startWithBlock { (model) in
            guard let modeData = model as? YXCommentDetailModel else {
                return
            }
            if let post = modeData.post {
                YXSquareCommentManager.transformCommentDetailLayout(model: post)
                completion?(post )
            }else{
                completion?(nil)
            }
        } failure: { (request) in
           completion?(nil)
        }
    }

    //删除或举报 post 帖子
    @objc static func queryReplyDeleteOrReport( replyId: String, status:Int, completion: ((_ success: Bool, _ isDelete:Bool) -> Void)?) {
        let requestModel: YXCommentDetailReplyDeleteOrReporeReq = YXCommentDetailReplyDeleteOrReporeReq()
        requestModel.reply_id = replyId
        requestModel.status = status
    
        let request: YXRequest = YXRequest.init(request: requestModel)
        request.startWithBlock { (response) in
            if response.code == .success {
                completion?(true, false)
            }else{
                if CommentButtonType.init(rawValue:Int(response.code.rawValue)) == .postIsDeleted  {  //帖子已经被删除
                    YXProgressHUD.showMessage(response.msg)
                    completion?(false, true)
               
                }else{
                    completion?(false, false)
                }
            }
        } failure: { (request) in
            print("%@",request)
        }
        
    }
    //获取评论下回复列表
    @objc static func queryReplyListData(commentId:String, limit:Int, offset:Int, completion: ((_ model: YXCommentDetailReplyListModel?) -> Void)? ) {
        if commentId.count == 0 {
            return
        }
        let requestModel: YXQueryReplyListReq = YXQueryReplyListReq()
        requestModel.comment_id = commentId
        requestModel.limit = limit
        requestModel.offset = offset
        let request: YXRequest = YXRequest.init(request: requestModel)
        request.startWithBlock { (model) in
            guard let modeData = model as? YXCommentDetailReplyListModel else {
                return
            }
            if modeData.list.count > 0 {
//                YXSquareCommentManager.transformCommentDetailLayout(model: post)
//                completion?(post )
            }else{
                completion?(nil)
            }
        } failure: { (request) in
           completion?(nil)
        }
    }
    
    //MARK:盈广场评论布局模型转换
    @objc static func transformCommentLayout(list: [YXSquareStockPostListModel]?) -> YXSquareCommentLayout {
        
        let allLayout:YXSquareCommentLayout = YXSquareCommentLayout()
        
        var postListArray = [YXSquareStockPostListLayout]()
        
        if let finalList = list,  finalList.count > 0 {
            
            for item in finalList {
                
                let postListLayout: YXSquareStockPostListLayout = YXSquareCommentManager.transformSingleCommentLayout(model: item)
                
                postListArray.append(postListLayout)
            }
            allLayout.post_list = postListArray
        }

        return allLayout
    }
    
    @objc static func transformSingleCommentLayout(model: YXSquareStockPostListModel?) -> YXSquareStockPostListLayout {
        
        let postListLayout:YXSquareStockPostListLayout = YXSquareStockPostListLayout()
        if let item = model {
            //header
            let headerLayout: YXSquareCommentHeaderFooterLayout = YXSquareCommentHeaderFooterLayout()
            headerLayout.userHeight = 64
            
            let postContent:String = ( item.source_type == 1 ) ? item.title : item.content //文章类型时取title
            let contentNoHtml: String = YXToolUtility.reverseTransformHtmlString(postContent) ?? ""
            //富文本内容
            let contentAttr: NSMutableAttributedString = YXSquareCommentManager.transformAttributeString(text: contentNoHtml, font: UIFont.systemFont(ofSize: 16), textColor: QMUITheme().textColorLevel1())
            
            let textParser = YXReportTextParser()
            textParser.font = UIFont.systemFont(ofSize: 16)
            textParser.parseText(contentAttr, selectedRange: nil)
            
            let modifier = YXTextLinePositionModifier()
            modifier.font = UIFont.systemFont(ofSize: 16)
            modifier.lineHeightMultiple = 1.4
            
            let container: YYTextContainer = YYTextContainer.init(size: CGSize(width: YXConstant.screenWidth - 80, height: CGFloat.greatestFiniteMagnitude))
            container.linePositionModifier = modifier
            container.maximumNumberOfRows = 3
            container.truncationType = .end
            container.truncationToken = NSAttributedString(string: "...", attributes: [.foregroundColor: QMUITheme().textColorLevel1(), .font: UIFont.systemFont(ofSize: 16)])
            headerLayout.contentlayout = YYTextLayout.init(container: container, text: contentAttr)
            
            let images: [String] = item.pictures
            headerLayout.singleImageSize = YXUGCCommentManager.getPictureSize(pictures: images, picType: .postNormal)
            
            headerLayout.toolBarHeight = 48
            if images.count > 0 { //有图片时
                if item.content.count == 0 {
                    headerLayout.toolBarHeight = 48
                }else {
                    headerLayout.toolBarHeight = 48
                }
            }
            
            /*20220418 beerich 大咖类型的评论 增加标题的计算begin*/
            //富文本标题
            if item.source_type == 4 {
                let titleNoHtml: String = YXToolUtility.reverseTransformHtmlString(item.title) ?? ""
                let titleAttr: NSMutableAttributedString = YXSquareCommentManager.transformAttributeString(text: titleNoHtml, font: UIFont.systemFont(ofSize: 16, weight: .medium), textColor: QMUITheme().textColorLevel1())
                let titlecontainer: YYTextContainer = YYTextContainer.init(size: CGSize(width: YXConstant.screenWidth - 80, height: CGFloat.greatestFiniteMagnitude))
                titlecontainer.linePositionModifier = modifier
                titlecontainer.maximumNumberOfRows = 2
                titlecontainer.truncationType = .end
                titlecontainer.truncationToken = NSAttributedString(string: "...", attributes: [.foregroundColor: QMUITheme().textColorLevel1(), .font: UIFont.systemFont(ofSize: 16, weight: .medium)])
                headerLayout.titleContentLayout = YYTextLayout.init(container: titlecontainer, text: titleAttr)
                
                let contentAttr: NSMutableAttributedString = YXSquareCommentManager.transformAttributeString(text: contentNoHtml, font: UIFont.systemFont(ofSize: 14), textColor: QMUITheme().textColorLevel2())
                let container: YYTextContainer = YYTextContainer.init(size: CGSize(width: YXConstant.screenWidth - 80, height: CGFloat.greatestFiniteMagnitude))
                
                let textParser1 = YXReportTextParser()
                textParser1.font = UIFont.systemFont(ofSize: 14)
                textParser1.parseText(contentAttr, selectedRange: nil)
                
                let modifier1 = YXTextLinePositionModifier()
                modifier1.font = UIFont.systemFont(ofSize: 14)
                modifier1.lineHeightMultiple = 1.4
                
                container.linePositionModifier = modifier1
                container.maximumNumberOfRows = 3
                container.truncationType = .end
                container.truncationToken = NSAttributedString(string: "...", attributes: [.foregroundColor: QMUITheme().textColorLevel1(), .font: UIFont.systemFont(ofSize: 14)])
                headerLayout.contentlayout = YYTextLayout.init(container: container, text: contentAttr)
            }
            /*20220418 beerich 大咖类型的评论 增加标题的计算end*/
            
            postListLayout.headerLayout = headerLayout
            
            //评论
            var commentList: [YXSquareCommentHeaderFooterLayout] = []
            
            for comentItem in item.comment_list {

                //header
                let commentheaderLayout: YXSquareCommentHeaderFooterLayout = YXSquareCommentHeaderFooterLayout()
                
                //富文本内容
                let contentColor = QMUITheme().textColorLevel2()
                let contentFoneSize = UIFont.systemFont(ofSize: 14)
                let contentNoHtml: String = YXToolUtility.reverseTransformHtmlString(comentItem.content) ?? ""
                var nickNameContent = String(format: "%@: ", comentItem.creator_user?.nickName ?? "")
                if let reply = comentItem.replied_data {
                    nickNameContent = String(format: "%@ ▶ %@: ", comentItem.creator_user?.nickName ?? "", reply.creator_user?.nickName ?? "")
                }
                
                let contentMutAttr: NSMutableAttributedString = YXSquareCommentManager.transformAttributeString(text: (nickNameContent+contentNoHtml), font: contentFoneSize, textColor: contentColor)
                let textParser = YXReportTextParser()
                textParser.font = contentFoneSize
                textParser.parseText(contentMutAttr, selectedRange: nil)
                
                let modifier = YXTextLinePositionModifier()
                modifier.font = contentFoneSize
                modifier.lineHeightMultiple = 1.4
                
                contentMutAttr.addAttributes([.font :  UIFont.systemFont(ofSize: 14, weight: .medium),NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1()], range: NSRange(location: 0, length: nickNameContent.count))
                
                let str = (nickNameContent+contentNoHtml)
                let range = (str as NSString).range(of: "▶")
                contentMutAttr.addAttributes([.foregroundColor:QMUITheme().textColorLevel3(), .font: UIFont.systemFont(ofSize: 14, weight: .regular)], range: range)
                
                let container: YYTextContainer = YYTextContainer.init(size: CGSize(width: YXConstant.screenWidth - (63 + 16 + 12 + 12), height: CGFloat(MAXFLOAT)))
                container.linePositionModifier = modifier
                container.maximumNumberOfRows = 3
                container.truncationType = .end
                container.truncationToken = NSAttributedString(string: "...", attributes: [.foregroundColor: contentColor, .font: contentFoneSize])
                
                if comentItem.pictures.count > 0 {  //评论里面有图片
                    let emptyStr:String = " "
                    let emptyAttribut:NSAttributedString = NSAttributedString.init(string: emptyStr)
                    contentMutAttr.append(emptyAttribut)
                    
                    let iconButton:UIButton = UIButton()
                    iconButton.setImage( UIImage.init(named: "comment_icon_default_WhiteSkin"), for: .normal)
                    _ = iconButton.rx.tap.subscribe(onNext: { (_) in
                        XLPhotoBrowser.show(withImages: comentItem.pictures, currentImageIndex: 0)
                    })
                    iconButton.sizeToFit()
                    let attachMent = NSMutableAttributedString.yy_attachmentString(withContent: iconButton, contentMode: .center, attachmentSize: CGSize(width: 14, height: 14), alignTo: UIFont.systemFont(ofSize: 14), alignment: .center)
                   
                    contentMutAttr.append(attachMent)
                }
                
                commentheaderLayout.contentlayout = YYTextLayout.init(container: container, text: contentMutAttr)
                
//                let replyPicSize:CGSize = YXUGCCommentManager.getPictureSize(pictures: comentItem.pictures, picType: .reply)
//                commentheaderLayout.singleImageSize = replyPicSize
//                commentheaderLayout.imageHeight = replyPicSize.height
                
                //
                if let reply = comentItem.replied_data {
                   
                    let authUserString:String = String(format: "%@ ▶ ", comentItem.creator_user?.nickName ?? "")
                    let nickNameString:String = String(format: "%@ : ", reply.creator_user?.nickName ?? "")
                    let replayHeaderString:String = authUserString + nickNameString
                     
                    let replycontentNoHtml: String = YXToolUtility.reverseTransformHtmlString(reply.content) ?? ""
                    let inputString:String = String(format: "%@%@", replayHeaderString, replycontentNoHtml)
                    
                    
                    let replycontentMutAttr: NSMutableAttributedString = YXSquareCommentManager.transformAttributeString(text: inputString, font: UIFont.systemFont(ofSize: 14), textColor: QMUITheme().textColorLevel1().withAlphaComponent(0.65))
                    
                    let textParser = YXReportTextParser()
                    textParser.font = UIFont.systemFont(ofSize: 14)
                    textParser.parseText(replycontentMutAttr, selectedRange: nil)
                    
                    replycontentMutAttr.addAttributes([.font :  UIFont.systemFont(ofSize: 14)], range: NSRange(location: 0, length: replayHeaderString.count))
                    
                    let container: YYTextContainer = YYTextContainer.init(size: CGSize(width: YXConstant.screenWidth - 104, height: CGFloat(MAXFLOAT)))
                    container.linePositionModifier = modifier
                    container.maximumNumberOfRows = 1
                    container.truncationType = .end
                    container.truncationToken = NSAttributedString(string: "...", attributes: [.foregroundColor: QMUITheme().textColorLevel1().withAlphaComponent(0.65), .font: UIFont.systemFont(ofSize: 14)])
                    if reply.pictures.count > 0 {
                        let emptyStr:String = " "
                        let emptyAttribut:NSAttributedString = NSAttributedString.init(string: emptyStr)
                        replycontentMutAttr.append(emptyAttribut)
                        
                        let iconButton:UIButton = UIButton()
                        iconButton.setImage( UIImage.init(named: "comment_icon_default_WhiteSkin"), for: .normal)
                        _ = iconButton.rx.tap.subscribe(onNext: { (_) in
                            XLPhotoBrowser.show(withImages: reply.pictures, currentImageIndex: 0)
                        })
                        iconButton.sizeToFit()
                        let attachMent = NSMutableAttributedString.yy_attachmentString(withContent: iconButton, contentMode: .center, attachmentSize: CGSize(width: 14, height: 14), alignTo: UIFont.systemFont(ofSize: 14), alignment: .center)
                       
                        replycontentMutAttr.append(attachMent)
                    }
                    commentheaderLayout.replayLayout = YYTextLayout.init(container: container, text: replycontentMutAttr)
                }
                
                commentList.append(commentheaderLayout)
            }
            postListLayout.comment_list = commentList
        }
        
        
        return postListLayout
    }

    
    //MARK:个股评论详情头部layout模型
    @objc static func transformCommentDetailLayout(model: YXCommentDetailPostModel?) {

        if let item = model {
            //post正文
            let postHeaderLayout: YXSquareCommentHeaderFooterLayout = YXSquareCommentHeaderFooterLayout()
            postHeaderLayout.userHeight = 70
            
            //富文本内容
            postHeaderLayout.contentlayout = YXSquareCommentManager.transformStockContentLayout(text: item.content, font: UIFont.systemFont(ofSize: 16), textColor: QMUITheme().textColorLevel1(), maxRows: 0, width: YXConstant.screenWidth - 16*2)
            
            //imageHeight
            let images: [String] = item.pictures
            var imageHeight: CGFloat = 0.0
            if images.count > 6 {
                imageHeight = 355
            }else if images.count > 3 {
                imageHeight = 230
            }else if images.count >= 2 {
                imageHeight = 115
            } else if images.count == 1 {
                let size:CGSize = YXUGCCommentManager.getPictureSize(pictures: images, picType: .postNormal)
                postHeaderLayout.singleImageSize = size
                
                imageHeight = size.height
            }
    
            postHeaderLayout.imageHeight = imageHeight
             
            //toolBarHeight
            var postToolBarHeight:CGFloat = 36

            if imageHeight > 0 { //有图片时
                postToolBarHeight = postToolBarHeight + 10
            }
            if item.content.count == 0 {
                postToolBarHeight = postToolBarHeight - 10
            }
            postHeaderLayout.toolBarHeight = postToolBarHeight
            
            //风险提示
            let riskString:String = YXLanguageUtility.kLang(key: "risk_tips_comment")
            postHeaderLayout.replayLayout = YXSquareCommentManager.transformStockContentLayout(text: riskString, font: UIFont.systemFont(ofSize: 12, weight: .light), textColor: QMUITheme().textColorLevel4(), maxRows: 0, width: YXConstant.screenWidth - 16*2)

            item.postHeaderLayout = postHeaderLayout
            
            //评论
            for comentItem in item.comment_list {
                YXSquareCommentManager.transformCommentDetailCommentListLayout(model: comentItem)
                
            }
           
        }
    }
    
    
    //MARK:个股评论详情 评论 layout模型
    @objc static func transformCommentDetailCommentListLayout(model: YXCommentDetailCommentModel?) {
        guard let model = model else {
            return
        }
        
        //header
        let commentheaderLayout: YXSquareCommentHeaderFooterLayout = YXSquareCommentHeaderFooterLayout()
        commentheaderLayout.userHeight = (24+32)
        //富文本内容
        commentheaderLayout.contentlayout = YXSquareCommentManager.transformStockContentLayout(text: model.content, font: UIFont.systemFont(ofSize: 16), textColor: QMUITheme().textColorLevel1(), maxRows: 0, width: YXConstant.screenWidth - 70)
        //图片
        let commentPicSize:CGSize = YXUGCCommentManager.getPictureSize(pictures: model.pictures, picType: .comment)
        commentheaderLayout.singleImageSize = commentPicSize
        commentheaderLayout.imageHeight = commentPicSize.height
        //工具条
        var toolBarHeight:CGFloat = 10
        if model.pictures.count > 0 {
            if model.content.count == 0 {
                toolBarHeight = 10
            }else{
                toolBarHeight = 15
            }
        }
        commentheaderLayout.toolBarHeight = toolBarHeight
        model.commentHeaderLayout = commentheaderLayout

        //回复条数
        for replyItem in model.reply_list {
        
            let replyItemLayout:YXSquareCommentHeaderFooterLayout = YXSquareCommentHeaderFooterLayout()
            
            replyItemLayout.userHeight = 47
            replyItemLayout.contentlayout = YXSquareCommentManager.transformStockContentLayout(text: replyItem.content, font: UIFont.systemFont(ofSize: 14), textColor: QMUITheme().textColorLevel1(), maxRows: 0, width: YXConstant.screenWidth - 164)
            
            let replyPicSize:CGSize = YXUGCCommentManager.getPictureSize(pictures: replyItem.pictures, picType: .reply)
            replyItemLayout.singleImageSize = replyPicSize
            replyItemLayout.imageHeight = replyPicSize.height
            
            var replyItemToolHeight:CGFloat = 33
            if replyItem.replied_data != nil {
                replyItemToolHeight = replyItemToolHeight + 6
            }
            if replyItem.pictures.count > 0 {
                replyItemToolHeight = replyItemToolHeight + 10
            }
            replyItemLayout.toolBarHeight = replyItemToolHeight
            
            if let replyData = replyItem.replied_data {
                let replycontentNoHtml: String = YXToolUtility.reverseTransformHtmlString(replyData.content) ?? ""
                let inputString:String = String(format: "▶ %@ : %@", replyData.creator_user?.nickName ?? "", replycontentNoHtml)
                let nickNameString:String = String(format: "%@ :", replyData.creator_user?.nickName ?? "")
                let replycontentMutAttr: NSMutableAttributedString = YXSquareCommentManager.transformAttributeString(text: inputString, font: UIFont.systemFont(ofSize: 14), textColor: QMUITheme().textColorLevel1().withAlphaComponent(0.65))
               
                let textParser = YXReportTextParser()
                textParser.font = UIFont.systemFont(ofSize: 14)
                textParser.parseText(replycontentMutAttr, selectedRange: nil)
                
                replycontentMutAttr.addAttributes([.font :  UIFont.systemFont(ofSize: 14)], range: NSRange(location: 0, length: nickNameString.count))
                
                let modifier = YXTextLinePositionModifier()
                modifier.font = UIFont.systemFont(ofSize: 14)
                modifier.lineHeightMultiple = 1.4
                let container: YYTextContainer = YYTextContainer.init(size: CGSize(width: YXConstant.screenWidth - 104, height: CGFloat(MAXFLOAT)))
                container.linePositionModifier = modifier
                container.maximumNumberOfRows = 2
                container.truncationType = .end
                container.truncationToken = NSAttributedString(string: "...", attributes: [.foregroundColor: QMUITheme().textColorLevel1().withAlphaComponent(0.65), .font: UIFont.systemFont(ofSize: 14)])
                
                if replyData.pictures.count > 0 {
                    let emptyStr:String = " "
                    let emptyAttribut:NSAttributedString = NSAttributedString.init(string: emptyStr)
                    replycontentMutAttr.append(emptyAttribut)
                    
                    let iconButton:UIButton = UIButton()
                    iconButton.setImage( UIImage.init(named: "comment_icon_default_WhiteSkin"), for: .normal)
                    _ = iconButton.rx.tap.subscribe(onNext: { (_) in
                        XLPhotoBrowser.show(withImages: replyData.pictures, currentImageIndex: 0)
                    })
                    iconButton.sizeToFit()
                    let attachMent = NSMutableAttributedString.yy_attachmentString(withContent: iconButton, contentMode: .center, attachmentSize: CGSize(width: 14, height: 14), alignTo: UIFont.systemFont(ofSize: 14), alignment: .center)
                   
                    replycontentMutAttr.append(attachMent)
                }
                replyItemLayout.replayLayout = YYTextLayout.init(container: container, text: replycontentMutAttr)
            }
            
            replyItem.replyLayout = replyItemLayout
            
        }
    }
    
    
    //变成有解析股票的内容
    static func transformStockContentLayout(text:String, font:UIFont, textColor:UIColor, maxRows:UInt, width:CGFloat, addDefaultIcon:Bool = false, defaultIconUrl:String = "" ) -> YYTextLayout? {
        let postContentNoHtml: String = YXToolUtility.reverseTransformHtmlString(text) ?? ""
        let postContentAttr: NSMutableAttributedString = YXSquareCommentManager.transformAttributeString(text: postContentNoHtml, font: font, textColor: textColor)
      
        let postParser = YXReportTextParser()
        postParser.font = font
        postParser.parseText(postContentAttr, selectedRange: nil)
        
        
        let modifier = YXTextLinePositionModifier()
        modifier.font = font
        modifier.lineHeightMultiple = 1.4
        
        let container: YYTextContainer = YYTextContainer.init(size: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        container.linePositionModifier = modifier
        container.maximumNumberOfRows = maxRows
       
        if maxRows > 0 {
            container.truncationType = .end
            container.truncationToken = NSAttributedString(string: "...", attributes: [.foregroundColor: textColor, .font: font])
        }
        
        if addDefaultIcon {
            let emptyStr:String = " "
            let emptyAttribut:NSAttributedString = NSAttributedString.init(string: emptyStr)
            postContentAttr.append(emptyAttribut)
            
            let iconButton:UIButton = UIButton()
            iconButton.setImage( UIImage.init(named: "comment_icon_default_WhiteSkin"), for: .normal)
            _ = iconButton.rx.tap.subscribe(onNext: { (_) in
                XLPhotoBrowser.show(withImages: [defaultIconUrl], currentImageIndex: 0)
            })
            iconButton.sizeToFit()
            
            let attachMent = NSMutableAttributedString.yy_attachmentString(withContent: iconButton, contentMode: .center, attachmentSize: CGSize(width: 14, height: 14), alignTo: font, alignment: .center)
           
            postContentAttr.append(attachMent)
        }
        
        let textLayout:YYTextLayout = YYTextLayout.init(container: container, text: postContentAttr)!
        
        return textLayout
    }
    
    //MARK:工具方法
    static func transformAttributeString(text: String, font: UIFont, textColor: UIColor) -> NSMutableAttributedString {
       let attribute = NSMutableAttributedString.init(string: text, attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor : textColor])
        
        return attribute
    }
    
    
    static func transformCount(count:Int64) -> String {
        var countString:String = ""
      
        if count >= 1000 {
            let countTemp:CGFloat = CGFloat(count) / 1000.0
            countString = String(format: "%.2fk", countTemp)
        }else{
            countString = String(format: "%d", count)
        }
        
        return countString
       
    }
   
    @objc static func commentDeleteAlert(completion: (() -> Void)?) {
        
        let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "comment_delete_pop"))
        alertView.clickedAutoHide = false
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: {[weak alertView] action in
            alertView?.hide()
        }))
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "delelte_comment_sure"), style: .default, handler: {[weak alertView] action in
            alertView?.hide()
            completion?()
        }))
        alertView.showInWindow()

       
    }
    
    //二次确认(通用)
    @objc static func sureAgainAlert(title:String, okText:String, cancelText:String, complish:(() -> Void)?) {
        let alertView = YXAlertView.alertView(message: title)
        alertView.clickedAutoHide = true
        alertView.addAction(YXAlertAction.action(title: cancelText, style: .cancel, handler: {[weak alertView] action in
            alertView?.hide()
        }))
        
        alertView.addAction(YXAlertAction.action(title: okText, style: .default, handler: {[weak alertView] action in
            complish?()
            alertView?.hide()
        }))
        
        alertView.showInWindow()
    }
    
    //判断Uid 是不是本人
    @objc static func isMyUserId(uid:String) -> Bool {
        let userIdDouble: Double = Double(uid) ?? 99
        if  YXUserManager.userUUID() == UInt64(userIdDouble) { //是本人
            return true
        }else{
            return false
        }
    }
    
    //去原生个股评论详情
    @objc static func gotoStockCommentDetail(cid:String) {
        if let root = UIApplication.shared.delegate as? YXAppDelegate {
            let viewModel = YXStockCommentDetailViewModel(services: root.navigator, params: ["cid":cid])
            root.navigator.push(viewModel, animated: true)
        }
    }
}
