//
//  YXQuoteKickTool.swift
//  uSmartOversea
//
//  Created by youxin on 2021/1/21.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXQuoteKickTool: NSObject {

    @objc static let shared = YXQuoteKickTool()

    @objc var isGettingUserLevel = false

    private var isKickToDealy = false
    private var isCurrentReal = false
    
    @objc static let kUSAndIndex = "USAndIndex"

    override init() {
        super.init()

//        self.isKickToDealy = self.isQuoteLevelKickToDelay()
//        self.isCurrentReal = self.currentQuoteLevleIsReal()
//
//        _ = NotificationCenter.default.rx
//            .notification(Notification.Name(rawValue: YXUserManager.notiUpdateUserInfo))
//            .takeUntil(self.rx.deallocated) //页面销毁自动移除通知监听
//            .subscribe(onNext: { [weak self] noti in
//                guard let `self` = self else { return }
//
//                if self.isGettingUserLevel == false {
//                    //用户的通知，处理后台进入前台，实时变为延时的情况
//                    let isRealToDealy = !self.isKickToDealy && self.isQuoteLevelKickToDelay()
//                    //当前为延时，用户主动退出再登录变为实时的情况
//                    let isDelayToReal = !self.isCurrentReal && self.currentQuoteLevleIsReal()
//                    if isRealToDealy || isDelayToReal {
//
//                        self.resetQuoteLevelRequest({
//                            _ in
//
//                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiQuoteKick), object: nil)
//                        })
//                    }
//                }
//
//                self.isKickToDealy = self.isQuoteLevelKickToDelay()
//                self.isCurrentReal = self.currentQuoteLevleIsReal()
//
//            }).disposed(by: rx.disposeBag)
//
//        _ = NotificationCenter.default.rx
//            .notification(Notification.Name(rawValue: YXUserManager.notiLoginOut))
//            .takeUntil(self.rx.deallocated) //退出登录，隐藏行情互踢小黄条
//            .subscribe(onNext: { _ in
//
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiQuoteKick), object: nil)
//
//            }).disposed(by: rx.disposeBag)

    }

    @objc func getUserQuoteLevelRequest(activateToken: Bool, resultBock: ((_ success: Bool) -> Void)?) {
        getUserQuoteLevelRequest(isFromAlert: false, activateToken: activateToken, resultBock: {
            success in
            resultBock?(success)
        })
    }

    @objc func getUserQuoteLevelRequest(isFromAlert: Bool, activateToken: Bool, resultBock: ((_ success: Bool) -> Void)?) {

        self.isGettingUserLevel = true
        YXUserManager.getUserInfo(postNotification: true, activateToken: activateToken, complete: {
            [weak self] in
            guard let `self` = self else { return }

            self.resetQuoteLevelRequest({ [weak self] success in
                guard let `self` = self else { return }

                resultBock?(success)

                NotificationCenter.default.post(name: NSNotification.Name(rawValue: YXUserManager.notiQuoteKick), object: NSNumber(value: isFromAlert))

                self.isGettingUserLevel = false
            })
        })
    }

    @objc func resetQuoteLevelRequest(_ resultBock: ((_ success: Bool) -> Void)?) {
        let requestModel = YXResetQuoteLevelRequestModel()

        let request = YXRequest(request: requestModel)
        request.startWithBlock(success: { (responseModel) in
            if responseModel.code == .success {
                resultBock?(true)
            } else {
                resultBock?(false)
            }
        }, failure: { (request) in
            resultBock?(false)
        })
    }

    //是否展示行情互踢小黄条
    @objc func isQuoteLevelKickToDelay(_ market: String = "") -> Bool {
//        if market == kYXMarketHK {
//            return isHKQuoteLevelKickToDelay()
//        } else if market == kYXMarketUS {
//            return isUSQuoteLevelKickToDelay()
//        } else {
//            if isHKQuoteLevelKickToDelay() || isUSQuoteLevelKickToDelay() {
//                return true
//            }
//            return false
//        }
        return false
    }

    @objc func isHKQuoteLevelKickToDelay() -> Bool {

        if YXUserManager.isLogin(),
           YXUserManager.shared().getHighestUserLevel(with: kYXMarketHK) == .level2 {

            let currentHKLevel = YXUserManager.shared().getLevel(with: kYXMarketHK).rawValue
            if currentHKLevel < QuoteLevel.level2.rawValue {
                return true
            }
        }
        return false
    }

    @objc func isUSQuoteLevelKickToDelay() -> Bool {

        if YXUserManager.isLogin(),
           YXUserManager.shared().getHighestNsdqLevel() == .level1 {

            let currentUSLevel = YXUserManager.shared().getNsdqLevel().rawValue
            if currentUSLevel < QuoteLevel.level1.rawValue {
                return true
            }
        }
        return false
    }
    
    @objc func isQuoteLevelKickToDelay(_ market: String = "", symbol: String) -> Bool {
        if market == kYXMarketHK {
            return isHKQuoteLevelKickToDelay()
        } else if market == YXQuoteKickTool.kUSAndIndex {
            return isUSQuoteLevelKickToDelay() || isUSOptionQuoteLevelKickToDelay() || isUSThreeQuoteLevelKickToDelay()
        } else if market == kYXMarketUS {
            let arr = [YXMarketIndex.DJI.rawValue, YXMarketIndex.IXIC.rawValue, YXMarketIndex.SPX.rawValue]
            if !symbol.isEmpty, arr.contains(symbol) {
                return isUSThreeQuoteLevelKickToDelay()
            } else {
                return isUSQuoteLevelKickToDelay() || isUSOptionQuoteLevelKickToDelay()
            }
        }else if market == kYXMarketUsOption {
            return isUSOptionQuoteLevelKickToDelay()
        } else {
            if isHKQuoteLevelKickToDelay() || isUSQuoteLevelKickToDelay() || isUSOptionQuoteLevelKickToDelay() {
                return true
            }
            return false
        }
    }
    
    @objc func isUSThreeQuoteLevelKickToDelay() -> Bool {

        if YXUserManager.isLogin(),
           YXUserManager.shared().getHighestUsaThreeLevel() == .level1 {

            let currentUSLevel = YXUserManager.shared().getUsaThreeLevel().rawValue
            if currentUSLevel < QuoteLevel.level1.rawValue {
                return true
            }
        }
        return false
    }
    
    @objc func isUSOptionQuoteLevelKickToDelay() -> Bool {

        if YXUserManager.isLogin(),
           YXUserManager.shared().getHighestUserLevel(with: kYXMarketUsOption) == .level1 {

            let currentUSLevel = YXUserManager.shared().getLevel(with: kYXMarketUsOption).rawValue
            if currentUSLevel < QuoteLevel.level1.rawValue {
                return true
            }
        }
        return false
    }
    

    //用户当前的行情权限是否是实时
    @objc func currentQuoteLevleIsReal(_ market: String = "") -> Bool {
        if market == kYXMarketHK {
            return YXUserManager.shared().getLevel(with: kYXMarketHK) == .level2
        } else if market == kYXMarketUS {
            return YXUserManager.shared().getLevel(with: kYXMarketUS) == .level1
        } else {
            return (YXUserManager.shared().getLevel(with: kYXMarketHK) == .level2 ||
                        YXUserManager.shared().getLevel(with: kYXMarketUS) == .level1)
        }

    }

    //用户最高的行情权限是否是实时
    @objc func highestQuoteLevleIsReal() -> Bool {
        return (YXUserManager.shared().getHighestUserLevel(with: kYXMarketHK) == .level2 ||
                    YXUserManager.shared().getHighestUserLevel(with: kYXMarketUS) == .level1)
    }


    @objc class func createNoticeView() -> YXQuoteKickNoticeView {
        let noticeView = YXQuoteKickNoticeView()

        let content = YXLanguageUtility.kLang(key: "quote_kick_message")
        let str = YXLanguageUtility.kLang(key: "quote_kick_regot")

        let dic = ["clickClose": "0"] as NSDictionary
        let noticeModel = YXNoticeModel.init(msgId: 0, title: "", content: content, pushType: .none, pushPloy: dic.yy_modelToJSONString() ?? "", msgType: 0, contentType: 0, startTime: 0.0, endTime: 0.0, createTime: 0.0, newFlag: 0)
        noticeModel.isQuoteKicks = true

        let attrM = NSMutableAttributedString.init(string: content, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1()])

        attrM.addAttributes([NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue], range: (content as NSString).range(of: str))

        noticeModel.attributeContent = attrM

        noticeView.dataSource = [noticeModel]


        return noticeView;
    }

    weak var modalVC: QMUIModalPresentationViewController? = nil
    @objc func showQuoteKickAlert(_ message: String) {

        if QMUIModalPresentationViewController.isAnyModalPresentationViewControllerVisible() {
            return
        }

        UIApplication.shared.keyWindow?.endEditing(true)

        let alertView = UIView(frame: CGRect(x: 0, y: 0, width: 285, height: 245))
        alertView.backgroundColor = UIColor.white
        alertView.layer.cornerRadius = 10

        let titleLabel = UILabel()
        titleLabel.text = YXLanguageUtility.kLang(key: "quote_kick_title")
        titleLabel.textColor = QMUITheme().textColorLevel1()
        titleLabel.font = .systemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        alertView.addSubview(titleLabel)

        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.5)
        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        alertView.addSubview(messageLabel)

        let realTimeButton = UIButton()
        realTimeButton.layer.cornerRadius = 6
        realTimeButton.layer.borderWidth = 1.0
        realTimeButton.layer.masksToBounds = true
        realTimeButton.layer.borderColor = QMUITheme().themeTextColor().cgColor
        realTimeButton.backgroundColor = QMUITheme().themeTextColor()
        realTimeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        realTimeButton.setTitleColor(UIColor.white, for: .normal)
        realTimeButton.setTitle(YXLanguageUtility.kLang(key: "quote_level_real"), for: .normal)
        alertView.addSubview(realTimeButton)


        let delayTimeButton = UIButton()
        delayTimeButton.layer.cornerRadius = 6
        delayTimeButton.layer.borderWidth = 1.0
        delayTimeButton.layer.borderColor = QMUITheme().themeTextColor().cgColor
        delayTimeButton.backgroundColor = UIColor.white
        delayTimeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        delayTimeButton.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        delayTimeButton.setTitle(YXLanguageUtility.kLang(key: "quote_level_delay"), for: .normal)
        alertView.addSubview(delayTimeButton)

        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(14)
            make.right.equalToSuperview().offset(-14)
        }

        messageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(13)
            make.left.equalToSuperview().offset(14)
            make.right.equalToSuperview().offset(-14)
        }

        realTimeButton.snp.makeConstraints { (make) in
            make.top.equalTo(messageLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(48)
        }

        delayTimeButton.snp.makeConstraints { (make) in
            make.top.equalTo(realTimeButton.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(48)
        }

        let messageHeight: CGFloat = (message as NSString).boundingRect(with: CGSize(width: 285 - 28, height: 1000), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font : messageLabel.font!], context: nil).height + 2
        alertView.mj_h = 200 + messageHeight


        let modalViewController = QMUIModalPresentationViewController()

        modalViewController.isModal = true
        weak var weakView = alertView
        modalViewController.animationStyle = .popup
        modalViewController.contentViewMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        modalViewController.contentView = weakView;

        //modalViewController.showWith(animated: true, completion: nil)
        weak var currentVC = UIViewController.current()
        currentVC?.present(modalViewController, animated: false, completion: nil)
        self.modalVC = modalViewController

        var isIgnore = false
        if let vc = currentVC, vc.isKind(of: YXStockDetailViewController.self) {
            isIgnore = true
        }

        if (!isIgnore) {
            currentVC?.beginAppearanceTransition(false, animated: false)
            currentVC?.endAppearanceTransition()
        }


        realTimeButton.rx.tap
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: {
                [weak self, weak currentVC] _ in
                guard let `self` = self else { return }

                //self.modalVC?.hideWith(animated: true, completion: nil)
                self.modalVC?.dismiss(animated: true, completion: nil)
                self.modalVC = nil

                YXQuoteKickTool.shared.getUserQuoteLevelRequest(isFromAlert: true, activateToken: true, resultBock: { (success) in

                    if (!isIgnore) {
                        currentVC?.beginAppearanceTransition(true, animated: false)
                        currentVC?.endAppearanceTransition()
                    }

                })

            }).disposed(by: rx.disposeBag)

        delayTimeButton.rx.tap
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: {
                [weak self, weak currentVC] _ in
                guard let `self` = self else { return }

                //self.modalVC?.hideWith(animated: true, completion: nil)
                self.modalVC?.dismiss(animated: true, completion: nil)
                self.modalVC = nil

                YXQuoteKickTool.shared.getUserQuoteLevelRequest(isFromAlert: true, activateToken: false, resultBock: { (success) in

                    if (!isIgnore) {
                        currentVC?.beginAppearanceTransition(true, animated: false)
                        currentVC?.endAppearanceTransition()
                    }
                })

            }).disposed(by: rx.disposeBag)
    }


}
