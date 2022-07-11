//
//  YXShortVideoItemHKView.swift
//  uSmartOversea
//
//  Created by usmart on 2022/3/22.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import Foundation
import UIKit
import QMUIKit

class YXShortVideoItemHKView: UIView,YXShortVideoItemViewProtocol {
    
    lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = QMUITheme().textColorLevel3()
        label.numberOfLines = 1
        label.isHidden = true
        return label
    }()
    
    lazy var progressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 1
        label.isHidden = true
        return label
    }()
    
    lazy var player: TXVodPlayer = {
        let player = TXVodPlayer.init()
        player.loop = true
        player.isAutoPlay = false
        return player
    }()
    
    lazy var slider: YXProgressSliderBar = {
        let s = YXProgressSliderBar()
        return s
    }()
    
    lazy var kolNameLabel: UILabel = {
        let label = UILabel()
        label.font = .mediumFont18()
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    lazy var lessonNameLabel: UILabel = {
        let label = UILabel()
        label.font = .mediumFont18()
        label.textColor = .white
        label.numberOfLines = 3
        return label
    }()
    
    lazy var lessonDescLabel: YXFoldLabel = {
        let label = YXFoldLabel()
        return label
    }()
    
    lazy var learnNowBtn: QMUIButton = {
        let learnNow = QMUIButton()
        learnNow.backgroundColor = UIColor(hexString: "2F79FF")
        learnNow.layer.cornerRadius = 4
        learnNow.setTitleColor(.white, for: .normal)
        learnNow.titleLabel?.font = .systemFont(ofSize: 14)
        learnNow.contentEdgeInsets = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8)
        learnNow.isUserInteractionEnabled = false
        learnNow.setTitle(YXLanguageUtility.kLang(key: "beerich_learnnow"), for: .normal)
        return learnNow
    }()
    
    var courseDetailTap = UITapGestureRecognizer()
    lazy var courseDetailView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        view.addGestureRecognizer(courseDetailTap)
        let label = UILabel()
        label.font = .normalFont12()
        label.textColor = .white
        label.text = YXLanguageUtility.kLang(key: "beerich_coursedetail")
        
        let imageV = UIImageView(image: UIImage(named: "icon_lesson"))
        
        view.addSubview(imageV)
        view.addSubview(label)
        view.addSubview(learnNowBtn)
        
        imageV.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        label.snp.makeConstraints { make in
            make.left.equalTo(imageV.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }
        
        learnNowBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.height.equalTo(26)
        }
        return view
    }()
    
    lazy var animateView: LOTAnimationView = {
        let animateView = LOTAnimationView(name: "like_animation")
        animateView.isUserInteractionEnabled = false
        animateView.loopAnimation = false
        return animateView
    }()
    
    lazy var followIcon: QMUIButton = {
        let btn = QMUIButton()
        btn.backgroundColor = .clear
        btn.addSubview(animateView)
        animateView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(20)
        }
        return btn
    }()
    
    lazy var kolButton: QMUIButton = {
        let button = QMUIButton()
        button.imageView?.layer.borderWidth = 1
        button.imageView?.layer.borderColor = UIColor.white.cgColor
        button.imageView?.layer.cornerRadius = 22
        button.imageView?.layer.masksToBounds = true
        //        button.addSubview(followIcon)
        //        followIcon.snp.makeConstraints { make in
        //            make.centerY.equalTo(button.snp.bottom)
        //            make.centerX.equalTo(button)
        //            make.height.equalTo(30)
        //            make.width.equalTo(40)
        //        }
        
        return button
    }()
    
    lazy var shareButton:  QMUIButton = {
        let button = QMUIButton()
        button.imagePosition = .top
        button.spacingBetweenImageAndTitle = 4
        button.titleLabel?.font = .mediumFont12()
        button.setTitleColor(.white, for: .normal)
        button.setImage(UIImage(named: "home_share_icon"), for: .normal)
        return button
    }()
    
    lazy var foldButton:  QMUIButton = {
        let button = QMUIButton()
        button.titleLabel?.font = .mediumFont12()
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 2
        button.backgroundColor = UIColor(hexString: "#000000")?.withAlphaComponent(0.26)
        button.setTitle(YXLanguageUtility.kLang(key: "live_expand"), for: .normal)
        button.setTitle(YXLanguageUtility.kLang(key: "live_hide"), for: .selected)
        button.contentEdgeInsets = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        return button
    }()
    
    lazy var collectButton: QMUIButton = {
        let button = QMUIButton()
        button.imagePosition = .top
        button.spacingBetweenImageAndTitle = 4
        button.titleLabel?.font = .mediumFont12()
        button.setTitleColor(.white, for: .normal)
        button.setImage(UIImage(named: "home_collect"), for: .normal)
        button.setImage(UIImage(named: "home_collected"), for: .selected)
        
        return button
    }()
    
    lazy var likeButton: QMUIButton = {
        let button = QMUIButton()
        button.imagePosition = .top
        button.spacingBetweenImageAndTitle = 4
        button.titleLabel?.font = .mediumFont12()
        button.setTitleColor(.white, for: .normal)
        button.setImage(UIImage(named: "like_heart"), for: .normal)
        button.setImage(UIImage(named: "liked_heart"), for: .selected)
        
        return button
    }()
    
    lazy var commentButton: QMUIButton = {
        let button = QMUIButton()
        button.imagePosition = .top
        button.spacingBetweenImageAndTitle = 4
        button.titleLabel?.font = .mediumFont12()
        button.setTitleColor(.white, for: .normal)
        button.setImage(UIImage(named: "home_comment"), for: .normal)
        return button
    }()
    
    lazy var bottomSheet: YXBottomSheetViewTool = {
        let sheet = YXBottomSheetViewTool()
        sheet.leftButton.isHidden = true
        sheet.rightButton.setTitle(nil, for: .normal)
        sheet.rightButton.setImage(UIImage(named: "close_common"), for: .normal)
        sheet.rightButtonAction = {
            sheet.hide()
        }
        return sheet
    }()
    
    lazy var shadowBgView: YXGradientLayerView = {
        let view = YXGradientLayerView()
        view.direction = .vertical
        view.colors = [UIColor.black.withAlphaComponent(0.5), UIColor.black.withAlphaComponent(0)]
        return view
    }()
    
    var pauseBackgroundTap = UITapGestureRecognizer()
    lazy var pauseBackgroundView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        let playicon = UIImageView(image: UIImage(named: "play_icon"))
        view.addSubview(playicon)
        playicon.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        //        let tap = UITapGestureRecognizer.init { [weak self] _ in
        //            guard let `self` = self else { return }
        //            if self.isFullScreen {
        //                self.resumePlayer()
        //            } else {
        //                self.didClickedPlayBlock?()
        //                self.resumePlayer()
        //            }
        //        }
        //        view.addGestureRecognizer(pauseBackgroundTapGes)
        return view
    }()
    
    lazy var videoloadingAnimationView: LOTAnimationView = {
        let view = LOTAnimationView.init(name: "videoLoading")
        view.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 5)
        view.loopAnimation = true
        view.play()
        return view
    }()
    
    lazy var gradientView: YXGradientLayerView = {
        let view = YXGradientLayerView()
        view.direction = .vertical
        view.colors = [UIColor.black.withAlphaComponent(0), UIColor.black.withAlphaComponent(0.5)]
        return view
    }()
    
    lazy var coverImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    lazy var loadingHud: YXProgressHUD = {
        let hud = YXProgressHUD()
        hud.isUserInteractionEnabled = false
        return hud
    }()
    
    lazy var rightSideView: UIStackView = {
        let array = [kolButton,likeButton,commentButton,shareButton]
        let stackView = UIStackView.init(arrangedSubviews: array)
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 24
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        player.setupVideoWidget(self, insert: 0)
        addSubview(pauseBackgroundView)
        addSubview(gradientView)
        addSubview(lessonNameLabel)
        addSubview(lessonDescLabel)
        addSubview(courseDetailView)
        addSubview(shadowBgView)
        addSubview(kolNameLabel)
        addSubview(slider)
        bringSubviewToFront(slider)
        addSubview(rightSideView)
        addSubview(foldButton)
        
        addSubview(durationLabel)
        addSubview(progressLabel)
        
        addGestureRecognizer(pauseBackgroundTap)
        
        progressLabel.snp.makeConstraints { make in
            make.bottom.equalTo(slider.snp.top).offset(-24)
            make.right.equalTo(self.snp.centerX)
        }
        
        durationLabel.snp.makeConstraints { make in
            make.top.equalTo(progressLabel.snp.top)
            make.left.equalTo(progressLabel.snp.right)
        }
        
        shadowBgView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(100)
        }
        
        rightSideView.snp.makeConstraints { make in
            make.width.equalTo(44)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-100)
        }
        
        kolButton.snp.makeConstraints { make in
            make.width.height.equalTo(44)
        }
        
        pauseBackgroundView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        gradientView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(lessonNameLabel.snp.top).offset(-7)
            make.bottom.equalToSuperview()
        }
        
        kolNameLabel.snp.makeConstraints { make in
            make.bottom.equalTo(lessonNameLabel.snp.top).offset(-8)
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(rightSideView.snp.left).offset(-50)
        }
        
        lessonNameLabel.snp.makeConstraints { make in
            make.bottom.equalTo(lessonDescLabel.snp.top).offset(-8)
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(rightSideView.snp.left).offset(-50)
        }
        
        lessonDescLabel.snp.makeConstraints { make in
            make.bottom.equalTo(courseDetailView.snp.top).offset(-16)
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(rightSideView.snp.left).offset(-50)
        }
        
        foldButton.snp.makeConstraints { make in
            make.bottom.equalTo(lessonDescLabel.snp.bottom)
            make.left.equalTo(lessonDescLabel.snp.right).offset(8)
        }
        
        courseDetailView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(0)
            make.left.right.equalToSuperview()
            make.height.equalTo(42)
        }
        
        slider.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(20)
            make.bottom.equalToSuperview().offset(0)
        }
        
    }
    
    func updateUI(isFullScreen: Bool) {
        
        courseDetailView.snp.remakeConstraints { make in
            make.bottom.equalToSuperview().offset(isFullScreen ? -YXConstant.safeAreaInsetsBottomHeight()-10 : 0)
            make.left.right.equalToSuperview()
            make.height.equalTo(42)
        }
        
        slider.snp.remakeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(20)
            make.bottom.equalToSuperview().offset(isFullScreen ? -YXConstant.safeAreaInsetsBottomHeight()-10 : 0)
        }
    }
        
}
