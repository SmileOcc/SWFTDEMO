//
//  YXAccountAssetView.swift
//  uSmartOversea
//
//  Created by 覃明明 on 2021/7/6.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import NSObject_Rx

@objc enum YXAccountRiskType: Int {
    case safe = 1
    case warning = 2
    case dangerous = 3
    case emergency = 4
    case liquidated = 5
    
    var text: String {
        switch self {
        case .safe:
            return "Safe"
        case .liquidated:
            return "Liquidated"
        case .dangerous:
            return "Dangerous"
        case .emergency:
            return "Emergency"
        case .warning:
            return "Warning"
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .safe:
            return UIColor(hexString: "#00C264")!
        case .liquidated:
            return UIColor(hexString: "#B0B6CB")!
        case .dangerous:
            return UIColor(hexString: "#FF8637")!
        case .emergency:
            return UIColor(hexString: "#EA3D3D")!
        case .warning:
            return UIColor(hexString: "#F9A800")!
        default:
            return UIColor.white
        }
    }
}

class YXAccountAssetDetailButton: QMUIButton {

    let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: -0.32, y: -0.4)
        layer.endPoint = CGPoint(x: 0.57, y: 0.57)
        layer.colors = [UIColor.white.withAlphaComponent(0.3).cgColor, UIColor.white.withAlphaComponent(0.1).cgColor];
        layer.locations = [0, 1.0]
        return layer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(gradientLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds

        let maskPath = UIBezierPath(
            roundedRect: self.bounds,
            byRoundingCorners: [.topLeft, .bottomLeft],
            cornerRadii: CGSize(width: self.bounds.size.height / 2, height: self.bounds.size.height / 2)
        )
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        self.layer.mask = shape
    }

}

class YXAccountAssetView: UIView, HasDisposeBag {

    static let AssetEyeKey = "ASSET_SHOW_HIDE_FLAG"

    @objc static var assetHidden: Bool {
        return MMKV.default().bool(forKey: AssetEyeKey, defaultValue: false)
    }

    let kAccountAssetViewIsExpandKey = "kAccountAssetViewIsExpandKey"

    private(set) var isExpand: Bool {
        get {
            MMKV.default().bool(forKey: kAccountAssetViewIsExpandKey, defaultValue: true)
        }

        set {
            MMKV.default().set(newValue, forKey: kAccountAssetViewIsExpandKey)
        }
    }

    private(set) var assetViewHeight: CGFloat = 0

    var didChoose:((_ moneyType: YXCurrencyType)->())?
    var heightDidChange: ((_ height: CGFloat) -> Void)?
    var tapAssetAction: (() -> Void)?
    var shouldHidden = false
    var profitAndLossAmountLabelTextColor: UIColor?
    var totalPLLabelTextColor: UIColor?
    var dailyPLLabelTextColor: UIColor?

