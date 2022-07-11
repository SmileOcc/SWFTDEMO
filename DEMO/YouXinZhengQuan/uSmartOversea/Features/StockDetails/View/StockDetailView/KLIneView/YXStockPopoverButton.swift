//
//  YXStockPopoverButton.swift
//  uSmartOversea
//
//  Created by youxin on 2020/8/3.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class YXStockPopoverButton: QMUIButton {

    @objc var clickItemBlock: ((_ selectIndex: Int) -> Void)?
    var menuRowHeight: CGFloat = 40

    @objc convenience init(titles: [String]) {
        self.init(frame: .zero, titles: titles)
    }

    var titles: [String] = []

    @objc var needShowSelected = true
    @objc var isOnlyShowImage = false

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    @objc init(frame: CGRect, titles: [String]) {
        super.init(frame: frame)

        self.titles = titles

        initUI()

        self.rx.tap.subscribe(onNext: {
            [weak self] _ in
            guard let `self` = self else { return }

            let menuView = self.getMenuView()
            var index = 0
            for (i, title) in self.titles.enumerated() {
                let selfTitle = self.titleLabel?.text ?? ""
                if selfTitle == title || title.hasPrefix(selfTitle) {
                    index = i
                    break
                }
            }
            if self.needShowSelected {
                menuView.selectIndex = index
            }

            self.popover.show(menuView, from: self)

        }).disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {

    }

    lazy var popover: YXStockPopover = {
        let view = YXStockPopover()

        return view
    }()

    func getMenuView() -> YXStockLineMenuView {

        var maxWidth: CGFloat = 0
        for title in self.titles {
            let width = (title as NSString).boundingRect(with: CGSize(width: 1000, height: 30), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)], context: nil).size.width
            if maxWidth < width {
                maxWidth = width
            }
        }

        let menuView = YXStockLineMenuView.init(frame: CGRect(x: 0, y: 0, width: maxWidth + 30, height: CGFloat(menuRowHeight * CGFloat(self.titles.count))), andTitles: self.titles)
        menuView.clickCallBack = {
            [weak self] sender in
            guard let `self` = self else { return }

            self.popover.dismiss()
            if sender.isSelected {
                return
            }

            if !self.isOnlyShowImage {
                self.setTitle(self.titles[sender.tag], for: .normal)
                self.layoutIfNeeded()
            }

            self.clickItemBlock?(sender.tag)

        }

        return menuView

    }
}

class YXStockFinancialPopoverButton: YXStockPopoverButton {

    override convenience init(frame: CGRect) {
        let titles = [YXLanguageUtility.kLang(key: "financial_report_quarter_Annual"),
                      YXLanguageUtility.kLang(key: "financial_report_quarter_Interim"),
                      YXLanguageUtility.kLang(key: "common_report_first_quarter"),
                      YXLanguageUtility.kLang(key: "common_report_third_quarter")]
        self.init(frame: .zero, titles: titles)
    }

    override init(frame: CGRect, titles: [String]) {
        super.init(frame: frame, titles: titles)

        self.setTitle(titles.first, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        self.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.titleLabel?.minimumScaleFactor = 0.3
        self.imagePosition = .right
        self.spacingBetweenImageAndTitle = 5.0
        self.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 0)
        self.contentHorizontalAlignment = .right
        self.setImage(UIImage(named: "pull_down_arrow_20"), for: .normal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

