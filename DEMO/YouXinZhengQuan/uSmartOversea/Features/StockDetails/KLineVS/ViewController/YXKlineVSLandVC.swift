//
//  YXKlineVSLandVC.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2021/2/4.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import YXKit
import RxSwift

class YXKlineVSLandVC: YXViewController {

    var vsViewModel: YXKlineVSLandViewModel {
        let vm = viewModel as! YXKlineVSLandViewModel
        return vm
    }

    var progressHUD: YXProgressHUD?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.forceToLandscapeRight = true

        initUI()

//        if let nav = UIViewController.current().navigationController,
//           nav.viewControllers.count >= 1 {
//            var vcArray = nav.viewControllers
//            for (index, vc) in nav.viewControllers.enumerated() {
//                if vc.isKind(of: YXVSSearchViewController.self) {
//                    vcArray.remove(at: index)
//                    break
//                }
//            }
//            nav.viewControllers = vcArray
//        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.progressHUD = YXProgressHUD.showLoading("", in: self.view)
        self.vsViewModel.dataSourceObservable.subscribe(onNext: {
            [weak self] _ in
            guard let `self` = self else { return }
            self.progressHUD?.hide(animated: true)
//            self.klineVSView.refreshUI()
            YXKlineVSTool.shared.calculatelSelectList()
            self.klineVSView.refreshAfterCalculatelSelectListUI()

        }).disposed(by: rx.disposeBag)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func preferredNavigationBarHidden() -> Bool {
        return true
    }

    func initUI() {
        self.view.backgroundColor = QMUITheme().foregroundColor()
        self.view.addSubview(backButton)
        self.view.addSubview(topLabel)
        self.view.addSubview(changeButton)

        backButton.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *), YXConstant.deviceScaleEqualToXStyle() {
                make.left.equalTo(self.view.safeAreaLayoutGuide.snp.left)
            } else {
                make.left.equalToSuperview().offset(16)
            }
            make.top.equalToSuperview().offset(14)
            make.width.height.equalTo(20)
        }

        topLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(backButton)
            make.left.equalTo(backButton.snp.right).offset(16)
        }

        changeButton.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *), YXConstant.deviceScaleEqualToXStyle() {
                make.right.equalTo(self.view.safeAreaLayoutGuide.snp.right)
            } else {
                make.right.equalToSuperview().offset(-16)
            }
            make.top.equalToSuperview().offset(10)
            make.width.equalTo(88)
            make.height.equalTo(30)
        }

        self.view.addSubview(klineVSView)
        klineVSView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(48)
            make.bottom.equalToSuperview()
        }

        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().separatorLineColor()
        self.view.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *), YXConstant.deviceScaleEqualToXStyle() {
                make.left.equalTo(self.view.safeAreaLayoutGuide.snp.left)
                make.right.equalTo(self.view.safeAreaLayoutGuide.snp.right)
            } else {
                make.left.equalToSuperview()
                make.right.equalToSuperview()
            }
            make.height.equalTo(1)
            make.top.equalToSuperview().offset(48)
        }

    }
    override func shouldPopViewController(byBackButtonOrPopGesture byPopGesture: Bool) -> Bool {
        return false
    }

    @objc func closeDidClick() {

        self.vsViewModel.services.popViewModel(animated: true)
    }

    lazy var backButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.expandX = 10
        button.expandY = 10
        button.setImage(UIImage(named: "vskline_left_arrow"), for: .normal)
        button.addTarget(self, action: #selector(closeDidClick), for: .touchUpInside)
        return button
    }()

    lazy var topLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        label.text = YXLanguageUtility.kLang(key: "klinevs_day_line") 
        return label
    }()

    lazy var klineVSView: YXKlineVSView = {
        let view = YXKlineVSView(frame: CGRect(x: 0, y: 48, width: YXConstant.screenHeight, height: YXConstant.screenWidth - 48), isLandscape: true)
        return view
    }()

    @objc func changeDidClick() {

//        let viewModel = YXVSSearchViewModel.init(services: self.vsViewModel.services, params: nil)
//        self.vsViewModel.services.push(viewModel, animated: true)

        self.vsViewModel.services.popViewModel(animated: true)
    }

    lazy var changeButton: QMUIButton = {
        let button = QMUIButton()
        button.imagePosition = .left
        button.spacingBetweenImageAndTitle = 4.0
        button.setImage(UIImage(named: "vs_change"), for: .normal)
        button.addTarget(self, action: #selector(changeDidClick), for: .touchUpInside)
        button.setTitle(YXLanguageUtility.kLang(key: "klinevs_switch_stock"), for: .normal)
        button.backgroundColor = QMUITheme().themeTextColor()
        button.layer.cornerRadius = 4.0
        button.layer.masksToBounds = true
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return button
    }()
}
