//
//  YXMyAssetsDetailStatisticsView.swift
//  uSmartOversea
//
//  Created by Evan on 2022/5/6.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import Charts

class YXMyAssetsDetailStatisticsView: UIView {

    static let AssetDetailShowOrHideKey = "MY_ASSETS_DETAIL_SHOW_OR_HIDE_KEY"

    @objc static var assetHidden: Bool {
        set {
            MMKV.default().set(newValue, forKey: YXMyAssetsDetailStatisticsView.AssetDetailShowOrHideKey)
        }

        get {
            return MMKV.default().bool(forKey: AssetDetailShowOrHideKey, defaultValue: false)
        }
    }

    var didChoose:((_ moneyType: YXCurrencyType)->())?
    var contentHeightDidChangeBlock:((_ height: CGFloat)->())?

    private(set) var contentHeight: CGFloat = 0

    var exchangeRateList: [YXMoneyTypeSelectionCellViewModel]? {
        didSet {
            moneyTypeSelectionView.dataSource = exchangeRateList ?? []

            if let selectedVM = moneyTypeSelectionView.dataSource.first(where: { $0.selected }) {
                assetTitleLabel.text = "\(YXLanguageUtility.kLang(key: "account_net_assets")) (\(selectedVM.moneyType.requestParam))"
            }
        }
    }

