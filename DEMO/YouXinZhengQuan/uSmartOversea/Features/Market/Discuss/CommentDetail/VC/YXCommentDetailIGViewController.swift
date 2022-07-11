//
//  YXCommentDetailIGViewController.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/25.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import IGListKit
import IGListSwiftKit
import TYAlertController

class YXCommentDetailIGViewController: ListSectionController, ListSupplementaryViewSource {
    
    private var commentData: YXCommentDetailCommentModel?
    
    @objc var refreshDataBlock:((_ mode:Any?, _ type:CommentRefreshDataType) -> Void)?
    
    typealias ShowMoreBlock = () -> Void
    @objc var showMoreCommentBlock: ShowMoreBlock?
   
    @objc var postId:String = ""
    @objc var postType:String = ""
    
    @objc var showMoreComments:Bool = false
    
    override init() {
        super.init()
        supplementaryViewSource = self
        
    }
    
    // MARK: IGListSectionController Overrides
    override func numberOfItems() -> Int {
        if let list = commentData?.reply_list  {
            return  list.count
        }else{
            return 0
        }
    }

    override func sizeForItem(at index: Int) -> CGSize {
        let height = calcurateCellHeight(atIndex: index)
        return CGSize(width: collectionContext!.containerSize.width, height: height)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: YXCommentDetailReplyCollectionViewCell = collectionContext.dequeueReusableCell(for: self, at: index)
        if let commentData = commentData {
            cell.postId = self.postId
            cell.postType = self.postType
            let isLastLine:Bool = (index == commentData.reply_list.count - 1)
            cell.updateUI(model: commentData.reply_list[index], isLast: isLastLine)
            cell.commentButtonBlock = { [weak self] (paramDic, type) in
                guard let `self` = self else { return }
                self.handleBlockDataCenter(dic: paramDic, type: type)
            }
        }
        return cell
    }

    override func didUpdate(to object: Any) {
        commentData = object as? YXCommentDetailCommentModel
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
        let view: YXCommentDetailCommentCollectionViewCell = collectionContext.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, for: self, class: YXCommentDetailCommentCollectionViewCell.self, at: index) as! YXCommentDetailCommentCollectionViewCell
       
        view.postId = self.postId
        view.post_type = self.postType
        view.model = commentData
        
        view.commentButtonBlock = { [weak self] (paramDic, type) in
            guard let `self` = self else { return }
            self.handleBlockDataCenter(dic: paramDic, type: type)

        }