    var model: YXAccountAssetResModel? {
        didSet {
            if let m = model {
                let totalData = m.totalData

                if let asset = totalData?.asset {
                    let formatString = moneyFormatter.string(from: asset)
                    let attributeString = NSMutableAttributedString(
                        string: formatString!,
                        attributes: [
                            .font: UIFont.systemFont(ofSize: 32, weight: .bold),
                            .foregroundColor: UIColor.themeColor(withNormalHex: "#FFFFFF", andDarkColor: "#D3D4E6")
                        ])

                    if  let formatString = formatString,
                        let location = formatString.range(of: ".", options: [])?.lowerBound {
                        // 判断是否存在"."字符
                        // 如果存在，则将"."和"."之后的字符，都设置为小号字体
                        // 例如  100,000.24  ，则distance = 7的位置开始，到length这个范围内的字符都用小号字体
                        let distance = formatString.distance(from: formatString.startIndex, to: location)
                        let length = formatString.distance(from: location, to: formatString.endIndex)
                        attributeString.addAttributes([.font: UIFont.systemFont(ofSize: 20, weight: .bold)], range: NSRange(location: distance, length: length))
                    }
                    assetValueLabel.attributedValue = attributeString
                } else {
                    assetValueLabel.attributedValue = NSAttributedString(string: "--")
                }

                buyingPower.valueLabel.value = moneyFormatValue(value: totalData?.purchasePower?.stringValue)
                positionValue.valueLabel.value = moneyFormatValue(value: totalData?.marketValue?.stringValue)
                cashBalance.valueLabel.value = moneyFormatValue(value: totalData?.cashBalance?.stringValue)
                marginLoans.valueLabel.value = moneyFormatValue(value: totalData?.debitBalance?.stringValue)
                availableCash.valueLabel.value = moneyFormatValue(value: totalData?.availableBalance?.stringValue)

                let riskName = m.totalData?.riskCodeName
                let riskType = m.totalData?.riskCode
                var marginCushionValue: String
                if let marginCushion = m.totalData?.mv {
                    marginCushionValue = String(format: "%.0lf%%", (Double(marginCushion) ?? 0) * 100)
                }else {
                    marginCushionValue = "--"
                }
                
                let text = marginCushionValue + " " + (riskName ?? "--")
                
                let attributeString = NSMutableAttributedString(
                    string: text,
                    attributes: [
                        NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .medium),
                        NSAttributedString.Key.foregroundColor : UIColor.themeColor(withNormalHex: "#FFFFFF", andDarkColor: "#D3D4E6")
                    ]
                )
                
                let range = (text as NSString).range(of: riskName ?? "--")
                attributeString.addAttributes([NSAttributedString.Key.foregroundColor : riskType?.textColor ?? .white], range: range)
                
                riskLevel.valueLabel.attributedValue = attributeString

                let dataSource =
                    m.assetSingleInfoRespVOS
                    .filter( { $0.accountBusinessType == .normal && $0.fundAccountStatus == .opened })
                    .sorted(by: { (assetData1, assetData2) -> Bool in
                        let array = ["SGD", "USD", "HKD"]
                        if let moneyType1 = assetData1.moneyType,
                           let idx1 = array.firstIndex(of: moneyType1),
                           let moneyType2 = assetData2.moneyType,
                           let idx2 = array.firstIndex(of: moneyType2) {
                            return idx1 < idx2
                        }
                        return false
                    })
                    .map { assetData -> YXAvailableCashCellViewModel in
                        let moneyType = YXCurrencyType.currenyType(assetData.moneyType ?? "")
                        let cellVM = YXAvailableCashCellViewModel(moneyType: moneyType, availableCash: assetData.availableBalance)
                        return cellVM
                    }
                availableCashListView.dataSource = dataSource
            }
        }
    }

    var exchangeRateList: [YXMoneyTypeSelectionCellViewModel]? {
        didSet {
            moneyTypeSelectionView.dataSource = exchangeRateList ?? []

            if let selectedVM = moneyTypeSelectionView.dataSource.first(where: { $0.selected }) {
                assetTitleLabel.text = "\(YXLanguageUtility.kLang(key: "account_net_assets")) (\(selectedVM.moneyType.requestParam))"
            }
        }
    }

    func moneyFormatValue(value: String?) -> String {
        if let v = Double(value ?? "") {
            return moneyFormatter.string(from: NSNumber(value: v)) ?? "--"
        }else {
            return "--"
        }
    }
    
    // 金额格式化
    fileprivate lazy var moneyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.positiveFormat = "###,##0.00";
        formatter.locale = Locale(identifier: "zh")
        return formatter;
    }()

    lazy var hideButton: QMUIButton = {
        let button = QMUIButton()
        button.qmui_outsideEdge = UIEdgeInsets(top: -20, left: -20, bottom: -20, right: -20)
        button.setImage(UIImage(named: "eye_open"), for: .normal)
        button.setImage(UIImage(named: "eye_close"), for: .selected)
        button.setImage(UIImage(named: "eye_close"), for: [.selected, .highlighted])
        button.isSelected = YXAccountAssetView.assetHidden

        button.rx.tap.subscribe { [weak self, weak button]_ in
            guard let `self` = self else { return }

            if let button = button {
                button.isSelected = !button.isSelected
            }

            MMKV.default().set(!YXAccountAssetView.assetHidden, forKey: YXAccountAssetView.AssetEyeKey)

            NotificationCenter.default.post(
                name: NSNotification.Name(YXCanHideTextLabel.hideValueNotiName),
                object: nil,
                userInfo: ["shouldHide": YXAccountAssetView.assetHidden]
            )
        }.disposed(by: disposeBag)

        return button
    }()

    lazy var assetTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor.themeColor(withNormalHex: "#FFFFFF", andDarkColor: "#D3D4E6").withAlphaComponent(0.6)
        label.text = YXLanguageUtility.kLang(key: "account_net_assets")
        return label
    }()

    lazy var moneyTypeSelectionButton: QMUIButton = {
        let button = QMUIButton()
        button.qmui_outsideEdge = UIEdgeInsets(top: -20, left: -40, bottom: -20, right: -10)
        button.setImage(UIImage(named: "icon_asset_arrow"), for: .normal)

        button.rx.tap.subscribe { [weak self, weak button]_ in
            guard let `self` = self else { return }

            if self.moneyTypeSelectionView.dataSource.isEmpty {
                return
            }

            if self.moneyTypeSelectionView.isShowing() {
                self.moneyTypeSelectionView.hideWith(animated: true)
            } else {
                self.moneyTypeSelectionView.sourceView = button
                self.moneyTypeSelectionView.showWith(animated: true)
            }
        }.disposed(by: disposeBag)

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
        return view
    }()
    
    lazy var infoButton: QMUIButton = {
        let button = QMUIButton()
        button.qmui_outsideEdge = UIEdgeInsets(top: -20, left: -10, bottom: -20, right: -20)
        button.setImage(UIImage(named: "icon_asset_info"), for: .normal)

        button.rx.tap.subscribe { [weak self]_ in
            guard let `self` = self else { return }
            let accountType = YXUserManager.shared().canMargin ? "margin" : "cash"
            let url = YXH5Urls.assetsDesc(accountType: accountType)
            YXWebViewModel.pushToWebVC(url)
        }.disposed(by: disposeBag)

        return button
    }()
    
    lazy var assetValueLabel: YXCanHideTextLabel = {
        let label = YXCanHideTextLabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = UIColor.themeColor(withNormalHex: "#FFFFFF", andDarkColor: "#D3D4E6")
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.text = "--"
        return label
    }()

    lazy var enterDetailButton: YXAccountAssetDetailButton = {
        let button = YXAccountAssetDetailButton()
        button.setTitle(YXLanguageUtility.kLang(key: "my_assets"), for: .normal)
        button.setImage(UIImage(named: "icon_asset_detail"), for: .normal)
        button.imagePosition = .right
        button.spacingBetweenImageAndTitle = 0
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 4)
        button.setTitleColor(UIColor.themeColor(withNormalHex: "#FFFFFF", andDarkColor: "#D3D4E6"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)

        button.rx.tap.subscribe { [weak self]_ in
            self?.tapAssetAction?()
        }.disposed(by: disposeBag)

        return button
    }()

    lazy var gridView: QMUIGridView = {
        let gridView = QMUIGridView(column: 3, rowHeight: 34)!
        gridView.qmui_outsideEdge = UIEdgeInsets(top: 0, left: 0, bottom: -22, right: 0)
        gridView.separatorColor = .clear
        gridView.separatorWidth = 16
        gridView.columnCount = 3
        gridView.isUserInteractionEnabled = true

        gridView.rx.tapGesture(configuration: { [weak self] gesture, delegate in
            gesture.delegate = self
        }).when(.recognized).subscribe { [weak self]_ in
            guard let `self` = self else { return }
            if YXUserManager.shared().canMargin {
                self.isExpand = !self.isExpand
                self.expandButton.isSelected = self.isExpand
                self.expandOrCollapse()
            }
        }.disposed(by: disposeBag)

        return gridView
    }()

    lazy var buyingPower: YXAssetTitleValueItemView = {
        let item = creatTitleValueItem(withTitle: YXLanguageUtility.kLang(key: "account_buying_power"))
        item.titleLabel.textAlignment = .left
        item.valueLabel.textAlignment = .left
        return item
    }()

    lazy var positionValue: YXAssetTitleValueItemView = {
        let item = creatTitleValueItem(withTitle: YXLanguageUtility.kLang(key: "account_position_value"))
        item.titleLabel.textAlignment = .center
        item.valueLabel.textAlignment = .center
        return item
    }()

    lazy var cashBalance: YXAssetTitleValueItemView = {
        let item = creatTitleValueItem(withTitle: YXLanguageUtility.kLang(key: "account_cash_balance"))
        item.titleLabel.textAlignment = .right
        item.valueLabel.textAlignment = .right
        return item
    }()

    lazy var marginLoans: YXAssetTitleValueItemView = {
        let item = creatTitleValueItem(withTitle: YXLanguageUtility.kLang(key: "account_margin_loansr"))
        item.titleLabel.textAlignment = .left
        item.valueLabel.textAlignment = .left
        return item
    }()

    lazy var availableCash: YXAssetTitleValueItemView = {
        let item = creatTitleValueItem(
            withTitle: YXLanguageUtility.kLang(key: "newStock_certified_funds"),
            andIcon: UIImage(named: "icon_available_cash_menu")
        )
        item.titleLabel.textAlignment = .right
        item.valueLabel.textAlignment = .right

        item.rx.tapGesture().when(.recognized).subscribe { [weak self, weak item]_ in
            guard let `self` = self, let item = item else { return }

            if self.availableCashListView.isShowing() {
                self.availableCashListView.hideWith(animated: true)
            } else {
                self.availableCashListView.sourceView = item
                self.availableCashListView.showWith(animated: true)
            }
        }.disposed(by: disposeBag)

        return item
    }()

    lazy var riskLevel: YXAssetTitleValueItemView = {
        let item = creatTitleValueItem(withTitle: YXLanguageUtility.kLang(key: "account_risk_level"))
        item.titleLabel.textAlignment = .center
        item.valueLabel.textAlignment = .center
        return item
    }()

    private lazy var availableCashListView: YXAvailableCashView = {
        let view = YXAvailableCashView()
        view.automaticallyHidesWhenUserTap = true
        view.preferLayoutDirection = QMUIPopupContainerViewLayoutDirection.below
        return view
    }()

    // 展开/关闭事件加载在 gridView 上了，这个按钮只做状态展示
    lazy var expandButton: QMUIButton = {
        let expandButton = QMUIButton()
        expandButton.isHidden = true
        expandButton.isSelected = isExpand
        expandButton.setImage(UIImage(named: "down_arrow"), for: .normal)
        expandButton.setImage(UIImage(named: "up_arrow"), for: .selected)
        expandButton.isUserInteractionEnabled = false
        return expandButton
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.cornerRadius = 4
        layer.masksToBounds = true
        backgroundColor = UIColor.themeColor(withNormalHex: "#414FFF", andDarkColor: "#343FCC")

        let imageView = UIImageView(image: UIImage(named: "account_asset_$"))
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(11)
        }

        addSubview(hideButton)
        addSubview(assetTitleLabel)
        addSubview(assetValueLabel)
        addSubview(moneyTypeSelectionButton)
        addSubview(infoButton)
        addSubview(enterDetailButton)
        addSubview(gridView)
        addSubview(expandButton)

        hideButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalTo(assetTitleLabel)
        }

        assetTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.hideButton.snp.right).offset(2)
            make.top.equalToSuperview().offset(16)
        }

        moneyTypeSelectionButton.snp.makeConstraints { make in
            make.left.equalTo(self.assetTitleLabel.snp.right).offset(6)
            make.centerY.equalTo(assetTitleLabel)
        }

        infoButton.snp.makeConstraints { make in
            make.left.equalTo(self.moneyTypeSelectionButton.snp.right).offset(15)
            make.centerY.equalTo(assetTitleLabel)
        }

        assetValueLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(assetTitleLabel.snp.bottom).offset(4)
        }

        enterDetailButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(35)
            make.height.equalTo(20)
        }

        gridView.snp.makeConstraints { make in
            make.top.equalTo(assetValueLabel.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-22)
        }

        expandButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
        }

        reloadAccountType()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 账户类型变更
    func reloadAccountType() {
        gridView.removeAllSubviews()

        if YXUserManager.shared().canMargin { // 保证金账户
            gridView.addSubview(buyingPower)
            gridView.addSubview(positionValue)
            gridView.addSubview(cashBalance)
            gridView.addSubview(marginLoans)
            gridView.addSubview(riskLevel)
            gridView.addSubview(availableCash)

            positionValue.titleLabel.textAlignment = .center
            positionValue.valueLabel.textAlignment = .center

            cashBalance.titleLabel.textAlignment = .right
            cashBalance.valueLabel.textAlignment = .right

            expandButton.isHidden = false
        } else { // 现金账户
            gridView.addSubview(positionValue)
            gridView.addSubview(cashBalance)
            gridView.addSubview(availableCash)

            positionValue.titleLabel.textAlignment = .left
            positionValue.valueLabel.textAlignment = .left

            cashBalance.titleLabel.textAlignment = .center
            cashBalance.valueLabel.textAlignment = .center

            expandButton.isHidden = true
        }

        self.expandOrCollapse()
    }

    private func creatTitleValueItem(
        withTitle title: String,
        andIcon icon: UIImage? = nil
    ) -> YXAssetTitleValueItemView {
        let item = YXAssetTitleValueItemView()

        let attributedText = NSMutableAttributedString(string: title)
        if let icon = icon {
            attributedText.appendString(" ")

            let titleFont = item.titleLabel.font ?? .systemFont(ofSize: 12)

            let attachment = NSTextAttachment()
            attachment.image = icon
            attachment.bounds = CGRect(
                x: 0,
                y: (titleFont.capHeight - icon.size.height).rounded() / 2,
                width: icon.size.width,
                height: icon.size.height
            )

            let iconAttributedText = NSAttributedString(attachment: attachment)
            attributedText.append(iconAttributedText)
        }
        item.titleLabel.attributedText = attributedText

        item.valueLabel.text = "--"
        return item
    }

    private func expandOrCollapse() {
        if YXUserManager.shared().canMargin {
            self.marginLoans.isHidden = !isExpand
            self.availableCash.isHidden = !isExpand
            self.riskLevel.isHidden = !isExpand
        } else {
            self.availableCash.isHidden = false
        }

        var height: CGFloat = 149
        if YXUserManager.shared().canMargin, isExpand { // 展开
            height = 199
        }

        self.assetViewHeight = height

        snp.updateConstraints { make in
            make.height.equalTo(height)
        }

        self.heightDidChange?(height)
    }

}

