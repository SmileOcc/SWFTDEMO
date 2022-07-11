//
//  YXCourseDetailViewController.swift
//  uSmartEducation
//
//  Created by usmart on 2021/11/10.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import SnapKit
import YXKit
import RxCocoa
import RxSwift
import TXLiteAVSDK_Professional

class YXCourseDetailViewController: YXHKViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var isFreeCourse = true
    fileprivate var shareUrl = YXUrlRouterConstant.staticResourceBaseUrl() + "/webapp/course/course-details.html?courseId={0}&appType=12&langType=\(YXUserHelper.currentLanguage())#/intro"
    //播放器
    lazy var player: YXVodPlayerView = {
        let view = YXVodPlayerView()
        view.delegate = self
        ///旋转屏幕回调
        view.rotateCallback = { [weak view ] (isFullScreen,isPortrait) in
            UIView.animate(withDuration: 0.3, animations: {
                if (isFullScreen) {
                    if (isPortrait) {
                        view?.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: YXConstant.screenHeight)
                    } else {
                        view?.frame = CGRect(x: 0, y: 0, width: YXConstant.screenHeight, height: YXConstant.screenWidth)
                    }
                } else {
                    view?.frame = CGRect(x: 0, y: YXConstant.statusBarHeight(), width: YXConstant.screenWidth, height: 221)
                }
            })
        }
        //点击返回回调
        view.backBtnTapCallback = {
            NavigatorServices.shareInstance.popViewModel(animated: true)
        }
        view.moreBtn.isHidden = true
        return view
    }()
    
    lazy var bottomView: YXCourseDetailBottomView = {
        let view = YXCourseDetailBottomView()
        return view
    }()
    
    lazy var tabView: YXTabView = {
        let tabLayout = YXTabLayout.default()
        tabLayout.lineHidden = false
        tabLayout.tabMargin = 20
        tabLayout.lineHeight = 4
        tabLayout.lineCornerRadius = 2
        tabLayout.lineColor = QMUITheme().mainThemeColor()
        tabLayout.lineWidth = 16
        tabLayout.titleFont = .systemFont(ofSize: 16)
        tabLayout.titleSelectedFont = .systemFont(ofSize: 16, weight: .semibold)
        tabLayout.titleColor = QMUITheme().textColorLevel3()
        tabLayout.titleSelectedColor = QMUITheme().mainThemeColor()
//        tabLayout.tabColor = QMUITheme().themeTextColor().withAlphaComponent(0.1)
//        tabLayout.tabSelectedColor = QMUITheme().themeTextColor().withAlphaComponent(0.1)
        let tabView = YXTabView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 44), with: tabLayout)
        tabView.backgroundColor = QMUITheme().foregroundColor()
        tabView.pageView = pageView
        tabView.delegate = self
        return tabView
    }()
    
    lazy var pageView: YXPageView = {
        let pageView = YXPageView(frame: view.bounds)
        pageView.parentViewController = self
        return pageView
    }()
    
    lazy var contentsVC: YXCourseDetailLessonViewController = {
        let vc = YXCourseDetailLessonViewController()
        vc.viewModel.courseId = viewModel.courseId
        vc.viewModel.isUserPayed = viewModel.isUserPayed
        vc.viewModel.selectedLesson.subscribe(onNext: { [weak self] value in
            guard let `self` = self else { return }
            let (lessonModel,recordModle) = value
            if let lessonModel = lessonModel, let vedioModel = lessonModel.videoList.first {
                self.viewModel.currentLesson = lessonModel
                self.viewModel.lessonId = vedioModel.lessonIdStr
                self.reloadQuizAction.onNext(vedioModel.lessonIdStr)
                self.commentVC.viewModel.lessonId = vedioModel.lessonIdStr ?? ""
                if let url = vedioModel.videoInfo {
                    self.coursewareVC.vm.videoId.accept(vedioModel.videoIdStr)
                    self.coursewareVC.vm.lessonId.accept(vedioModel.lessonIdStr)
                    var duration = 0
                    ///判断记录是否是当前视频
                    if let recordModel = recordModle,recordModel.lessonId == lessonModel.lessonId, recordModel.videoIdStr == vedioModel.videoIdStr {
                        duration = recordModel.watchTimePosition
                    }
                    self.viewModel.videoId = vedioModel.videoId
                    self.player.play(url: url, duration: Float(duration))
                    self.player.lessonNameLable.text = lessonModel.courseName
                }
            }
            self.infoHearder.titleLabel.text = "--"
            if let name = lessonModel?.lessonName,!name.isEmpty{
                self.infoHearder.titleLabel.text = name
            }
            self.infoHearder.descLabel.text = "--"
            if let desc = lessonModel?.lessonDesc,!desc.isEmpty{
                self.infoHearder.descLabel.text = lessonModel?.lessonDesc
            }
            _ = self.infoHearder.needHideExpandBtn(lessonDesc: self.infoHearder.descLabel.text!)
            //self.infoHearder.favoriteBtn.isSelected = lessonModel?.favoriteFlag ?? false
        }).disposed(by: disposeBag)
        return vc
    }()
    
    ///课件vc
    lazy var coursewareVC: YXCourseDetailCoursewareViewController = {
        return YXCourseDetailCoursewareViewController()
    }()
    
    lazy var commentVC : YXCommentViewController1 = {
        
        let vc = YXCommentViewController1()
        vc.viewModel.lessonId = self.viewModel?.lessonId ?? ""
//        vc.getDataCompleteBlock = { [weak self]count in
//            //self?.bottomSheet.titleLabel.text = "\(count)" + YXLanguageUtility.kLang(key: "nbb_commentcount")
//        }
        return vc
    }()
    
    let testBtn : QMUIButton = {
        let btn = QMUIButton()
        btn.setImage(UIImage.init(named: "course_test"), for: .normal)
        btn.isHidden = true
        return btn
    }()
    
    
    ///顶部课程标题
    lazy var infoHearder: YXCourseDetailInfoView = {
        return YXCourseDetailInfoView()
    }()
    

    
    var viewModel: YXCourseDetailViewModel!
    
    //随堂小测
    let reloadQuizAction = PublishSubject<String?>()
    
    var isDisplayAlert = false
    
    let playerHeight: CGFloat = 9/16*YXConstant.screenWidth
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binding()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        player.resume()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player.pause()
        saveUserRecord()
    }
    
    deinit {
        player.stop()
    }
    
    override func didInitialize() {
        super.didInitialize()
        
//        let collectAction = self.infoHearder.favoriteBtn.rx.tap.map { [weak self]_ in
//            guard let `self` = self else { return false }
//            return !self.infoHearder.favoriteBtn.isSelected
//        }.asDriver(onErrorJustReturn: false)
        viewModel = YXCourseDetailViewModel(reloadQuizAction: reloadQuizAction.asDriver(onErrorJustReturn: ""))
    }
    
    func setupUI() {
        
        view.backgroundColor = QMUITheme().backgroundColor()
        let playerBgView = UIView()
        view.addSubview(player)
        view.addSubview(playerBgView)
        view.addSubview(infoHearder)
        view.addSubview(tabView)
        view.addSubview(pageView)
        view.addSubview(bottomView)
        view.addSubview(testBtn)
        view.bringSubviewToFront(player)
        
        let lineView = UIView.init()
        lineView.backgroundColor = QMUITheme().separatorLineColor()
        view.addSubview(lineView)

        player.frame = CGRect(x: 0, y: YXConstant.statusBarHeight(), width: YXConstant.screenWidth, height: playerHeight)
        playerBgView.backgroundColor = .black
        playerBgView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(playerHeight+YXConstant.statusBarHeight())
        }
        
        infoHearder.snp.makeConstraints { make in
            make.top.equalTo(playerBgView.snp.bottom)
            make.left.right.equalToSuperview()
        }
        
        tabView.snp.makeConstraints { make in
            make.top.equalTo(infoHearder.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(tabView.snp.bottom)
            make.height.equalTo(0.5)
        }
        
        pageView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(lineView.snp.bottom)
        }
        
        bottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(52 + YXConstant.safeAreaInsetsBottomHeight())
        }
        
        testBtn.snp.makeConstraints { make in
            make.size.equalTo(66)
            make.bottom.equalTo(bottomView.snp.top).offset(-14)
            make.right.equalToSuperview().offset(-16)
        }
        
        tabView.titles = [YXLanguageUtility.kLang(key: "nbb_contents"),YXLanguageUtility.kLang(key: "nbb_courseware"),YXLanguageUtility.kLang(key: "nbb_discussions")]
        pageView.viewControllers = [contentsVC,coursewareVC,commentVC]
        
    }
    
    func binding() {
        ///判断课程
        viewModel.fetchUserPurchased().subscribe { [weak self] res in
            if let res = res {
                self?.isFreeCourse = res.isFreeCourse
            }
        } onError: { [weak self] err in
        }.disposed(by: disposeBag)
        
//        viewModel.collectResult.drive { [weak self] result in
//            if let result = result {
//                self?.infoHearder.favoriteBtn.isSelected = result
//                if result {
//                    YXProgressHUD.showMessage(YXLanguageUtility.kLang(key:"nbb_collectsuccess"))
//                }
//            }
//        }.disposed(by: disposeBag)
        
        viewModel.hasQuiz.drive{ [weak self] value in
            let (examPaperId,shouldTestAfterFinish) = value
            self?.testBtn.isHidden = examPaperId == nil
            if let examPaperId = examPaperId {
                self?.viewModel.examPaperId = examPaperId
            } else {
                self?.viewModel.examPaperId = nil
            }
        }.disposed(by: disposeBag)
//
//        _ = bottomView.testBtn.rx.tap.subscribe(onNext: { [weak self] (_) in
//            if let examPaperId = self?.viewModel?.examPaperId, let lessonId = self?.viewModel?.lessonId {
//                let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.courseTest(examPaperId: "\(examPaperId)", lessonId: lessonId)]
//                NavigatorServices.shareInstance.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
//            }
//        })
        
        bottomView.commentView.qmui_tapBlock = { [weak self] _ in
            guard let `self` = self else { return }
            YXToolUtility.handleBusinessWithLogin {
                self.tabView.selectTab(at: 2, animated: false)
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                    self.commentVC.benginInput()
                }
            }
        }
        
        bottomView.shareBtn.rx.tap.subscribe(onNext:{ [weak self] _ in
            guard let `self` = self else { return }

            let shareView = YXShareCommonView(frame: UIScreen.main.bounds,sharetype: .link, isShowCommunity:false)
            shareView.shareTitle = self.viewModel.currentLesson?.courseName
            shareView.shareText = self.viewModel.currentLesson?.courseName
            if self.isFreeCourse {
                shareView.shareUrl = YXH5Urls.courseUrl(courseId: self.viewModel.currentLesson?.courseIdStr ?? "",
                                                        lessonId: self.viewModel.currentLesson?.lessonIdStr ?? "")
            } else {
                shareView.shareUrl = self.shareUrl.replacingOccurrences(of: "{0}", with: self.viewModel.courseId ?? "")
            }
            shareView.showShareBottomView()
            
        }).disposed(by: disposeBag)

        _ = testBtn.rx.tap.subscribe(onNext: { [weak self] (_) in

            if let examPaperId = self?.viewModel?.examPaperId, let lessonId = self?.viewModel?.lessonId {
                let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.courseTest(examPaperId: "\(examPaperId)", lessonId: lessonId)]
                NavigatorServices.shareInstance.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            }
        })
        
    }
    
    func saveUserRecord() {
        if self.viewModel.videoId != 0 && self.player.duration > 0 {
            self.viewModel.userCourseRecord(watchProgress: Int((self.player.progress/self.player.duration)*100),
                                       watchTimePosition: Int(self.player.progress))
        }
    }
    
}

