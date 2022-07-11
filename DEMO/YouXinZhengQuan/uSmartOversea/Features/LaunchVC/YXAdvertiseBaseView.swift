//
//  YXAdvertiseBgView.swift
//  uSmartOversea
//
//  Created by rrd on 2019/5/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import URLNavigator

/// 闪屏广告
class YXAdvertiseBaseView: UIView {
    
    let disposeBag = DisposeBag()
    var timeCount = 3
    let timerMark = "registerCode"
    //回调 关闭
    var callBack: (() -> Void)!
    
    var navigator: NavigatorServicesType
    
    lazy var jumpBtn: UIButton = {
        let text = YXLanguageUtility.kLang(key: "bind_jumpOver") + " 3"
        let btn = UIButton() 
        btn.setTitle(text, for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setBackgroundImage(UIImage.init(named: "icon_skip"), for: .normal)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return btn
    }()

    init(frame: CGRect, image: UIImage, navigator: NavigatorServicesType) {
        self.navigator = navigator
        super.init(frame: frame)
        self.backgroundColor = QMUITheme().foregroundColor()
        
        let screenHeight = YXConstant.screenHeight
        //广告图片
        let advertiseImgView = UIImageView(image: image)
        advertiseImgView.contentMode = .scaleAspectFill
//        advertiseImgView.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: screenHeight * 25/32)
        advertiseImgView.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: screenHeight)
        advertiseImgView.clipsToBounds = true
        self.addSubview(advertiseImgView)
        //点击事件
        let tap = UITapGestureRecognizer(target: self, action: #selector(advertiseGesture))
        advertiseImgView.addGestureRecognizer(tap)
        advertiseImgView.isUserInteractionEnabled = true
        
        //底部的logo图片
        let advertiseImage = getImage(name: "advertise_bottom")!
        let logoImgView = UIImageView(image: advertiseImage)
        logoImgView.contentMode = .scaleAspectFit
        self.addSubview(logoImgView)
        var advertiseWidth:CGFloat = 130.0
        switch YXConstant.screenSize {
        case .size3_5:
            advertiseWidth = 130
        case .size4:
            advertiseWidth = 130
        case .size4_7:
            advertiseWidth = 150
        case .size5_5:
            advertiseWidth = 150
        case .size5_8:
            advertiseWidth = 150
        case .size6_1:
            advertiseWidth = 150
        default://size6_5
            advertiseWidth = 150
        }
        let advertiseHeight = advertiseWidth / advertiseImage.size.width * advertiseImage.size.height
        let advertiseTop = screenHeight * 7.0 / 32 / 2.0 - advertiseHeight
        logoImgView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(advertiseImgView.snp.bottom).offset(advertiseTop)
            make.size.equalTo(CGSize(width: advertiseWidth, height: advertiseHeight))
        }
        
        
        self.addSubview(jumpBtn)
        jumpBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(YXConstant.statusBarHeight() + 14)
            make.right.equalToSuperview().offset(-14)
            make.height.equalTo(26)
        }
        jumpBtn.rx.tap.bind { [weak self] in
            YXTimer.shared.cancleTimer(WithTimerName: self?.timerMark)
            self?.callBack()
            }.disposed(by: disposeBag)
        
        self.startTimer()
        
        let icon = UIImageView.init(image: UIImage.init(named: "icon_banner_tag"))
        self.addSubview(icon)
        let bottomLabel = UILabel()
        bottomLabel.text = "2021 Dolpin"
        bottomLabel.textColor = QMUITheme().textColorLevel3()
        bottomLabel.font = .systemFont(ofSize: 14)
        self.addSubview(bottomLabel)
        bottomLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImgView.snp.bottom).offset(4)
            make.height.equalTo(16)
            make.centerX.equalTo(logoImgView).offset(4)
        }
        
        icon.snp.makeConstraints { make in
            make.centerY.equalTo(bottomLabel)
            make.right.equalTo(bottomLabel.snp.left).offset(-4)
        }
        //先隐藏底部图标
        logoImgView.isHidden = true
        bottomLabel.isHidden = true
        icon.isHidden = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func advertiseGesture() {
        let data = MMKV.default().data(forKey: YXUserManager.YXSplashScreenAdvertisementShowing)
        do {
            let first = try JSONDecoder().decode(SplashscreenList.self, from: data ?? Data())
                if first.jumpURL?.count ?? 0 <= 0 {
                    return
                }
                let banner = BannerList(bannerID: first.bannerID,
                                        adType: first.adType,
                                        adPos: first.adPos,
                                        pictureURL: first.pictureURL,
                                        originJumpURL: first.jumpURL,
                                        newsID: String(describing: first.bannerID),
                                        bannerTitle: "",
                                        tag: "0",
                                        jumpType: YXInfomationType(rawValue: Int(first.jumpType ?? "0") ?? 0)?.converNewType()
                                       )
                YXBannerManager.goto(withBanner: banner, navigator: self.navigator)
                self.callBack()
        } catch {
            
        }
    }
    
    func startTimer() {
        
        timeCount = 3
        YXTimer.shared.cancleTimer(WithTimerName: self.timerMark)
        YXTimer.shared.scheduledDispatchTimer(WithTimerName: self.timerMark, timeInterval: 1, queue: .main, repeats: true) { [weak self] in
            self?.timerAction()
        }
    }
    
    @objc func timerAction() {
        if timeCount >= 0 {
            jumpBtn.setTitle( String(format: "%@ %ld", YXLanguageUtility.kLang(key: "bind_jumpOver"),timeCount), for: .normal)
            timeCount -= 1
        }else {
            YXTimer.shared.cancleTimer(WithTimerName: timerMark)
            self.callBack()
        }
    }

}
