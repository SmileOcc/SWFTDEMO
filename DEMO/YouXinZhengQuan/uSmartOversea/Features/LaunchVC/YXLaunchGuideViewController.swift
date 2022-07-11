//
//  YXLaunchGuideViewController.swift
//  YouXinZhengQuan
//
//  Created by Mac on 2019/10/25.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator

import SDCycleScrollView

import SnapKit

import GoogleSignIn

class YXLaunchGuideViewController: YXHKViewController {
    
    let disposeBag = DisposeBag()
    //回调 关闭
    var dismissClosure: (() -> Void)!
    
    private var navigator: NavigatorType?
    private var services: AppServices?
    private var enterButton: UIButton? // 立即体验
    private var pageTitleLab: UILabel? //第二页文字
    
    private var numberOfGuide: Int {
       4
    }
    private var scrollContentHeight: CGFloat {
        YXConstant.screenHeight - YXConstant.statusBarHeight() - YXConstant.safeAreaInsetsBottomHeight()
    }
    
    private lazy var pageControl: TAPageControl = {
        let pageControl = TAPageControl()
        pageControl.numberOfPages = numberOfGuide
        pageControl.isUserInteractionEnabled = false
        pageControl.hidesForSinglePage = true
        pageControl.currentPage = 0
        let dotSize = CGSize(width: 12, height: 4)
        pageControl.currentDotImage = UIImage.qmui_image(with: QMUITheme().mainThemeColor(), size: dotSize, cornerRadius: 3)
        pageControl.dotImage = UIImage.qmui_image(with: QMUITheme().blockColor(), size: dotSize, cornerRadius: 3)
        return pageControl
    }()
    
    private lazy var guideScrollView:UIScrollView = {
        let scroll = UIScrollView.init(frame: UIScreen.main.bounds)
        scroll.contentSize = CGSize(width: YXConstant.screenWidth * CGFloat(numberOfGuide), height: 0)
        scroll.isPagingEnabled = true
        scroll.bounces = true
      //  scroll.backgroundColor = UIColor.qmui_color(withHexString: "#D2F3FF")
        scroll.showsHorizontalScrollIndicator = false
        return scroll
    }()
    
