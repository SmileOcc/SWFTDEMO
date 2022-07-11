//
//  YXSharePlatformView.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2021/10/28.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXSharePlatformView: UIView {
    
    var shareBlock: ((YXSharePlatform) -> Void)?
    var cancelBlock: (() -> Void)?

    var config: YXShareConfig = YXShareConfig()
    let kBaseTag = 1000
    
    convenience init(config: YXShareConfig) {
        self.init(frame: .zero, config: config)
    }
    
    init(frame: CGRect, config: YXShareConfig) {
        super.init(frame: frame)
        self.config = config
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.cornerRadius = 20
        backgroundColor = UIColor.white

        //分享图标
        var shareButtons: [UIButton] = []
        // Whats app
        if YXShareSDKHelper.isClientIntalled(.typeWhatsApp) {

            shareButtons.append(shareButton(with: "share-whats", tag: Int(YXSharePlatform.whatsApp.rawValue)))
        }

        // Facebook
        if YXShareSDKHelper.isClientIntalled(.typeFacebook) {

            shareButtons.append(shareButton(with: "share-fb", tag: Int(YXSharePlatform.facebook.rawValue)))
        }

        // Wechat
        if YXShareSDKHelper.isClientIntalled(.typeWechat) {

            shareButtons.append(shareButton(with: "share-wechat", tag: Int(YXSharePlatform.wechat.rawValue)))
        }

        // FacebookMessenger
        if YXShareSDKHelper.isClientIntalled(.typeFacebookMessenger) {

            shareButtons.append(shareButton(with: "share-fb-messenger", tag: Int(YXSharePlatform.facebookMessenger.rawValue)))
        }

        if (shareButtons.count > 0) {
            let lrMargin: CGFloat = 10
            let buttonWidth: CGFloat = 60
            let itemMargin = (YXConstant.screenWidth - 2.0 * lrMargin - CGFloat(shareButtons.count) * buttonWidth) / CGFloat(shareButtons.count)

            for (index, button) in shareButtons.enumerated() {
                self.addSubview(button)
                button.snp.makeConstraints { (make) in
                    make.top.bottom.equalToSuperview()
                    make.width.equalTo(buttonWidth)
                    make.left.equalToSuperview().offset(lrMargin + itemMargin * CGFloat(index) + itemMargin / 2.0 + buttonWidth * CGFloat(index))
                }
            }
        }
        
        self.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 120)
    }

    func shareButton(with imageName: String, tag: Int) -> QMUIButton {

        let shareButton = QMUIButton()
        shareButton.setImage(UIImage(named: imageName), for: .normal)
        shareButton.tag = tag + kBaseTag
        shareButton.addTarget(self, action: #selector(shareButtonAction(_:)), for: .touchUpInside)
        return shareButton
    }

    @objc func shareButtonAction(_ sender: UIButton) {
        
        var shareType: YXSharePlatform = .unKnown
        if let type = YXSharePlatform.init(rawValue: UInt(sender.tag - kBaseTag)) {
            shareType = type
        }
        
        self.shareBlock?(shareType)
    }
}
