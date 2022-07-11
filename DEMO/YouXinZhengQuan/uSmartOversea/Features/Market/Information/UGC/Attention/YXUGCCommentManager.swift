//
//  YXUGCCommentManager.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/29.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

@objc enum CommentPictureType:Int {
    case unKnow = 0
    case horizontal = 1 //横图
    case vertical = 2  //竖图
}

@objc enum YXFollowStatus:Int {
    case none = 0  //无关注
    case attentioned = 1 //关注
    case eachOther = 2 //相互关注
    
    var text: String {
        switch self {
        case .none:
            return YXLanguageUtility.kLang(key: "ugc_attention")
        case .attentioned:
            return YXLanguageUtility.kLang(key: "ugc_attentioned")
        case .eachOther:
            return YXLanguageUtility.kLang(key: "ugc_attentionedEachother")
        }
    }
}

@objc enum YXLikeBizPreFix:Int {
    case post = 0
    case comment = 1
    case reply = 2
    
    var reqPrefix:String {
        switch self {
        case .post:
            return "postLikeUids"
        case .comment:
            return "commentLikeUids"
        case .reply:
            return "replyLikeUids"
        }
    }
}


@objc enum CommentPostionType: Int {
    case ygc = 1 //盈广场
    case attention = 2 //关注
}

@objc enum CommentSinglePictureType: Int {
    case postNormal = 0 //帖子位图正常
    case postLiving = 1 //视频图
    
    case comment = 2 //评论图
    case reply = 3 //回复图
}

class YXUGCCommentManager: NSObject {

    //用户动态
    @objc static func queryPersonFeedListData(
        userID: String = "",
        queryToken: String = "",
        type: NSInteger,
        completion: ((_ model: YXUGCFeedAttentionPostListModel?) -> Void)?
    ) {
        let requestModel: YXQueryPersonFeedListReq = YXQueryPersonFeedListReq()
        requestModel.person_uid = userID
        requestModel.query_token = queryToken
        requestModel.tab_type = type

        let request: YXRequest = YXRequest.init(request: requestModel)
        request.startWithBlock {  (model) in
            guard let modeData = model as? YXUGCFeedAttentionPostListModel else {
                completion?(nil)
                return
            }

            completion?(modeData)

        } failure: { (request) in
            completion?(nil)
        }
    }
    
    //关注 信息流
    @objc static func queryAttentionFeedListData(pageSize:Int, queryToken:String  , completion: ((_ model: YXUGCFeedAttentionPostListModel?) -> Void)?) {
        
       
        let requestModel: YXQueryAttentionFeedListReq = YXQueryAttentionFeedListReq()
        requestModel.page_size = pageSize
        requestModel.query_token = queryToken
        
        let request: YXRequest = YXRequest.init(request: requestModel)
        request.startWithBlock {  (model) in
            guard let modeData = model as? YXUGCFeedAttentionPostListModel else {
                completion?(nil)
                return
            }

            completion?(modeData)

        } failure: { (request) in
            completion?(nil)
        }
        
    }
    
    //获取推荐关注用户列表
    @objc static func queryRecommendUserListData(limit:Int, queryToken:String, completion: ((_ model: YXUGCRecommandUserListModel?) -> Void)?) {
        
       
        let requestModel: YXQueryRecommendUserListReq = YXQueryRecommendUserListReq()
        requestModel.limit = limit
        requestModel.query_token = queryToken
        
        let request: YXRequest = YXRequest.init(request: requestModel)
        request.startWithBlock {  (model) in
            guard let modeData = model as? YXUGCRecommandUserListModel else {
                completion?(nil)
                return
            }
            completion?(modeData)

        } failure: { (request) in
         
        }
    }
    
    //获取评论列表
    @objc static func queryCommentListData(post_ids:String, completion: ((_ model: YXUGCAttentionCommentListModel?) -> Void)?) {
        
        if post_ids.count == 0 {
            return
        }
        let requestModel: YXQueryCommentListReq = YXQueryCommentListReq()
        requestModel.post_ids = post_ids
      
        let request: YXRequest = YXRequest.init(request: requestModel)
        request.startWithBlock {  (model) in
            guard let modeData = model as? YXUGCAttentionCommentListModel else {
                completion?(nil)
                return
            }
            completion?(modeData)

        } failure: { (request) in
            completion?(nil)
        }
    }
    