    private lazy var bgImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.init(named: "guide_page_bg")
        return imageView
    }()
    
    private lazy var animatedViewArr: [UIImageView] = {
        var arr = [UIImageView]()
        for i in 0 ..< numberOfGuide {
            var image = UIImage(named: "guide_page\(i)")
            if YXUserManager.curLanguage() == .CN {
                image = UIImage(named: "guide_page_cn\(i)")
            }
         //   let edgeInset = UIEdgeInsets(top: image!.size.height*0.8, left: 0, bottom: 0, right: 0)
            let animationView = UIImageView(image: image?.resizableImage(withCapInsets: .zero, resizingMode: .stretch))
            arr.append(animationView)
        }
        return arr
    }()
    
    private var isLogin: Bool = false //缓存是否登录

    override func viewDidLoad() {
        super.viewDidLoad()
        
        isLogin = YXUserManager.isLogin() //初始化

        // Do any additional setup after loading the view.
        initUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ///TODO:从登录页面返回时，把GuideToLogin 设置为false
        YXLaunchGuideManager.setGuideToLogin(withFlag: false)   //关闭从引导页到登录的标记
        
        
        //为解决：在引导页，外部跳转进来，登录成功，后面返回到引导页时，按钮的变化。
        if isLogin != YXUserManager.isLogin() {
            //更新按钮
            self.refreshBtn()
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)        
    }
    
    override func preferredNavigationBarHidden() -> Bool {
        return true
    }
    
    
    init(navigator: NavigatorServicesType, andServices: AppServices) {
        super.init(nibName: nil, bundle: nil)
        self.navigator = navigator
        self.services = andServices
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func refreshBtn() {
        setupButton()
    }
    
    func setupButton() {
        //移除之前的button按钮
        for btn in self.view.subviews where btn.isKind(of: UIButton.self) {
            btn.removeFromSuperview()
        }
        
        //代码和 initUI()中的一致
        YXUserManager.getLocalShowLoginRegister()

        YXUserManager.shared().fetchGrayStatusBit({
            if YXUserManager.isLogin() == false {
                YXUserManager.getLocalShowLoginRegister()
            }
         })
//        for lab in self.view.subviews where lab.isKind(of: UILabel.self) {
//            lab.removeFromSuperview()
//        }
        
        //代码和 initUI()中的一致
//        if YXUserManager.isLogin() {
//            //立即体验
//            let notLoginBtn: UIButton = {
//                let button = UIButton(type: .custom)
//                button.setTitle(YXLanguageUtility.kLang(key: "guide_nowGo"), for: .normal)
//                button.backgroundColor = QMUITheme().mainThemeColor()
//                button.layer.cornerRadius = 4
//                button.setTitleColor(.white, for: .normal)
//                return button
//            }()
//            self.enterButton = notLoginBtn
//            view.addSubview(notLoginBtn)
//            notLoginBtn.addTarget(self, action: #selector(notLoginClick), for: .touchUpInside)
//            notLoginBtn.snp.makeConstraints { (make) in
//                make.centerX.equalToSuperview()
//                make.bottom.equalToSuperview().offset(-84)
//                make.size.equalTo(CGSize(width: 102, height: 30))
//            }
//            if self.pageControl.currentPage == numberOfGuide - 1 {
//                notLoginBtn.isHidden = false
//            }else {
//                notLoginBtn.isHidden = true
//            }
//        } else {
//            //登录/注册
//            let loginRegisterBtn: UIButton = {
//                let button = UIButton(type: .custom)
//                button.setTitle(YXLanguageUtility.kLang(key: "default_loginTip"), for: .normal)
//                button.backgroundColor = QMUITheme().mainThemeColor()
//                button.layer.cornerRadius = 4
//                button.setTitleColor(.white, for: .normal)
//                return button
//            }()
//
//            view.addSubview(loginRegisterBtn)
//            self.enterButton = loginRegisterBtn
//            loginRegisterBtn.addTarget(self, action: #selector(loginClick), for: .touchUpInside)
//
//            loginRegisterBtn.snp.makeConstraints { (make) in
//                make.centerX.equalToSuperview()
//                make.bottom.equalToSuperview().offset(-84)
//                make.size.equalTo(CGSize(width: 102, height: 30))
//            }
//
//            if self.pageControl.currentPage == numberOfGuide - 1 {
//                loginRegisterBtn.isHidden = false
//            }else {
//                loginRegisterBtn.isHidden = true
//            }
//        }
        
        //立即体验
        let notLoginBtn: UIButton = {
            let button = UIButton(type: .custom)
            button.setTitle(YXLanguageUtility.kLang(key: "guide_nowGo"), for: .normal)
            if !YXUserManager.isLogin() && YXUserManager.isGuideShowLoginRegister(){
                button.setTitle(YXLanguageUtility.kLang(key: "default_loginTip"), for: .normal)
            }
            button.backgroundColor = QMUITheme().mainThemeColor()
            button.layer.cornerRadius = 4
            button.titleLabel?.font = .systemFont(ofSize: 16)
            button.setTitleColor(.white, for: .normal)
            return button
        }()
        self.enterButton = notLoginBtn
        view.addSubview(notLoginBtn)
        notLoginBtn.addTarget(self, action: #selector(notLoginClick), for: .touchUpInside)
        notLoginBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            //make.bottom.equalTo(pageControl.snp.bottom).offset(20)
            make.centerY.equalTo(pageControl)
            make.size.equalTo(CGSize(width: 189, height: 48))
        }
        if self.pageControl.currentPage == numberOfGuide - 1 {
            notLoginBtn.isHidden = false
        }else {
            notLoginBtn.isHidden = true
        }
        
        //跳过
        let skipBtn: UIButton = {
            let button = UIButton(type: .custom)
            button.setTitle(YXLanguageUtility.kLang(key: "launch_Guide_skip"), for: .normal)
            button.backgroundColor = UIColor.qmui_color(withHexString: "#3056AB")?.withAlphaComponent(0.4)
            button.layer.cornerRadius = 11
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            button.setTitleColor(QMUITheme().foregroundColor(), for: .normal)
            return button
        }()
        view.addSubview(skipBtn)
        skipBtn.addTarget(self, action: #selector(notSkipLoginClick), for: .touchUpInside)
        skipBtn.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(20 + YXConstant.statusBarHeight())
            make.size.equalTo(CGSize(width: 49, height: 22))
        }
   
    }
    
    private func initUI() {
        
        view.addSubview(bgImageView)
        bgImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.guideScrollView.delegate = self as UIScrollViewDelegate
        self.view.addSubview(self.guideScrollView)
        
        let safeAreaBottomHeight = YXConstant.safeAreaInsetsBottomHeight()
        self.view.addSubview(self.pageControl)
        self.pageControl.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-(64 + safeAreaBottomHeight))
        }
        
        let titleArr = ["guide_page0_title", "guide_page1_title", "guide_page2_title", "guide_page3_title", "guide_page4_title", "guide_page5_title"]
        let descArr = ["guide_page0_desc", "guide_page1_desc", "guide_page2_desc", "guide_page3_desc", "guide_page4_desc", "guide_page5_desc"]