        return view
    }

    private func commentFooterView(atIndex index: Int) -> UICollectionReusableView {
        let view: YXUGCCommentFooterCell = collectionContext.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, for: self, class: YXUGCCommentFooterCell.self, at: index) as! YXUGCCommentFooterCell

        if let commentModel = commentData {
            view.updateAttentionUI(showMoreReply: showHadMoreReplys(), likeFlag: commentModel.like_flag , likeCount: commentModel.likeCount)
            view.commentData = commentModel
            view.commentId = commentModel.comment_id
            view.likeType = .comment
            view.postType = YXInformationFlowType.init(rawValue: Int(self.postType) ?? 5) ?? .stockdiscuss
            view.updateCommentCount(Int64(commentModel.reply_count))

            view.didLikeAction = { [weak self] (likFlag, count) in
                commentModel.like_flag = likFlag
                commentModel.likeCount = count
            }
            
            view.toolBarButtonBlock = { [weak self] (type) in
                guard let `self` = self else { return }
               
                var paramDic: [String : String] = [:]

                if type == .comment {
                    var reply_target_uid:String = ""
                    var reply_nickName:String = ""
                    if let replyUser = commentModel.creator_user {
                        reply_target_uid = replyUser.uid
                        reply_nickName = replyUser.nickName
                    }
                    paramDic = ["post_id":self.postId, "comment_id":commentModel.comment_id, "post_type":self.postType,
                        "reply_id":"",
                        "reply_target_uid":reply_target_uid,
                        "nick_name":reply_nickName]
                    self.handleBlockDataCenter(dic: paramDic, type: .replyComment)//详情页的评论 是 对应的回复评论
                }
               
            }
            
        }
        
        view.showMoreBlock = { [weak self] in
            guard let `self` = self else { return }
            self.loadMoreCommentReplys()
        }

        return view
    }
    //MARK: 算高度
    private func calcurateCellHeight(atIndex index:Int ) -> CGFloat {
        var height: CGFloat = 0
        if let replyModel = commentData?.reply_list[index], let layout = replyModel.replyLayout {
            if let commentRect = layout.contentlayout?.textBoundingRect {
                height = height + commentRect.maxY + 8
            }
            if let replyRect = layout.replayLayout?.textBoundingRect {
                height = height + replyRect.maxY + 8
            }
            
            height = height + layout.imageHeight + 12
            
        }
       
       
        return height
    }
    
    private func calcurateHeaderHeight(atIndex index:Int ) -> CGFloat {
        var height: CGFloat = 0
        if let headerLayout = commentData?.commentHeaderLayout {
            if let rect = headerLayout.contentlayout?.textBoundingRect {
                height = rect.height
            }
            height = height + headerLayout.userHeight + headerLayout.imageHeight+4 //4是图片距离content的top高度，这里修改height要结合cell的布局看，十分麻烦
            if headerLayout.imageHeight > 0 {
                height = height + 8
            }
        }
        return height
    }
    
    private func calcurateFooterHeight() -> CGFloat {
        var height: CGFloat = 38
        if showHadMoreReplys() {
            height = (38+25)
        }
        return height
    }
    
    
    //MARK: 数据处理
    private func handleBlockDataCenter(dic:[String:String], type:CommentButtonType) {
        if !YXUserManager.isLogin() {
            YXToolUtility.handleBusinessWithLogin {
                
            }
        }else{
            if type == .comment {   //评论帖子
                if let root = UIApplication.shared.delegate as? YXAppDelegate {
                    
                    let commentViewModel = YXCommentViewModel.init(services: root.navigator, params: dic)
                    commentViewModel.isReply = false
                    commentViewModel.successBlock = { [weak self] _ in
                        guard let `self` = self else { return }
                        self.deletePostDataBeforCheck(postId: self.postId, onlyRefresh: true)
                    }
                    commentViewModel.postDeleteBlock = { [weak self] in
                        guard let `self` = self else { return }
                        self.deletePostDataBeforCheck(postId: self.postId)
                    }
                    let commentVC = YXCommentViewController.init(viewModel: commentViewModel)
                    YXToolUtility.alertNoFullScreen(commentVC)
                }
            }else if type == .replyComment {  ////回复评论
                
                if let root = UIApplication.shared.delegate as? YXAppDelegate {
              
                    let replyViewModel = YXCommentViewModel.init(services: root.navigator, params: dic)
                    replyViewModel.isReply = true
                    let comment_id:String = dic["comment_id"] ?? ""
                    replyViewModel.successBlock = { [weak self] _ in
                        guard let `self` = self else { return }
                        self.refreshSingleComment(commentId: comment_id)
                    }
                    let commentVC = YXCommentViewController.init(viewModel: replyViewModel)
                    YXToolUtility.alertNoFullScreen(commentVC)
                }
            }else if type == .replyCommentReply { //回复评论中的回复
                if let root = UIApplication.shared.delegate as? YXAppDelegate {
              
                    let replyViewModel = YXCommentViewModel.init(services: root.navigator, params: dic)
                    replyViewModel.isReply = true
                    let comment_id:String = commentData?.comment_id ?? ""  //这里没有comment_id
                    replyViewModel.successBlock = { [weak self] _ in
                        guard let `self` = self else { return }
                        self.refreshSingleComment(commentId: comment_id)
                    }
                    let commentVC = YXCommentViewController.init(viewModel: replyViewModel)
                    YXToolUtility.alertNoFullScreen(commentVC)
                }
            } else if type == .report { //举报
                self.deleteOrReportHandle(dict: dic, type: type)
            }else if type == .delete { ////删除讨论
                self.deleteOrReportHandle(dict: dic , type: type)
            }else if type == .share {
            
            }else if type == .postIsDeleted {

            }
            
        }
    }
    
    //MARK:删除举报
    private func deleteOrReportHandle(dict:[String:String], type:CommentButtonType) {
        
        let comment_id:String = dict["comment_id"] ?? ""
        let reply_id:String = dict["reply_id"] ?? ""
        let post_type:Int = Int(self.postType) ?? 5
        if type == .delete {
            YXSquareCommentManager.commentDeleteAlert(completion: {
                [weak self] in
                guard let `self` = self else { return }
                if comment_id.count > 0 {
                    YXUGCCommentManager.deleteOrReportCommentData(comment_id: comment_id, post_type: post_type, status: 3) {[weak self] isSuc in
                        guard let `self` = self else { return }
                        if isSuc {
                           //去删除数据
                            YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "mine_del_success"))
                            self.refreshDataBlock?(nil, .deleteData)

                        }
                    }
                }
                if reply_id.count > 0 {
                    YXUGCCommentManager.deleteOrReportReplyData(reply_id: reply_id, post_type:post_type , status: 3) {[weak self] isSuc in
                        guard let `self` = self else { return }
                        if isSuc {
                            YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "mine_del_success"))
                            self.refreshSingleComment(commentId: self.commentData?.comment_id ?? comment_id)
                        }
                    }
                }
            })
            
        }else if type == .report {
            if comment_id.count > 0 {
                YXUGCCommentManager.deleteOrReportCommentData(comment_id: comment_id, post_type: post_type, status: 4) { isSuc in
                    if isSuc {
                        YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "report_success"))
                    }
                }
            }
            if reply_id.count > 0 {
                YXUGCCommentManager.deleteOrReportReplyData(reply_id: reply_id, post_type:post_type , status: 4) { isSuc in
                    if isSuc {
                        YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "report_success"))
                    }
                }
            }
        }
    }
    
    //MARK:加载更多回复
    private func loadMoreCommentReplys() {
        let hud = YXProgressHUD.showLoading("")
        let commentId:String = self.commentData?.comment_id ?? ""
        let offset:Int = self.commentData?.reply_list.count ?? 0
        YXUGCCommentManager.querySingleCommentData(comment_id:commentId , limit:5, offset: offset) {[weak self] model in
            guard let `self` = self else { return }
            hud.hide(animated: true)
            YXSquareCommentManager.transformCommentDetailCommentListLayout(model:model?.comment )
            if let commentmodel = self.commentData {
                var oldList:[YXCommentDetailListReplyModel] = []
                oldList.append(contentsOf: commentmodel.reply_list)
                if let plyList = model?.comment?.reply_list, plyList.count > 0  {
                    oldList.append(contentsOf: plyList)
                }else{
                    YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "common_no_data"))
                }
                commentmodel.reply_list = oldList
              
            }
            self.refreshDataBlock?(self.commentData, .refreshDataReplace)
          
        }
       
    }
    
    //MARK:刷新单个评论
    private func refreshSingleComment(commentId:String) {
        YXUGCCommentManager.querySingleCommentData(comment_id: commentId, limit:5, offset: 0) {[weak self] model in
            guard let `self` = self else { return }
            
            YXSquareCommentManager.transformCommentDetailCommentListLayout(model:model?.comment )
            self.refreshDataBlock?(model?.comment, .refreshDataReplace)
        }
    }
    
    //MARK:对帖子操作时 处理帖子已删除的情况
    private func deletePostDataBeforCheck(postId:String, onlyRefresh:Bool? = false) {
 
        YXSquareCommentManager.querySinglePostData(postId: postId, sourceType: "0") {[weak self] mode in
            guard let `self` = self else { return }
            if let model = mode {
                self.refreshDataBlock?(model, .refreshDataReplace)
            }else{
                if onlyRefresh == false {
                    self.refreshDataBlock?(nil, .deleteData)
                }
            }
        }
    }
    
    private func showHadMoreComments() -> Bool {
        if let model = commentData {
            return self.showMoreComments && model.isLast
        }
        return false
    }

    private func showHadMoreReplys() -> Bool {
        
        var showMoreReply:Bool = false
        if let reply_count = commentData?.reply_count , let replyListCount = commentData?.reply_list.count {
            if reply_count != replyListCount && reply_count > 5 {
                showMoreReply = true
            }
        }
        return showMoreReply
    }
}
