//
//  YXCommentDetailCommentCollectionViewCell.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/26.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXCommentDetailCommentCollectionViewCell: UICollectionViewCell {
    typealias CommentButtonBlock = (_ paramsDic:[String:String], _ type:CommentButtonType ) -> Void
    var commentButtonBlock:CommentButtonBlock?

    var postId:String = ""
    var post_type:String = ""
    
    lazy var nickNameLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    lazy var phoneView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.init(named:"user_default_photo")
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        
        return imageView
    }()
    
    lazy var levelImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage.init(named: "da_V")
        return imageView
    }()
    
    
    lazy var detailButton: YXExpandAreaButton = {
        let btn = YXExpandAreaButton()
        btn.expandX = 20
        btn.expandY = 20
        btn.setBackgroundImage(UIImage.init(named:"theme_ygc_more"), for: .normal)
        btn.addTarget(self, action: #selector(detailAction(_:)), for: .touchUpInside)
        
        return btn
    }()
    
    lazy var commentLabel: YYLabel = {
        let label = YYLabel()
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
    
    lazy var popover: YXStockPopover = {

        let pop = YXStockPopover()

        return pop
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
       
        contentView.addSubview(phoneView)
        contentView.addSubview(nickNameLabel)
        contentView.addSubview(levelImageView)
        
        contentView.addSubview(detailButton)
        contentView.addSubview(commentLabel)
        
        contentView.addSubview(imageBGView)

        phoneView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(24)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(32)
        }
 
        nickNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(phoneView)
            make.left.equalTo(phoneView.snp.right).offset(8)
            make.height.equalTo(20)
        }
        
        levelImageView.snp.makeConstraints { (make) in
            make.bottom.equalTo(phoneView)
            make.right.equalTo(phoneView)
            make.width.height.equalTo(12)
        }
        
        commentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nickNameLabel)
            make.right.equalToSuperview().offset(-14)
            make.top.equalTo(phoneView.snp.bottom)
            make.height.equalTo(0)
        }
        
        detailButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(phoneView)
            make.width.height.equalTo(18)
        }
        
        imageBGView.snp.makeConstraints { (make) in
            make.top.equalTo(commentLabel.snp.bottom).offset(4)
            make.left.equalTo(commentLabel.snp.left)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(0)
        }

    }
    
    
    var model:YXCommentDetailCommentModel? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        
        if let creatorUserModel = model?.creator_user {
            phoneView.sd_setImage(with: URL.init(string: creatorUserModel.avatar), placeholderImage: UIImage.init(named:"user_default_photo"), options: [], context: [:])
            nickNameLabel.text = creatorUserModel.nickName
            levelImageView.isHidden = !creatorUserModel.auth_user
        } else {
            levelImageView.isHidden = true
        }
        
        if let model = model {
            
            if let headerlayout = model.commentHeaderLayout {
                commentLabel.textLayout = headerlayout.contentlayout
                
                commentLabel.snp.updateConstraints { make in
                    make.height.equalTo( (headerlayout.contentlayout?.textBoundingRect.maxY ?? 0))
                }
                
                let imageTopMas:CGFloat = model.content.count == 0 ? 0 : 8
                imageBGView.snp.updateConstraints { (make) in
                    make.top.equalTo(commentLabel.snp.bottom).offset(imageTopMas)
                }

                if model.pictures.count > 0 {
                    imageBGView.isHidden = false
                    imageBGView.snp.updateConstraints { make in
                        make.height.equalTo(headerlayout.imageHeight)
                    }
                    var pictures:[String] = []
                    let first:String = model.pictures.first ?? ""
                    pictures.append(first)  //评论里只有一张图
                    
                    imageBGView.updatePicture(pictures: pictures, height: headerlayout.imageHeight, singlePicSize: headerlayout.singleImageSize)
                }else{
                    imageBGView.isHidden = true
                }
            }

        }
    }
    
    @objc func detailAction(_ sender: YXExpandAreaButton) {
        
        YXToolUtility.handleBusinessWithLogin { [weak self] in
            guard let `self` = self else { return }
            if let model = self.model, let uid = model.creator_user?.uid {
                
                var popList: [Int] = []
                
                let userIdDouble: Double = Double(uid) ?? 99
                if  YXUserManager.userUUID() == UInt64(userIdDouble) { //是本人
                    popList = [CommentButtonType.delete.rawValue]
                }else{
                    popList = [CommentButtonType.report.rawValue]
                }
                let view:YXCommentDetailPopView = YXCommentDetailPopView.init(list: popList, isWhiteStyle: true) {
                    [weak self] type in
                    guard let `self` = self else { return }
                    
                    if let model = self.model {
                        let paramDic:[String:String] = ["post_type":self.post_type, "comment_id":model.comment_id]
                        self.commentButtonBlock?(paramDic , CommentButtonType.init(rawValue: type) ?? .report)
                        
                    }
                    self.popover.dismiss()
                }
                self.popover.show(view, from: sender)
            }
        }
    }
   
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}
