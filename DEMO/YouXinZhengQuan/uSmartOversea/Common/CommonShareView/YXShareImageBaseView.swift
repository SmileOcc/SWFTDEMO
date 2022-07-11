//
//  YXShareImageBaseView.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2021/9/29.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXShareImageBaseView: UIView {
    
    var config: YXShareConfig = YXShareConfig()

    class func show(config: YXShareConfig?, shareImage: UIImage?) {
        if let shareConfig = config, let image = shareImage, let window = UIApplication.shared.keyWindow {
            
            let shareView = YXShareImageBaseView.init(frame: UIScreen.main.bounds, config: shareConfig)
            shareView.shareImage = image
            window.addSubview(shareView)
        }
    }
    
    var shareImage: UIImage? {
        didSet {
            if let tempImageWidth = shareImage?.cgImage?.width, let tempImageHeight = shareImage?.cgImage?.height, let imageScale = shareImage?.scale {
                
                //优先根据宽度布局
                let originWidth = CGFloat(tempImageWidth) / imageScale
                let originHeight = CGFloat(tempImageHeight) / imageScale
                
                //有精度问题，减一
                let maxWidth: CGFloat = YXConstant.screenWidth - config.lrMargin * 2.0-1
                
                
                let imageViewWidth: CGFloat = (originWidth > maxWidth) ? maxWidth : originWidth
         
                let imageViewHeight: CGFloat = imageViewWidth * originHeight / originWidth
                
                imageView.frame = CGRect(x: (maxWidth - imageViewWidth) / 2.0, y: 0, width: imageViewWidth, height: imageViewHeight)

                var qrHeight: CGFloat = QRCodeViewHeight
                if config.splicingQRView == false {
                    qrHeight = 0
                }
                
                let maxHeight: CGFloat = imageViewHeight + qrHeight - 1
                contentView.frame = CGRect(x: 0, y: 0, width: maxWidth, height: maxHeight)
                contentView.layer.cornerRadius = 8
                contentView.layer.masksToBounds = true

                self.scrollView.contentSize = CGSize(width: maxWidth, height: maxHeight)

                let currentBottmViewHeight = self.bottomView.currentContentHeight()
                let scrollViewHeight: CGFloat = YXConstant.screenHeight - kImageViewTopMargin - 20.0 - currentBottmViewHeight
                
                if scrollViewHeight < maxHeight {
                    let scrollIndicatorHeight = (scrollViewHeight / maxHeight) * scrollViewHeight
                    let vertialScrollIndicator = UIView.init(frame: CGRect(x: maxWidth + config.lrMargin - 6, y: qrHeight + 1, width: 4, height: scrollIndicatorHeight))
                    vertialScrollIndicator.layer.cornerRadius = 2.0
                    vertialScrollIndicator.backgroundColor = QMUITheme().textColorLevel4()
                    self.addSubview(vertialScrollIndicator)
                    
                    self.scrollView.rx.contentOffset.subscribe(onNext:{
                        [weak indicatorView = vertialScrollIndicator] contentOffset in
                        guard let strongView = indicatorView else { return }
                        
                        var y: CGFloat = (contentOffset.y / maxHeight) * scrollViewHeight
                        
                        if (y < 0) {
                            y = 0
                        }
                        
                        if (y > scrollViewHeight - vertialScrollIndicator.frame.size.height) {
                            y = scrollViewHeight - vertialScrollIndicator.frame.size.height
                        }
                        
                        strongView.mj_y = y + qrHeight + 1
                        
                    }).disposed(by: self.rx.disposeBag)
                } else {
                    contentView.mj_y = (scrollViewHeight - maxHeight) / 2.0
                }

                
            }
            imageView.image = shareImage
            self.layoutIfNeeded()
            if let image = YXToolUtility.normalSnapShotImage(self.contentView.layer) {
                self.bottomView.shareImage = image
            }
        }
    }
    
    let QRCodeViewHeight: CGFloat = 56
    let kImageViewTopMargin: CGFloat = 44 + (YXConstant.deviceScaleEqualToXStyle() ? 20.0 : 0.0)
    
    @objc init(frame: CGRect, config: YXShareConfig) {
        super.init(frame: frame)
        self.config = config
        let tap = UITapGestureRecognizer.init { [weak self] _ in
            guard let `self` = self else { return }
            self.cancelButtonEvent()
        }
        self.addGestureRecognizer(tap)

        let bgview = UIView()
        bgview.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        addSubview(bgview)
        bgview.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurview = UIVisualEffectView(effect: blurEffect)
        blurview.alpha = 0.95
        self.addSubview(blurview)
        blurview.snp.makeConstraints { (make) in
            make.left.top.bottom.right.equalToSuperview()
        }

        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.alpha = 0.95
        blurview.contentView.addSubview(vibrancyView)
        vibrancyView.snp.makeConstraints { (make) in
            make.left.top.bottom.right.equalToSuperview()
        }
        
        addSubview(scrollView)
        addSubview(bottomView)
        let currentBottmViewHeight = self.bottomView.currentContentHeight()
        bottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(currentBottmViewHeight)
        }
        
        self.scrollView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kImageViewTopMargin)
            make.left.equalToSuperview().offset(config.lrMargin)
            make.right.equalToSuperview().offset(-config.lrMargin)
            make.bottom.equalTo(bottomView.snp.top).offset(-20)
        }
        
        scrollView.addSubview(contentView)
        contentView.addSubview(imageView)

        if config.splicingQRView {
            let bottomView = YXShareQRCodeView.init(config: config)
            contentView.addSubview(bottomView)
            bottomView.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(QRCodeViewHeight)
            }
        }
    
        if config.cornerRadius > 0 {
            contentView.layer.cornerRadius = config.cornerRadius
            contentView.layer.masksToBounds = true 
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()

        return view
    }()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        
        return view
    }()
    
