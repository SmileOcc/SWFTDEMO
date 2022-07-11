//
//  YXShortVideoViewProtocol.swift
//  uSmartEducation
//
//  Created by usmart on 2022/3/9.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import Lottie
import QMUIKit
import TXLiteAVSDK_Professional

protocol YXShortVideoItemViewProtocol where Self: UIView {
    
    var durationLabel:UILabel { get set }
    
    var progressLabel: UILabel { get set }
    
    var player: TXVodPlayer { get set }
    
    var slider: YXProgressSliderBar { get set }
    
    var kolNameLabel: UILabel { get set }
    
    var lessonNameLabel: UILabel { get set }
    
    var lessonDescLabel: YXFoldLabel { get set }
    
    var learnNowBtn: QMUIButton { get set }
    
    var animateView: LOTAnimationView { get set }
    
    var followIcon: QMUIButton { get set }
    
    var kolButton: QMUIButton { get set }
    
    var shareButton: QMUIButton { get set }
    
    var foldButton:  QMUIButton { get set }
    
    var collectButton: QMUIButton { get set }
    
    var likeButton: QMUIButton { get set }
    
    var commentButton: QMUIButton { get set }
    
    var shadowBgView: YXGradientLayerView { get set }
    
    var pauseBackgroundTap: UITapGestureRecognizer { get set }
    
    var pauseBackgroundView: UIView { get set }
    
    var videoloadingAnimationView: LOTAnimationView { get set }
    
    var gradientView: YXGradientLayerView { get set }
    
    var rightSideView: UIStackView { get set }
    
    var courseDetailTap: UITapGestureRecognizer { get set }
    
    var courseDetailView: UIView { get set }
    
    var bottomSheet: YXBottomSheetViewTool { get set }
    
    var coverImageView: UIImageView { get set }
    
    func updateUI(isFullScreen: Bool)
    
}
