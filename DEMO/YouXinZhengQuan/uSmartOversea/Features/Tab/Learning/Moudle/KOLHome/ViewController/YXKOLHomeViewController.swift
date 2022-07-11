//
//  YXKOLHomeViewController.swift
//  uSmartEducation
//
//  Created by usmart on 2021/12/2.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import SnapKit
import YXKit
import RxCocoa
import RxSwift
import SDWebImage
//kol主页
class YXKOLHomeViewController: YXHKViewController {
    /// kolID
    var kolId: String?
    
    var viewModel: YXKOLHomeViewModel!
    
    var currentPageViewController: YXKOLHomeContentViewController!
    
    //hearderView高度
    var hearderViewHeight: CGFloat = 326
    
    let followAction = PublishSubject<Bool>()
    
    var shouldShowSubscribView = false {
        didSet {
            self.subscribView.isHidden = !shouldShowSubscribView
        }
    }
    
    lazy var navView: YXKOLHomeNavView = {
        let nav = YXKOLHomeNavView()
        return nav
    }()
    
    lazy var hearderView: YXKOLHomeHeaderView = {
        return YXKOLHomeHeaderView()
    }()
    
    lazy var tabView: YXTabView = {
        let tabLayout = YXTabLayout.default()
        tabLayout.lineHidden = false
        tabLayout.tabMargin = 20
//        tabLayout.leftAlign = true
        tabLayout.lineHeight = 4
        tabLayout.lineCornerRadius = 2
        tabLayout.lineColor = QMUITheme().mainThemeColor()
        tabLayout.lineWidth = 16
        tabLayout.titleFont = .systemFont(ofSize: 16, weight: .regular)
        tabLayout.titleSelectedFont = .systemFont(ofSize: 16, weight: .medium)
        tabLayout.titleColor = QMUITheme().textColorLevel3()
        tabLayout.titleSelectedColor = QMUITheme().mainThemeColor()
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
    
    fileprivate lazy var tabPageView: YXTabPageView = {
        let tabPageView = YXTabPageView(delegate: self)
        if #available(iOS 15.0, *) {
//            tabPageView.mainTableView.sectionHeaderTopPadding = 0
        }
        tabPageView.mainTableView.backgroundColor = .clear
        return tabPageView
    }()
    
    lazy var subscribBtn: QMUIButton = {
        let btn = QMUIButton()
        btn.setBackgroundImage(UIImage(gradientColors: [UIColor(hexString: "FFDA9A")!,UIColor(hexString: "E5AA63")!]), for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "nbb_btn_vip_membership"), for: .normal)
        btn.adjustsButtonWhenHighlighted = false
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        btn.layer.masksToBounds = true
        btn.cornerRadius = 7
        return btn
    }()
    
    lazy var bgImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "kol_page_bg"))
        return view
    }()
    
    lazy var subscribView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().foregroundColor()
        view.addSubview(subscribBtn)
        subscribBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(52)
        }
        return view
    }()
    
    
    /// 子页面-文章
    lazy var articleVC: YXKOLHomeContentViewController = {
        return YXKOLHomeContentViewController(kolId: kolId, businessType: .articles)
    }()
    
    ///子页面-问股
    lazy var answerVC: YXAskListViewController = {
        return YXAskListViewController(businessType: .kol,
                                       kolId: kolId)
    }()
    
    ///子页面-聊天室
    lazy var chatVC: YXKOLHomeContentViewController = {
        return YXKOLHomeContentViewController(kolId: kolId, businessType: .chat)
    }()
    
    ///子页面-短视频
    lazy var videoVC: YXKOLHomeVideoViewController = {
        let vc = YXKOLHomeVideoViewController(kolId: kolId)
        return vc
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
//        UIApplication.shared.statusBarStyle = preStatusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binding()
    }
    
    func menuTitleCtrls(model: YXKOLUserInfoResModel?) {
        if tabView.titles.count > 0 {
            return
        }
        
        if let model = model,let viewsSgSorts = model.viewsSortSg {

            var titlesArray:[String] = []
            var subViewControllers:[UIViewController] = []

            for str in viewsSgSorts{
                switch str {
                case "1":
                    titlesArray.append(YXLanguageUtility.kLang(key: "nbb_master_title_view"))
                    subViewControllers.append(articleVC)
                case "2":
                    titlesArray.append(YXLanguageUtility.kLang(key: "nbb_title_short_video"))
                    subViewControllers.append(videoVC)
                case "3":
                    titlesArray.append(YXLanguageUtility.kLang(key: "nbb_tab_Answer"))
                    subViewControllers.append(answerVC)
                case "4":
                    titlesArray.append(YXLanguageUtility.kLang(key: "nbb_title_chatroom"))
                    subViewControllers.append(chatVC)
                default:
                    break
                }
            }

            tabView.titles = titlesArray
            pageView.viewControllers = subViewControllers
        }
        
        if tabView.titles.count <= 0 {
            tabView.titles = [YXLanguageUtility.kLang(key: "nbb_master_title_view"),
                              YXLanguageUtility.kLang(key: "nbb_title_short_video"),
                              YXLanguageUtility.kLang(key: "nbb_tab_Answer"),
                              YXLanguageUtility.kLang(key: "nbb_title_chatroom")]
            pageView.viewControllers = [articleVC,videoVC,answerVC,chatVC]
        }
        tabView.reloadData()
        pageView.reloadData()
        tabPageView.reloadData()
        currentPageViewController = pageView.viewControllers.first as? YXKOLHomeContentViewController

    }
    
    func setupUI() {
        
        view.addSubview(bgImageView)
        
        view.addSubview(tabPageView)
        view.addSubview(subscribView)
        view.addSubview(navView)
        
        view.backgroundColor = QMUITheme().foregroundColor()
        bgImageView.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 171 + 2)
        navView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(YXConstant.statusBarHeight() + 44)
        }
        
        subscribView.isHidden = true
        subscribView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(52+16+YXConstant.safeAreaInsetsBottomHeight())
        }
        
        tabPageView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(YXConstant.statusBarHeight()+44)
        }
        
        //导航栏左侧 - 返回
