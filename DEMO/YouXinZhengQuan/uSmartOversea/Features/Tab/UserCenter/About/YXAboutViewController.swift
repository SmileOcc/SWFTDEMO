//
//  YXAboutViewController.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/13.
//  Copyright © 2019 RenRenDai. All rights reserved.
//
//关于友信
import UIKit
import Reusable
import RxSwift
import RxCocoa
import YXKit


class YXAboutViewController: YXHKViewController, HUDViewModelBased {

    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXAboutViewModel!
    
    var scrollView :UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = QMUITheme().foregroundColor()
        return scrollView
    }()
    
    // 用于触发调试配置的按钮
    lazy var fakeButton: QMUIButton = {
        let fakeButton = QMUIButton()
        return fakeButton
    }()
    
    lazy var titleLabel : QMUILabel = {
        let titleLabel = QMUILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        titleLabel.textColor = QMUITheme().textColorLevel1()
        titleLabel.textAlignment = .center
        #if PRD || PRD_HK
        titleLabel.text = "uSMART " + YXLanguageUtility.kLang(key: "mine_version_info") + " " + YXConstant.appVersion!
        #else
        //多加了一个build号
        titleLabel.text = "uSMART " + YXLanguageUtility.kLang(key: "mine_version_info") + " " + YXConstant.appVersion! + "(" + YXConstant.appBuild! + ")"
        #endif
        
        return titleLabel
    }()
    