    //获取单个post下的评论列表
    @objc static func querySingleCommentListData(post_id:String, completion: ((_ model: YXUGCSingleCommentListCommentModel?) -> Void)?) {
        
        if post_id.count == 0 {
            return
        }
        let requestModel: YXQuerySingleCommentListDataReq = YXQuerySingleCommentListDataReq()
        requestModel.post_id = post_id
      
        let request: YXRequest = YXRequest.init(request: requestModel)
        request.startWithBlock {  (model) in
            guard let modeData = model as? YXUGCSingleCommentListCommentModel else {
                completion?(nil)
                return
            }
            completion?(modeData)

        } failure: { (request) in
         
        }
    }
    
    //获取资讯视频下的评论列表
    @objc static func queryNewsOrLiveCommentListData(post_id:String, limit:Int, offset:Int, completion: ((_ model: YXNewsOrLiveCommentListModel?) -> Void)?) {
        
        if post_id.count == 0 {
            return
        }
        let requestModel: YXQueryNewsAndLiveCommentListDataReq = YXQueryNewsAndLiveCommentListDataReq()
        requestModel.post_id = post_id
        requestModel.limit = limit
        requestModel.offset = offset
        let request: YXRequest = YXRequest.init(request: requestModel)
        request.startWithBlock {  (model) in
            guard let modeData = model as? YXNewsOrLiveCommentListModel else {
                completion?(nil)
                return
            }
            completion?(modeData)

        } failure: { (request) in
         
        }
    }
    
    //获取单个评论
    @objc static func querySingleCommentData(comment_id:String, limit:Int, offset:Int, completion: ((_ model: YXSingleCommentModel?) -> Void)?) {
        
        if comment_id.count == 0 {
            return
        }
        let requestModel: YXQuerySingleCommentDataReq = YXQuerySingleCommentDataReq()
        requestModel.comment_id = comment_id
        requestModel.limit = limit
        requestModel.offset = offset
        let request: YXRequest = YXRequest.init(request: requestModel)
        request.startWithBlock {  (model) in
            guard let modeData = model as? YXSingleCommentModel else {
                completion?(nil)
                return
            }
            completion?(modeData)

        } failure: { (request) in
            completion?(nil)
        }
    }
    
    ////删除（举报）评论v3
    @objc static func deleteOrReportCommentData(comment_id:String, post_type:Int, status:Int, completion: ((_ isSuccess: Bool) -> Void)?) {
        
        if comment_id.count == 0 {
            return
        }
        let requestModel: YXQueryDeleteOrReportCommentReq = YXQueryDeleteOrReportCommentReq()
        requestModel.comment_id = comment_id
        requestModel.post_type = post_type
        requestModel.status = status
    
        let request: YXRequest = YXRequest.init(request: requestModel)
        request.startWithBlock {  (model) in
            if model.code == .success {
                completion?(true)
            }else {
                YXProgressHUD.showMessage(model.msg ?? "")
                completion?(false)
            }
        } failure: { (request) in
            
        }
    }
    
    ////删除（举报）回复v3
    @objc static func deleteOrReportReplyData(reply_id:String, post_type:Int, status:Int, completion: ((_ isSuccess: Bool) -> Void)?) {
        
        if reply_id.count == 0 {
            return
        }
        let requestModel: YXQueryDeleteOrReportReplyReq = YXQueryDeleteOrReportReplyReq()
        requestModel.reply_id = reply_id
        requestModel.post_type = post_type
        requestModel.status = status
    
        let request: YXRequest = YXRequest.init(request: requestModel)
        request.startWithBlock {  (model) in
            if model.code == .success {
                completion?(true)
            }else {
                YXProgressHUD.showMessage(model.msg ?? "")
                completion?(false)
            }
          
    
        } failure: { (request) in
            
        }
    }
    
    //通用 （取消）关注
    @objc static func queryAttention(bizType:Int, focusStatus:Int, targetUid:String, completion: ((_ isSuccess: Bool, _ followStatus: YXFollowStatus ) -> Void)?) {
        
        if targetUid.count == 0 {
            return
        }
        let requestModel: YXLiveConcernRequestModel = YXLiveConcernRequestModel()
        requestModel.biz_type = bizType
        requestModel.focus_status = focusStatus
        requestModel.target_uid = targetUid
        requestModel.uid = String(YXUserManager.userUUID())
        
        let request: YXRequest = YXRequest.init(request: requestModel)
        request.startWithBlock {  (model) in
            if model.code == .success {
                var status: YXFollowStatus = .none
                if let dataDic = model.data, let followStatusInt = dataDic["follow_status"] as? Int {
                    status = YXFollowStatus.init(rawValue: followStatusInt) ?? .none
                }
                completion?(true , status)
            }else {
                YXProgressHUD.showMessage(model.msg ?? "")
                completion?(false, .none)
            }
        } failure: { (request) in
            
        }
    }
    