//        let backItem = UIBarButtonItem.qmui_item(with: UIImage(named: "nav_back_white") ?? UIImage(), target: self, action: nil)
//        backItem.rx.tap.bind { [weak self] in
//            guard let `self` = self else { return }
//            self.navigationController?.popViewController(animated: true)
//        }.disposed(by: disposeBag)
//        self.navigationItem.leftBarButtonItems = [backItem]
        
//        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func didInitialize() {
        super.didInitialize()
        initInput()
    }
    
    func initInput() {
        let viewDidLoad = self.rx.methodInvoked(#selector(viewDidLoad)).map { [weak self] e in
            return self?.kolId
        }.asDriver(onErrorJustReturn: nil)
        
        viewModel = YXKOLHomeViewModel(input: (viewDidLoad: viewDidLoad,
                                               followAction: followAction.asDriver(onErrorJustReturn: true)))
    }
    func binding() {
        ///kol信息回调
        viewModel.kolUserInfo.drive{ [weak self] res in
            if let res = res {
                self?.configHeaderView(model: res)
                self?.menuTitleCtrls(model: res)
            } else {
                self?.menuTitleCtrls(model: nil)
            }
        }.disposed(by: disposeBag)
        
        ///头部展开点击
        hearderView.expandBtn.rx.tap.subscribe(onNext:{ [weak self] _ in
            guard let `self` = self else { return }
            self.hearderView.expandBtn.isSelected = !self.hearderView.expandBtn.isSelected
            self.hearderView.isExpand =  self.hearderView.expandBtn.isSelected
            self.hearderViewHeight = self.hearderView.systemLayoutSizeFitting(self.view.bounds.size).height
            self.tabPageView.reloadData()
        }).disposed(by: disposeBag)
        
        Driver.merge(hearderView.askBtn.rx.tap.asDriver(),navView.askBtn.rx.tap.asDriver()).drive(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            YXToolUtility.handleBusinessWithLogin {
                let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.ask(replyUid: self.kolId ?? "")]
                NavigatorServices.shareInstance.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            }
        }).disposed(by: disposeBag)
        
        Driver.merge(hearderView.followBtn.rx.tap.asDriver(),navView.followBtn.rx.tap.asDriver()).drive(onNext: { [weak self] in
            guard let `self` = self else { return }
            if self.hearderView.followBtn.isSelected {
                YXAlertTool.commonAlert(title: "",
                                        message: YXLanguageUtility.kLang(key: "nbb_diolog_unfollow_msg"),
                                        leftTitle: YXLanguageUtility.kLang(key: "mine_no"),
                                        rightTitle: YXLanguageUtility.kLang(key: "mine_yes")) { [weak self] in
                    guard let `self` = self else { return }
                } rightBlock: {
                    self.followAction.onNext(false)
                }
            } else {
                self.followAction.onNext(true)
            }
        }).disposed(by: disposeBag)
        
        viewModel.followResult.drive { [weak self] res in
            guard let `self` = self else { return }
            if let res = res {
                if res.code == .success {
                    NotificationCenter.default.post(name: NSNotification.Name(YXLearningViewController.subPageTabFollowBtn), object: nil)
                    self.hearderView.followBtn.isSelected = !self.hearderView.followBtn.isSelected
                    self.navView.followBtn.isSelected = !self.navView.followBtn.isSelected
                    let action = self.hearderView.followBtn.isSelected ? YXShortVideoFollowAction.follow : YXShortVideoFollowAction.unfollow
                    NotificationCenter.default.post(name: Notification.Name.userFollowAction, object: nil, userInfo: ["action":action,"uid":self.kolId ?? ""])
                } else {
                    YXProgressHUD.showError(res.msg)
                }
            }
        }.disposed(by: disposeBag)

        self.tabPageView.mainTableView.rx.contentOffset.subscribe(onNext:{ [weak self] value in
            
            guard let `self` = self else { return }
            
            let width = YXConstant.screenWidth     //图片宽度
            let yOffSet = value.y   //偏移量
            if yOffSet < 0 { //表示向下滑动
                let totalOffset = 171 + abs(yOffSet)
                let f = totalOffset / 171 //缩放系数
                self.bgImageView.frame = CGRect(x: -(f * width - width) / 2, y: 0, width: width * f, height: totalOffset + 2)
            }
            
            if value.y < 120 {
                self.navView.contentView.alpha = value.y/120 >= 1 ? 0 : value.y/120
//                UIApplication.shared.statusBarStyle = .lightContent
                self.navView.backBtn.isHidden = true
                self.navView.backBtn_white.isHidden = false
                return
            }
            self.navView.contentView.alpha = 1
            self.navView.backBtn.isHidden = false
            self.navView.backBtn_white.isHidden = true

//            UIApplication.shared.statusBarStyle = .default
        }).disposed(by: disposeBag)
        
        let _ = self.navView.backBtn.rx.tap.subscribe(onNext:{ _ in
            YXNavigationMap.navigator.popViewModel(animated: true)
        })
        
        let _ = self.navView.backBtn_white.rx.tap.subscribe(onNext:{ _ in
            YXNavigationMap.navigator.popViewModel(animated: true)
        })
        
        self.subscribBtn.rx.tap.subscribe(onNext:{ [weak self] _ in
            guard let `self` = self else { return }
            if let _ = YXUserManager.shared().curLoginUser?.phoneNumber {
                let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.kolPay(kolId: self.kolId ?? "")]
//                NavigatorServices.shareInstance.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                YXNavigationMap.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            } else {
                let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.bindingPhone(type: 2, courseId: self.kolId ?? "")]
                YXNavigationMap.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            }
        }).disposed(by: disposeBag)
    }
    
    func configHeaderView(model: YXKOLUserInfoResModel) {
        self.hearderView.nameLabel.text = model.nickname
        self.navView.nameLabel.text = model.nickname
//        self.shouldShowSubscribView = model.paidType == 0 ? false : !model.hasPurchased
        self.shouldShowSubscribView = false

        self.hearderView.addKolTags(tags: model.kolTag?.compactMap({ tagStr in
            return YXKOLHomeTagType(rawValue: tagStr)
        }) ?? [])
        if let content = model.personalProfile {
            let paragraph = NSMutableParagraphStyle()
            paragraph.minimumLineHeight = 20
            paragraph.lineBreakMode = .byTruncatingTail
            let attributeString = NSMutableAttributedString.init(string: content, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),  NSAttributedString.Key.paragraphStyle : paragraph])
            self.hearderView.desLabel.attributedText = attributeString
            
            ///通过行数判断是否显示展开图标
            let height = YXToolUtility.getStringSize(with: content, andFont: .systemFont(ofSize: 14, weight: .regular), andlimitWidth: (Float(YXConstant.screenWidth)-56.0), andLineSpace: 5).height
            self.hearderView.expandBtn.isHidden =  height < 40
            
        } else {
            self.hearderView.expandBtn.isHidden =  true
        }
        self.hearderView.followBtn.isSelected = model.followFlag
        self.navView.followBtn.isSelected = model.followFlag
        if model.chatRoomFlag {
            self.tabView.showBadge(at: 1)
        }
        if let str = model.avatar, let url = URL(string: str) {
            self.hearderView.kolHeaderView.sd_setImage(with: url, placeholderImage: UIImage(named: "user_default_photo"))
            self.navView.kolHearderImage.sd_setImage(with: url, placeholderImage: UIImage(named: "user_default_photo"))
        } else {
            self.hearderView.kolHeaderView.image = UIImage(named: "user_default_photo")
        }
        self.hearderView.isShowTipsView = !self.subscribView.isHidden
        self.hearderView.vipLabel.text = YXLanguageUtility.kLang(key: "nbb_header_vip_header").replacingOccurrences(of: "{0}", with: model.nickname ?? "")
        self.hearderViewHeight = hearderView.systemLayoutSizeFitting(self.view.bounds.size).height
        self.tabPageView.reloadData()
    
    }
    
}

extension YXKOLHomeViewController: YXTabPageViewDelegate{
        
    func headerViewInTabPage() -> UIView {
        hearderView.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: hearderViewHeight)
        return hearderView
    }
    
    func heightForHeaderViewInTabPage() -> CGFloat {
        return hearderViewHeight
    }
    
    func tabViewInTabPage() -> YXTabView {
        return tabView
    }
    
    func heightForTabViewInTabPage() -> CGFloat {
        return 46
    }
    
    func pageViewInTabPage() -> YXPageView {
        return pageView
    }
    
    func heightForPageViewInTabPage() -> CGFloat {
        return self.view.bounds.size.height - YXConstant.safeAreaInsetsBottomHeight() - 44 - 48
    }
}

extension YXKOLHomeViewController: YXTabViewDelegate {
    func tabView(_ tabView: YXTabView, didSelectedItemAt index: UInt, withScrolling scrolling: Bool) {
        currentPageViewController = pageView.viewControllers[Int(index)] as? YXKOLHomeContentViewController
        if shouldShowSubscribView {
            subscribView.isHidden = !(currentPageViewController == articleVC)
        }
        
        if (currentPageViewController == chatVC) {
            tabView.hideBadge(at: 2)
        }
    }
}

