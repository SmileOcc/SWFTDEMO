//
//  YXCommentUserView.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/6/5.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXCommentUserView: UIView {
    var attentionedBlock:((_ uid:String) -> Void)?
    
    var photoBtn:QMUIButton = {
        let btn = QMUIButton()
        btn.addTarget(self, action: #selector(phoneAction(_ :)), for: .touchUpInside)
        
        return btn
    }()
    
    var isWhiteSkin: Bool = false {
        didSet {
            nickNameLabel.textColor = isWhiteSkin ? QMUITheme().textColorLevel1() : QMUITheme().textColorLevel1()
            timeLabel.textColor = isWhiteSkin ? QMUITheme().textColorLevel3() : QMUITheme().textColorLevel3()
        }
    }
    
    lazy var phoneView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        
        return imageView
    }()
    
    lazy var levelImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage.init(named: "da_V")
        return imageView
    }()
    
    lazy var nickNameLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    
    lazy var timeLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    lazy var attentionBtn: YXExpandAreaButton = {
        let btn = YXExpandAreaButton()
        btn.expandX = 20
        btn.expandY = 20
        btn.setTitle("+关注", for: .normal)
        btn.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.addTarget(self, action: #selector(attentionAction(_:)), for: .touchUpInside)
        btn.isHidden = true
        return btn
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCommonUI()
    }
    
    convenience init(frame:CGRect, hadRightBtn:Bool) {
        self.init()
        
        setupCommonUI()
        if hadRightBtn {
            attentionBtn.isHidden = false
        }else{
            attentionBtn.isHidden = true

        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCommonUI() {
        addSubview(phoneView)
        addSubview(levelImageView)
        addSubview(nickNameLabel)
        addSubview(timeLabel)
        addSubview(photoBtn)
        addSubview(attentionBtn)
        phoneView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.width.height.equalTo(40)
        }
 
        nickNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(phoneView.snp.top)
            make.left.equalTo(phoneView.snp.right).offset(8)
            make.height.equalTo(20)
        }
        
        levelImageView.snp.makeConstraints { (make) in
            make.bottom.equalTo(phoneView.snp.bottom)
            make.right.equalTo(phoneView.snp.right)
            make.width.height.equalTo(12)
        }

        timeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nickNameLabel.snp.left)
            make.bottom.equalTo(phoneView.snp.bottom)
        }
        
        photoBtn.snp.makeConstraints { make in
            make.left.equalTo(phoneView)
            make.top.equalTo(phoneView)
            make.right.equalTo(nickNameLabel.snp.right)
            make.height.equalTo(phoneView)
        }
        attentionBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
            make.top.equalTo(nickNameLabel.snp.top)
            make.height.equalTo(20)
        }
        
    }

    var model:YXCreateUserModel?
    
    func updateUI(model:YXCreateUserModel?, createTime:String, followStates:Int) {
        self.model = model
        self.commonUIUpdate(model: model)

        self.timeLabel.text = YXToolUtility.compareCurrentTime(createTime)
      
    }
    
    func commonUIUpdate(model:YXCreateUserModel?) {
        
        self.phoneView.sd_setImage(with: URL.init(string: model?.avatar ?? "" ), placeholderImage: UIImage.init(named:"user_default_photo"), options: [], context: [:])
        self.nickNameLabel.text = model?.nickName
        
        if let user = self.model {
            self.levelImageView.isHidden = !user.auth_user
        }else{
            self.levelImageView.isHidden = true
        }
       
    }
    
    @objc func attentionAction(_ sender: YXExpandAreaButton) {
        
        if let uid = model?.uid {
            YXToolUtility.handleBusinessWithLogin {
                [weak self] in
                guard let `self` = self else { return }
                YXUGCCommentManager.queryAttention(bizType: 1, focusStatus: 1, targetUid: uid) { [weak self] ( isSuc , _) in
                    guard let `self` = self else { return }
                    if isSuc {
                        YXProgressHUD.showMessage("关注成功")
                        self.attentionBtn.setTitle("已关注", for: .normal)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                            guard let `self` = self else { return }
                            self.attentionBtn.isHidden = true
                            self.attentionedBlock?(uid)
                        }
                        
//                        if UIViewController.current().description == YXStockDetailViewController.description() {
//                            YXSensorAnalyticsTrack.track(withEvent: .ViewClick, properties: [
//                                YXSensorAnalyticsPropsConstant.PROP_VIEW_PAGE: "个股详情页",
//                                YXSensorAnalyticsPropsConstant.PROP_VIEW_NAME: "点击关注",
//                                YXSensorAnalyticsPropsConstant.PROP_ID: uid,
//                            ]);
//                        }
                    }
                }
            }
        }
       
    }
    
    
    @objc func phoneAction(_ sender: QMUIButton) {
        if let model = self.model {
            YXUGCCommentManager.gotoUserCenter(uid: model.uid )
                        
//            if UIViewController.current().description == YXStockDetailViewController.description() {
//                YXSensorAnalyticsTrack.track(withEvent: .ViewClick, properties: [
//                    YXSensorAnalyticsPropsConstant.PROP_VIEW_PAGE: "个股详情页",
//                    YXSensorAnalyticsPropsConstant.PROP_VIEW_NAME: "点击用户头像",
//                    YXSensorAnalyticsPropsConstant.PROP_ID: model.uid,
//                ]);
//            }
        }
    }
    
    
    
}