    //通用（取消）点赞
    @objc static func queryLike(direction:Int, bizId:String, bizPreFix:YXLikeBizPreFix, postType:Int, completion: ((_ isSuccess: Bool, _ count:Int64) -> Void)?) {
        let requestModel: YXQueryLikeThumbUpOPReq = YXQueryLikeThumbUpOPReq()
        
        requestModel.common = ["bizId":bizId, "bizPreFix":bizPreFix.reqPrefix]
        requestModel.needPush = true
        requestModel.direction = direction
        requestModel.content_type = postType

        
        let request: YXRequest = YXRequest.init(request: requestModel)
        request.startWithBlock {  (model) in
            if model.code == .success {
                var count:Int64 = 0
                if let countInt = model.data?["count"] as? Int {
                    count = Int64(countInt)
                }
              
                completion?(true, count)
            }else {
                YXProgressHUD.showMessage(model.msg)
                completion?(false, 0)
            }
          
    
        } failure: { (request) in
            completion?(false, 0)
        }
    }
    
    //查询是否已经关注
    @objc static func queryHadAttentionedUser(targetUid:String, completion: ((_ isSuccess: Bool, _ flag:Bool) -> Void)?) {
        let requestModel:YXQueryHadAttentionedUserReq = YXQueryHadAttentionedUserReq()
        requestModel.target_uid = targetUid
        let request: YXRequest = YXRequest.init(request: requestModel)
        request.startWithBlock {  (model) in
            if model.code == .success {
                if  let flag = model.data?["flag"] as? Bool {
                    completion?(true, flag)
                }else{
                    completion?(true, false)
                }
            }else {
                YXProgressHUD.showMessage(model.msg ?? "")
                completion?(false, false)
            }
          
        } failure: { (request) in
            
        }
    }
    
    //查询关注列表
    @objc static func queryAttentionedUsers(targetUid:String, limit:Int, offset:Int, completion: ((_ model: YXUserAttentionModel? ) -> Void)?) {
        let requestModel:YXQueryConcernListReq = YXQueryConcernListReq()
        requestModel.offset = offset
        requestModel.target_uid = targetUid
        requestModel.limit = limit
        let request: YXRequest = YXRequest.init(request: requestModel)
        request.startWithBlock {  (model) in
            guard let modeData = model as? YXUserAttentionModel else {
                completion?(nil)
                return
            }
            completion?(modeData)
        } failure: { (request) in
            completion?(nil)
        }
    }
    
