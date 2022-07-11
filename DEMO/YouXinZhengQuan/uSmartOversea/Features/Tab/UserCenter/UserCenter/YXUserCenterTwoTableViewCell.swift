//
//  YXUserCenterTwoTableViewCell.swift
//  uSmartOversea
//
//  Created by Mac on 2019/12/31.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXUserCenterTwoTableViewCell: UITableViewCell {
    //獎品中心
    let couponView = YXUserCenterItemView(imgName: "user_coupon", title: YXLanguageUtility.kLang(key: "user_coupon"))
    //佣金詳情
    let yongjinView = YXUserCenterItemView(imgName: "user_yongjin", title: YXLanguageUtility.kLang(key: "user_yongjin"))
    //我的收藏
    let colletView = YXUserCenterItemView(imgName: "user_collet", title: YXLanguageUtility.kLang(key: "user_collet"))
    //我的報價
    let marketView = YXUserCenterItemView(imgName: "user_mymarket", title: YXLanguageUtility.kLang(key: "user_mymarket"))
    //關於uSMART
    let aboutView = YXUserCenterItemView(imgName: "user_about", title: YXLanguageUtility.kLang(key: "user_about"))
    //幫助與客服
    let helpView = YXUserCenterItemView(imgName: "user_help", title: YXLanguageUtility.kLang(key: "user_help"))
    //意見反映
    let feedbackView = YXUserCenterItemView(imgName: "user_feedback", title: YXLanguageUtility.kLang(key: "user_feedback"))
    //風險評估
    let riskView = YXUserCenterItemView(imgName: "risk_assessment", title: YXLanguageUtility.kLang(key: "risk_assessment"))
    //我的课程
    lazy var myCourseView = YXUserCenterItemView(imgName: "user_my_course", title: YXLanguageUtility.kLang(key: "news_course_my_course"))
    //我的专属服务
    lazy var myExclusiveService = YXUserCenterItemView(imgName: "user_exclusive_service", title: YXLanguageUtility.kLang(key: "mine_exclusive_service"))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.initialUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initialUI()  {
        let horSpace: CGFloat = 18.0
        let viewWidth: CGFloat = (YXConstant.screenWidth - horSpace * 2) / 2.0
        
        var itemArr = [
            couponView,     yongjinView,
            colletView,     marketView,
            aboutView,      helpView,
            myExclusiveService, feedbackView,
            riskView,
        ]
        if YXUserManager.curLanguage() == .HK || YXUserManager.curLanguage() == .CN {
            itemArr = [
                couponView,     yongjinView,
                colletView,     marketView,
                myCourseView,   helpView,
                myExclusiveService, aboutView,
                riskView, feedbackView
            ]
        }
        
        for (idx, view) in itemArr.enumerated() {
            
            let yushu = CGFloat(idx % 2)
            let zhengshu = CGFloat(idx / 2)
            contentView.addSubview(view)
            view.frame = CGRect(x: viewWidth*yushu + horSpace, y: 10.0 + 52.0 * zhengshu, width: viewWidth, height: 52)
        }
    }
    
    func refreshUI(with list: [YXQueryCopywritListModel]) {
        //先置空
        self.couponView.refresh(with: "")
        self.yongjinView.refresh(with: "")
        self.marketView.refresh(with: "")
        
        if list.count > 0 {
            
            for model in list {
                switch model.positionID {
                case 1: //登录按钮
                    break
                case 2: //奖励中心
                    self.couponView.refresh(with: model.copyDesc)
                case 3: //晒单动态
                    break
                case 4: //我的拥金
                    self.yongjinView.refresh(with: model.copyDesc)
                case 5: //我的行情
                    self.marketView.refresh(with: model.copyDesc)
                default:
                    break
                }
            }
            
        }
        
        self.couponView.redDot.isHidden = YXLittleRedDotManager.shared.isHiddenNewCoupon()
        
    }
}

class YXUserCenterItemView: UIView {
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        addSubview(iv)
        return iv
    }()
    
    //标题
    lazy var titleLab: QMUILabel = {
        let lab = QMUILabel()
        lab.numberOfLines = 1
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.textAlignment = .left
        lab.textColor = QMUITheme().textColorLevel1()
        lab.adjustsFontSizeToFitWidth = true
        lab.minimumScaleFactor = 0.3
        addSubview(lab)
        return lab
    }()
    
    //副标题
    lazy var subTitleLab: QMUILabel = {
        let lab = QMUILabel()
        lab.numberOfLines = 1
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.textAlignment = .left
        lab.textColor = QMUITheme().textColorLevel3()
        addSubview(lab)
        return lab
    }()
    
    //小红点
    lazy var redDot: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().sell()
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        view.isHidden = true
        addSubview(view)
        return view
    }()
    
    //点击按钮
    private var clickBtn: UIButton = {
        let btn = UIButton(type: .custom)
        return btn
    }()
    
    var clickBtnBlock: ( () -> () )? //跳转响应
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
            make.height.width.equalTo(30)
        }

        titleLab.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(imageView.snp.right).offset(10)
            make.right.lessThanOrEqualToSuperview()
        }
        
        redDot.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLab.snp.top)
            make.left.equalTo(titleLab.snp.right)
            make.width.height.equalTo(8.0)
        }

        addSubview(clickBtn)
        clickBtn.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        self.clickBtn.rx.tap.subscribe(onNext: {[weak self] (_) in
            guard let `self` = self else { return }
            
            if let block = self.clickBtnBlock {
                block()
            }
        }).disposed(by: self.rx.disposeBag)
    }
    
    convenience init(imgName: String, title: String) {
        self.init(frame: .zero)
        
        imageView.image = UIImage(named: imgName)
        titleLab.text = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refresh(with subTitle:String?) {
        
        
        if let sub = subTitle, sub.count > 0 {
            titleLab.snp.remakeConstraints { (make) in
                make.top.equalTo(imageView)
                make.left.equalTo(imageView.snp.right).offset(10)
                make.right.lessThanOrEqualToSuperview()
            }
            subTitleLab.snp.makeConstraints { (make) in
                make.top.equalTo(titleLab.snp.bottom)
                make.left.equalTo(imageView.snp.right).offset(10)
                make.right.equalToSuperview()
            }
            subTitleLab.isHidden = false
            subTitleLab.text = subTitle
        } else {
            subTitleLab.isHidden = true
            titleLab.snp.remakeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(imageView.snp.right).offset(10)
                make.right.lessThanOrEqualToSuperview()
            }
        }
    }
    
}