//    lazy var versionLab : QMUILabel = {
//        //【版本信息】
//        let versionLab = QMUILabel()
//        versionLab.font = UIFont.systemFont(ofSize: 12)
//        versionLab.textColor = QMUITheme().textColorLevel2()
//        var versionFormat = "%@ %@"
//        if YXUserManager.curLanguage() != .EN {
//            versionFormat = "%@V%@"
//        }
//        #if PRD || PRD_HK
//        versionLab.text = String(format: versionFormat, YXLanguageUtility.kLang(key: "mine_version_info"), YXConstant.appVersion!)
//        #else
//        //多加了一个build号
//        versionFormat += "(%@)"
//        versionLab.text = String(format: versionFormat, YXLanguageUtility.kLang(key: "mine_version_info"), YXConstant.appVersion!, YXConstant.appBuild!)
//        #endif
//
//        return versionLab
//    }()
    
    lazy var logoView : UIView = {
        //【logo图片】
        
        let containView = UIView()
        containView.layer.cornerRadius = uniHorLength(20)
        
        //containView.layer.borderColor = QMUITheme().itemBorderColor().cgColor
        containView.backgroundColor = QMUITheme().foregroundColor()
        
        if !YXThemeTool.isDarkMode() {
            containView.layer.borderColor = UIColor.qmui_color(withHexString: "#F3F3F3")?.cgColor
            containView.layer.borderWidth = 1
        }
        
        let bgView = UIView()
        bgView.clipsToBounds = true
        bgView.layer.cornerRadius = uniHorLength(20)
        
        let logoImgView = UIImageView(image: UIImage(named: "Logo_SC"))
        bgView.addSubview(logoImgView)
        containView.addSubview(bgView)
        logoImgView.snp.makeConstraints { (make) in
            //make.center.equalToSuperview()
            make.edges.equalToSuperview()
        }
        
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return containView
       
    }()
    
    lazy var checkView: UIView = {
        let view = UIView()
      
        //左边文字
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = QMUITheme().textColorLevel1()
        view.addSubview(label)
        label.snp.makeConstraints({ (make) in
            make.left.equalToSuperview().offset(16)
            make.top.bottom.equalToSuperview()
        })
        
        label.text = YXLanguageUtility.kLang(key: "about_update")
        //箭头
        let arrow = UIImageView(image: UIImage(named: "about_detail_arrow"))
        view.addSubview(arrow)
        arrow.snp.makeConstraints({ (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        })
        let tap = UITapGestureRecognizer()
        tap.rx.event.asObservable().subscribe(onNext: {[weak self] (recognizer) in
            guard let `self` = self else {return}
            if YXUpdateManager.shared.needUpdate && YXUpdateManager.shared.updateUrlString.isEmpty == false {
                UIApplication.shared.open(URL(string: YXUpdateManager.shared.updateUrlString)!, completionHandler: nil)
            } else {
                YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "mine_app_did_update_tip"))
               // UIApplication.shared.open(URL(string: YXConstant.appStoreUrl)!, completionHandler: nil)
            }
        }).disposed(by: disposeBag)
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        
        return view
    }()
    
    lazy var debugView: UIView = {
        let view = UIView()
      
        //左边文字
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = QMUITheme().textColorLevel1()
        view.addSubview(label)
        label.snp.makeConstraints({ (make) in
            make.left.equalToSuperview().offset(16)
            make.top.bottom.equalToSuperview()
        })
        
        label.text = "调试配置"
        //箭头
        let arrow = UIImageView(image: UIImage(named: "about_detail_arrow"))
        view.addSubview(arrow)
        arrow.snp.makeConstraints({ (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        })
        let tap = UITapGestureRecognizer()
        tap.rx.event.asObservable().subscribe(onNext: {[weak self] (recognizer) in
            guard let `self` = self else {return}
            
            let context = YXNavigatable(viewModel: YXDebugViewModel())
            self.viewModel.navigator.push(YXModulePaths.debugInfo.url, context: context)
        }).disposed(by: disposeBag)
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        
        return view
    }()
    
    lazy var privacyView: UIView = {
        let view = UIView()
        //左边文字
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = QMUITheme().textColorLevel1()
        label.text = YXLanguageUtility.kLang(key: "about_privacy")
        view.addSubview(label)
        label.snp.makeConstraints({ (make) in
            make.left.equalToSuperview().offset(16)
            make.top.bottom.equalToSuperview()
        })
        //箭头
        let arrow = UIImageView(image: UIImage(named: "about_detail_arrow"))
        view.addSubview(arrow)
        arrow.snp.makeConstraints({ (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        })
        let tap = UITapGestureRecognizer()
        tap.rx.event.asObservable().subscribe(onNext: { [weak self] _ in
            let dic: [String: Any] = [
                YXWebViewModel.kWebViewModelUrl: YXH5Urls.PRIVACY_POLICY_URL(),
                YXWebViewModel.kWebViewModelCachePolicy : URLRequest.CachePolicy.reloadIgnoringLocalCacheData
            ]
            self?.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        }).disposed(by: disposeBag)
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        
        return view
    }()
    
    lazy var serviceView: UIView = {
        let view = UIView()
        //左边文字
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = QMUITheme().textColorLevel1()
        label.text = YXLanguageUtility.kLang(key: "about_service")
        view.addSubview(label)
        label.snp.makeConstraints({ (make) in
            make.left.equalToSuperview().offset(16)
            make.top.bottom.equalToSuperview()
        })
        //箭头
        let arrow = UIImageView(image: UIImage(named: "about_detail_arrow"))
        view.addSubview(arrow)
        arrow.snp.makeConstraints({ (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        })
        let tap = UITapGestureRecognizer()
        tap.rx.event.asObservable().subscribe(onNext: { [weak self] _ in
            let dic: [String: Any] = [
                YXWebViewModel.kWebViewModelUrl: YXH5Urls.USER_REGISTRATION_AGREEMENT_URL(),
                YXWebViewModel.kWebViewModelCachePolicy : URLRequest.CachePolicy.reloadIgnoringLocalCacheData
            ]
            self?.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        }).disposed(by: disposeBag)
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        
        return view
    }()
    
    lazy var gotoScoreView: UIView = {
        let view = UIView()
      
        //左边文字
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = QMUITheme().textColorLevel1()
        view.addSubview(label)
        label.snp.makeConstraints({ (make) in
            make.left.equalToSuperview().offset(16)
            make.top.bottom.equalToSuperview()
        })
        
        label.text = YXLanguageUtility.kLang(key: "about_score")
        //箭头
        let arrow = UIImageView(image: UIImage(named: "about_detail_arrow"))
        view.addSubview(arrow)
        arrow.snp.makeConstraints({ (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        })
        let tap = UITapGestureRecognizer()
        tap.rx.event.asObservable().subscribe(onNext: {[weak self] (recognizer) in
            guard let `self` = self else {return}
            YXGiveScoreAlertView.goToAppCommentStore()
        }).disposed(by: disposeBag)
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        
        return view
    }()
    
    
    
    lazy var introduceView:YXAboutIntroduceView = {
        let introduce = YXAboutIntroduceView.init(config: self.viewModel.introduces)
       // introduce.titleLabel.text = self.viewModel.introducesTip
        return introduce
    }()
    
    lazy var chowTaiFookImageView: UIImageView = {
        var imageName = "chow_tai_fook_en"
        let l = YXUserManager.curLanguage()
        var language = ""
        switch l {
        case .CN:
            imageName = "chow_tai_fook_cn"
        case .HK:
            imageName = "chow_tai_fook_hk"
        default:
            imageName = "chow_tai_fook_en"
        }
        
        let imageView = UIImageView(image: UIImage(named: imageName))
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        bindViewModel()
    }
    
    func initUI() {
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(logoView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(checkView)
        scrollView.addSubview(gotoScoreView)
        scrollView.addSubview(chowTaiFookImageView)
        scrollView.addSubview(introduceView)
    
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeArea.top)
            make.left.right.bottom.equalTo(self.view)
        }

        
        logoView.snp.makeConstraints {[weak self] (make) in
            make.size.equalTo(CGSize(width: 88, height: 88))
            make.centerX.equalTo(self!.view)
            make.top.equalToSuperview().offset(uniHorLength(26))
        }
        
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(logoView.snp.bottom).offset(12)
            make.centerX.equalTo(logoView)
        }
        
        chowTaiFookImageView.snp.makeConstraints { make in
            make.centerX.equalTo(logoView)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
        
//        versionLab.snp.makeConstraints { (make) in
//            make.centerX.equalTo(logoView)
//            make.top.equalTo(titleLabel.snp.bottom).offset(2)
//        }
        
        //添加 打开调试配置的 按钮
        if YXConstant.targetMode() == .prd || YXConstant.targetMode() == .prd_hk {
            self.view.addSubview(self.fakeButton)
            self.fakeButton.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: uniHorLength(100), height: uniHorLength(100)))
                make.centerX.equalTo(self.view)
                make.bottom.equalTo(titleLabel.snp.top).offset(-uniVerLength(13))
            }
            self.fakeButton.addTarget(self, action: #selector(debugAction(sender:)), for: .touchUpInside)
        }
        
        checkView.snp.makeConstraints { (make) in
            make.left.width.equalTo(self.scrollView)
            make.top.equalTo(titleLabel.snp.bottom).offset(24 + 20)
            make.height.equalTo(56)
        }
        
        gotoScoreView.snp.makeConstraints { (make) in
            make.left.width.equalTo(self.scrollView)
            make.top.equalTo(checkView.snp.bottom)
            make.height.equalTo(56)
        }
        
        let lineView = UIView()
        scrollView.addSubview(lineView)
        lineView.backgroundColor = QMUITheme().backgroundColor()
        
        lineView.snp.makeConstraints { (make) in
            make.left.width.equalTo(self.scrollView)
            make.top.equalTo(gotoScoreView.snp.bottom)
            make.height.equalTo(8)
        }
        introduceView.snp.makeConstraints { (make) in
            make.left.width.equalTo(self.scrollView)
            make.top.equalTo(lineView.snp.bottom)
            make.bottom.equalTo(scrollView.snp.bottom).offset(-YXConstant.tabBarPadding())
        }
        
        
        if (YXConstant.targetMode() != .prd && YXConstant.targetMode() != .prd_hk) {
            showDebugEntrance()
        }
        
        introduceView.setTitleText(self.viewModel.introducesTip)
    }
    
    func bindViewModel() {
        
    }
    
    @objc func debugAction(sender: UIButton) {
        YXDebugViewController.debugCounter += 1
        
        // 当次数超过10次时，打开调试配置
        if YXDebugViewController.debugCounter > DEBUG_COUNTER_MAX {
            QMUITips.showSucceed("您已打开调试配置", in: self.view, hideAfterDelay: 1.0)
            
            showDebugEntrance()
        }
    }
    
    private func showDebugEntrance() {
        scrollView.addSubview(debugView)
        
        debugView.snp.makeConstraints { (make) in
            make.left.width.equalTo(self.scrollView)
            make.top.equalTo(chowTaiFookImageView.snp.bottom).offset(-5)
            make.height.equalTo(30)
        }
    }
}