    //MARK:关注 正文的layout
    @objc static func transformAttentionPostLayout(model: YXUGCFeedAttentionModel?) {
        
        let layout:YXSquareCommentHeaderFooterLayout = YXSquareCommentHeaderFooterLayout()
        if let item = model {
            layout.userHeight = 74
            
            layout.contentlayout = YXSquareCommentManager.transformStockContentLayout(text: item.title, font: UIFont.systemFont(ofSize: 16), textColor: QMUITheme().textColorLevel1(), maxRows: 2, width: YXConstant.screenWidth - 24)
            
            layout.subContentLayout = YXSquareCommentManager.transformStockContentLayout(text:item.content, font: UIFont.systemFont(ofSize: 14), textColor: QMUITheme().textColorLevel1().withAlphaComponent(0.65), maxRows: 3, width: YXConstant.screenWidth - 24)
         
           
            var imageHeight: CGFloat = 0.0
            
            let flowType:YXInformationFlowType = item.content_type
            
            var imageUrls:[String] = []
            if flowType == .chatRoom {
                if let item = item.cover_images.first {
                    imageUrls.append(item.cover_images)
                }
            }else {
                for picItem in item.cover_images {
                    imageUrls.append(picItem.cover_images)
                }
            }
            
            if (imageUrls.count >= 2) {
                imageHeight = 114
            }else if (imageUrls.count == 1) {
                if flowType == .live || flowType == .replay || flowType == .chatRoom {
                    layout.singleImageSize = YXUGCCommentManager.getPictureSize(pictures:imageUrls, picType: .postLiving)
                }else{
                    layout.singleImageSize = YXUGCCommentManager.getPictureSize(pictures: imageUrls, picType: .postNormal)
                    if layout.singleImageSize.width <= 0, let coverModel = item.cover_images.first  {
                        let coverHeight:Int = Int(coverModel.cover_height) ?? 1
                        let coverWidth:Int = Int(coverModel.cover_width) ?? 1
                        layout.singleImageSize = YXUGCCommentManager.getPictureSizeFromCoverImageSize(size: CGSize(width: coverWidth, height: coverHeight))
                    }
                }
                
                imageHeight = layout.singleImageSize.height
            }
            
            layout.imageHeight = imageHeight
            
            var toolBarHeight:CGFloat = 10
           
            if imageHeight > 0 { //有图片时
                if item.content.count == 0 {
                    toolBarHeight = 15
                }else {
                   toolBarHeight = 15
                }
            }
            let noHtmlContent:String =  YXToolUtility.reverseTransformHtmlString(item.content) ?? ""
            if noHtmlContent.count == 0 {
                toolBarHeight = toolBarHeight - 10
            }
            
            //有股票时
            if item.stock_info?.symbol.count ?? 0 > 0 {
                toolBarHeight = toolBarHeight + 25
            }
            layout.toolBarHeight = toolBarHeight + 8
            item.layout = layout
        }
    }
    
    @objc static func transformNewHotAttentionPostLayout(model: YXUGCFeedAttentionModel?) {
        
        let layout:YXSquareCommentHeaderFooterLayout = YXSquareCommentHeaderFooterLayout()
        if let item = model {
            layout.userHeight = 74
            
            layout.contentlayout = YXSquareCommentManager.transformStockContentLayout(text: item.title, font: UIFont.systemFont(ofSize: 16), textColor: QMUITheme().textColorLevel1(), maxRows: 2, width: YXConstant.screenWidth - 68)
            
            layout.subContentLayout = YXSquareCommentManager.transformStockContentLayout(text:item.content, font: UIFont.systemFont(ofSize: 14), textColor: QMUITheme().textColorLevel1().withAlphaComponent(0.65), maxRows: 3, width: YXConstant.screenWidth - 68)
         
           
            var imageHeight: CGFloat = 0.0
            
            let flowType:YXInformationFlowType = item.content_type
            
            var imageUrls:[String] = []
            if flowType == .chatRoom {
                if let item = item.cover_images.first {
                    imageUrls.append(item.cover_images)
                }
            }else {
                for picItem in item.cover_images {
                    if !picItem.cover_images.isEmpty {
                        imageUrls.append(picItem.cover_images)
                    }
                }
            }
            
            if (imageUrls.count >= 2) {
                imageHeight = 114
            }else if (imageUrls.count == 1) {
                if flowType == .live || flowType == .replay || flowType == .chatRoom {
                    layout.singleImageSize = YXUGCCommentManager.getPictureSize(pictures:imageUrls, picType: .postLiving)
                }else{
                    layout.singleImageSize = YXUGCCommentManager.getPictureSize(pictures: imageUrls, picType: .postNormal)
                    if layout.singleImageSize.width <= 0, let coverModel = item.cover_images.first  {
                        let coverHeight:Int = Int(coverModel.cover_height) ?? 1
                        let coverWidth:Int = Int(coverModel.cover_width) ?? 1
                        layout.singleImageSize = YXUGCCommentManager.getPictureSizeFromCoverImageSize(size: CGSize(width: coverWidth, height: coverHeight))
                    }
                }
                
                imageHeight = layout.singleImageSize.height
            }
            
            layout.imageHeight = imageHeight
            
            var toolBarHeight:CGFloat = 10
           
            if imageHeight > 0 { //有图片时
                if item.content.count == 0 {
                    toolBarHeight = 15
                }else {
                   toolBarHeight = 15
                }
            }
            let noHtmlContent:String =  YXToolUtility.reverseTransformHtmlString(item.content) ?? ""
            if noHtmlContent.count == 0 {
                toolBarHeight = toolBarHeight - 10
            }
            
            //有股票时
            if item.stock_info?.symbol.count ?? 0 > 0 {
                toolBarHeight = toolBarHeight + 25
            }
            layout.toolBarHeight = toolBarHeight + 8
            item.layout = layout
        }
    }
    
