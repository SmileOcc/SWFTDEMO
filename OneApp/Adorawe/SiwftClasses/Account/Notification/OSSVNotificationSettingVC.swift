//
//  OSSVNotificationSettingVC.swift
// XStarlinkProject
//
//  Created by odd on 2021/9/1.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

class OSSVNotificationSettingVC: OSSVBaseVcSw {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = STLLocalizedString_("notification")
        stlInitView()
        stlAutoLayoutView()
        updatePushState()
        
        
        NotificationCenter.default.rx.notification(Notification.Name(kAppDidBecomeActiveNotification),object:nil).subscribe(onNext: {[weak self] notification in
            self?.updateNotificateState(notify: notification)
        }).disposed(by: disposeBag)
    }
    
    
    func updateNotificateState(notify: Notification) {
        ////进入【设置】修改通知后，在回到界面时，判断处理通知变化
        updatePushState()
    }
    
    func updatePushState() {
        //< ------- 第一种，不弹窗直接进入设置界面 ------- >
        STLPushManager.isRegisterRemoteNotification { [weak self] isRegister in
            self?.switchEnable = isRegister
            print("=====occcc通知开关：\(isRegister)")
        }
        
    }
    
    @objc func switchAction(sender: UISwitch) {
        //< ------- 第一种，不弹窗直接进入设置界面 ------- >
        self.switchEnable = sender.isOn
        let isPopAlert = UserDefaults.standard.bool(forKey: kHadShowSystemNotificationAlert)
        if isPopAlert {
            let url = NSURL.init(string: UIApplication.openSettingsURLString)! as URL
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else {
            STLPushManager.saveShowAlertTimestamp()
            AppDelegate.stlRegisterRemoteNotification { openFlag in
                /**
                 * ⚠️⚠️⚠️⚠️⚠️
                 * 需要在这里回调，从系统设置再次进入app时，
                 * 1、先触发重新活动的通知触发的方法，通知更新的信息方法，不是最新状态，自己获取的状态可能是错的
                 * 2、在重新更新状态
                 */
                self.updatePushState()
            }
        }
        OSSVAnalyticsTool.analyticsGAEvent(withName: "notification", parameters: ["screen_group":"Notification","action":"On"])

    }
    
    override func stlInitView() {
        view.addSubview(topBagView)
        view.addSubview(nameLabel)
        view.addSubview(pushSwitchView)
        view.addSubview(stateLabel)
        view.addSubview(stateTipLabel)
    }
    
    override func stlAutoLayoutView() {
        
        topBagView.snp.makeConstraints { make in
            make.leading.equalTo(self.view.snp.leading).offset(12)
            make.trailing.equalTo(self.view.snp.trailing).offset(-12)
            make.top.equalTo(self.view.snp.top).offset(12)
            make.height.equalTo(48)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.topBagView.snp.centerY)
            make.leading.equalTo(self.topBagView.snp.leading).offset(14)
        }
        
        pushSwitchView.snp.makeConstraints { make in
            make.trailing.equalTo(self.topBagView.snp.trailing).offset(-14)
            make.centerY.equalTo(self.topBagView.snp.centerY)
        }
        
        stateLabel.snp.makeConstraints { make in
            make.trailing.equalTo(self.topBagView.snp.trailing).offset(-14)
            make.centerY.equalTo(self.topBagView.snp.centerY)
        }
        
        stateTipLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.topBagView.snp.leading)
            make.trailing.equalTo(self.topBagView.snp.trailing)
            make.top.equalTo(self.topBagView.snp.bottom).offset(8)
        }
    }
    

    //MARK: - setter
    
    var switchEnable: Bool = false {
        didSet {
            if switchEnable {
                self.stateLabel.isHidden = false
                self.pushSwitchView.isHidden = true
                self.stateLabel.text = STLLocalizedString_("enable")
            } else {
                self.stateLabel.isHidden = true
                self.pushSwitchView.isHidden = false
                self.pushSwitchView.isOn = false
            }
        }
    }
    
    var topBagView: UIView = {
        let view = UIView.init()
        view.backgroundColor = OSSVThemesColors.stlWhiteColor()
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        return view
    }()
    
    var nameLabel: UILabel = {
        let lable = UILabel.init(frame: CGRect.zero)
        lable.textColor = OSSVThemesColors.col_0D0D0D()
        lable.textAlignment = OSSVSystemsConfigsUtils.isRightToLeftShow() ? NSTextAlignment.right : NSTextAlignment.left
        lable.font = UIFont.systemFont(ofSize: 14)
        lable.text = STLLocalizedString_("notifications")
        return lable
    }()
    
    lazy var pushSwitchView: UISwitch = {
        let view = UISwitch.init()
        view.addTarget(self, action: #selector(switchAction(sender:)), for: .valueChanged)
        return view
    }()
    
    var stateLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.zero)
        label.textColor = OSSVThemesColors.col_B2B2B2()
        label.textAlignment = OSSVSystemsConfigsUtils.isRightToLeftShow() ? NSTextAlignment.right : NSTextAlignment.left
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = STLLocalizedString_("enable")
        label.isHidden = true
        return label
    }()
    
    var stateTipLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = OSSVThemesColors.col_B2B2B2()
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.textAlignment = OSSVSystemsConfigsUtils.isRightToLeftShow() ? NSTextAlignment.right : NSTextAlignment.left
        label.text = STLLocalizedString_("enableNotifi")

        return label
    }()
    
    

}