//        var largeStrs: [[String]] = []
//        var font = UIFont.systemFont(ofSize: 20)
//        var largeFont = UIFont.systemFont(ofSize: 20)
//        if YXUserManager.curLanguage() == .CN {
//            largeStrs = [["获周大福代理人有限公司"], ["0佣金","低41%","2.98%","3.98%","0认购费"], ["BeeRich App","10个知名老师"], ["10种智能下单类型"], ["港美A","3只优质股票","10个智投策略"],["40档","稳定快捷"]]
//        }else if YXUserManager.curLanguage() == .HK {
//            largeStrs = [["獲周大福代理人有限公司"], ["0佣金","平41%","2.98%","3.98%","0認購費"], ["BeeRich App","10個知名老師"], ["10種智能下單功能"], ["港美A","3隻優質股票","10個智投策略"],["40檔","穩定快捷"]]
//        }else if YXUserManager.curLanguage() == .EN {
//            largeStrs = [["Chow Tai Fook Nominee Limited"], ["0 commission","41% lower","2.98%","3.98%","0 subscription fee"], ["BeeRich App","10 well-known teachers"],["10 types of smart order"], ["HK/ US / A-share","10 smart strategy"], ["40 columns US stock","Stable and Fast"]]
//            font = .systemFont(ofSize: 14)
//            largeFont = UIFont.systemFont(ofSize: 14)
//        }
        
        
        for i in 0 ..< numberOfGuide {
            
            let baseView = UIView.init(frame: CGRect(x: YXConstant.screenWidth * CGFloat(i), y: 0, width: YXConstant.screenWidth, height: scrollContentHeight + YXConstant.tabBarPadding()))
           // baseView.backgroundColor = UIColor.qmui_color(withHexString: "#D2F3FF")
            self.guideScrollView.addSubview(baseView)
            
            let animationView = animatedViewArr[i]
            baseView.addSubview(animationView)
            
            let wholeText = YXLanguageUtility.kLang(key: descArr[i])
         //   let shouldLargeStrs = largeStrs[i]
            var font = UIFont.systemFont(ofSize: uniHorLength(12), weight: .regular)
            
            if i == 0 {
                font = UIFont.systemFont(ofSize: uniHorLength(16), weight: .semibold)
            }
            
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineSpacing = 4
            paragraph.alignment = .center
            
            let attributeString = NSMutableAttributedString.init(string: wholeText, attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor : UIColor.qmui_color(withHexString: "#FFFFFF")!, NSAttributedString.Key.paragraphStyle : paragraph])
            
