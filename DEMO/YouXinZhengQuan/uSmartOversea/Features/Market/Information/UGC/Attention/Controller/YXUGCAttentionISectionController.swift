//
//  YXUGCAttentionISectionController.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/29.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import IGListKit
import IGListSwiftKit
import TYAlertController

class YXUGCAttentionISectionController: ListSectionController, ListSupplementaryViewSource {
        
    private var commentData: YXUGCFeedAttentionSumItemModel?
    
    @objc var refreshDataBlock:((_ mode:Any?, _ type:CommentRefreshDataType) -> Void)?
    @objc var jumpToBlock:((_ dict:[String:String]) -> Void)?

    @objc var isUserFeedListPage: Bool = false
    
    override init() {
        super.init()
        supplementaryViewSource = self
        
    }
    
    // MARK: IGListSectionController Overrides
    override func numberOfItems() -> Int {
        
        if let list = commentData?.attentionCommentModel?.comment_list  {
            return  list.count > 3 ? 3 : list.count
        }else{
            return 0
        }
    }

    override func sizeForItem(at index: Int) -> CGSize {
        let height = calcurateCellHeight(atIndex: index)
        return CGSize(width: collectionContext!.containerSize.width, height: height)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        
        let cell: YXCommentCollectionViewCell = collectionContext.dequeueReusableCell(for: self, at: index)
        if let commentDataObj = commentData?.attentionCommentModel {
            let comentList = commentDataObj.comment_list
            if let layout = comentList[index].layout , comentList.count > 0 {
                var lastIndex: Int = 2
                if comentList.count < 3 {
                    lastIndex = comentList.count - 1
                }
                
                cell.updateUI(model: comentList[index], layout: layout , index: index)
                
                cell.positionType = .attention
                cell.commentButtonBlock = { [weak self] (paramDic, type) in
                    guard let `self` = self else { return }
                    self.handleBlockDataCenter(dic: paramDic, type: type)
                }
            }
        }
        if let postData = commentData?.attentionPostModel {
            cell.postId = postData.cid
            cell.postType = String( postData.content_type.rawValue)
        }
        
        return cell
    }

    override func didUpdate(to object: Any) {
        commentData = object as? YXUGCFeedAttentionSumItemModel
    }
    
    // MARK: ListSupplementaryViewSource

