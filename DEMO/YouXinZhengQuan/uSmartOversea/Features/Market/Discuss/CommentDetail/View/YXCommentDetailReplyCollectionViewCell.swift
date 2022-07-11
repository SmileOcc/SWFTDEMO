//
//  YXCommentDetailReplyCollectionViewCell.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/26.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXCommentDetailReplyCollectionViewCell: UICollectionViewCell {
    
    typealias CommentButtonBlock = (_ paramsDic:[String:String], _ type:CommentButtonType ) -> Void
    
    var model:YXCommentDetailListReplyModel?
    var commentButtonBlock:CommentButtonBlock?
    
    var postType:String = ""
    var postId:String = ""
    
    lazy var popover: YXStockPopover = {
        let pop = YXStockPopover()

        return pop
    }()

    lazy var nickNameLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14)
        label.lineBreakMode = .byTruncatingMiddle
//        label.textAlignment = .right
        return label
    }()
    
    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.qmui_color(withHexString: "#191919")?.withAlphaComponent(0.03) //QMUITheme().commentBgColor()
        return view
    }()
    
    lazy var commentLabel: YYLabel = {
        let label = YYLabel()
//        label.textVerticalAlignment = .top
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 14)
        label.highlightTapAction = { (containerView, text, range ,rect) in
            let string = (text.string as NSString).substring(with: range)
            YXStockDetailViewModel.pushSafty(paramDic: ["dataSource": [string.reportStock], "selectIndex": 0])
        }
        
        return label
    }()

    lazy var imageBGView:YXCommentImagesView = {
        let view = YXCommentImagesView()
        view.tapImageBlock = { [weak self] index in
            guard let `self` = self else { return }
            if let model = self.model {
                if model.pictures.count > 0 {
                    XLPhotoBrowser.show(withImages: model.pictures, currentImageIndex: index)
                }
            }
        }
        
        return view
    }()
    
    lazy var replyLabel: YYLabel = {
        let label = YYLabel()
        label.highlightTapAction = { (containerView, text, range ,rect) in
            let string = (text.string as NSString).substring(with: range)
            YXStockDetailViewModel.pushSafty(paramDic: ["dataSource": [string.reportStock], "selectIndex": 0])
        }
        
        label.textTapAction = { (containerView, text, range ,rect) in
            
        }
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {

        bgView.addSubview(nickNameLabel)
        bgView.addSubview(commentLabel)
     
        bgView.addSubview(imageBGView)
        bgView.addSubview(replyLabel)
        
        addSubview(bgView)
        
        bgView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview().inset(13)
            make.left.equalToSuperview().offset(56)
        }
      
        nickNameLabel.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().offset(12)
            make.width.equalTo(60)
        }
        
        commentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nickNameLabel.snp.right)
            make.right.equalToSuperview().offset(-12)
            make.top.equalTo(nickNameLabel)
            make.height.equalTo(0)
        }
        
        imageBGView.snp.makeConstraints { (make) in
            make.top.equalTo(commentLabel.snp.bottom)
            make.left.equalTo(commentLabel.snp.left)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(0)
        }
        
        replyLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
            make.top.equalTo(imageBGView.snp.bottom).offset(4)
            make.left.equalTo(nickNameLabel.snp.left)
            make.height.equalTo(0)
        }


    }
    
    func updateUI(model:YXCommentDetailListReplyModel?, isLast:Bool) {
        if let model = model {
            self.model = model
            
            
            if let creatorUser = model.creator_user {
                nickNameLabel.text = creatorUser.nickName + ":"
            } else {
                nickNameLabel.text = "*****"
            }
            
            if let layout = model.replyLayout {
                
                self.commentLabel.textLayout = layout.contentlayout
                
                commentLabel.snp.updateConstraints { make in
                    make.height.equalTo(2 + (layout.contentlayout?.textBoundingRect.maxY ?? 0))
                }
                
                if model.pictures.count > 0 {
                    imageBGView.isHidden = false
                    imageBGView.snp.updateConstraints { make in
                        make.height.equalTo(layout.imageHeight)
                    }
                    var pictures:[String] = []
                    let first:String = model.pictures.first ?? ""
                    pictures.append(first)  //评论里只有一张图
                    imageBGView.updatePicture(pictures: pictures, height: layout.imageHeight, singlePicSize: layout.singleImageSize)
                }else{
                    imageBGView.isHidden = true
                }
                
                if model.replied_data != nil {
                    self.replyLabel.isHidden = false
                    self.replyLabel.textLayout = layout.replayLayout
                    
                    replyLabel.snp.updateConstraints { make in
                        make.height.equalTo(2 + (layout.replayLayout?.textBoundingRect.maxY ?? 0))
                    }
                }else{
                    self.replyLabel.isHidden = true
                }
            }

        }
    }
   
    
    //MARK:回复评论中的回复
    func replyCommemtReplyAction() {

        if let model = model {
            var reply_target_uid:String = ""
            var reply_nickName:String = ""
            if let replyUser = model.creator_user {
                reply_target_uid = replyUser.uid
                reply_nickName = replyUser.nickName
            }
            
            let paramDic =  ["post_id":self.postId,
                             "post_type":self.postType,
                             "comment_id":"",
                             "reply_id":model.reply_id,
                             "reply_target_uid":reply_target_uid,
                             "nick_name":reply_nickName]
            
            commentButtonBlock?(paramDic, .replyCommentReply)
        }
       
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        replyCommemtReplyAction()
    }
}
