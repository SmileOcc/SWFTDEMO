//
//  YXYGCCommentHeaderCollectionViewCell.swift
//  YouXinZhengQuan
//
//  Created by suntao on 2021/5/6.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXCommentHeaderCell: UICollectionViewCell {
    
    typealias ClickActionBlock = ( _ paramDic:[String:String]?, _ type:CommentButtonType, _ model:YXSquareStockPostListModel?) -> Void
    var toolBarButtonBlock:ClickActionBlock?
    var tapImageBlock:((_ index: Int) -> Void)?
    var popList: [CommentButtonType] = []
    var attentionedBlock:((_ uid:String) -> Void)?
    
    var likeBlock:((_ flag:Bool, _ likeCount:Int) -> Void)?
    
    lazy var userView: YXCommentUserView = {
        let view = YXCommentUserView()
        view.attentionedBlock = { [weak self] uid in
            guard let `self` = self else { return }
//            self.attentionedBlock?(uid)
            
        }
        return view
    }()
    
    lazy var popover: YXStockPopover = {        
        let pop = YXStockPopover()
        return pop
    }()
    
    lazy var shareButton: QMUIButton = {
        let btn = QMUIButton()
        btn.setTitleColor(QMUITheme().textColorLevel1().withAlphaComponent(0.65), for: .normal)
        btn.setImage(UIImage(named: "ygc_share"), for: .normal)
        btn.spacingBetweenImageAndTitle = 4
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.titleLabel?.minimumScaleFactor = 0.5
        btn.contentMode = .left
        btn.addTarget(self, action: #selector(shareAction(_:)), for: .touchUpInside)
//        btn.contentHorizontalAlignment = .left
        return btn
    }()
    
    lazy var commentButton: QMUIButton = {
        let btn = QMUIButton()
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.setTitleColor(QMUITheme().textColorLevel1().withAlphaComponent(0.65), for: .normal)
        btn.setImage(UIImage(named: "ygc_comment"), for: .normal)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.titleLabel?.minimumScaleFactor = 0.5
        btn.spacingBetweenImageAndTitle = 8
        btn.contentMode = .left
        btn.addTarget(self, action: #selector(commentAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    //点赞
    lazy var likeButton: QMUIButton = {
        let btn = QMUIButton()
        btn.addSubview(likeImageView)
        btn.addSubview(likeCountLabel)
        likeImageView.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        likeCountLabel.snp.makeConstraints { make in
            make.left.equalTo(likeImageView.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
        }
        btn.contentMode = .left
        btn.addTarget(self, action: #selector(likeAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var likeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "theme_ygc_like_big")
        return imageView
    }()
    
    lazy var likeCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    var model:YXSquareStockPostListModel?

    
    lazy var detailButton: YXExpandAreaButton = {
        let btn = YXExpandAreaButton()
        btn.expandX = 20
        btn.expandY = 20
        btn.setBackgroundImage(UIImage(named:"theme_ygc_more"), for: .normal)
        btn.addTarget(self, action: #selector(detailAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var titleLabel: YYLabel = {
        let label = YYLabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .left
        label.numberOfLines = 2
        
        return label
    }()
    
    lazy var commentLabel: YYLabel = {
        let label = YYLabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        label.numberOfLines = 3
        
        label.highlightTapAction = { (containerView, text, range ,rect) in
            let string = (text.string as NSString).substring(with: range)
            if let stock = string.reportStock {
                YXSquareManager.getTopService()?.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [stock], "selectIndex" : 0])
            }
        }
        
        return label
    }()
    
    lazy var imageBGView:YXCommentImagesView = {
        let view = YXCommentImagesView()
        view.tapImageBlock = { [weak self] index in
            guard let `self` = self else { return }
            if let pictures = self.model?.pictures {
                XLPhotoBrowser.show(withImages: pictures, currentImageIndex: index)
            }

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
        contentView.addSubview(userView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(commentLabel)
        contentView.addSubview(detailButton)
        contentView.addSubview(imageBGView)
        
        contentView.addSubview(shareButton)
        contentView.addSubview(commentButton)
        contentView.addSubview(likeButton)
        
        userView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.left.equalToSuperview().offset(14)
            make.height.equalTo(40)
            make.right.equalToSuperview().offset(-41)
        }
       
        detailButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(userView)
            make.width.height.equalTo(25)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(userView.nickNameLabel)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(userView.snp.bottom).offset(10)
            make.height.equalTo(0)
        }
        
        commentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(userView.nickNameLabel)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.height.equalTo(0)
        }
        
        imageBGView.snp.makeConstraints { make in
            make.top.equalTo(commentLabel.snp.bottom).offset(8)
            make.left.equalTo(commentLabel)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(0)
        }
        
        likeButton.snp.makeConstraints { make in
            make.top.equalTo(imageBGView.snp.bottom).offset(16)
            make.left.equalTo(commentLabel)
            make.height.equalTo(20)
            make.width.equalTo(70)
        }

        commentButton.snp.makeConstraints { make in
            make.centerX.equalTo(commentLabel)
            make.centerY.equalTo(likeButton)
            make.height.equalTo(18)
            make.width.greaterThanOrEqualTo(18)
        }

        shareButton.snp.makeConstraints { make in
            make.right.equalTo(detailButton)
            make.centerY.equalTo(likeButton)
            make.height.equalTo(18)
            make.width.greaterThanOrEqualTo(18)
        }
                
        
    }
    
    @objc func detailAction(_ sender: YXExpandAreaButton) {
        if !YXUserManager.isLogin()  {
            if let root = UIApplication.shared.delegate as? YXAppDelegate {
                let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: nil, vc: nil))
                root.navigator.push(YXModulePaths.defaultLogin.url, context: context)
            }
            return
        }
        if let model = model, let uid = model.creator_user?.uid {
            let userIdDouble: Double = Double(uid) ?? 99
            
            var popList: [Int] = []
            if  YXUserManager.userUUID() == UInt64(userIdDouble) { //是本人
                popList = [CommentButtonType.delete.rawValue, CommentButtonType.share.rawValue]
            }else{
                popList = [CommentButtonType.report.rawValue, CommentButtonType.share.rawValue]
            }
            let view:YXCommentDetailPopView = YXCommentDetailPopView.init(list: popList, isWhiteStyle: false) {
                [weak self] type in
                guard let `self` = self else { return }
                
                if let model = self.model {
                    let content:String = YXToolUtility.reverseTransformHtmlString(model.content) ?? ""
                    let paramDic:[String:String] = ["post_id":model.post_id, "share_content":content]

                    self.toolBarButtonBlock?(paramDic , CommentButtonType(rawValue: type) ?? CommentButtonType.report, model)

                }
                self.popover.dismiss()
            }
            self.popover.show(view, from: sender)
        }
        
    }
    
    
    func updateUI(model: YXSquareStockPostListModel?, layout: YXSquareCommentHeaderFooterLayout) {
        
        userView.updateUI(model: model?.creator_user ?? nil, createTime: model?.create_time ?? "", followStates: model?.follow_status ?? 0)
        
        if let model = model {
            self.model = model
            if self.model?.source_type == 4 {
                commentLabel.font = UIFont.systemFont(ofSize: 14)
                commentLabel.textColor = QMUITheme().textColorLevel2()
                self.titleLabel.textLayout = layout.titleContentLayout
                titleLabel.snp.updateConstraints { make in
                    make.height.equalTo(4 + (layout.titleContentLayout?.textBoundingRect.maxY ?? 0))
                }
            } else {
                commentLabel.font = UIFont.systemFont(ofSize: 16)
                commentLabel.textColor = QMUITheme().textColorLevel1()
                titleLabel.snp.updateConstraints { make in
                    make.height.equalTo(0)
                }
            }
            self.commentLabel.textLayout = layout.contentlayout
            commentLabel.snp.updateConstraints { make in
                make.height.equalTo(4 + (layout.contentlayout?.textBoundingRect.maxY ?? 0))
            }
            
            imageBGView.snp.updateConstraints { make in
                make.height.equalTo(layout.singleImageSize.height)
            }

//           //内容类型 1=要闻资讯 2=图文 3=直播 4=回放 5=个股讨论
            var contentType:String = String(YXInformationFlowType.stockdiscuss.rawValue)
            if model.source_type == 1 { //文章
                contentType = String(YXInformationFlowType.imageText.rawValue)
            }
            let dict = [
                "content_type":contentType,
                "duration":model.video?.duration ?? "",
                "videoUrl":model.video?.url ?? ""
            ]
            updateLikeCount()
            updateCommentCount(Int64(model.comment_count))
            
            imageBGView.updatePictureFromeSinglePicSize(pictures: model.pictures, picSize: layout.singleImageSize, dict: dict)

        }
    }

    @objc func headClick() {
            if let model = model {
                if let root = UIApplication.shared.delegate as? YXAppDelegate {
                    if model.source_type == 4 { //beerich 的评论类型
                        if model.jump_type == 1 {
                            if model.jump_url.count > 0 {
                                YXWebViewModel.pushToWebVC(model.jump_url)
                            }
                        }else if model.jump_type == 2 {
                            if model.jump_url.count > 0 {
                                YXGoToNativeManager.shared.gotoNativeViewController(withUrlString: model.jump_url)
                            }
                        }
                    } else {
                        let viewModel = YXStockCommentDetailViewModel(services: root.navigator, params: ["cid":model.post_id])
                        root.navigator.push(viewModel, animated: true)
                    }
                }
            }
        }
        
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            headClick()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard UIApplication.shared.applicationState != .background else { return }
        commentLabel.textLayout = commentLabel.textLayout
    }
}

