//
//  YXShortVedioBaseViewController.swift
//  uSmartEducation
//
//  Created by usmart on 2022/3/9.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import TXLiteAVSDK_Professional
import Lottie
import RxSwift
import RxCocoa
import QMUIKit
import Alamofire
import YXKit
import SDWebImage

enum YXShortVideoPlayStatus {
    case playing
    case puase
    case stop
}

class YXShortVideoItemViewController: YXHKViewController {
    
    var businessType = ShortVideoViewControllerBuinessType.mutile {
        didSet {
            switch businessType {
            case .mutile:
                break
            case .detail:
                break
            }
        }
    }
    
    //    override var pageName: String {
    //        switch self.businessType {
    //        case .mutile:
    //            return "首页"
    //        case .detail:
    //            return "短视频详情"
    //        }
    //
    //    }
    
    let shareAction = PublishSubject<(Int,String)>()
    
    var viewModel: YXShortVideoItemViewModel!
    
    var isCanPlay = false
    
    var playerStatus: YXShortVideoPlayStatus = .stop
    
    let refreshCommentCount = PublishSubject<Void>()
    
    let kolHomeAction = PublishSubject<()>()
    
    var model: YXShortVideoRecommendItem?
    
    var animationPlayed = false
    
    var didClickedPlayBlock: (()->Void)?
    
    var isFullScreen = false {
        didSet {
            if !isFullScreen {
                self.pausePlayer()
            }
            self.rootView.coverImageView.isHidden = isFullScreen
        }
    }
    
    var backFullScreen: (() -> Void)?
    
    var duration: Float = 0 {
        didSet {
            self.rootView.durationLabel.text = "/" + String(format: "%02d:%02d", Int(ceil(duration)/60),Int(ceil(duration))%60)
        }
    }
    var progress: Float = 0 {
        didSet {
            self.rootView.progressLabel.text = String(format: "%02d:%02d", Int(ceil(progress)/60),Int(ceil(progress))%60)
        }
    }
    