    //MARK:关注 评论的layout
    @objc static func transformAttentionCommentLayout(model: YXSquareStockPostListCommentModel?) {
        let layout:YXSquareCommentHeaderFooterLayout = YXSquareCommentHeaderFooterLayout()
        if let item = model {
    
            layout.userHeight = 38
            layout.contentlayout = YXSquareCommentManager.transformStockContentLayout(text: item.content, font: UIFont.systemFont(ofSize: 14), textColor: QMUITheme().textColorLevel1(), maxRows: 3, width: YXConstant.screenWidth - 80, addDefaultIcon: item.pictures.count > 0 , defaultIconUrl: item.pictures.first ?? "")
            
            if let reply = item.replied_data  {
                let replycontentNoHtml: String = YXToolUtility.reverseTransformHtmlString(reply.content) ?? ""
                let inputString:String = String(format: "%@ : %@", reply.creator_user?.nickName ?? "", replycontentNoHtml)
                let nickNameString:String = String(format: "%@ : ", reply.creator_user?.nickName ?? "")
                let replycontentMutAttr: NSMutableAttributedString = YXSquareCommentManager.transformAttributeString(text: inputString, font: UIFont.systemFont(ofSize: 14), textColor: QMUITheme().textColorLevel1().withAlphaComponent(0.65))
               
                let textParser = YXReportTextParser()
                textParser.font = UIFont.systemFont(ofSize: 14)
                textParser.parseText(replycontentMutAttr, selectedRange: nil)
                
                replycontentMutAttr.addAttributes([.font :  UIFont.systemFont(ofSize: 14)], range: NSRange(location: 0, length: nickNameString.count))
                
                let container: YYTextContainer = YYTextContainer.init(size: CGSize(width: YXConstant.screenWidth - 86, height: CGFloat(MAXFLOAT)))
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
                layout.replayLayout = YYTextLayout.init(container: container, text: replycontentMutAttr)
            }
            
            
            layout.imageHeight = 0
            
            //toolBarHeight
            layout.toolBarHeight = 40
            if item.replied_data != nil {
                layout.toolBarHeight = 52
            }
            
            item.layout = layout
        }
    }
    

    @objc static func gotoUserCenter(uid:String) {
        if let root = UIApplication.shared.delegate as? YXAppDelegate {
            let navigator = root.navigator
            //TODO:屏蔽跳转个人中心
//            let viewModel = YXUserHomePageViewModel.init(services: navigator, params: [:])
//            viewModel.userInfoid = uid
//            navigator.push(viewModel, animated: true)
        }
    }
    
    @objc static func gotoStockCommentDetail(cid: String) {
        if cid.count == 0 {
            return
        }
        if let root = UIApplication.shared.delegate as? YXAppDelegate {
            let viewModel = YXStockCommentDetailViewModel(services: root.navigator, params: ["cid":cid])
            root.navigator.push(viewModel, animated: true)
        }
    }
    
    //MARK:关注信息流里的跳转
    @objc static func jumpToSeedVC(params:[String:String], flowType:YXInformationFlowType) {
        
        guard let root = UIApplication.shared.delegate as? YXAppDelegate else {
            return
        }
        let navigator = root.navigator
        var viewModel: YXViewModel!
        switch flowType {
        case .live:
            viewModel = YXWatchLiveViewModel(services: navigator, params: params)
        case .replay:
            break
        //TODO:屏蔽点击回放
//            viewModel = YXReviewLiveViewModel(services: navigator, params: params)
        case .stockdiscuss:
            viewModel = YXStockCommentDetailViewModel(services: navigator, params: params)
        case .customUrl, .chatRoom:
            viewModel = YXViewModel()
        default:
            break
        
        
        }
       navigator.push(viewModel, animated: true)
    }
    //毫秒 转 分：秒
    @objc static func transforMinSencond(ms:String) -> String {
        if ms.count == 0 {
            return ""
        }
        let msDouble:Int64 = Int64(ms) ?? 0
        let totalSecond = msDouble / 1000
        let hour = totalSecond / 3600
        let min = (totalSecond % 3600) / 60
        let sec = (totalSecond % 3600) % 60
        if hour > 0 {
            return String(format: "%02d:%02d:%02d", hour, min, sec)
        }else {
            return String(format: "%02d:%02d", min, sec)
        }
    }

