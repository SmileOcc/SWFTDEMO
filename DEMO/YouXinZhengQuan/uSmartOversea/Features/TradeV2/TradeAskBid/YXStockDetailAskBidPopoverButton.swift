//
//  YXStockDetailAskBidPopoverButton.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2021/6/23.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class YXStockDetailAskBidPopoverButton: YXExpandAreaButton {

    @objc var clickItemBlock: ((_ selectIndex: Int) -> Void)?

    @objc convenience init(titles: [String]) {
        self.init(frame: .zero, titles: titles)
    }

    @objc var titles: [String] = []

    @objc init(frame: CGRect, titles: [String]) {
        super.init(frame: frame)
        
        self.expandX = 5
        self.expandY = 5

        self.titles = titles

        initUI()

        self.rx.tap.subscribe(onNext: {
            [weak self] _ in
            guard let `self` = self else { return }

            let menuView = self.getMenuView()
            var index = 0
            for (i, title) in self.titles.enumerated() {
                if self.titleLabel?.text == title {
                    index = i
                    break
                }
            }

            menuView.selectIndex = index

            self.popover.show(menuView, from: self)

        }).disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        self.titleLabel?.font = .systemFont(ofSize: 14)
        self.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        
        self.layer.cornerRadius = 2
        self.layer.masksToBounds = true
        
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.titleLabel?.minimumScaleFactor = 0.7
        
        self.setTitle(titles.first, for: .normal)
        self.layer.borderWidth = 1
     
        self.layer.borderColor = QMUITheme().textColorLevel1().cgColor
    }

    lazy var popover: YXStockPopover = {
        let view = YXStockPopover()

        return view
    }()

    func getMenuView() -> YXStockDetailAskBidMenuView {

        let maxWidth: CGFloat = 64
//        for title in self.titles {
//            let width = (title as NSString).boundingRect(with: CGSize(width: 1000, height: 30), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)], context: nil).size.width
//            if maxWidth < width {
//                maxWidth = width
//            }
//        }

        let menuView = YXStockDetailAskBidMenuView.init(frame: CGRect(x: 0, y: 0, width: maxWidth, height: CGFloat(41 * self.titles.count)), titles: self.titles)
        menuView.itemClickBlock = {
            [weak self, weak menuView] index in
            guard let `self` = self else { return }

            self.popover.dismiss()
            if menuView?.selectIndex == index {
                return
            }

            self.setTitle(self.titles[index], for: .normal)
            self.layoutIfNeeded()

            self.clickItemBlock?(index)

        }

        return menuView

    }
}

class YXStockDetailAskBidMenuView: UIView {
    
    @objc var itemClickBlock: ((_ selectIndex: Int) -> Void)?
    
    var titles: [String] = []
    private var buttonViews: [UIButton] = []
    
    @objc var selectIndex: Int = 0 {
        didSet {
            for (index, button) in buttonViews.enumerated() {
                if index == selectIndex {
                    button.isSelected = true
                } else {
                    button.isSelected = false
                }
            }
        }
    }
    
    @objc init(frame: CGRect, titles: [String]) {
        super.init(frame: frame)
        self.titles = titles
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        
        let lineColor: UIColor = QMUITheme().popSeparatorLineColor()
       
        
        for (index, title) in self.titles.enumerated() {
            let button = UIButton()
            button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
            button.setTitleColor(QMUITheme().themeTextColor(), for: .selected)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 14)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.7
            addSubview(button)
            
            button.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.height.equalTo(40)
                make.top.equalToSuperview().offset(41 * index)
            }
            
            buttonViews.append(button)
            
            if index < self.titles.count - 1 {
                let lineView = UIView()
                lineView.backgroundColor = lineColor
                addSubview(lineView)
                lineView.snp.makeConstraints { make in
                    make.left.equalToSuperview().offset(5)
                    make.right.equalToSuperview().offset(-5)
                    make.height.equalTo(1)
                    make.top.equalTo(button.snp.bottom)
                }
            }
            
            button.rx.tap.subscribe(onNext: {
                [weak self] _ in
                guard let `self` = self else { return }
        
                self.itemClickBlock?(index)
                
            }).disposed(by: self.rx.disposeBag)
            
        }
    }

    
    
}
