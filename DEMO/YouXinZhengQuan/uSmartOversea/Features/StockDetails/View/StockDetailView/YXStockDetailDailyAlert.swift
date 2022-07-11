//
//  YXStockDetailDailyAlert.swift
//  uSmartOversea
//
//  Created by youxin on 2020/8/20.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXStockDetailDailyAuthorityView: UIView {

    var market: String = ""

    @objc func showAlertView() {

        self.contentView.isHidden = false
        self.alpha = 0.0
        self.contentView.transform = CGAffineTransform.init(scaleX: 0, y: 0)
        UIView.animate(withDuration: 0.3, animations: {
            self.contentView.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            self.alpha = 1.0
        }) { (_) in
            self.contentView.transform = CGAffineTransform.identity
        }
    }

    @objc func hideAlertView() {
        self.alpha = 1.0
        self.contentView.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0.0
            self.contentView.transform = CGAffineTransform.init(scaleX: 0.0, y: 0.0)
        }) { (_) in
            self.removeFromSuperview()
            self.isHidden = true
        }
    }

    init(frame: CGRect, market: String, superview: UIView) {
        super.init(frame: frame)
        self.market = market
        superview.addSubview(self)
        self.frame = superview.bounds
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        addSubview(contentView)
    }

    lazy var contentView: YXStockDetailDailyAlert = {
        let width: CGFloat = 310
        let height: CGFloat = (YXUserManager.isENMode()) ? 450 : 400

        let x = (self.bounds.width - width) / 2.0
        let y = (self.bounds.height - height) / 2.0
        let view = YXStockDetailDailyAlert.init(frame: CGRect(x: x, y: y, width: width, height: height), market: self.market)
        view.isHidden = true
        view.closeClosure = {
            [weak self] in
            guard let `self` = self else { return }
            self.hideAlertView()
        }
        return view
    }()

    lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().textColorLevel1().withAlphaComponent(0.2)
        view.rx.tapGesture().subscribe(onNext: {
            [weak self] ges in
            guard let `self` = self else { return }
            if ges.state == .ended {
                self.hideAlertView()
            }

        }).disposed(by: rx.disposeBag)
        return view
    }()
}



class YXStockDetailDailyAlert: UIView {

    @objc var upgradeMarginClosure: (() -> Void)? //保证金
    @objc var openMarginClosure: (() -> Void)?  //日内融
    @objc var aboutClosure: (() -> Void)?
    @objc var closeClosure: (() -> Void)?

    var isOpenMarginAccount = false

    //MARK: Show Or Hide

    init(frame: CGRect, market: String) {
        super.init(frame: frame)
        isOpenMarginAccount = YXUserManager.isFinancing(market: market)
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {

        self.backgroundColor = QMUITheme().foregroundColor()
        self.layer.cornerRadius = 10

        addSubview(titleLabel)
        addSubview(closeButton)
        addSubview(authorityImageView)
        addSubview(authorityLabel)
        addSubview(stepOneLabel)
        addSubview(stepTwoLabel)
        addSubview(stepOneButton)
        addSubview(stepTwoButton)
        addSubview(aboutLabel)

        closeButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(20)
            make.right.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(15)
        }

        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.right.lessThanOrEqualTo(closeButton.snp.left)
            make.left.greaterThanOrEqualToSuperview().offset(20)
        }

        authorityImageView.snp.makeConstraints { (make) in
            make.width.equalTo(130)
            make.height.equalTo(120)
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
        }

        authorityLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(authorityImageView.snp.bottom).offset(14)
        }

        let circleOne = UIView()
        circleOne.backgroundColor = QMUITheme().themeTextColor()
        circleOne.layer.cornerRadius = 3.5
        self.addSubview(circleOne)

        let circleTwo = UIView()
        circleTwo.backgroundColor = QMUITheme().themeTextColor()
        circleTwo.layer.cornerRadius = 3.5
        self.addSubview(circleTwo)

        let lineView = UIView()
        lineView.backgroundColor = UIColor.qmui_color(withHexString: "#979797")
        self.addSubview(lineView)

        circleOne.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(14)
            make.width.height.equalTo(7)
            make.top.equalTo(authorityLabel.snp.bottom).offset(35)
        }

        lineView.snp.makeConstraints { (make) in
            make.centerX.equalTo(circleOne)
            make.width.equalTo(1)
            make.height.equalTo(50)
            make.top.equalTo(circleOne.snp.bottom)
        }

        circleTwo.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(14)
            make.width.height.equalTo(7)
            make.top.equalTo(lineView.snp.bottom)
        } 

        stepOneButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(circleOne)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(25)
            if (YXUserManager.isENMode()) {
                make.width.equalTo(100)
            } else {
                make.width.equalTo(80)
            }
        }

        stepOneLabel.snp.makeConstraints { (make) in
            make.top.equalTo(stepOneButton.snp.top).offset(3)
            make.left.equalTo(circleOne.snp.right).offset(7)
            make.right.lessThanOrEqualTo(stepOneButton.snp.left).offset(-5)
        }


        stepTwoButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(circleTwo)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(25)
            if (YXUserManager.isENMode()) {
                make.width.equalTo(100)
            } else {
                make.width.equalTo(80)
            }

        }

        stepTwoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(stepTwoButton.snp.top).offset(3)
            make.left.equalTo(circleTwo.snp.right).offset(7)
            make.right.lessThanOrEqualTo(stepTwoButton.snp.left).offset(-5)
        }

        aboutLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(stepTwoLabel.snp.bottom).offset(30)
        }

    }

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        label.text = YXLanguageUtility.kLang(key: "daily_margin_trade")
        return label
    }()

    lazy var authorityImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.image = UIImage(named: "no_authority")
        return imageView
    }()

    lazy var authorityLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.text = YXLanguageUtility.kLang(key: "daily_margin_trade_alert")
        return label
    }()

    lazy var closeButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setImage(UIImage(named: "nav_close"), for: .normal)
        button.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        return button
    }()

    @objc func closeAction() {
        self.closeClosure?()
    }


    lazy var stepOneLabel: UILabel = {
        let label = UILabel()
        if YXUserManager.isENMode() {
            label.numberOfLines = 2
        } else {
            label.numberOfLines = 1
        }
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        return label
    }()

    lazy var stepTwoLabel: UILabel = {
        let label = UILabel()
        if YXUserManager.isENMode() {
            label.numberOfLines = 2
        } else {
            label.numberOfLines = 1
        }
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        return label
    }()

    lazy var stepOneButton: QMUIButton = {
        let button = QMUIButton()

        if self.isOpenMarginAccount {

            button.setTitle(YXLanguageUtility.kLang(key: "already_upgrade"), for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            button.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
            button.imagePosition = .right
            button.spacingBetweenImageAndTitle = 5.0
            button.setImage(UIImage(named: "tag_confirm"), for: .normal)
        } else {
            button.setTitle(YXLanguageUtility.kLang(key: "upgrade_immediately"), for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
            button.backgroundColor = QMUITheme().themeTextColor()
            button.layer.cornerRadius = 12.5
            button.layer.masksToBounds = true
            button.addTarget(self, action: #selector(openMarginAccount), for: .touchUpInside)
        }
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.3
        
        return button
    }()

    lazy var stepTwoButton: QMUIButton = {
        let button = QMUIButton()
        button.setTitle(YXLanguageUtility.kLang(key: "common_open_now"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)

        if self.isOpenMarginAccount {
            button.backgroundColor = QMUITheme().themeTextColor()
            button.addTarget(self, action: #selector(openDailyMarginAccount), for: .touchUpInside)
        } else {
            button.backgroundColor = QMUITheme().textColorLevel3()
        }
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.3
        button.layer.cornerRadius = 12.5
        button.layer.masksToBounds = true
        return button
    }()

    @objc func openMarginAccount() {
        self.closeClosure?()
        self.upgradeMarginClosure?()
    }

    @objc func openDailyMarginAccount() {
        self.closeClosure?()
        self.openMarginClosure?()
    }

    lazy var aboutLabel: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        let attributeString = NSMutableAttributedString.init(string: YXLanguageUtility.kLang(key: "about_daily_margin"), attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel3(), NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue])
        button.setAttributedTitle(attributeString, for: .normal)
        button.addTarget(self, action: #selector(aboutAction), for: .touchUpInside)
        return button
    }()

    @objc func aboutAction() {
        self.aboutClosure?()
    }


}