//            for str in shouldLargeStrs {
//                let range = (wholeText as NSString).range(of: str)
//                attributeString.addAttributes([NSAttributedString.Key.font : largeFont, NSAttributedString.Key.foregroundColor : UIColor.qmui_color(withHexString: "#0074E5")!], range: range)
//            }
            //描述
            
            let descContentView = UIView.init()
            descContentView.backgroundColor = .clear
            baseView.addSubview(descContentView)
            
            
            let desc = UILabel()
            desc.attributedText = attributeString
            desc.textAlignment = .center
            desc.minimumScaleFactor = 0.5
            desc.adjustsFontForContentSizeCategory = true
            desc.adjustsFontSizeToFitWidth = true
            desc.numberOfLines = 4
            descContentView.addSubview(desc)
          
            
            
            //标题
            let title = UILabel()
            title.text = YXLanguageUtility.kLang(key: titleArr[i])
            title.textColor = UIColor.qmui_color(withHexString: "#FFFFFF")
            if i == 0 {
                title.font = .systemFont(ofSize: uniHorLength(20), weight: .semibold)
            }else {
                title.font = .systemFont(ofSize: uniHorLength(18), weight: .semibold)
            }
            title.numberOfLines = 2
            title.textAlignment = .center
            title.adjustsFontSizeToFitWidth = true
            descContentView.addSubview(title)

            
            if animationView.image != nil {
                let sacal = animationView.image!.size.height / animationView.image!.size.width
                let width = YXConstant.screenWidth / 375 * animationView.image!.size
                    .width
                animationView.snp.makeConstraints { (make) in
                    make.top.equalTo(descContentView.snp.bottom).offset(17)
                    make.width.equalTo(width)
                    make.height.equalTo(animationView.snp.width).multipliedBy(sacal)
                    make.centerX.equalToSuperview()
                    make.center.equalToSuperview().offset(30)
                }
            } 
            
