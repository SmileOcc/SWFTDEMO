//
//  YXSelectTypeView.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/4/7.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import NSObject_Rx

class YXSelectTypeView<E: EnumTextProtocol & Equatable>: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var menuitmeAlignment:UIControl.ContentHorizontalAlignment = .center
    var isEnabled: Bool = true {
        didSet {
            typeButton.titleLabel?.isHighlighted = !isEnabled
            arrowImageView.isHighlighted = !isEnabled
            typeButton.isEnabled = isEnabled
        }
    }
    
    var ignoreTypes: [E] = []
    
    private var typeArr: [E]! {
        didSet {
            if oldValue != typeArr {
                updateUI()
            }
        }
    }
    
    private(set) var selectedType: E! {
        didSet {
            typeButton.setTitle(selectedType.text, for: .normal)
        }
    }
    
    private var selectedBlock: ((E) -> Void)?
    
    private(set) lazy var inputBGView: YXInputBaseView = {
        let view = YXInputBaseView()
        view.backgroundColor = .clear
        return view
    }()
    
    private(set) lazy var typeButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        btn.titleLabel?.font = .systemFont(ofSize: 16)
        btn.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        btn.setTitleColor(QMUITheme().textColorLevel1(), for: .disabled)
        btn.contentHorizontalAlignment = contentHorizontalAlignment
        btn.titleLabel?.highlightedTextColor = QMUITheme().textColorLevel4()
        btn.setTitle(selectedType.text, for: .normal)
        
        btn.rx.controlEvent(.touchUpInside).subscribe { [weak self] (_) in
            self?.showMenu()
        }.disposed(by: btn.rx.disposeBag)
        
        return btn
    }()
    
    private lazy var menuView: QMUIPopupMenuView = {
        let menuView = QMUIPopupMenuView()
        menuView.backgroundColor = QMUITheme().popupLayerColor()
        menuView.automaticallyHidesWhenUserTap = true
        menuView.maskViewBackgroundColor = .clear
        menuView.arrowSize = .zero
        menuView.preferLayoutDirection = .below
        menuView.itemSeparatorColor = QMUITheme().popSeparatorLineColor()
        menuView.itemTitleColor = QMUITheme().mainThemeColor()
        menuView.itemTitleFont = .systemFont(ofSize: 14)
        menuView.distanceBetweenSource = 0
        menuView.safetyMarginsOfSuperview = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        menuView.padding = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        menuView.shouldShowItemSeparator = true
//        menuView.itemSeparatorInset = UIEdgeInsets.init(top: 0, left: 5, bottom: 0, right: 5)
        menuView.cornerRadius = 6
        menuView.borderColor = UIColor.themeColor(withNormalHex: "#E1E4E7", andDarkColor: "#212129")
        if contentHorizontalAlignment == .right {
            menuView.sourceView = arrowImageView
        } else {
            menuView.sourceView = self
        }
        menuView.didHideBlock = { [weak self] (hideByUserTap) in
//            self?.inputBGView.isSelect = false
        }
        return menuView
    }()
    
    private lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = arrowImage
        imageView.highlightedImage = arrowImage?.qmui_image(withTintColor: QMUITheme().textColorLevel4())
        imageView.contentMode = .center
        return imageView
    }()
    
    var typeClickBlock: (() -> Void)?
    var contentHorizontalAlignment: UIControl.ContentHorizontalAlignment!
    var arrowImage: UIImage!
    var isNewStyle = false
    convenience init(typeArr: [E], selected: E? = nil,
                     contentHorizontalAlignment: UIControl.ContentHorizontalAlignment = .right,
                     arrowImage: UIImage? = nil,
                     selectedBlock:((E) -> Void)?) {
        self.init()
        
        self.typeArr = typeArr
        self.selectedBlock = selectedBlock
        self.contentHorizontalAlignment = contentHorizontalAlignment
        self.arrowImage = arrowImage ?? UIImage(named: "pull_down_arrow_20")
        
        if let type = selected, self.typeArr.contains(type) {
            self.selectedType = type
        } else {
            self.selectedType = typeArr.first
        }
        
        initUI()
        updateUI()

        DispatchQueue.main.async {
            selectedBlock?(self.selectedType)
        }
    }
    
    private func initUI() {
        addSubview(inputBGView)
        addSubview(typeButton)
        addSubview(arrowImageView)
        
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer()
        tap.addActionBlock { [weak self] _ in
            guard let `self` = self else { return }
            if self.typeButton.isEnabled == true{
                self.showMenu()
            }
        }
        addGestureRecognizer(tap)
                
        inputBGView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        typeButton.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-1)
            if contentHorizontalAlignment == .center {
                make.right.equalToSuperview()
            } else {
                make.right.equalTo(arrowImageView.snp.left)
            }
        }
        
        arrowImageView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(0)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalTo(arrowImage.size.width)
        }
    }
    
    private func updateUI() {
        if typeArr.count <= 1 {
            arrowImageView.isHidden = true
            typeButton.isEnabled = false
            arrowImageView.snp.updateConstraints { make in
                make.width.equalTo(0)
                make.right.equalToSuperview().offset(0)
            }
            
            typeButton.titleEdgeInsets = .zero
        } else {
            arrowImageView.isHidden = false
            typeButton.isEnabled = true
            arrowImageView.snp.updateConstraints { make in
                make.width.equalTo(arrowImage.size.width)
                if contentHorizontalAlignment == .center {
                    make.right.equalToSuperview().offset(-16)
                } else {
                    make.right.equalToSuperview().offset(0)
                }
            }
            
            typeButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        }
        
        menuView.items = typeArr.map {[weak self] (type) -> QMUIPopupMenuButtonItem in
           
            let buttionItme = QMUIPopupMenuButtonItem(image: nil, title: type.text) { [weak self] (item) in
                guard let strongSelf = self else { return }
                if strongSelf.ignoreTypes.contains(type) {
                    
                } else {
                    strongSelf.selectedType = type
                }
                strongSelf.hideMenu()
                strongSelf.selectedBlock?(type)
            }
            buttionItme.button.contentHorizontalAlignment = self?.menuitmeAlignment ?? .center
            return buttionItme
        }
    }
    
    var menuMinimumWidth: CGFloat = 160
    private func showMenu() {
        typeClickBlock?()
//        inputBGView.isSelect = true
        if isNewStyle {
            menuView.minimumWidth = 210
        } else {
            menuView.minimumWidth = menuMinimumWidth
        }
        menuView.itemConfigurationHandler = { [weak self] (_, aItem, section, index) in
            guard let strongSelf = self else { return }
            if strongSelf.typeArr[index] == strongSelf.selectedType {
                (aItem as? QMUIPopupMenuButtonItem)?.button.setTitleColor(QMUITheme().mainThemeColor(), for: .normal)
            } else {
                (aItem as? QMUIPopupMenuButtonItem)?.button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
            }
        }
        menuView.showWith(animated: false)
    }
    
    private func hideMenu() {
        menuView.hideWith(animated: false)
    }
    
    func updateType(_ typeArr: [E]? = nil, selected: E? = nil) {
        if let array = typeArr, self.typeArr != array {
            self.typeArr = array
            
            if array.count > 0 {
                if let selected = selected {
                    self.selectedType = selected
                }
                if !self.typeArr.contains(self.selectedType) {
                    self.selectedType = array.first
                }

                selectedBlock?(self.selectedType)
            }
        } else {
            if let selected = selected, selected != self.selectedType {
                if self.typeArr.contains(selected) {
                    self.selectedType = selected
                }
                selectedBlock?(self.selectedType)
            }
        }
    }
}