extension YXCommentHeaderCell {
    
    @objc func shareAction(_ sender: QMUIButton) {
        if let model = model {
            let content:String = YXToolUtility.reverseTransformHtmlString(model.content) ?? ""
            let dic:[String:String] = ["post_id":model.post_id, "post_type":"5", "share_content":content]
            
            toolBarButtonBlock?(dic, .share, model)
        }
    }
    
    @objc func commentAction(_ sender: QMUIButton) {
        if let model = model {
            var post_type:String = String(YXInformationFlowType.stockdiscuss.rawValue)
            if model.source_type == 1 {
                post_type = String(YXInformationFlowType.imageText.rawValue)
            }
            let dic:[String:String] = ["post_id":model.post_id, "post_type":post_type]
            toolBarButtonBlock?(dic, .comment, model)
        }
    }
    
//    @objc func likeAction(_ sender: QMUIButton) {
//        if let model = model {
//            if !YXUserManager.isLogin()  {
//                YXToolUtility.handleBusinessWithLogin {
//
//                }
//                return
//            }
//            sender.isEnabled = false
//            if !model.like_flag {
//                let animationView = LOTAnimationView(name: "comment_like")
//                animationView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
//                animationView.center = self.likeImageView.center
//                animationView.loopAnimation = false
//                animationView.completionBlock = { [weak self] (_) in
//                    animationView.removeFromSuperview()
//                    self?.likeImageView.isHidden = false
//                }
//                likeButton.addSubview(animationView)
//
//                self.likeImageView.isHidden = true
//                animationView.play()
//            }
//
//            let opration:Int = (model.like_flag) ? -1 : 1
//            var post_type:Int = YXInformationFlowType.stockdiscuss.rawValue
//            if model.source_type == 1 {
//                post_type = YXInformationFlowType.imageText.rawValue
//            }
//
//            YXUGCCommentManager.queryLike(direction: opration, bizId: model.post_id, bizPreFix: YXLikeBizPreFix.post, postType: post_type) {  [weak self] success, count in
//                guard let `self` = self else { return }
//
//                if success {
//                    model.like_flag = !model.like_flag
//                    model.likeCount = count
//                    self.updateLikeCount()
//                }
//
//                sender.isEnabled = true
//            }
//        }
//
//    }
    
