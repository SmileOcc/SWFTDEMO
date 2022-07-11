//
//  YXMoneyTypeSelectionView.swift
//  uSmartOversea
//
//  Created by Evan on 2022/4/18.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXMoneyTypeSelectionView: QMUIPopupContainerView {

    var didChoose:((_ moneyType: YXCurrencyType)->())?

    var dataSource: [YXMoneyTypeSelectionCellViewModel] = [] {
        didSet {
            self.updateLayout()
            self.tableView.reloadData()
        }
    }

    private let kMoneyTypeSelectionViewRowHeight: CGFloat = 54.0

    private lazy var tableView: QMUITableView = {
        let view = QMUITableView(frame: CGRect.zero, style: .plain)
        view.separatorStyle = UITableViewCell.SeparatorStyle.none
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = UIColor.clear
        view.rowHeight = kMoneyTypeSelectionViewRowHeight
        view.register(YXMoneyTypeSelectionCell.self, forCellReuseIdentifier: NSStringFromClass(YXMoneyTypeSelectionCell.self))
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.cornerRadius = 4
        self.arrowSize = .zero
        self.maskViewBackgroundColor = .clear
        self.distanceBetweenSource = 4
        self.contentEdgeInsets = .zero

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
        let height = kMoneyTypeSelectionViewRowHeight * CGFloat(dataSource.count)
        return CGSize(width: 166, height: height)
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

extension YXMoneyTypeSelectionView: QMUITableViewDelegate, QMUITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: NSStringFromClass(YXMoneyTypeSelectionCell.self)
        ) as! YXMoneyTypeSelectionCell
        cell.bind(to: dataSource[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellVM = dataSource[indexPath.row]
        didChoose?(cellVM.moneyType)
        self.hideWith(animated: true)
    }

}
