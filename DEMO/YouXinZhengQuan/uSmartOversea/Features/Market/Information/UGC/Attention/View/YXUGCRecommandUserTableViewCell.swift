//
//  YXUGCRecommandUserTableViewCell.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/29.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXUGCRecommandUserTableViewCell: UITableViewCell {
    
    var attentionBlock:(() -> Void)?
    
    var isAttentioned:Bool = false  //是关注还是粉丝
    
    lazy var photoBtn:QMUIButton = {
        let btn = QMUIButton()
        btn.qmui_tapBlock = { [weak self] (_) in
            guard let `self` = self else { return }
            self.gotoUserCenter()
        }
        return btn
    }()
    
    lazy var phoneImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 26
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
  
    lazy var authBtn:QMUIButton = {
        let btn = QMUIButton()
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        btn.setTitle(YXLanguageUtility.kLang(key: "had_authed"), for: .normal)
        btn.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        btn.setImage(UIImage.init(named: "authed_icon"), for: .normal)
        btn.isHidden = true
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.titleLabel?.minimumScaleFactor = 0.5
        btn.titleLabel?.baselineAdjustment = .alignCenters
        return btn
    }()
   
    
    lazy var titleLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    lazy var subTitleLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
 

    lazy var attentionButton:QMUIButton = {
        let btn = QMUIButton()
        btn.setTitle(YXLanguageUtility.kLang(key: "ugc_attention"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = QMUITheme().themeTextColor().withAlphaComponent(0.1)
        btn.layer.cornerRadius = 12
        btn.layer.masksToBounds = true
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.titleLabel?.minimumScaleFactor = 0.5
        btn.titleLabel?.baselineAdjustment = .alignCenters
        btn.qmui_tapBlock = { [weak self] (_) in
            guard let `self` = self else { return }
            self.reqAttentionData()
        }
       
        
        return btn
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
        backgroundColor = QMUITheme().foregroundColor()
        contentView.backgroundColor = QMUITheme().foregroundColor()
        contentView.addSubview(phoneImageView)
        contentView.addSubview(authBtn)
      
        contentView.addSubview(titleLabel)
     
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(photoBtn)
        contentView.addSubview(attentionButton)
        
        phoneImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(12)
            make.width.height.equalTo(52)
        }
    
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(phoneImageView.snp.centerY).offset(-12)
            make.left.equalTo(phoneImageView.snp.right).offset(12)
            make.height.equalTo(25)
        }
     
        authBtn.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.right).offset(6)
            make.right.lessThanOrEqualTo(attentionButton.snp.left).offset(-5)
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.width.equalTo(55)
        }
        subTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.left)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.right.equalTo(attentionButton.snp.left).offset(-5)
        }
        photoBtn.snp.makeConstraints { make in
            make.left.equalTo(phoneImageView)
            make.top.equalTo(phoneImageView)
            make.right.equalTo(authBtn.snp.right)
            make.height.equalTo(phoneImageView)
        }
        attentionButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalTo(phoneImageView.snp.centerY)
            make.width.equalTo(66)
            make.height.equalTo(24)
        }
    }
 
    func reqAttentionData() {
        if (!YXUserManager.isLogin()) {
            YXToolUtility.handleBusinessWithLogin {
                
            }
            return
        }

        if let model = attentionFunsItemModel {
            let focus_status:Int = ( model.follow_status != .none ) ? 2 : 1
            
            if focus_status == 2 {
                YXSquareCommentManager.sureAgainAlert(title: YXLanguageUtility.kLang(key: "confirm_no_follow"), okText: YXLanguageUtility.kLang(key: "common_confirm"), cancelText: YXLanguageUtility.kLang(key: "common_cancel")) {
                    
                    YXUGCCommentManager.queryAttention(bizType: 1, focusStatus: focus_status, targetUid: model.uid) {[weak self] ( isSuccss, followStatus) in
                        guard let `self` = self else { return }
                        
                        if isSuccss {
                            self.updateAttentionButtonUI(followStatus: followStatus)
                        }
                    }
                }
                
                return
            }
            
            YXUGCCommentManager.queryAttention(bizType: 1, focusStatus: focus_status, targetUid: model.uid) {[weak self] ( isSuccss, followStatus) in
                guard let `self` = self else { return }
                
                if isSuccss {
                    self.updateAttentionButtonUI(followStatus: followStatus)
//                    YXSensorAnalyticsTrack.track(withEvent: .ViewClick, properties: [
//                        YXSensorAnalyticsPropsConstant.PROP_VIEW_PAGE : "盈财经-关注",
//                        YXSensorAnalyticsPropsConstant.PROP_VIEW_NAME : "关注推荐用户",
//                        YXSensorAnalyticsPropsConstant.PROP_USER_ID : model.uid,
//                    ])
                }
            }
        }
    }
    
    func noAttentionUI() {
        self.attentionButton.backgroundColor = QMUITheme().themeTextColor().withAlphaComponent(0.1)
        self.attentionButton.setTitle(YXLanguageUtility.kLang(key: "ugc_attention"), for: .normal)
        self.attentionButton.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
    }
    
    func attentionedUI() {
      
        self.attentionButton.backgroundColor = QMUITheme().itemBorderColor().withAlphaComponent(0.5)
        self.attentionButton.setTitle(YXLanguageUtility.kLang(key: "ugc_attentioned"), for: .normal)
        
        self.attentionButton.setTitleColor(.white, for: .normal)
    }
    
    func attentionEachOtherUI() {
        self.attentionButton.backgroundColor = QMUITheme().itemBorderColor().withAlphaComponent(0.5)
        self.attentionButton.setTitle(YXLanguageUtility.kLang(key: "ugc_attentionedEachother"), for: .normal)
        self.attentionButton.setTitleColor(.white, for: .normal)
     
    }

    var attentionFunsItemModel:YXUserAttentionItemModel? {
        didSet {
            refreshUIInAttentionVc()
        }
    }
    func refreshUIInAttentionVc() {
        if let model = attentionFunsItemModel {
            self.phoneImageView.sd_setImage(with: URL.init(string: model.avatar ), placeholderImage: UIImage.init(named: "nav_user"), options: [], context: [:])
            self.titleLabel.text = model.nick_name
            let profile: String = YXToolUtility.moveEnterSymbol(model.profile, with: " ")
            self.subTitleLabel.text =  profile
            
            self.authBtn.isHidden = !model.auth_user

            
            if profile.count > 0 {
                titleLabel.snp.updateConstraints { (make) in
                    make.centerY.equalTo(phoneImageView.snp.centerY).offset(-12)
                }
            }else{
                titleLabel.snp.updateConstraints { (make) in
                    make.centerY.equalTo(phoneImageView.snp.centerY).offset(0)
                }
            }

            self.attentionButton.isHidden = YXSquareCommentManager.isMyUserId(uid: model.uid)

            if model.follow_status == .attentioned {
                attentionedUI()
            }else if model.follow_status == .eachOther {
                attentionEachOtherUI()
            }else{
                noAttentionUI()
            }
        }
       
    }
    
    func updateAttentionButtonUI(followStatus:YXFollowStatus) {
        guard let model = self.attentionFunsItemModel else {
            return
        }
        if followStatus == .attentioned {
            model.follow_status = .attentioned
            YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "sub_success"))
            self.attentionedUI()
        }else if followStatus == .none{
            model.follow_status = .none
            YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "sub_failure"))
            self.noAttentionUI()
        }else if followStatus == .eachOther{
            model.follow_status = .eachOther
            YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "sub_success"))
            self.attentionEachOtherUI()
        }
    }
    
    private func gotoUserCenter() {
        if let attentModel = self.attentionFunsItemModel {
            YXUGCCommentManager.gotoUserCenter(uid: attentModel.uid )
        }
    }
    

}
