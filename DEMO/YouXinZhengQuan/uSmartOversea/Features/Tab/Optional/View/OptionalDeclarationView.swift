//
//  OptionalDeclarationView.swift
//  uSmartOversea
//
//  Created by lennon on 2022/5/5.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class OptionalDeclarationView: UIView {

    lazy var button: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(QMUITheme().mainThemeColor(), for: .normal)
        button.contentHorizontalAlignment = .right
        button.setTitle(YXLanguageUtility.kLang(key: "optionQuoteStatementGo"), for: .normal)
        return button
    }()
    
    
    lazy var titleLabel:YXMarqueeLabel = {
        let titleLabel = YXMarqueeLabel.init()
        titleLabel.pauseDurationWhenMoveToEdge = 0
        titleLabel.fadeWidthPercent = 0
        titleLabel.adjustsFontSizeToFitWidth = false
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.enableMarqueeAnimation = true
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textColor = QMUITheme().textColorLevel3()
        titleLabel.text = YXLanguageUtility.kLang(key: "optionQuoteStatement")
        return titleLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        
        backgroundColor = QMUITheme().foregroundColor()
        
        let containView = UIView.init()
        containView.backgroundColor = QMUITheme().blockColor()
        containView.layer.cornerRadius = 4
        containView.layer.masksToBounds = true
        addSubview(containView)
        
        containView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.top.equalToSuperview().offset(8)
            $0.bottom.equalToSuperview().offset(-8)
        }
        
        containView.addSubview(titleLabel)
        containView.addSubview(button)
        
        titleLabel.snp.makeConstraints{
            $0.left.equalToSuperview().offset(12)
            $0.right.equalToSuperview().offset(-107)
            $0.top.equalToSuperview().offset(12)
            $0.bottom.equalToSuperview().offset(-12)
        }
        
        button.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-12)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(89)
        }
    }
}

class OptionalDeclarationHeaderView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.layer.cornerRadius = 20
        self.backgroundColor = QMUITheme().popupLayerColor()

        if !YXThemeTool.isDarkMode() {
            self.layer.shadowColor = QMUITheme().textColorLevel1().withAlphaComponent(0.08).cgColor
            self.layer.shadowOffset = CGSize(width: 0, height: -4)
            self.layer.shadowOpacity = 1.0
            self.layer.shadowRadius = 16.0
        }

        addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.width.equalTo(40)
            make.height.equalTo(3)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(12)
        }
    }

    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.themeColor(withNormalHex: "#D8D8D8", andDarkColor: "#A3A5B3")
        view.layer.cornerRadius = 1.5
        return view
    }()
}

class OptionalDeclarationDragView: JXBottomSheetView {
    
    let kHeaderHeight: CGFloat = 27
    var minHeight: CGFloat = 52 + 27 + YXConstant.tabBarPadding()
    var maxHeight: CGFloat {
        return YXConstant.screenHeight - YXConstant.navBarHeight() - kHeaderHeight -  YXConstant.tabBarPadding()
    }


    override init(contentView: UIScrollView, headerView: UIView) {
        super.init(contentView: contentView, headerView: headerView)
        defaultMininumDisplayHeight = self.minHeight
        defaultMaxinumDisplayHeight = self.maxHeight
        shouldRecognizeOtherGestureRecognizer = false
        headerViewHeight = kHeaderHeight
        displayState = .minDisplay
        
        self.sendSubviewToBack(headerView)
        self.clipsToBounds = false
        self.displayMin()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


@objcMembers class OptionalDeclarationScrollView: UIScrollView {

    let kHeight: CGFloat = 52
    var declarationGoBlock: (() -> Void)?
    
    ////行情声明
    lazy var declarationView:OptionalDeclarationView = {
        let view = OptionalDeclarationView.init()
        view.backgroundColor = QMUITheme().foregroundColor()
        view.button.qmui_tapBlock = { [weak self] _ in
            guard let `self` = self else { return }
            self.declarationGoBlock?()
        }
        return view
    }()
    
    var moveDidChange = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = QMUITheme().popupLayerColor()
        self.delaysContentTouches = false
        self.isScrollEnabled = false


        self.addSubview(self.declarationView)
        self.declarationView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(YXConstant.screenWidth)
            make.height.equalTo(self.kHeight)
        }


        addSubview(dragVC.view)
        dragVC.view.backgroundColor = UIColor.systemPink
        dragVC.view.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.equalTo(YXConstant.screenWidth)
            make.height.equalTo(pageHeight)
            make.top.equalTo(self.declarationView.snp.bottom)
        }

    }

    var pageHeight: CGFloat {
        return YXConstant.screenHeight - YXConstant.navBarHeight() - 27  - self.kHeight - YXConstant.tabBarPadding() - YXConstant.tabBarHeight()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var dragVC: YXWebViewController = {
        let root = UIApplication.shared.delegate as! YXAppDelegate
        let viewModel = YXUSAuthStateWebViewModel(dictionary: [:])
        viewModel.dragStyle = true
        let vc = YXUSAuthStateWebViewController.instantiate(withViewModel: viewModel, andServices: root.appServices, andNavigator: root.navigator)
        return vc
    }()
    
    func updateUI(hidden:Bool) {
        self.declarationView.isHidden = hidden
        
        if hidden {
            self.declarationView.snp.updateConstraints { (make) in
                make.height.equalTo(0)
            }
        } else {
            self.declarationView.snp.updateConstraints { (make) in
                make.height.equalTo(self.kHeight)
            }
        }
        
    }
}

extension OptionalDeclarationScrollView: JXBottomSheetViewDelegate {

    func bottomSheet(bottomSheet: JXBottomSheetView, didDisplayed state: JXBottomSheetState) {

        if state == .maxDisplay {
            if moveDidChange != false {
                moveDidChange = false
            }
            if YXThemeTool.isDarkMode() {
                backgroundColor = QMUITheme().foregroundColor()
                
            }
            
        } else {
            if moveDidChange != true {
                moveDidChange = true
            }
            if YXThemeTool.isDarkMode() {
                backgroundColor = QMUITheme().popupLayerColor()
            }
        }
    }
    

}