//            if (IS_65INCH_SCREEN || IS_61INCH_SCREEN || IS_58INCH_SCREEN || IS_NOTCHED_SCREEN) {
//                // x xr xsmax
//                imageNames = @[@"guide_ipx_1", @"guide_ipx_2", @"guide_ipx_3", @"guide_ipx_4"];
//            }else if (IS_55INCH_SCREEN || IS_47INCH_SCREEN) {
//                // 8 8plus
//                imageNames = @[@"guide_ip8_1", @"guide_ip8_2", @"guide_ip8_3", @"guide_ip8_4"];
//            }else {
//                // 5s se
//                imageNames = @[@"guide_se_1", @"guide_se_2", @"guide_se_3", @"guide_se_4"];
//            }
            
            
            title.snp.makeConstraints { (make) in
                make.leading.equalToSuperview()
                make.top.equalToSuperview()
                make.trailing.equalToSuperview()
            }
            
            
            descContentView.snp.makeConstraints { (make) in
                make.leading.equalToSuperview().offset(50)
                make.trailing.equalToSuperview().offset(-50)
                make.height.lessThanOrEqualTo(100)
            }
            
            
            desc.snp.makeConstraints { (make) in
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.top.equalTo(title.snp.bottom).offset(10)
                make.bottom.equalToSuperview()

            }
        }
        
        setupButton()

    }
    
    @objc func loginClick() {
        //登录/注册成功的 回调
        let callback: (([String: Any])->Void)? = {[weak self] _ in
            self?.notLoginClick()
        }
        YXLaunchGuideManager.setGuideToLogin(withFlag: true)  //做标记
        let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: callback, vc: self))
        self.navigator?.push(YXModulePaths.defaultLogin.url, context: context)
    }
    
    @objc func notSkipLoginClick() {
        
        //存在deeplink不处理登录灰度
        if YXUserManager.isGuideShowLoginRegister() {
//            MMKV.default().set(false, forKey: "YXIsInstallCacheKey") //设置：不是 新版本app
//            YXUserManager.registerLoginInitRootViewControler()
//            MMKV.default().set(YXConstant.appVersion ?? "", forKey: "YXShortVersion")
            //登录/注册成功的 回调
            let callback: (([String: Any])->Void)? = {[weak self] _ in
                self?.notLoginClick()
            }
            YXLaunchGuideManager.setGuideToLogin(withFlag: true)  //做标记
            let loginModel = YXLoginViewModel(callBack: callback, vc: self)
            let context = YXNavigatable(viewModel: loginModel)
            self.navigator?.push(YXModulePaths.defaultLogin.url, context: context)
            
            return
        }
        MMKV.default().set(false, forKey: "YXIsInstallCacheKey") //设置：不是 新版本app
        self.dismissClosure()
        //保存当前的 appVersion
        MMKV.default().set(YXConstant.appVersion ?? "", forKey: "YXShortVersion")
    }
    @objc func notLoginClick() {
//        if !MMKV.default().bool(forKey: YXConstant.firstLaunchKeyForHotStock) {
//            MMKV.default().set(true, forKey: YXConstant.firstLaunchKeyForHotStock)
//            let hotStockViewModel = YXHotStockViewModel(services: navigator as! YXViewModelServices, params: nil)
//            hotStockViewModel.dismissBlock = {
//                self.dismissClosure()
//            }
//            let vc = YXHotStockViewController(viewModel: hotStockViewModel)
//            vc.modalPresentationStyle = .fullScreen
//            navigator?.present(vc)
//        } else {
//            MMKV.default().set(false, forKey: "YXIsInstallCacheKey") //设置：不是 新版本app
//            //没有保存过appVersion
//            let cacheVersion: String = MMKV.default().string(forKey: "YXShortVersion") ?? ""
//            if cacheVersion.isEmpty == true {
//                //cacheVersion.isEmpty == true  --->  新安装的，即：不是升级上来的 --->  需要显示
//                let context = YXNavigatable(viewModel: YXPreferenceSetViewModel(finishClosure:self.dismissClosure))
//                navigator?.push(YXModulePaths.preferenceSetting.url, context: context)
//            } else {
//                //cacheVersion.isEmpty == false  --->  升级上来的 --->  不需要显示
//                self.dismissClosure()
//            }
//            //保存当前的 appVersion
//            MMKV.default().set(YXConstant.appVersion ?? "", forKey: "YXShortVersion")
//        }
        
        if !YXUserManager.isLogin() && YXUserManager.isGuideShowLoginRegister() {
//            MMKV.default().set(false, forKey: "YXIsInstallCacheKey") //设置：不是 新版本app
//            YXUserManager.registerLoginInitRootViewControler()
//            MMKV.default().set(YXConstant.appVersion ?? "", forKey: "YXShortVersion")
            //登录/注册成功的 回调
            let callback: (([String: Any])->Void)? = {[weak self] _ in
                self?.notLoginClick()
            }
            YXLaunchGuideManager.setGuideToLogin(withFlag: true)  //做标记
            let loginModel = YXLoginViewModel(callBack: callback, vc: self)
            //去掉，【登录注册】走灰度埋点事件
            //loginModel.isGuideLoginRegister = true
            let context = YXNavigatable(viewModel: loginModel)
            self.navigator?.push(YXModulePaths.defaultLogin.url, context: context)
            
            return
        }
        MMKV.default().set(false, forKey: "YXIsInstallCacheKey") //设置：不是 新版本app
        self.dismissClosure()
        //保存当前的 appVersion
        MMKV.default().set(YXConstant.appVersion ?? "", forKey: "YXShortVersion")
    }

}

extension YXLaunchGuideViewController: UIScrollViewDelegate {
    //scrollView 已结束 减速
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = self.guideScrollView.contentOffset.x / YXConstant.screenWidth
        self.pageControl.currentPage = Int(index)
        self.enterButton?.isHidden = self.pageControl.currentPage != numberOfGuide - 1
        self.pageControl.isHidden = !self.enterButton!.isHidden
    }
}
