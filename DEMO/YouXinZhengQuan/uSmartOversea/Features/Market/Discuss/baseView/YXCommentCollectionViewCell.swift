//
//  YXYGCCommentCollectionViewCell.swift
//  YouXinZhengQuan
//
//  Created by suntao on 2021/5/6.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXCommentCollectionViewCell: UICollectionViewCell {
    
    typealias CommentButtonBlock = (_ paramsDic:[String:String], _ type:CommentButtonType ) -> Void
    var commentButtonBlock:CommentButtonBlock?
    var model:YXSquareStockPostListCommentModel?
    
    var postId:String = ""
    var postType:String = ""
    var positionType:CommentPostionType = .ygc
    
    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().textColorLevel1().withAlphaComponent(0.03)
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var nickNameLabel: YYLabel = {
        let label = YYLabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.lineBreakMode = .byTruncatingMiddle
//        label.textAlignment = .right
        label.textVerticalAlignment = .top

        return label
    }()
    
    lazy var commentLabel: YYLabel = {
        let label = YYLabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.numberOfLines = 3
        label.textVerticalAlignment = .top
        label.highlightTapAction = { (containerView, text, range ,rect) in
            let string = (text.string as NSString).substring(with: range)
                        
            if let stock = string.reportStock {
                YXSquareManager.getTopService()?.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [stock], "selectIndex" : 0])
            }
        }
        return label
    }()
    
    lazy var replyLabel: YYLabel = {
        let label = YYLabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.highlightTapAction = { (containerView, text, range ,rect) in
            let string = (text.string as NSString).substring(with: range)
            if let stock = string.reportStock {
                YXSquareManager.getTopService()?.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [stock], "selectIndex" : 0])
            }
            
        }
        label.textTapAction = { (containerView, text, range ,rect) in
            
        }
        return label
    }()
    
    lazy var imageBGView:YXCommentImagesView = {
        let view = YXCommentImagesView()
        
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        bgView.addSubview(commentLabel)
        contentView.addSubview(bgView)
        
        bgView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(64)
            make.right.equalToSuperview().offset(-16)
        }

        commentLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(12)
            make.right.equalTo(bgView.snp.right).offset(-12)
            make.height.equalTo(0)
        }
    }
    
    func updateUI(model: YXSquareStockPostListCommentModel?, layout: YXSquareCommentHeaderFooterLayout, index:Int) {
        
        if let model = model {
            self.model = model
            
//            if index == 0 {
//                nickNameLabel.snp.updateConstraints { make in
//                    make.top.equalToSuperview().offset(12)
//                }
//            } else {
//                nickNameLabel.snp.updateConstraints { make in
//                    make.top.equalToSuperview().offset(8)
//                }
//            }
            
            self.commentLabel.textLayout = layout.contentlayout
            self.commentLabel.snp.updateConstraints { make in
                make.height.equalTo(8 + (layout.contentlayout?.textBoundingRect.maxY ?? 0))
            }
            
//            if model.pictures.count > 0 {
//                imageBGView.isHidden = false
//                imageBGView.snp.updateConstraints { make in
//                    make.height.equalTo(layout.imageHeight)
//                }
//                var pictures:[String] = []
//                let first:String = model.pictures.first ?? ""
//                pictures.append(first)  //评论里只有一张图
//                imageBGView.updatePicture(pictures: pictures, height: layout.imageHeight, singlePicSize: layout.singleImageSize)
//            }else{
//                imageBGView.isHidden = true
//            }
            
//            if model.replied_data != nil {
//                self.replyLabel.isHidden = false
//                self.replyLabel.textLayout = layout.replayLayout
//                replyLabel.snp.updateConstraints { make in
//                    make.height.equalTo(8 + (layout.replayLayout?.textBoundingRect.maxY ?? 0))
//                }
//            }else{
//                self.replyLabel.isHidden = true
//            }
//            imageBGView.isHidden = true
        }
    }
        
    func commentAction() {
       
        if let model = model {
            var reply_target_uid:String = ""
            var reply_nickName:String = ""
            if let replyUser = model.creator_user {
                reply_target_uid = replyUser.uid
                reply_nickName = replyUser.nickName
            }
            var paramDic:[String:String] = [:]
            
            if self.positionType == .attention {
                if model.replied_data != nil {
                    paramDic =  ["post_id":self.postId, "comment_id":"", "post_type":self.postType, "reply_id":model.comment_id, "reply_target_uid":reply_target_uid, "nick_name":reply_nickName]
                }else{
                    paramDic =  ["post_id":self.postId, "comment_id":model.comment_id, "post_type":self.postType, "reply_id":"", "reply_target_uid":reply_target_uid, "nick_name":reply_nickName]
                }
            }else{
                if model.level == 1 {
                    paramDic =  ["post_id":self.postId, "post_type":"5", "comment_id":model.comment_id, "reply_id":"", "reply_target_uid":reply_target_uid, "nick_name":reply_nickName]
                }else{
                    paramDic =  ["post_id":self.postId, "post_type":"5", "comment_id":"", "reply_id":model.comment_id, "reply_target_uid":reply_target_uid, "nick_name":reply_nickName]
                }
            }
            
            commentButtonBlock?(paramDic, .replyComment)
        }
       
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        commentAction()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard UIApplication.shared.applicationState != .background else { return }
        commentLabel.textLayout = commentLabel.textLayout
    }
  
}


class YXCommentSectionHeaderSelectTabCell: UICollectionViewCell {
    
    typealias CommentButtonBlock = (_ paramsDic:[String:String], _ type:CommentButtonType ) -> Void
    var commentButtonBlock:CommentButtonBlock?
    var selectIndex:Int?
    
    lazy var headerView: YXCommunityHeaderView = {
        let view = YXCommunityHeaderView.init(selectIndex: YXDiscussionSelectedType.singaporeTab.rawValue)
        view.selectCallBack = { [weak self] (index) in
            guard let self = `self` else { return }

        }
        return view
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        contentView.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(45)
        }
    }
    
    func updateUI(model: Int?) {
        
        if let model = model {
            self.selectIndex = model
            

        }
    }
            
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard UIApplication.shared.applicationState != .background else { return }
    }
  
}
