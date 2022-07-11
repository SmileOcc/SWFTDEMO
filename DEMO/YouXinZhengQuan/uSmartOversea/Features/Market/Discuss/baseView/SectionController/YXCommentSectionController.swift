//
//  YXCommentSectionController.swift
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/5/6.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import IGListKit
import IGListSwiftKit
import TYAlertController

/*
 评论cell算高度函数：sizeForItem
 讨论模块图 + 文算高度函数：sizeForSupplementaryView
 */
class YXCommentSectionController: ListSectionController, ListSupplementaryViewSource {
    
    private var commentData: YXSquareStockPostListModel?
    @objc var refreshDataBlock:((_ mode:Any?, _ type:CommentRefreshDataType) -> Void)?
    
    @objc var refreshAttentionStatusBlock:((_ uid:String, _ type:CommentRefreshDataType) -> Void)?
    
    override init() {
        super.init()
        supplementaryViewSource = self
        
    }
    
    // MARK: IGListSectionController Overrides
    override func numberOfItems() -> Int {
        if let list = commentData?.comment_list  {
            if commentData?.source_type == 4 {
                return 0
            }
            return (list.count > 3) ? 3 : list.count
        }else{
            return 0
        }
    }

    override func sizeForItem(at index: Int) -> CGSize {
        //在sizeForItem计算评论cell的高度
        let height = calcurateCellHeight(atIndex: index)
        return CGSize(width: collectionContext!.containerSize.width, height: height)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: YXCommentCollectionViewCell = collectionContext.dequeueReusableCell(for: self, at: index)
        if let commentData = commentData {
            let comentList = commentData.comment_list
            if let layout = commentData.layout, comentList.count > 0 {
                var lastIndex: Int = 2
                if comentList.count < 3 {
                    lastIndex = comentList.count - 1
                }
               
                cell.updateUI(model: comentList[index], layout: layout.comment_list[index], index: index)
                cell.postId = commentData.post_id
                var post_type:String = String( YXInformationFlowType.stockdiscuss.rawValue)
                if commentData.source_type == 1 {
                    post_type = String(YXInformationFlowType.imageText.rawValue)
                }
                cell.postType = post_type
                cell.commentButtonBlock = { [weak self] (paramDic, type) in
                    guard let `self` = self else { return }
                    self.handleBlockDataCenter(dic: paramDic, type: type, model: nil)
                }
            }
        }
        
        return cell
    }

    override func didUpdate(to object: Any) {
        commentData = object as? YXSquareStockPostListModel
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
        let view: YXCommentHeaderCell = collectionContext.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, for: self, class: YXCommentHeaderCell.self, at: index) as! YXCommentHeaderCell
        if let headerLayout = commentData?.layout?.headerLayout {
            view.updateUI(model: commentData, layout: headerLayout)
            
        }
        view.toolBarButtonBlock = { [weak self] (paramDic, type, model) in
            guard let `self` = self else { return }
            
            self.handleBlockDataCenter(dic: paramDic, type: type, model:model)
        }
       