    fileprivate lazy var moneyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.positiveFormat = "###,##0.00";
        formatter.locale = Locale(identifier: "zh")
        return formatter;
    }()

    lazy var chartView: PieChartView = {
        let view = PieChartView.init(frame: .zero)
        view.maxAngle = 180
        view.drawCenterTextEnabled = false
        view.drawHoleEnabled = true
        view.holeColor = self.backgroundColor
        view.drawEntryLabelsEnabled = false
        view.holeRadiusPercent = (130.0 - 10.0) / 130.0
        view.transparentCircleRadiusPercent = 0
        view.rotationAngle = 180.0
        view.legend.enabled = false
        return view
    }()

    lazy var hideButton: QMUIButton = {
        let button = QMUIButton()
        button.qmui_outsideEdge = UIEdgeInsets(top: -20, left: -20, bottom: -20, right: -20)
        button.setImage(UIImage(named: "eye_open"), for: .normal)
        button.setImage(UIImage(named: "eye_close"), for: .selected)
        button.setImage(UIImage(named: "eye_close"), for: [.selected, .highlighted])
        button.isSelected = YXMyAssetsDetailStatisticsView.assetHidden
        button.tintColor = QMUITheme().textColorLevel3()
        button.adjustsImageTintColorAutomatically = true

        button.rx.tap.subscribe { [weak self, weak button]_ in
            guard let `self` = self else { return }

            if let button = button {
                button.isSelected = !button.isSelected
            }

            YXMyAssetsDetailStatisticsView.assetHidden = !YXMyAssetsDetailStatisticsView.assetHidden

            NotificationCenter.default.post(
                name: NSNotification.Name(YXMyAssetsDetailSecretLabel.hideValueNotificationName),
                object: nil,
                userInfo: nil
            )
        }.disposed(by: rx.disposeBag)

        return button
    }()

    lazy var assetTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel3()
        label.text = YXLanguageUtility.kLang(key: "account_net_assets")
        return label
    }()

    lazy var assetValueLabel: YXMyAssetsDetailSecretLabel = {
        let label = YXMyAssetsDetailSecretLabel()
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textColor = QMUITheme().textColorLevel1()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.text = "--"
        return label
    }()

    lazy var moneyTypeSelectionButton: QMUIButton = {
        let button = QMUIButton()
        button.qmui_outsideEdge = UIEdgeInsets(top: -20, left: -40, bottom: -20, right: -10)
        button.setImage(UIImage(named: "icon_asset_arrow"), for: .normal)
        button.tintColor = QMUITheme().textColorLevel3()
        button.adjustsImageTintColorAutomatically = true

        button.rx.tap.subscribe { [weak self] _ in
            guard let `self` = self else { return }

            if self.moneyTypeSelectionView.dataSource.isEmpty {
                return
            }

            if self.moneyTypeSelectionView.isShowing() {
                self.moneyTypeSelectionView.hideWith(animated: true)
            } else {
                self.moneyTypeSelectionView.sourceView = self.assetTitleLabel
                self.moneyTypeSelectionView.showWith(animated: true)
            }
        }.disposed(by: rx.disposeBag)

        return button
    }()

    private lazy var moneyTypeSelectionView: YXMoneyTypeSelectionView = {
        let view = YXMoneyTypeSelectionView()
        view.didChoose = { [weak self] moneyType in
            self?.didChoose?(moneyType)
            self?.assetTitleLabel.text = "\(YXLanguageUtility.kLang(key: "account_net_assets")) (\(moneyType.requestParam))"
        }
        view.automaticallyHidesWhenUserTap = true
        view.preferLayoutDirection = QMUIPopupContainerViewLayoutDirection.below
        view.distanceBetweenSource = 8
        return view
    }()

    private lazy var tableView: QMUITableView = {
        let view = QMUITableView(frame: .zero, style: .plain)
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.themeColor(withNormalHex: "#F8F9FC", andDarkColor: "#19191F")
        view.dataSource = self
        view.delegate = self
        view.separatorStyle = .none
        view.isScrollEnabled = false
        view.register(YXMyAssetsDetailHeaderItemCell.self, forCellReuseIdentifier: NSStringFromClass(YXMyAssetsDetailHeaderItemCell.self))
        view.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        view.rowHeight = 28
        return view
    }()

    private var dataSource: [AnyObject] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.themeColor(withNormalHex: "#FFFFFF", andDarkColor: "#101014")
        initSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initSubviews() {
        addSubview(chartView)
        addSubview(hideButton)
        addSubview(assetTitleLabel)
        addSubview(moneyTypeSelectionButton)
        addSubview(assetValueLabel)
        addSubview(tableView)

        chartView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.centerX.equalToSuperview()
            make.width.equalTo(260)
            make.height.equalTo(260)
        }

        hideButton.snp.makeConstraints { make in
            make.right.equalTo(self.assetTitleLabel.snp.left).offset(-2)
            make.centerY.equalTo(assetTitleLabel)
        }

        assetTitleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(assetValueLabel)
            make.bottom.equalTo(assetValueLabel.snp.top).offset(-12)
        }

        moneyTypeSelectionButton.snp.makeConstraints { make in
            make.left.equalTo(self.assetTitleLabel.snp.right).offset(2)
            make.centerY.equalTo(assetTitleLabel)
        }

        assetValueLabel.snp.makeConstraints { make in
            make.centerX.equalTo(chartView)
            make.bottom.equalTo(chartView.snp.centerY)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(chartView.snp.centerY).offset(24)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-24)
        }
    }

    func bind(to model: AnyObject) {
        var sumNetAsset: NSDecimalNumber?
        var moneyType: String?
        var hasNegativeAsset: Bool = false

        if let model = model as? YXMyAssetsDetailViaCategoryResModel {
            self.dataSource = model.assetDetailList

            sumNetAsset = model.sumNetAsset
            moneyType = model.moneyType
            hasNegativeAsset = model.hasNegativeAsset
        } else if let model = model as? YXMyAssetsDetailViaMarketResModel  {
            self.dataSource = model.assetDetailList

            sumNetAsset = model.sumNetAsset
            moneyType = model.moneyType
            hasNegativeAsset = model.hasNegativeAsset
        }

        assetTitleLabel.text = "\(YXLanguageUtility.kLang(key: "account_net_assets")) (\(moneyType ?? ""))"

        if let asset = sumNetAsset {
            let formatString = moneyFormatter.string(from: asset)
            let attributeString = NSMutableAttributedString(
                string: formatString!,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 24, weight: .semibold),
                ])

            if  let formatString = formatString,
                let location = formatString.range(of: ".", options: [])?.lowerBound {
                // 判断是否存在"."字符
                // 如果存在，则将"."和"."之后的字符，都设置为小号字体
                // 例如  100,000.24  ，则distance = 7的位置开始，到length这个范围内的字符都用小号字体
                let distance = formatString.distance(from: formatString.startIndex, to: location)
                let length = formatString.distance(from: location, to: formatString.endIndex)
                attributeString.addAttributes([.font: UIFont.systemFont(ofSize: 18, weight: .semibold)], range: NSRange(location: distance, length: length))
            }
            assetValueLabel.attributedValue = attributeString
        } else {
            assetValueLabel.attributedValue = NSAttributedString(string: "--")
        }

        setupPieChartData()

        tableView.reloadData()

        chartView.isHidden = hasNegativeAsset
        tableView.isHidden = hasNegativeAsset

        assetValueLabel.snp.remakeConstraints { make in
            make.centerX.equalTo(chartView)
            if hasNegativeAsset {
                make.bottom.equalTo(-24)
            } else {
                make.bottom.equalTo(chartView.snp.centerY)
            }
        }

        var contentHeight: CGFloat = 0
        if hasNegativeAsset {
            contentHeight = 110
        } else {
            contentHeight = 32 + 130 + 24
            if dataSource.count > 0 {
                let tableViewHeight: CGFloat = tableView.rowHeight * CGFloat(dataSource.count) + UIEdgeInsetsGetVerticalValue(tableView.contentInset)
                contentHeight += tableViewHeight
                contentHeight += 24
            }
        }
        self.contentHeight = contentHeight
        self.contentHeightDidChangeBlock?(contentHeight)
    }

    private func setupPieChartData() {
        var entries: [PieChartDataEntry] = []
        var colors: [UIColor] = []

        // 设置个阈值, 因为低于这个数值，占比图可能显示不了
        let threshold = 0.008

        for item in self.dataSource {
            if let model = item as? YXMyAssetsDetailViaCategroyListItem,
               model.percent > 0 {
                var value = model.percent
                if model.percent > 0 && model.percent < threshold {
                    value = threshold
                }
                let entry = PieChartDataEntry(value: value)
                entries.append(entry)

                colors.append(model.assetKind.color)
            } else if let model = item as? YXMyAssetsDetailViaMarketListItem,
                      model.percent > 0 {
                var value = model.percent
                if model.percent > 0 && model.percent < threshold {
                    value = threshold
                }
                let entry = PieChartDataEntry(value: value)
                entries.append(entry)

                colors.append(model.color)
            }
        }

        if entries.isEmpty {
            let entry = PieChartDataEntry(value: 100)
            entries.append(entry)

            colors.append(UIColor.themeColor(withNormalHex: "#EAEAEA", andDarkColor: "#292933"))
        }

        let set = PieChartDataSet(entries: entries, label: nil)
        set.drawValuesEnabled = false
        set.drawIconsEnabled = false
        set.sliceSpace = 2
        set.selectionShift = 0

        set.colors = colors

        let data = PieChartData(dataSet: set)
        chartView.data = data
        chartView.highlightValues(nil)
    }

}