    lazy var tapGes: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer.init { [weak self]_ in
            guard let `self` = self else { return }
            self.pausePlayer()
        }
        return tap
    }()
    
    let rootView: YXShortVideoItemViewProtocol
    
    init() {
#if OVERSEAS
        rootView = YXShortVideoItemSGView()
#endif
#if USMART_HK
        rootView = YXShortVideoItemHKView()
#endif
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        view.addSubview(rootView)
        rootView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        rootView.player.vodDelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBack), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        rootView.lessonNameLabel.text = model?.videoTitle ?? "--"
        rootView.lessonDescLabel.text = model?.videoDesc ?? "--"
        if let name = model?.releaseName {
            rootView.kolNameLabel.text = "@" + name
        }
        
        switch self.businessType {
        case .mutile:
            break
        default:
            rootView.coverImageView.isHidden = true
        }
        
        bind()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rootView.updateUI(isFullScreen: self.isFullScreen)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //        self.trackViewEvent(act: "screen_start", other: [YXSensorAnalyticsPropsConstant.PROP_VIDEO_ID:self.model?.videoIdStr ?? "",
        //                                                         YXSensorAnalyticsPropsConstant.PROP_VIDEO_TITLE:self.model?.videoTitle ?? ""])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //        self.trackViewEvent(act: "screen_skip", other:
        //                                [YXSensorAnalyticsPropsConstant.PROP_VIDEO_ID:self.model?.videoIdStr ?? "",
        //                                 YXSensorAnalyticsPropsConstant.PROP_VIDEO_DURATION:String(format: "%02d",self.progress),
        //                                 YXSensorAnalyticsPropsConstant.PROP_VIDEO_TITLE:self.model?.videoTitle ?? ""])
    }
    
    override func didInitialize() {
        super.didInitialize()
        hidesBottomBarWhenPushed = false
        initViewModelInput()
    }
    
    func initViewModelInput() {
        let viewDidLoad: Driver<YXShortVideoRecommendItem?> = self.rx.methodInvoked(#selector(viewDidLoad)).map { [weak self]_ in
            guard let `self` = self else { return nil}
            self.rootView.courseDetailView.isHidden = self.model?.relatedType == 0
            let url = self.model?.avatar ?? ""
            self.rootView.kolButton.sd_setImage(with: URL.init(string: url), for: .normal, placeholderImage: UIImage(named: "user_default_photo"))
            self.rootView.followIcon.isHidden = true
            return self.model
        }.asDriver(onErrorJustReturn: nil)
        
        self.rootView.lessonDescLabel.rx.observe(Bool.self, "canFold").subscribe(onNext: { [weak self] (change) in
            guard let `self` = self else { return }
            self.rootView.foldButton.isHidden = self.rootView.slider.beginTouch ? true : !self.rootView.lessonDescLabel.canFold
            var offset = self.model?.relatedType == 0 ? 24 : -16
            if let change = change,change == true {
                offset -= 28
            }
            self.rootView.lessonDescLabel.snp.updateConstraints({ make in
                make.bottom.equalTo(self.rootView.courseDetailView.snp.top).offset(offset)
            })
        }).disposed(by: disposeBag)
        
        let viewDidAppear: Driver<YXShortVideoRecommendItem?> = self.rx.methodInvoked(#selector(viewDidAppear)).map { [weak self] _ in
            guard let `self` = self else { return nil}
            return self.model
        }.asDriver(onErrorJustReturn: nil)
        
        let collectAction: Driver<YXShortVideoCollectionAction> = rootView.collectButton.rx.tap.do(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            if self.isFullScreen && !YXUserManager.isLogin() {
                self.backFullScreen?()
            }
            //            self.trackViewClickEvent(name: self.collectButton.isSelected ? "取消收藏按钮" : "收藏按钮",
            //                                     other: [YXSensorAnalyticsPropsConstant.PROP_VIDEO_TITLE: self.model?.videoTitle ?? ""])
        }).flatMapLatest { _ in
            // 是否已登录
            return YXToolUtility.checkLoginComplete()
        }.map { [weak self] _ in
            guard let `self` = self else { return .collect }
            var action: YXShortVideoCollectionAction
            if self.rootView.collectButton.isSelected {
                action = .unCollect
            }else {
                action = .collect
            }
            
            return action
            
        }.asDriver(onErrorJustReturn: .collect)
        
        let likeAction: Driver<YXShortVideoLikeAction> = rootView.likeButton.rx.tap.do(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            if self.isFullScreen && !YXUserManager.isLogin() {
                self.backFullScreen?()
            }
            //            self?.trackViewClickEvent(name: "点赞",
            //                                      other: [YXSensorAnalyticsPropsConstant.PROP_VIDEO_TITLE: self?.model?.videoTitle ?? ""])
        }).flatMapLatest { _ in
            // 是否已登录
            return YXToolUtility.checkLoginComplete()
        }.map { [weak self]_ in
            guard let `self` = self else { return .like }
            var action: YXShortVideoLikeAction
            if self.rootView.likeButton.isSelected {
                action = .unLike
            }else {
                action = .like
            }
            
            return action
            
        }.asDriver(onErrorJustReturn: .like)
        
        let courseDetailAction = self.rootView.courseDetailTap.rx.event.do(onNext: { [weak self] _ in
            //            self?.trackViewClickEvent(name: "立即学习按钮",
            //                                      other: [YXSensorAnalyticsPropsConstant.PROP_VIDEO_TITLE: self?.model?.videoTitle ?? ""])
            if UIApplication.shared.canOpenURL(URL(string: "usmart-goto://")!) {
                UIApplication.shared.open(URL(string: "usmart-goto://berich.stock.app/main?tag=course")!)
            } else {
                UIApplication.shared.open(URL(string: "https://itunes.apple.com/cn/app/id1590293090?mt=8")!)
            }
        }).map { [weak self]_ in
            return self?.model
        }.asDriver(onErrorJustReturn: nil)
        
        let followAction: Driver<YXShortVideoFollowAction> = rootView.followIcon.rx.tap.do(onNext: { [weak self] _ in
            self?.trackViewClickEvent(name: "关注kol按钮")
            if !YXUserManager.isLogin() {
                self?.backFullScreen?()
                return
            }
        }).flatMapLatest { _ in
            // 是否已登录
            return YXToolUtility.checkLoginComplete()
        }.map { _ in
            return .follow
        }.asDriver(onErrorJustReturn: .follow)
        
        viewModel = YXShortVideoItemViewModel.init(input: (viewDidLoad: viewDidLoad,
                                                           collectAction: collectAction,
                                                           refreshCommentCount: self.refreshCommentCount.asDriver(onErrorJustReturn: ()),
                                                           courseDetailAction: courseDetailAction,
                                                           likeAction: likeAction,
                                                           followAction:followAction,
                                                           shareAction: shareAction.asDriver(onErrorJustReturn: (0,"")),
                                                           viewDidAppear: viewDidAppear))
    }
    
    func bind() {
        
                NotificationCenter.default.rx.notification(Notification.Name.userFollowAction).subscribe (onNext: { [weak self] noti in
                    guard let `self` = self else { return }
                    if let uid = noti.userInfo?["uid"] as? String, uid == self.model?.releaseId {
                        if let action = noti.userInfo?["action"] as? YXShortVideoFollowAction {
                            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                                self.rootView.followIcon.isHidden = action == .follow ? true : false
                            }
                        }
                    }
                }).disposed(by: disposeBag)
        
        
        rootView.slider.touchEventBlock = {[weak self](event,value) in
            guard let `self` = self else { return }
            switch event {
            case .touchesBegan:
                //                self.trackViewClickEvent(name: "进度条",
                //                                         other:[YXSensorAnalyticsPropsConstant.PROP_VIDEO_ID: self.model?.videoIdStr ?? ""])
                self.detailView(isHidden: true)
                break;
            case .touchesMoved:
                self.progress = self.duration * value
                break;
            case .touchesEnded:
                self.detailView(isHidden: false)
                self.rootView.player.seek(self.duration*value)
                break;
            }
        }
        
        _ = rootView.shareButton.rx.tap.asControlEvent().subscribe(onNext: { [weak self] (btn) in
            guard let `self` = self else { return }
            let url = YXH5Urls.shareShortVideo(langType: "\(YXUserManager.curLanguage().rawValue)",
                                               id: self.model?.videoIdStr ?? "")
            let desc = YXLanguageUtility.kLang(key: "beerich_share_video").replacingOccurrences(of: "$0", with: "\(self.model?.releaseName ?? "")")
            let config = YXShareConfig.linkConfig(title: self.model?.videoTitle ?? "",
                                                  desc: desc,
                                                  shortUrl: url,
                                                  pageUrl: url,
                                                  wechatDescription: desc)
            
            YXShareManager.shared.showLink(config, shareResultBlock: { [weak self] (platform, success) in
                guard let `self` = self else { return }
                switch platform {
                case .save,.more:
                    break
                case .copy:
                    if success {
                        if let window = UIApplication.shared.keyWindow {
                            YXProgressHUD.showError(YXLanguageUtility.kLang(key: "copy_success"), in: window)
                        }
                    }
                default:
                    if success {
                        self.shareAction.onNext((platform.shareChannalTypeId,self.model?.videoIdStr ?? ""))
                        if let window = UIApplication.shared.keyWindow {
                            YXProgressHUD.showError(YXLanguageUtility.kLang(key: "share_succeed"), in: window)
                        }
                    } else {
                        if let window = UIApplication.shared.keyWindow {
                            YXProgressHUD.showError(YXLanguageUtility.kLang(key: "share_failed"), in: window)
                        }
                    }
                }
            })
        }).disposed(by: disposeBag)
        
        _ = rootView.foldButton.rx.tap.asControlEvent().subscribe(onNext: { [weak self] (_) in
            guard let `self` = self else { return }
            self.rootView.foldButton.isSelected = !self.rootView.foldButton.isSelected
            //            self.trackViewClickEvent(name: button.isSelected ? "展开" : "收起")
            self.rootView.lessonDescLabel.fold = !self.rootView.lessonDescLabel.fold
            if YXConstant.appTypeValue == .HK {
                self.rootView.lessonNameLabel.numberOfLines = self.rootView.foldButton.isSelected ? 0 : 2
            }
        }).disposed(by: disposeBag)
        
        _ = rootView.commentButton.rx.tap.asControlEvent().subscribe(onNext: { [weak self] (btn) in
            guard let `self` = self else { return }
            let vc = YXShortVideoCommentViewController()
            vc.viewModel.businessType = .shortVideo
            vc.viewModel.authorId = self.model?.releaseId
            vc.viewModel.lessonId = self.model?.videoIdStr ?? ""
            if YXConstant.appTypeValue == .OVERSEA_SG {
                self.rootView.bottomSheet.titleLabel.text = YXLanguageUtility.kLang(key: "nbb_discussions")
                vc.getDataCompleteBlock = { [weak self] count in
                    self?.refreshCommentCount.onNext(())
                }
            } else {
                vc.getDataCompleteBlock = { [weak self] count in
                    self?.rootView.bottomSheet.titleLabel.text = "\(count)" + YXLanguageUtility.kLang(key: "beerich_commentcount")
                    self?.refreshCommentCount.onNext(())
                }
                self.rootView.bottomSheet.titleLabel.text = "0" + YXLanguageUtility.kLang(key: "beerich_commentcount")
            }
            
            vc.shouldLoginCallBack = { [weak self] in
                self?.backFullScreen?()
                self?.rootView.bottomSheet.presentVC?.hideWith(animated: false)
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                    YXToolUtility.handleBusinessWithLogin {
                    }
                })
            }
            #if OVERSEAS
            self.rootView.bottomSheet.header.backgroundColor = QMUITheme().popupLayerColor()
            #endif
            self.rootView.bottomSheet.showViewController(vc: vc, contentHeight: YXConstant.screenHeight * 2 / 3.0)
        }).disposed(by: disposeBag)
        
        rootView.pauseBackgroundTap.rx.event.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            switch self.businessType {
            case .mutile:
                if self.rootView.player.isPlaying() {
                    self.pausePlayer()
                } else {
                    if self.isFullScreen {
                        self.resumePlayer()
                    } else {
                        self.didClickedPlayBlock?()
                        self.resumePlayer()
                    }
                }
            default:
                if self.rootView.player.isPlaying() {
                    self.pausePlayer()
                } else {
                    self.resumePlayer()
                }
            }
            
            
        }).disposed(by: disposeBag)
        
        viewModel.collectResult.drive { [weak self]action in
            if let a = action {
                if a == .collect {
                    //                    YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "nbb_collectsuccess"))
                    self?.rootView.collectButton.isSelected = true
                }else {
                    self?.rootView.collectButton.isSelected = false
                }
            }
            
        }.disposed(by: disposeBag)
        
        viewModel.likeResult.drive { [weak self]action in
            if let a = action {
                if a == .like {
                    self?.rootView.likeButton.isSelected = true
                    if let countStr = self?.rootView.likeButton.titleLabel?.text, let count = Int(countStr) {
                        self?.rootView.likeButton.setTitle("\(count+1)", for: .normal)
                        self?.rootView.likeButton.setTitle("\(count+1)", for: .selected)
                    }
                    
                }else {
                    self?.rootView.likeButton.isSelected = false
                    if let countStr = self?.rootView.likeButton.titleLabel?.text, let count = Int(countStr) {
                        self?.rootView.likeButton.setTitle("\(count-1)", for: .normal)
                        self?.rootView.likeButton.setTitle("\(count-1)", for: .selected)
                    }
                }
            } else {
                if let window = UIApplication.shared.keyWindow {
                    YXProgressHUD.showError(YXLanguageUtility.kLang(key: "network_timeout"), in: window)
                }
            }
        }.disposed(by: disposeBag)
        
        viewModel.shareResult.drive {_ in
        }.disposed(by: disposeBag)
        
        viewModel.followResult.drive { [weak self] action in
            if let a = action {
                if a == .follow {
                    NotificationCenter.default.post(name: Notification.Name.userFollowAction, object: nil, userInfo: ["action":a,"uid":self?.model?.releaseId ?? ""])
                    self?.rootView.animateView.play(completion: { [weak self] _ in
                        self?.rootView.followIcon.isHidden = true
                        self?.rootView.animateView.animationProgress = 0
                    })
                }
            } else {
                if let window = UIApplication.shared.keyWindow {
                    YXProgressHUD.showError(YXLanguageUtility.kLang(key: "network_timeout"), in: window)
                }
            }
        }.disposed(by: disposeBag)
        
        viewModel.lessonPopularData.drive { [weak self] lessonPopularityResModel in
            self?.rootView.collectButton.isSelected = lessonPopularityResModel?.isCollection ?? false
            
            self?.rootView.collectButton.setTitle("\(self?.displayCount(countStr: lessonPopularityResModel?.collectionNum) ?? "--")", for: .normal)
            self?.rootView.collectButton.setTitle("\(self?.displayCount(countStr: lessonPopularityResModel?.collectionNum) ?? "--")", for: .selected)
            
            self?.rootView.commentButton.setTitle("\(self?.displayCount(countStr: lessonPopularityResModel?.commentCount) ?? "--")", for: .normal)
            
            self?.rootView.likeButton.isSelected = lessonPopularityResModel?.isAgree ?? false
            
            self?.rootView.likeButton.setTitle("\(self?.displayCount(countStr: lessonPopularityResModel?.agreeCount) ?? "--")", for: .normal)
            self?.rootView.likeButton.setTitle("\(self?.displayCount(countStr: lessonPopularityResModel?.agreeCount) ?? "--")", for: .selected)
            
            self?.rootView.followIcon.isHidden = lessonPopularityResModel?.subscribeFlag ?? true
            
            self?.rootView.shareButton.setTitle("\(self?.displayCount(countStr: lessonPopularityResModel?.shareNum) ?? "--")", for: .normal)
            
        }.disposed(by: disposeBag)
        
        viewModel.courseDetailResult.drive{ [weak self] res in
            if let res = res {
                if res.isFreeCourse || res.isPurchased {
                    return
                }
            }
            
            //            YXToolUtility.handleBusinessWithLogin {
            //                if let courseId = self?.model?.courseIdStr {
            //                    let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.courseUrl(courseId: courseId, lessonId: self?.model?.lessonIdStr)]
            //                    NavigatorServices.shareInstance.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            //                }
            //            }
            
        }.disposed(by: disposeBag)
        
        switch self.businessType {
        case .mutile:
            viewModel.vedioRecordResult.drive{ _ in
            }.disposed(by: disposeBag)
        default:
            break
        }
        
        rootView.kolButton.rx.tap.do(onNext: { [weak self] _ in
            //            self?.trackViewClickEvent(name: "kol头像",
            //                                      other: [YXSensorAnalyticsPropsConstant.PROP_KOL_NAME: self?.model?.releaseName ?? "",
            //                                              YXSensorAnalyticsPropsConstant.PROP_KOL_ID:self?.model?.releaseId ?? ""])
        }).subscribe(onNext:{ [weak self] _ in
            guard let `self` = self else { return }
#if OVERSEAS
            if self.isFullScreen {
                self.backFullScreen?()
            }
            YXToolUtility.handleBusinessWithLogin { [weak self] in
                NavigatorServices.shareInstance.pushPath(YXModulePaths.kolHome, context: ["kolId":self?.model?.releaseId ?? ""], animated: true)
            }
#endif
        }).disposed(by: disposeBag)
            }
    
    func displayCount(countStr: String?) -> String {
        if let countStr = countStr {
            if let count = Int(countStr) {
                if count > 10000 {
                    let s = String(format:"%.1f",Double(count/1000))
                    return "\(s)k"
                }
                return "\(count)"
            }
            return countStr
        }
        return "--"
    }
    
    func startPrepare() {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        if let url = model?.verticalVideoInfo {
            //            loadingHud.showLoading()
            let type = model?.videoType ?? 0
            rootView.player.setRenderMode(type == 0 ? .RENDER_MODE_FILL_SCREEN : .RENDER_MODE_FILL_EDGE)
            rootView.player.startPlay(url)
            self.duration = 0
            if let urlStr = model?.videoCover, let coverUrl = URL(string: urlStr) {
                rootView.coverImageView.sd_setImage(with: coverUrl)
            }
            if !isFullScreen {
                rootView.coverImageView.isHidden = true
            } else {
                pausePlayer()
            }
        }
    }
    
    func stopPlayer() {
        rootView.player.stopPlay()
        self.playerStatus = .stop
    }
    
    func pausePlayer(showMask: Bool = true) {
        self.rootView.player.pause()
        self.playerStatus = .puase
        self.rootView.pauseBackgroundView.isHidden = !showMask
    }
    
    func resumePlayer() {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        self.rootView.player.resume()
        self.playerStatus = .playing
        self.rootView.pauseBackgroundView.isHidden = true
    }
    
    @objc func didEnterBack() {
        self.pausePlayer()
    }
    
    @objc func didBecomeActive() {
        if isCanPlay && isFullScreen {
            self.resumePlayer()
        }
    }
    
    deinit {
        rootView.player.stopPlay()
    }
    
    func shakeAnimate() {
        if !self.animationPlayed {
            self.animationPlayed = !self.animationPlayed
            let keyAnimation:CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
            keyAnimation.beginTime = CACurrentMediaTime()
            keyAnimation.duration = 0.2
            keyAnimation.values = [-Double.pi/12, Double.pi/12,-Double.pi/12]
            keyAnimation.repeatCount = 3
            keyAnimation.isRemovedOnCompletion = true
            rootView.learnNowBtn.layer.add(keyAnimation, forKey: "shake")
        }
        
    }
    
    func detailView(isHidden: Bool) {
        self.rootView.courseDetailView.isHidden = isHidden ? true : self.model?.relatedType == 0
        self.rootView.rightSideView.isHidden = isHidden
        self.rootView.lessonNameLabel.isHidden = isHidden
        self.rootView.lessonDescLabel.isHidden = isHidden
        self.rootView.rightSideView.isHidden = isHidden
        self.rootView.foldButton.isHidden = isHidden
        self.rootView.kolNameLabel.isHidden = isHidden
        self.rootView.durationLabel.isHidden = !isHidden
        self.rootView.progressLabel.isHidden = !isHidden
        self.tapGes.isEnabled = !isHidden
    }
    
}