    func supportedElementKinds() -> [String] {
        return [UICollectionView.elementKindSectionHeader, UICollectionView.elementKindSectionFooter]
    }
    
    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            return commentHeaderView(atIndex: index)
        case UICollectionView.elementKindSectionFooter:
            return commentFooterView(atIndex: index)
        default:
            fatalError()
        }
       
    }

    func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            let height: CGFloat = calcurateHeaderHeight(atIndex: index)
            return CGSize(width: collectionContext!.containerSize.width, height: height)
        case UICollectionView.elementKindSectionFooter:
            let height: CGFloat = calcurateFooterHeight()
            return CGSize(width: collectionContext!.containerSize.width, height: height)
        default:
            fatalError()
        }
    }

    // MARK: Private
    private func commentHeaderView(atIndex index: Int) -> UICollectionReusableView {
        let view: YXUGCAttentionCollectionViewCell = collectionContext.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, for: self, class: YXUGCAttentionCollectionViewCell.self, at: index) as! YXUGCAttentionCollectionViewCell
        if let postData = commentData?.attentionPostModel {
           
            view.updateUI(model: postData, commentCount: commentData?.attentionCommentModel?.comment_count ?? 0 )
            view.postId = postData.cid
            view.postType = String( postData.content_type.rawValue)
        }

        view.jumpToBlock = { [weak self] (paramDic) in
            guard let `self` = self else { return }
            self.jumpToBlock?(paramDic)
        }
        view.toolBarButtonBlock = { [weak self] param, type in
            guard let `self` = self else { return }
            self.handleBlockDataCenter(dic: param, type: type)
        }
        return view
    }

    private func commentFooterView(atIndex index: Int) -> UICollectionReusableView {
        let view: YXUGCCommentFooterCell = collectionContext.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, for: self, class: YXUGCCommentFooterCell.self, at: index) as! YXUGCCommentFooterCell
        
        if let attentionModel = commentData?.attentionPostModel{

            if self.isUserFeedListPage {
                view.updateCommentCount(Int64(attentionModel.total_comment))
            }

            let commentModel = commentData?.attentionCommentModel
            let likeFlag = attentionModel.like_info?.like_flag ?? false
            view.updateAttentionUI(showMoreReply: commentModel?.comment_count ?? 0 > 3, likeFlag: likeFlag, likeCount: attentionModel.like_info?.like_count ?? 0)
            view.postId = attentionModel.cid
            view.postType = attentionModel.content_type
//            if attentionModel.content_type == .customUrl {
//                view.hideCommentButton = true
//            }else{
//                view.hideCommentButton = false
//            }
            view.didLikeAction = { [weak self] (likFlag, count) in
                guard let `self` = self else { return }
                attentionModel.like_info?.like_flag = likFlag
                attentionModel.like_info?.like_count = count
            }
            
            view.toolBarButtonBlock = { [weak self] (type) in
                guard let `self` = self else { return }

                if self.isUserFeedListPage && type == .comment { // 用户个人主页中点击留言要跳转到动态详情
                    let paraDict:[String:String] = ["show_time":attentionModel.show_time, "cid":attentionModel.cid]
                    self.jumpToBlock?(paraDict)
                    return
                }

                let postType:String = String(attentionModel.content_type.rawValue)
                var paramDic: [String : String] = [:]
                
                if type == .share {
                    let content:String = YXToolUtility.reverseTransformHtmlString(attentionModel.content) ?? ""
                    paramDic = ["post_id":attentionModel.cid, "post_type":postType, "share_content":content]
                  
                }else if type == .comment {
                    paramDic = ["post_id":attentionModel.cid, "post_type":postType]
                }
                self.handleBlockDataCenter(dic: paramDic, type: type)
            }
        }
        
        view.showMoreBlock = { [weak self] in
            guard let `self` = self else { return }
            self.jumpToBlock?([:])
        }
        
        return view
    }
    
    //MARK: 算高度
    private func calcurateCellHeight(atIndex index:Int ) -> CGFloat {
        
        var height: CGFloat = 0
        if let commentList = commentData?.attentionCommentModel?.comment_list {
            
            let commentItem:YXSquareStockPostListCommentModel = commentList[index]
            if let commentLayout = commentItem.layout {
                height = height + commentLayout.userHeight
                if let commentRect = commentLayout.contentlayout?.textBoundingRect {
                    height = height + commentRect.maxY
                }
                if let replyRect = commentLayout.replayLayout?.textBoundingRect {
                    height = height + replyRect.maxY
                }
                height = height + commentLayout.imageHeight + commentLayout.toolBarHeight
            }
        }
       
        return height
    }
    
    private func calcurateHeaderHeight(atIndex index:Int ) -> CGFloat {
        var height: CGFloat = 0
        if let headerLayout = commentData?.attentionPostModel?.layout {
            if let rect = headerLayout.contentlayout?.textBoundingRect {
                height = rect.maxY + 4
            }
            
            if let subRect = headerLayout.subContentLayout?.textBoundingRect {
                height = height + subRect.maxY + 4
            }
            height = height + headerLayout.userHeight + headerLayout.toolBarHeight + headerLayout.imageHeight
        }

        if let model = commentData?.attentionPostModel, model.pay_type {
            height += 26 // 订阅专属标志
        }

        return height
    }
    
    private func calcurateFooterHeight() -> CGFloat {
        var height: CGFloat = 47
        if let commentCount = commentData?.attentionCommentModel?.comment_count, commentCount > 3 {
            height = 75
            
        }
      
        return height
    }
    
    //MARK: 数据处理
    private func handleBlockDataCenter(dic:[String:String]?, type:CommentButtonType) {
        if !YXUserManager.isLogin() {
            YXToolUtility.handleBusinessWithLogin{
                
            }
        }else{
            
            let postId:String = dic?["post_id"] ?? ""
            //内容类型 1=要闻资讯 2=图文 3=直播 4=回放 5=个股讨论
            
            if type == .comment {   //评论帖子
                if let root = UIApplication.shared.delegate as? YXAppDelegate {
                    let commentViewModel = YXCommentViewModel.init(services: root.navigator, params: dic)
                    commentViewModel.isReply = false
                    commentViewModel.successBlock = { [weak self] _ in
                        guard let `self` = self else { return }
                        
                        self.refreshSinglePostComment(commentId: postId)
                    }
                    commentViewModel.postDeleteBlock = { [weak self] in
                        guard let `self` = self else { return }
                         self.refreshSinglePostComment(commentId: postId)
                    }

                    let commentVC = YXCommentViewController.init(viewModel: commentViewModel)
                    YXToolUtility.alertNoFullScreen(commentVC)
                }
            }else if type == .replyComment {  ////回复评论 或回复评论中的回复
                
                if let root = UIApplication.shared.delegate as? YXAppDelegate {
                    let commentId:String = dic?["comment_id"] ?? ""
                    let reply_id:String = dic?["reply_id"] ?? ""
                    let reply_target_uid:String = dic?["reply_target_uid"] ?? ""
                    let reply_nickName:String = dic?["nick_name"] ?? ""
                    let postTypeString:String = String(commentData?.attentionPostModel?.content_type.rawValue ?? 5)
                    
                    let paramDic = [
                        "post_id":postId,
                        "comment_id":commentId,
                        "reply_id":reply_id,
                        "reply_target_uid":reply_target_uid, "nick_name":reply_nickName,
                        "post_type":postTypeString
                    ]
                    let replyViewModel = YXCommentViewModel.init(services: root.navigator, params: paramDic)
                    replyViewModel.isReply = true
                    replyViewModel.successBlock = { [weak self] _ in
                        guard let `self` = self else { return }
                        self.refreshSinglePostComment(commentId: postId)
                    }
                    replyViewModel.postDeleteBlock = { [weak self] in
                        guard let `self` = self else { return }
                        self.refreshSinglePostComment(commentId: postId)
                    }
                    let commentVC = YXCommentViewController.init(viewModel: replyViewModel)
                    YXToolUtility.alertNoFullScreen(commentVC)
                }
            }else if type == .report { //举报
                self.reportHandle(postId: postId)
               
            }else if type == .delete { ////删除讨论
                self.deletePostHandle(postId: postId)
       
            }else if type == .share {
                
                if let model = self.commentData?.attentionPostModel, model.content_type == .stockdiscuss {
                    
                    let shareModel = YXSquareStockPostListModel()
                    shareModel.content = model.title
                    shareModel.create_time = model.show_time
                    shareModel.creator_user = model.creator_info
                    shareModel.pictures = model.cover_images.map { $0.cover_images }
           
                    YXDiscussShareView.showShareView(model: shareModel)
                } else {
                    let shareContent:String = dic?["share_content"] ?? ""
                    let cid:String = commentData?.attentionPostModel?.cid ?? ""
                    let chatRoomId: String = commentData?.attentionPostModel?.text_live_info?.broadcast_id ?? ""
                    var shortUrl:String = ""
                    var inviteCode = ""
                    if YXUserManager.isLogin() {
                        inviteCode = YXUserManager.shared().curLoginUser?.invitationCode ?? ""
                    }
                    
                    if let contentType = commentData?.attentionPostModel?.content_type {
                        if contentType == .stockdiscuss {
                            shortUrl = YXH5Urls.commentDetailUrl(with: cid)
                        }else if contentType == .imageText {
                            shortUrl = YXH5Urls.articleDetailIdUrl(with: cid, inviteCode: inviteCode)
                        }else if contentType == .news {
                            shortUrl = YXH5Urls.importantNewsDetailUrl(newsId: cid, inviteCode: inviteCode)
                        }else if contentType == .live {
                            shortUrl = YXH5Urls.playInviteCodeLiveUrl(with: cid, inviteCode: inviteCode)
                        }else if contentType == .replay {
                            shortUrl = YXH5Urls.playNewsRecordUrl(with: cid, inviteCode: inviteCode)
                        }else if contentType == .chatRoom {
                            shortUrl = YXH5Urls.chatRoomUrl(id: chatRoomId)
                        }else if contentType == .customUrl {
                            shortUrl = commentData?.attentionPostModel?.link_url ?? ""
                        }
                    }
                    let title:String = commentData?.attentionPostModel?.title ?? ""
                    let shareDict = [
                        "title":title,
                        "description":shareContent,
                        "shortUrl":shortUrl,
                        "pageUrl":shortUrl,
                        "wechatDescription":title.count > 0 ? title : YXLanguageUtility.kLang(key: "stock_detail_discuss")
                    ]
                    
                    YXLiveShareTool.shareComment(contentDic: shareDict, viewController: UIViewController.current()) { isSuc in
                        
                    }
//                    YXSensorAnalyticsTrack.track(withEvent: .ViewClick, properties: [
//                        YXSensorAnalyticsPropsConstant.PROP_VIEW_PAGE : "盈财经-关注",
//                        YXSensorAnalyticsPropsConstant.PROP_VIEW_NAME : "点击分享",
//                        YXSensorAnalyticsPropsConstant.PROP_ID : cid,
//                        YXSensorAnalyticsPropsConstant.PROP_TITLE: shareContent,
//                    ])
                }
                
            
            }else if type == .postIsDeleted {

            }
            
        }
    }
    
    //举报处理
    func reportHandle(postId:String) {
        //内容类型 1=要闻资讯 2=图文 3=直播 4=回放 5=个股讨论
        let content_type = commentData?.attentionPostModel?.content_type
        if content_type != .stockdiscuss {
            YXProgressHUD.showMessage(YXLanguageUtility.kLang(key:"report_success"))
            return
        }
        YXSquareCommentManager.queryUpdatePostStatus(ignorePush: true, ignoreWhiteList: true, postId: postId, status: 4) { [weak self] isSuc, isDelete in
            guard let `self` = self else { return }
            if isSuc {
                YXProgressHUD.showMessage(YXLanguageUtility.kLang(key:"report_success"))
            }else if(isDelete) {
            }
        }
    }
    
    //删除帖子
    func deletePostHandle(postId:String)  {
        //内容类型 1=要闻资讯 2=图文 3=直播 4=回放 5=个股讨论
        let content_type = commentData?.attentionPostModel?.content_type
        if content_type != .stockdiscuss {
            return
        }
        
        YXSquareCommentManager.commentDeleteAlert(completion: {
          [weak self] in
            YXSquareCommentManager.queryUpdatePostStatus(ignorePush: true, ignoreWhiteList: true, postId: postId, status: 3) {[weak self] isSuc, isDelete in
                guard let `self` = self else { return }
                if isSuc {
                    YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "mine_del_success"))
                    self.refreshDataBlock?(nil, .deleteData)
                }

            }
        })
    }
    
    //刷新单个post下的评论  有就替换，无就删除
    func refreshSinglePostComment(commentId:String) {
        
        YXUGCCommentManager.querySingleCommentListData(post_id: commentId) { [weak self] model in
            guard let `self` = self else { return }
            if let post = model?.post {
                for commentItem in post.comment_list {
                    YXUGCCommentManager.transformAttentionCommentLayout(model: commentItem)
                }
            }
            if self.commentData != nil {
                self.refreshDataBlock?(model?.post, .refreshDataOnly)
            }
        }
    }
    
  

}