        return view
    }

    private func commentFooterView(atIndex index: Int) -> UICollectionReusableView {
        let view: YXCommentFooterCell = collectionContext.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, for: self, class: YXCommentFooterCell.self, at: index) as! YXCommentFooterCell
        if commentData?.comment_list.count ?? 0 > 0 {
            view.commentCount = UInt64(commentData?.comment_count ?? 0)
            if commentData?.source_type == 4 {
                view.commentCount = 0
            }
        }else{
            view.commentCount = 0
        }
       
        view.showMoreBlock = { [weak self] in
            guard let `self` = self else { return }
            if let root = UIApplication.shared.delegate as? YXAppDelegate {
                let viewModel = YXStockCommentDetailViewModel(services: root.navigator, params: ["cid":self.commentData?.post_id ?? ""])
                root.navigator.push(viewModel, animated: true)
            }
        }
        
        return view
    }
    
    private func calcurateCellHeight(atIndex index:Int ) -> CGFloat {
        var height: CGFloat = 0
        if let commentData = commentData, let layout = commentData.layout {
         
            let commentLayout:YXSquareCommentHeaderFooterLayout = layout.comment_list[index]
            
            if let commentRect = commentLayout.contentlayout?.textBoundingRect {
                height = commentRect.maxY + 8 //这里加多少需要结合cell的布局去看，十分麻烦
            }
            
            if layout.comment_list.count == 1 {
                height = height + 8
            } else if layout.comment_list.count == 2 {
                if index == 1 {
                    height = height + 8
                }
            } else if layout.comment_list.count == 3 {
                if index == 2 {
                    height = height + 8
                }
            } else if layout.comment_list.count > 3 {
                if index == 2 {
                    height = height + 4
                }
            }
        }
        
        return height
    }
    
    private func calcurateHeaderHeight(atIndex index:Int ) -> CGFloat {
        var height: CGFloat = 0
        if let headerLayout = commentData?.layout?.headerLayout {
            
            if commentData?.source_type == 4 {
                if let titleRect = headerLayout.titleContentLayout?.textBoundingRect {
                    height = titleRect.height + 10 //这里加多少需要结合cell的布局去看，十分麻烦
                } else {
                    height += 10
                }
                if let contentSize = headerLayout.contentlayout?.textBoundingRect {
                    height = height + contentSize.height + 6
                }
            } else {
                if let contentSize = headerLayout.contentlayout?.textBoundingRect {
                    height = contentSize.height + 16
                }
            }
            
//            height = height + headerLayout.userHeight + headerLayout.toolBarHeight
            height = height + headerLayout.userHeight + headerLayout.toolBarHeight + headerLayout.singleImageSize.height

        }
        
        if let commentData = commentData, let layout = commentData.layout {
            if layout.comment_list.count > 0 {
                height = height +  12
            }
        }
        
        return height
    }
    
    private func calcurateFooterHeight() -> CGFloat {
        var height: CGFloat = 0
        if let commentCount = commentData?.comment_count {
            if commentData?.source_type == 4 { //产品要求source_type为4，berich大咖类型的评论(文章) 不显示评论区域
                return 24
            }
            if commentCount > 3 {
                height = 48
            }else if commentCount == 0 {
                height = 24
            }else{
                height = 24
            }
        }
      
        return height
    }
    
   
    //MARK: 数据处理
    private func handleBlockDataCenter(dic:[String:String]?, type:CommentButtonType, model:YXSquareStockPostListModel?) {
        if !YXUserManager.isLogin() {
            YXToolUtility.handleBusinessWithLogin {
                
            }
        }else{
            let postId:String = dic?["post_id"] ?? ""
            if type == .comment {   //评论帖子
                if let root = UIApplication.shared.delegate as? YXAppDelegate {
                    if commentData?.source_type == 4 {
                        if commentData?.jump_type == 1 {
                            if commentData?.jump_url.count ?? 0 > 0 {
                                YXWebViewModel.pushToWebVC(commentData?.jump_url ?? "")
                            }
                        }else if commentData?.jump_type == 2 {
                            if commentData?.jump_url.count ?? 0 > 0 {
                                YXGoToNativeManager.shared.gotoNativeViewController(withUrlString: commentData?.jump_url ?? "")
                            }
                        }
                    } else {
                        
                        let commentViewModel = YXCommentViewModel.init(services: root.navigator, params: dic)
                        commentViewModel.isReply = false
                        commentViewModel.successBlock = { [weak self] _ in
                            guard let `self` = self else { return }
                            self.deletePostDataBeforCheck(postId: postId, onlyRefresh: true)
                        }
                        commentViewModel.postDeleteBlock = { [weak self] in
                            guard let `self` = self else { return }
                            self.deletePostDataBeforCheck(postId: postId)
                        }
                        let commentVC = YXCommentViewController.init(viewModel: commentViewModel)
                        YXToolUtility.alertNoFullScreen(commentVC)
                    }
                }
            }else if type == .replyComment {  ////回复评论 或回复评论中的回复
                if let root = UIApplication.shared.delegate as? YXAppDelegate {
                    let replyViewModel = YXCommentViewModel.init(services: root.navigator, params: dic)
                    replyViewModel.isReply = true
                    replyViewModel.successBlock = { [weak self] _ in
                        guard let `self` = self else { return }
                        self.deletePostDataBeforCheck(postId: postId, onlyRefresh: true)
                    }
                    replyViewModel.postDeleteBlock = { [weak self] in
                        guard let `self` = self else { return }
                        self.deletePostDataBeforCheck(postId: postId)
                    }
                    
                    let commentVC = YXCommentViewController.init(viewModel: replyViewModel)
                    YXToolUtility.alertNoFullScreen(commentVC)
                }
            }else if type == .report { //举报
                YXSquareCommentManager.queryUpdatePostStatus(ignorePush: true, ignoreWhiteList: true, postId: postId, status: 4) { [weak self] isSuc, isDelete in
                    guard let `self` = self else { return }
                    if isSuc {
                        YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "report_success"))
                    }else if(isDelete) {
                        self.deletePostDataBeforCheck(postId: postId)
                    }
                }
            }else if type == .delete { ////删除讨论
                
                YXSquareCommentManager.commentDeleteAlert {
                    YXSquareCommentManager.queryUpdatePostStatus(ignorePush: true, ignoreWhiteList: true, postId: postId, status: 3) {[weak self] isSuc, isDelete in
                        guard let `self` = self else { return }
                        if isSuc {
                            YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "mine_del_success"))
                            self.refreshDataBlock?(nil, .deleteData)
                        }
                        if isDelete {
                            self.deletePostDataBeforCheck(postId: postId)
                        }
                    }
                }
            }else if type == .share {
                
                if let model = self.commentData, model.source_type == 0 {
                    YXDiscussShareView.showShareView(model: model)
                } else if model?.source_type == 4 {
                    let shareView = YXShareCommonView(frame: UIScreen.main.bounds,sharetype: .link, isShowCommunity:false)
                    shareView.shareTitle = commentData?.title ?? ""
                    shareView.shareText = dic?["share_content"]
                    shareView.shareUrl = commentData?.jump_url ?? ""
                    shareView.showShareBottomView()
                } else {
                    var shortUrl:String = YXH5Urls.commentDetailUrl(with: postId)
                    var inviteCode = ""
                    if YXUserManager.isLogin() {
                        inviteCode = YXUserManager.shared().curLoginUser?.invitationCode ?? ""
                    }
                    if commentData?.source_type == 1 {
                        shortUrl = YXH5Urls.articleDetailIdUrl(with: postId, inviteCode: inviteCode)
                    }
                    if commentData?.source_type == 4 {
                        shortUrl = commentData?.jump_url ?? ""
                    }
                    let shareContent:String = dic?["share_content"] ?? ""
                    let shareDict: [String : String] = [
                        "title":"",
                        "description":shareContent,
                        "shortUrl":shortUrl,
                        "pageUrl":shortUrl,
                        "wechatDescription":shareContent.count > 0 ? shareContent : YXLanguageUtility.kLang(key: "stock_detail_discuss")
                    ]
                    YXLiveShareTool.shareComment(contentDic: shareDict, viewController: UIViewController.current()) { isSuc in

                    }
                }
                
            }else if type == .postIsDeleted {
                self.deletePostDataBeforCheck(postId: postId)
            }
        
        }
    }
    
    //对帖子操作时 处理帖子已删除的情况
    private func deletePostDataBeforCheck(postId:String, onlyRefresh:Bool? = false) {
        guard  let model = commentData else {
            return
        }
        YXSquareCommentManager.querySinglePostData(postId: postId, sourceType: String(model.source_type)) {[weak self] mode in
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
    
}



//选择新加坡还是全球的cell
class YXCommentSectionHeaderSelectTabController: ListSectionController {
    var local = true //发现-社区模块默认请求值要改成-新加坡
    @objc var selectCallBack: ((_ selectIndex: Int) -> ())?
    
    private var commentData: YXSquareStockPostListModel?
    @objc var refreshDataBlock:((_ mode:Any?, _ type:CommentRefreshDataType) -> Void)?
    @objc var refreshAttentionStatusBlock:((_ uid:String, _ type:CommentRefreshDataType) -> Void)?
    
    override init() {
        super.init()
        
    }
    
    // MARK: IGListSectionController Overrides
    override func didUpdate(to object: Any) {
        let index = object as? Int
        if index == 0 {
            self.local = false
        } else if index == 1 {
            self.local = true
        }
    }
    
    override func numberOfItems() -> Int {
            return 1
    }

    override func sizeForItem(at index: Int) -> CGSize {
        //在sizeForItem计算评论cell的高度
        return CGSize(width: collectionContext!.containerSize.width, height: 45)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: YXCommentSectionHeaderSelectTabCell = collectionContext.dequeueReusableCell(for: self, at: index)
        
        return cell
    }
}