extension YXShortVideoItemViewController: TXVodPlayListener {
    func onPlayEvent(_ player: TXVodPlayer!, event EvtID: Int32, withParam param: [AnyHashable : Any]!) {
        if EvtID == EVT_VIDEO_PLAY_BEGIN.rawValue {
            
        } else if EvtID == EVT_VIDEO_PLAY_PROGRESS.rawValue {
            if let duration = param[EVT_PLAY_DURATION] as? Float, let progress = param[EVT_PLAY_PROGRESS] as? Float, duration != 0 {
                if !self.rootView.slider.beginTouch {
                    self.duration = duration
                    self.progress = progress
                    self.rootView.slider.slider.value = progress/duration
                }
                
                //播放到一半抖动
                if Int(duration/2) == Int(progress) {
                    self.shakeAnimate()
                }
                if duration == progress {
                    self.animationPlayed = false
                }
            }
        } else if EvtID == EVT_VOD_PLAY_PREPARED.rawValue {
            playerStatus = .puase
            rootView.player.seek(0)
            //            loadingHud.hide()
            
            switch businessType {
            case .mutile:
                if isCanPlay, self.navigationController?.visibleViewController is YXShortVideoMainViewController {
                    rootView.player.resume()
                    playerStatus = .playing
                }
            default:
                rootView.player.resume()
                playerStatus = .playing
            }
            
            
        } else if EvtID == EVT_RENDER_FIRST_I_FRAME.rawValue {
            
        } else if EvtID == EVT_VIDEO_PLAY_END.rawValue {
            //            startPrepare()
            //            self.trackViewEvent(act: "screen_end", other: [YXSensorAnalyticsPropsConstant.PROP_VIDEO_ID:self.model?.videoIdStr ?? "",
            //                                                             YXSensorAnalyticsPropsConstant.PROP_VIDEO_TITLE:self.model?.videoTitle ?? ""])
        }
    }
    
    func onNetStatus(_ player: TXVodPlayer!, withParam param: [AnyHashable : Any]!) {
        
    }
}

extension Notification.Name {
    ///关注操作通知
    static let userFollowAction = Notification.Name("userFollowAction")
}