//    lazy var shareButtonsView: YXSharePlatformView = {
//        let view = YXSharePlatformView.init(config: self.config)
//        view.shareBlock = {
//            [weak self] type in
//            guard let `self` = self else { return }
//            self.shareAction(type)
//        }
//
//        view.cancelBlock = {
//            [weak self]  in
//            guard let `self` = self else { return }
//            self.cancelButtonEvent()
//        }
//
//        return view
//    }()
    
//    lazy var bottomView: YXShareBottomButtonView = {
//        let view = YXShareBottomButtonView.init()
//        return view
//    }()
    lazy var bottomView: YXShareBottomAlertView = {
        let view = YXShareBottomAlertView()
        view.isDefaultShowMessage = true
        
        let thirdPlatforms:[YXSharePlatform] = [.facebook,.facebookMessenger,.whatsApp,.twitter,.instagram,.uSmartSocial,.telegram,.line]
        let toolsPlatforms:[YXSharePlatform] = [.save,.more]

        view.configure(shareType: .image, toolTypes: toolsPlatforms, thirdTypes: thirdPlatforms, clickCallBlock: nil) { [weak self] (platform, result) in
            guard let `self` = self else { return }
            if self.config.isHoldShare {
                YXGiveScoreAlertManager.sharedChangeScoreModel()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.cancelButtonEvent()
            }
        } cancelBlock: { [weak self] in
            guard let `self` = self else { return }
            self.cancelButtonEvent()
        }

        
        return view
    }()
    
//    func shareAction(_ shareType: YXSharePlatform) {
//
//        let image = UIImage.qmui_image(with: CGSize(width: self.contentView.frame.width, height: self.contentView.frame.height), opaque: false, scale: 0) { (contextRef) in
//            self.contentView.layer.render(in: contextRef)
//        }
//
//        if config.isHoldShare {
//            YXGiveScoreAlertManager.sharedChangeScoreModel()
//        }
//
//        YXShareManager.shared.shareImage(to: shareType, shareImage: image)
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            self.cancelButtonEvent()
//        }
//
//    }
  
    
    @objc func cancelButtonEvent() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        } completion: { finish in
            self.removeFromSuperview()
        }

    }
}