    @objc func likeAction(_ sender: QMUIButton) {
        
        if let model = model {
            if !YXUserManager.isLogin()  {
                if let root = UIApplication.shared.delegate as? YXAppDelegate {
                    let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: nil, vc: nil))
                    root.navigator.push(YXModulePaths.defaultLogin.url, context: context)
                }
                return
            } else if model.source_type == 4 {
                if model.jump_type == 1 {
                    if model.jump_url.count ?? 0 > 0 {
                        YXWebViewModel.pushToWebVC(model.jump_url ?? "")
                    }
                }else if model.jump_type == 2 {
                    if model.jump_url.count ?? 0 > 0 {
                        YXGoToNativeManager.shared.gotoNativeViewController(withUrlString: model.jump_url ?? "")
                    }
                }
                return
            }
            sender.isEnabled = false
            
//            if !model.like_flag {
//                let animationView = LOTAnimationView(name: "comment_like")
//                animationView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
//                animationView.center = self.likeImageView.center
//                animationView.loopAnimation = false
//                animationView.completionBlock = { [weak self] (_) in
//                    animationView.removeFromSuperview()
//                    self?.likeImageView.isHidden = false
//                }
//                likeButton.addSubview(animationView)
//
//                self.likeImageView.isHidden = true
//                animationView.play()
//            }
            
            let opration:Int = (model.like_flag) ? -1 : 1
            var itemType:Int = 1
//            if let reply = model.replied_data, reply.content.count > 0 {
//                itemType = 3
//            }
            YXSquareCommentManager.queryLikeOpration(itemType: itemType, itemId: model.post_id, opration: opration) { [weak self] success, count, isDelete in
                guard let `self` = self else { return }
                if success {
                    model.like_flag = !model.like_flag
                    model.likeCount = Int64(count) ?? 0
                    self.updateLikeCount()
                }
//                if isDelete {
//                    let paramDic =  ["post_id":self.postId]
//                    self.commentButtonBlock?(paramDic, .postIsDeleted)
//                }
                sender.isEnabled = true
            }
        }
       
    }

    
    func updateLikeCount() {
        guard let model = model else { return }
        
        if model.likeCount == 0 {
//            likeCountLabel.text = YXLanguageUtility.kLang(key: "comment_like")
            likeCountLabel.text = ""
            likeImageView.image = UIImage(named: "theme_ygc_like_big")
            likeCountLabel.textColor = QMUITheme().textColorLevel1()
        }else{
            if model.like_flag {
                likeImageView.image = UIImage(named: "ygc_liked")
                likeCountLabel.textColor = QMUITheme().textColorLevel1()
            }else{
                likeImageView.image = UIImage(named: "theme_ygc_like_big")
                likeCountLabel.textColor = QMUITheme().textColorLevel1()
            }
            likeCountLabel.text = YXSquareCommentManager.transformCount(count: model.likeCount)
        }
    }
    
    func updateCommentCount(_ count: Int64) {
//        let string = count > 0 ? "\(count)" : YXLanguageUtility.kLang(key: "comment")
        let string = count > 0 ? "\(count)" : ""
        commentButton.setTitle(string, for: .normal)
    }
}
