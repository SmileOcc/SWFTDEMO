//
//  YXAvailableCashView.swift
//  uSmartOversea
//
//  Created by Evan on 2022/4/18.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXAvailableCashView: QMUIPopupContainerView {

    var didChoose:((_ moneyType: YXCurrencyType)->())?

    var dataSource: [YXAvailableCashCellViewModel] = [] {
        didSet {
            self.updateLayout()
            self.tableView.reloadData()
        }
    }

    private lazy var tableView: QMUITableView = {
        let view = QMUITableView(frame: CGRect.zero, style: .plain)
        view.delegate = self
        view.dataSource = self
        view.separatorColor = QMUITheme().popSeparatorLineColor()
        view.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        view.backgroundColor = UIColor.clear
        view.rowHeight = 54
        view.register(YXAvailableCashCell.self, forCellReuseIdentifier: NSStringFromClass(YXAvailableCashCell.self))
        view.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 1))
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.cornerRadius = 4
        self.arrowSize = .zero
        self.maskViewBackgroundColor = .clear
        self.distanceBetweenSource = 4
        self.contentEdgeInsets = .zero
        self.safetyMarginsOfSuperview = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        if YXThemeTool.isDarkMode() {
            self.shadowColor = nil
        } else {
            self.shadowColor = QMUITheme().textColorLevel1().withAlphaComponent(0.2)
        }

        self.backgroundColor = QMUITheme().foregroundColor()
        self.borderColor = .clear
        contentView.addSubview(tableView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sizeThatFits(inContentView size: CGSize) -> CGSize {
        // title 最大宽度
        var maxTitle = ""
        for cellVM in dataSource {
            if cellVM.title.count > maxTitle.count {
                maxTitle = cellVM.title
            }
        }
        let maxTitleWidth = (maxTitle as NSString).width(for: .systemFont(ofSize: 10))

        // 按照可用现金最大的值计算宽度
        var maxAvailableCash = ""
        for cellVM in dataSource {
            if let availableCash = cellVM.availableCash, availableCash.doubleValue > maxAvailableCash.doubleValue {
                maxAvailableCash = availableCash
            }
        }

        var maxAvailableCashWidth = (maxAvailableCash as NSString).width(for: .systemFont(ofSize: 14))

        // 上面按照金额最大的计算总长度，但是由于数字不等宽，可能金额小的宽度更大一点，这里都加长一点，以防万一
        maxAvailableCashWidth += 5

        // 确定 cell 宽度
        let cellWidth = 42 + max(maxTitleWidth, maxAvailableCashWidth) + 16

        let height = tableView.rowHeight * CGFloat(dataSource.count)
        return CGSize(width: cellWidth, height: height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.tableView.frame = self.contentView.bounds
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if YXThemeTool.isDarkMode() {
            self.shadowColor = nil
        } else {
            self.shadowColor = QMUITheme().textColorLevel1().withAlphaComponent(0.2)
        }
    }

}

extension YXAvailableCashView: QMUITableViewDelegate, QMUITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: NSStringFromClass(YXAvailableCashCell.self)
        ) as! YXAvailableCashCell
        cell.bind(to: dataSource[indexPath.row])
        return cell
    }
    
}