extension YXMyAssetsDetailStatisticsView: QMUITableViewDataSource, QMUITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: NSStringFromClass(YXMyAssetsDetailHeaderItemCell.self)
        ) as! YXMyAssetsDetailHeaderItemCell

        let mode = self.dataSource[indexPath.row]
        cell.bind(to: mode)

        return cell
    }

}

class YXMyAssetsDetailHeaderItemCell: UITableViewCell {

    lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()

    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.textColor = QMUITheme().textColorLevel3()
        view.font = .normalFont14()
        return view
    }()

    lazy var valueLabel: YXMyAssetsDetailSecretLabel = {
        let view = YXMyAssetsDetailSecretLabel()
        view.textColor = QMUITheme().textColorLevel1()
        view.font = .normalFont14()
        view.textAlignment = .right
        return view
    }()

    lazy var percentLabel: YXMyAssetsDetailSecretLabel = {
        let view = YXMyAssetsDetailSecretLabel()
        view.textColor = QMUITheme().textColorLevel1()
        view.font = .normalFont14()
        view.textAlignment = .right
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        self.backgroundColor = UIColor.themeColor(withNormalHex: "#F8F9FC", andDarkColor: "#19191F")
        contentView.backgroundColor = UIColor.themeColor(withNormalHex: "#F8F9FC", andDarkColor: "#19191F")

        contentView.addSubview(colorView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        contentView.addSubview(percentLabel)

        colorView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(8)
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(colorView.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }

        valueLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(contentView.snp.right).multipliedBy(2.0 / 3).offset(-12)
        }

        percentLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-16)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(to model: AnyObject) {
        var color: UIColor = .clear
        var title: String = ""
        var sumAsset: NSDecimalNumber = .zero
        var percent: Double = 0

        if let model = model as? YXMyAssetsDetailViaCategroyListItem {
            color = model.assetKind.color
            title = model.assetKind.title
            sumAsset = model.sumAsset ?? .zero
            percent = model.percent
        } else if let model = model as? YXMyAssetsDetailViaMarketListItem  {
            color = model.color
            title = model.marketName
            sumAsset = model.sumAsset ?? .zero
            percent = model.percent
        }

        colorView.backgroundColor = color
        titleLabel.text = title

        let numberFormatter = NumberFormatter()
        numberFormatter.positiveFormat = "###,##0.00"
        numberFormatter.locale = Locale(identifier: "zh")
        valueLabel.value = numberFormatter.string(from: sumAsset)

        let percentFormatter = NumberFormatter()
        percentFormatter.numberStyle = .percent
        percentFormatter.maximumFractionDigits = 2
        percentFormatter.minimumFractionDigits = 2
        percentLabel.value = percentFormatter.string(from: NSNumber(value: percent))
    }

}