extension YXAccountAssetView: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == self.availableCash {
            return false
        }

        return true
    }

}

class YXAssetTitleValueItemView: UIView {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.themeColor(withNormalHex: "#FFFFFF", andDarkColor: "#D3D4E6").withAlphaComponent(0.6)
        label.font = .systemFont(ofSize: 12)
        label.text = "--"
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var valueLabel: YXCanHideTextLabel = {
        let label = YXCanHideTextLabel()
        label.textColor = UIColor.themeColor(withNormalHex: "#FFFFFF", andDarkColor: "#D3D4E6")
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.text = "--"
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(valueLabel)
        
        titleLabel.snp.remakeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview()
        }

        valueLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(4.0)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


class YXCanHideTextLabel: QMUILabel {
    @objc static let hideValueNotiName = "yx_hideLabel_text_noti"
    
    var value: String? {
        didSet {
            
            if shouldShowStar {
                self.text = "****"
            }else {
                self.text = value
            }
        }
        
    }
    
    var attributedValue: NSAttributedString? {
        didSet {

            if shouldShowStar {
                self.attributedText = NSAttributedString.init(string: "****")
            }else {
                self.attributedText = attributedValue
            }
        }
        
    }
    
    var shouldShowStar = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        refreshValueText()
        
        _ = NotificationCenter.default.rx.notification(NSNotification.Name(YXCanHideTextLabel.hideValueNotiName))
            .takeUntil(rx.deallocated)
            .subscribe(onNext: {
                [weak self] _ in
                self?.refreshValueText()
                
            }).disposed(by: rx.disposeBag)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func changeText(noti: Notification) {
        
        if let shouldHide = noti.userInfo?["shouldHide"] as? Bool {
            shouldShowStar = shouldHide
            if shouldShowStar {
                self.text = "****"
//                self.attributedText = NSAttributedString(string: "***")
            }else {
                if let value = self.value {
                    self.text = value
                }
                if let attValue = self.attributedValue {
                    self.attributedText = attValue
                }
            }
        }
    }
    
    private func refreshValueText() {
        self.shouldShowStar = YXAccountAssetView.assetHidden
        if YXAccountAssetView.assetHidden {
            self.text = "****"
        } else {
            if let value = self.value {
                self.text = value
            }
            if let attValue = self.attributedValue {
                self.attributedText = attValue
            }        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
