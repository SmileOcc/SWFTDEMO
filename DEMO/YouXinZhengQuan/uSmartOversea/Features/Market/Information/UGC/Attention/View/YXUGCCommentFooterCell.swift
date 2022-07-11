//
//  YXUGCCommentFooterCell.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/8/18.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXUGCCommentFooterCell: UICollectionViewCell {
    
    typealias ClickActionBlock = (_ type: CommentButtonType) -> Void
    var toolBarButtonBlock: ClickActionBlock?
    
    typealias ShowMoreBlock = () -> Void
    
    var showMoreBlock: ShowMoreBlock?
    
    //点击了点赞
    var didLikeAction: (( _ likeFlag: Bool, _ likeCount: Int64) -> Void)?
    
    var buttons = [QMUIButton]()
    
    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor =  QMUITheme().textColorLevel1().withAlphaComponent(0.03)
        view.isHidden = true
        return view
    }()
    
    lazy var moreReplyButton: YXExpandAreaButton = {
        let btn = YXExpandAreaButton()
        btn.expandX = 15
        btn.expandY = 15
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "more_comment_open"), for: .normal)
        btn.addTarget(self, action: #selector(showMoreReplyAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var buttonBgView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var timeLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    //点赞
    lazy var likeButton: QMUIButton = {
        let btn = QMUIButton()
        btn.addTarget(self, action: #selector(likeAction(_:)), for: .touchUpInside)
        btn.setImage(UIImage.init(named: "theme_ygc_like_big"), for: .normal)
        btn.setImage(UIImage.init(named: "ygc_liked"), for: .selected)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        btn.setTitleColor(QMUITheme().textColorLevel1(), for: .selected)
        btn.spacingBetweenImageAndTitle = 8
        return btn
    }()
    
    lazy var commentButton: QMUIButton = {
        let btn = QMUIButton()
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        btn.setImage(UIImage(named: "ygc_comment"), for: .normal)
        btn.spacingBetweenImageAndTitle = 8
        btn.addTarget(self, action: #selector(commentAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(buttonBgView)
        contentView.addSubview(bgView)
        bgView.addSubview(moreReplyButton)

        buttonBgView.addSubview(likeButton)
        buttonBgView.addSubview(commentButton)
        buttonBgView.addSubview(timeLabel)
        
        bgView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(56)
            make.right.equalToSuperview().offset(-13)
            make.height.equalTo(28)
        }
        moreReplyButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(44)
            make.bottom.equalToSuperview().offset(-12)
            make.top.equalToSuperview()
        }
        
        buttonBgView.snp.makeConstraints { (make) in
            make.height.equalTo(25)
            make.left.equalToSuperview().offset(56)
            make.bottom.equalToSuperview().offset(-10)
            make.right.equalToSuperview().offset(-13)
        }
             
        timeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(0)
        }
        
        likeButton.snp.makeConstraints { make in
            make.centerY.equalTo(timeLabel)
            make.right.equalTo(commentButton.snp.left).offset(-30)
//            make.width.equalTo(66)
        }
        
        commentButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalTo(timeLabel)
        }
     
    }
    
    var commentData: YXCommentDetailCommentModel? {
        didSet {
            if let model = commentData {
//                timeLabel.text = YXDateHelper.commonDateString(model.create_time, format: .DF_MDYHMS)
                timeLabel.text =  YXToolUtility.compareCurrentTime(model.create_time)
//                [YXToolUtility compareCurrentTime:headerModel.create_time];
            }
        }
    }
    
    var likeType:YXLikeBizPreFix = .post //点赞的类型
    var postId: String = ""
    var commentId: String = ""
    var postType: YXInformationFlowType = .stockdiscuss
   
    private var likeFlag: Bool = false
    //MARK:关注界面用
    func updateAttentionUI(showMoreReply:Bool, likeFlag: Bool, likeCount: Int64) {
        if showMoreReply {
            bgView.isHidden = false
            moreReplyButton.isHidden = false
        }else{
            bgView.isHidden = true
            moreReplyButton.isHidden = true
        }
        updateLikeCount(likeFlag: likeFlag, likeCount: likeCount)
    }

    func updateCommentCount(_ count: Int64) {
        if count > 0 {
            commentButton.setTitle("\(count)", for: .normal)
        } else {
            commentButton.setTitle("", for: .normal)
        }
    }

    //MARK:个股详情
    @objc func showMoreReplyAction(_ sender: YXExpandAreaButton) {
        self.showMoreBlock?()
    }
    
    private func updateLikeCount(likeFlag: Bool, likeCount: Int64) {
        self.likeFlag = likeFlag
        if likeCount > 0 {
            if likeFlag {
                likeButton.isSelected = true
                likeButton.setTitle(YXSquareCommentManager.transformCount(count: likeCount), for: .selected)
            }else{
                likeButton.isSelected = false
                likeButton.setTitle(YXSquareCommentManager.transformCount(count: likeCount), for: .normal)
            }
            likeButton.setTitle(YXSquareCommentManager.transformCount(count: likeCount), for: .normal)
        } else {
            likeButton.isSelected = false
            likeButton.setTitle("", for: .normal)
        }
    }
    
    @objc func likeAction(_ sender: QMUIButton) {
        if !YXUserManager.isLogin()  {
            YXToolUtility.handleBusinessWithLogin { [weak self] in
                guard let `self` = self else { return }
                self.likeReqHandle()
                
            }
            return
        }
        sender.isSelected = !sender.isSelected
        sender.isEnabled = false
        self.likeReqHandle()
        
    }
    
    private func likeReqHandle() {
        
        if !self.likeFlag {
        }
        
        let opration:Int = (self.likeFlag) ? 0 : 1
        var itemType:Int = 2
        
        YXSquareCommentManager.queryLikeOpration(itemType: itemType, itemId: self.commentId, opration: opration) { [weak self] success, count, isDelete in
            guard let `self` = self else { return }
            if success {
                self.likeFlag = !self.likeFlag
                self.updateLikeCount(likeFlag: self.likeFlag, likeCount: Int64(count) ?? 0)
                self.didLikeAction?(self.likeFlag, Int64(count) ?? 0)
            }
            self.likeButton.isEnabled = true
        }
    }
    
    @objc func commentAction(_ sender: QMUIButton) {
        self.toolBarButtonBlock?(.comment)
    }
    
    @objc func shareAction(_ sender: QMUIButton) {
        self.toolBarButtonBlock?(.share)
    }
 
}