    @objc static func parserPictureUrl(url:String) -> CommentPictureType {

        let array:[String] = url.components(separatedBy: "/")
        guard let last:String = array.last else {
            return .unKnow
        }
        let result:[String] = last.components(separatedBy: "_")
        guard let lastTemp = result.last else {
            return .unKnow
        }
        
        let resultTwo:[String]  = lastTemp.components(separatedBy: ".")
        guard let lastTwoTemp = resultTwo.first else {
            return .unKnow
        }
           
        let widthArray:[String]  = lastTwoTemp.components(separatedBy: "x")
        if widthArray.count == 2 , let width = widthArray.first, let height = widthArray.last {
            let widthInt:Int64 = Int64(width) ?? 0
            let heightInt:Int64 = Int64(height) ?? 1
            let dif:Int64 = widthInt / heightInt
            if dif >= 1 {
                return .horizontal
            }else{
                return .vertical
            }
        }
        return .unKnow
    }
    
    @objc static func getPictureSize(pictures:[String], picType:CommentSinglePictureType) -> CGSize {
        var size:CGSize = CGSize.init(width: 0, height: 0)
        if pictures.count >= 2 {
            //计算评论图片的宽度
            let boundsWith: CGFloat = (YXConstant.screenWidth - 64 - 16)
            let unitWidth:CGFloat = (boundsWith - 10) / 3
            size = CGSize.init(width: unitWidth, height: 96) //
        }else if pictures.count == 1 {
            
            let type:CommentPictureType = YXUGCCommentManager.parserPictureUrl(url: pictures.first ?? "")
            
            if picType == .postNormal {
                if type == .horizontal {
                    size = CGSize(width: 238, height: 140)
                }else if type == .vertical {
                    size = CGSize(width: 140, height: 238)
                }else{
                    size = CGSize(width: 0, height: 135) //不确定 由下载后知道 用固定高度来算
                }
            }else if picType == .postLiving{
                let width:Int = Int(YXConstant.screenWidth - 24)
                let height:Int = width * 197 / 351
                size = CGSize(width:width , height: height)
            }else if picType == .comment {
                if type == .horizontal {
                    size = CGSize(width: 238, height: 140)
                }else if type == .vertical {
                    size = CGSize(width: 140, height: 238)
                }else{
                    size = CGSize(width: 0, height: 105) //不确定 由下载后知道 用固定高度来算
                }
            }else if picType == .reply {
                if type == .horizontal {
                    size = CGSize(width: 120, height: 90)
                }else if type == .vertical {
                    size = CGSize(width: 90, height: 120)
                }else{
                    size = CGSize(width: 0, height: 90) //不确定 由下载后知道 用固定高度来算
                }
            }
        }
        return size
    }
    
    @objc static func getPictureSizeFromCoverImageSize(size: CGSize) -> CGSize {
        let widthInt:Int64 = Int64(size.width)
        let heightInt:Int64 = Int64(size.height)
        var dif:Int64 = 1
        if heightInt > 0 {
            dif = widthInt / heightInt
        }
        var type:CommentPictureType = .unKnow
        if dif >= 1 {
            type = .horizontal
        }else{
            type = .vertical
        }
        if widthInt == 1 && heightInt == 1 {
            type = .unKnow
        }
        
        var size:CGSize = CGSize(width: 0, height: 0)
        if type == .horizontal {
            size = CGSize(width: 180, height: 135)
        }else if type == .vertical {
            size = CGSize(width: 135, height: 180)
        }else{
            size = CGSize(width: 0, height: 135) //不确定 由下载后知道 用固定高度来算
        }
        
        return size
    }
    
    
    @objc static func changeThumbUrl(picUrl:String, size:CGSize) -> String {
        var temp:String = picUrl
        var shouldChange:Bool = true
        if size.width == 0 || size.height == 0 || temp.count == 0 {
            shouldChange = false
        }
        if temp.contains("myqcloud.com") == false || temp.contains("?") {
            shouldChange = false
        }
        if shouldChange {
            let width:Int = Int(size.width)
            let heigh:Int = Int(size.height)
            temp = temp + "?mageMogr2/thumbnail/" + "\(width)" + "x" + "\(heigh)"
        }
        
        return temp
    }
}