extension YXCourseDetailViewController: YXTabViewDelegate{
    func tabView(_ tabView: YXTabView, didSelectedItemAt index: UInt, withScrolling scrolling: Bool) {
        if self.viewModel.examPaperId != nil {
            self.testBtn.isHidden = index == 2
        }
    }
}

extension YXCourseDetailViewController: YXVodPlayerViewDelegate {
    func onPlayEvent(_ player: YXVodPlayerView!, event EvtID: Int32, withParam param: [AnyHashable : Any]!) {
        ///试听用户
        if viewModel.isUserPayed == false {
            switch EvtID {
            case PLAY_EVT_PLAY_PROGRESS.rawValue:
                if let duration = param[EVT_PLAY_DURATION] as? Float, let progress = param[EVT_PLAY_PROGRESS] as? Float  {
                    if duration == progress && !isDisplayAlert {
                        ///增加一个标志位来表示是否有弹窗显示,处理多次弹窗问题
                        self.isDisplayAlert = true
                        self.player.pause()
                        YXCourseDetailViewController.showPurchase(courseId: self.viewModel.courseId) { [weak self] _ in
                            self?.isDisplayAlert = false
                        }
                    }
                    
                }
                break
            default:
                break
            }
        }
    }
    
    static func showPurchase(courseId: String?, callback:((Bool)->Void)?) {
        YXAlertTool.commonAlert(title: "", message: YXLanguageUtility.kLang(key: "nbb_purchasealert"), leftTitle: YXLanguageUtility.kLang(key: "nbb_isee"), rightTitle: YXLanguageUtility.kLang(key: "nbb_joinin")) {
            callback?(true)
        } rightBlock: {
            callback?(true)
            guard let courseId = courseId else {
                return
            }
            if YXUserManager.isLogin() && YXUserManager.shared().curLoginUser?.phoneNumber != nil {
                let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.coursePay(courseId: courseId)]
                YXNavigationMap.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic), from: nil, animated: true)
                
            } else {
                let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.bindingPhone(type: 1, courseId: courseId)]
                YXNavigationMap.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic), from: nil, animated: true)
            }
        }
    }
}

