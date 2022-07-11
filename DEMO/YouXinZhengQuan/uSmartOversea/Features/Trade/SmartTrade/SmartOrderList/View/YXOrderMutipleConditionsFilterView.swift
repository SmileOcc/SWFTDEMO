//
//  YXOrderMutipleConditionsFilterView.swift
//  uSmartOversea
//
//  Created by Evan on 2021/12/30.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

protocol YXOrderFilterBase {
    var title: String { get }
    func requestValue(_ filterOrderType: YXOrderFilterType?) -> String
}

enum YXOrderSecurityFilterType: Int {
    case all
    case stock
    case warrant
    case option
    case fraction
}

extension YXOrderSecurityFilterType: CaseIterable, YXOrderFilterBase {
    var title: String {
        switch self {
        case .all:
            return YXLanguageUtility.kLang(key: "common_all")
        case .stock:
            return YXLanguageUtility.kLang(key: "hold_stock_name")
        case .warrant:
            return YXLanguageUtility.kLang(key: "derivatives")
        case .option:
            return YXLanguageUtility.kLang(key: "options")
        case .fraction:
            return YXLanguageUtility.kLang(key: "fractional_shares")
        }
    }

    var requestValue: String {
        switch self {
        case .all:
            return ""
        case .stock:
            return "1"
        case .warrant:
            return "3"
        case .option:
            return "4"
        case .fraction:
            return "2"
        }
    }

    var smartOrderRequestValue: String {
        switch self {
        case .all:
            return ""
        case .stock:
            return "1"
        case .warrant:
            return "2"
        case .option:
            return "3"
        default:
            return ""
        }
    }

    func requestValue(_ filterOrderType: YXOrderFilterType?) -> String {
        if filterOrderType == .smartOrder {
            return smartOrderRequestValue
        }
        return requestValue
    }
}

enum YXOrderFilterStatus: String {
    case all
    case traded
    case canceled
    case failed
    case active
    case triggered
    case expired
    case invalid

    case waitTrade
    case partTrade
    case partCancel

    case waitSubmit
}

extension YXOrderFilterStatus: YXOrderFilterBase {
    var title: String {
        switch self {
        case .all:
            return YXLanguageUtility.kLang(key: "common_all")
        case .traded:
            return YXLanguageUtility.kLang(key: "orderfilter_traded_order")
        case .canceled:
            return YXLanguageUtility.kLang(key: "orderfilter_had_removed")
        case .failed:
            return YXLanguageUtility.kLang(key: "orderfilter_place_order_fail")
        case .active:
            return YXLanguageUtility.kLang(key: "orderfilter_active")
        case .triggered:
            return YXLanguageUtility.kLang(key: "orderfilter_triggered")
        case .expired:
            return YXLanguageUtility.kLang(key: "orderfilter_lost_effectiveness")
        case .waitTrade:
            return YXLanguageUtility.kLang(key: "filter_wait_deal")
        case .partTrade:
            return YXLanguageUtility.kLang(key: "filter_part_deal")
        case .partCancel:
            return YXLanguageUtility.kLang(key: "filter_part_cancel")
        case .invalid:
            return YXLanguageUtility.kLang(key: "filter_invalid")
        case .waitSubmit:
            return YXLanguageUtility.kLang(key: "filter_pending_queue")
        }
    }

    var requestValue: String {
        switch self {
        case .all:
            return ""
        case .traded:
            return "29"
        case .canceled:
            return "30"
        case .failed:
            return "31"
        case .active:
            return "0"
        case .triggered:
            return "1"
        case .expired:
            return ""
        case .waitTrade:
            return "11"
        case .partTrade:
            return "20"
        case .partCancel:
            return "28"
        case .invalid:
            return "32"
        case .waitSubmit:
            return "11"
        }
    }

    //期权的全部订单筛选
    var filterOptionRequestValue: String {
        switch self {
        case .all:
            return ""
        case .traded:
            return "70"
        case .canceled:
            return "90"
        case .failed:
            return "30"
        case .waitTrade:
            return "50"
        case .partTrade:
            return "60"
        case .partCancel:
            return "100"
        default:
            return ""
        }
    }

    //沽空的全部订单筛选
    var filterShortRequestValue: String {
        switch self {
        case .all:
            return ""
        case .traded:
            return "70"
        case .canceled:
            return "90"
        case .failed:
            return "30"
        case .waitTrade:
            return "50"
        case .partTrade:
            return "60"
        case .partCancel:
            return "100"
        default:
            return ""
        }
    }

    //智能订单全部订单筛选
    var filterSmartOrderRequestValue: String {
        switch self {
        case .all:
            return ""
        case .active:
            return "0"
        case .triggered:
            return "1"
        case .expired:
            return "2"
        case .canceled:
            return "3"
        default:
            return ""
        }
    }

    func requestValue(_ filterOrderType: YXOrderFilterType?) -> String {
        switch filterOrderType {
        case .smartOrder:
            return filterSmartOrderRequestValue
        case .optionOrder:
            return filterOptionRequestValue
        case .shortOrder:
            return filterShortRequestValue
        default:
            return requestValue
        }
    }
}

enum YXSmartOrderFilterType: Int {
    case all
    case breakthroughBuy
    case buyLow
    case sellHigh
    case breakdownSell
    case stopProfitSell             // 止盈卖出
    case stopLossSell               // 止损卖出
    case trailingStop               // 跟踪止损
    case stockHandicap              // 关联资产触发
}

extension YXSmartOrderFilterType: CaseIterable, YXOrderFilterBase {
    var title: String {
        switch self {
        case .all:
            return YXLanguageUtility.kLang(key: "common_all")
        case .breakthroughBuy:
            return YXLanguageUtility.kLang(key: "trading_break_buy_order")
        case .buyLow:
            return YXLanguageUtility.kLang(key: "trading_low_price_buy_order")
        case .sellHigh:
            return YXLanguageUtility.kLang(key: "trading_high_price_sell_order")
        case .breakdownSell:
            return YXLanguageUtility.kLang(key: "trading_break_sell_order")
        case .stopProfitSell:
            return YXLanguageUtility.kLang(key: "trading_stop_profit_sell_order")
        case .stopLossSell:
            return YXLanguageUtility.kLang(key: "trading_stop_loss_sell_order")
        case .trailingStop:
            return YXLanguageUtility.kLang(key: "trading_traling_stop")
        case .stockHandicap:
            return YXLanguageUtility.kLang(key: "trigger_follow_stock_n")
        }
    }

    var requestValue: String {
        switch self {
        case .all:
            return ""
        case .breakthroughBuy:
            return "1"
        case .buyLow:
            return "2"
        case .sellHigh:
            return "3"
        case .breakdownSell:
            return "4"
        case .stopProfitSell:
            return "5"
        case .stopLossSell:
            return "6"
        case .trailingStop:
            return "7"
        case .stockHandicap:
            return "8"
        }
    }

    func requestValue(_ filterOrderType: YXOrderFilterType?) -> String {
        requestValue
    }
}

enum YXOrderFilterCondition {
    case securityType(_ orderFilterType: YXOrderFilterType)
    case orderStatus(_ orderFilterType: YXOrderFilterType)
    case smartOrderType

    var title: String {
        switch self {
        case .securityType:
            return YXLanguageUtility.kLang(key: "security_type")
        case.orderStatus(let orderFilterType):
            if orderFilterType == .smartOrder {
                return YXLanguageUtility.kLang(key: "smart_order_status")
            } else {
                return YXLanguageUtility.kLang(key: "order_status")
            }
        case .smartOrderType:
            return YXLanguageUtility.kLang(key: "smart_order_type")
        }
    }

    var items: [YXOrderFilterBase] {
        switch self {
        case .securityType(let orderFilterType):
            var orderFilterTypes: [YXOrderSecurityFilterType]
            if orderFilterType == .smartOrder {
                orderFilterTypes = [.all, .stock, .warrant]
            } else {
                orderFilterTypes = YXOrderSecurityFilterType.allCases
            }
            return orderFilterTypes
        case .orderStatus(let orderFilterType):
            var orderStatuses: [YXOrderFilterStatus]
            switch orderFilterType {
            case .allOrder:
                orderStatuses = [.all, .traded, .partTrade, .waitSubmit,  .partCancel, .canceled, .failed, .invalid]
            case .conditionOrder:
                orderStatuses = [.all, .active, .triggered, .expired]
            case .smartOrder:
                orderStatuses = [.all, .active, .triggered, .expired, .canceled]
            case .optionOrder:
                orderStatuses = [.all, .traded, .partTrade, .waitTrade, .partCancel, .canceled, .failed ]
            case .intradayHold:
                orderStatuses = []
            case .shortOrder:
                orderStatuses = [.all, .traded, .partTrade, .waitTrade,  .partCancel, .canceled, .failed ]
            default:
                orderStatuses = []
            }
            return orderStatuses
        case .smartOrderType:
            return YXSmartOrderFilterType.allCases
        }
    }
}

class YXOrderMutipleConditionsFilterView: UIControl {

    private var selectedSecurityType: YXOrderSecurityFilterType = .all

    private var selectedOrderStatus: YXOrderFilterStatus = .all

    private var selectedOrderType: YXSmartOrderFilterType?

    private var conditions: [YXOrderFilterCondition] = []

    private let bag = DisposeBag()

    private var contentViewHeight: CGFloat = 475

    var didSelectConditionBlock: ((YXOrderSecurityFilterType, YXOrderFilterStatus, YXSmartOrderFilterType?) -> Void)?

    var didHideBlock: ((Bool) -> Void)?

    lazy var cancelButton: QMUIButton = {
        let cancelButton = QMUIButton()
        cancelButton.setTitle(YXLanguageUtility.kLang(key: "common_cancel"), for: .normal)
        cancelButton.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        cancelButton.backgroundColor = QMUITheme().foregroundColor()
        cancelButton.layer.borderColor = QMUITheme().separatorLineColor().cgColor
        cancelButton.layer.borderWidth = 1.0
        cancelButton.layer.cornerRadius = 4
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)

        _ = cancelButton.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self](btn) in
            self?.hidden()
        })

        return cancelButton
    }()

    lazy var confirmButton: QMUIButton = {
        let confirmButton = QMUIButton()
        confirmButton.setTitle(YXLanguageUtility.kLang(key: "common_confirm2"), for: .normal)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.backgroundColor = QMUITheme().themeTextColor()
        confirmButton.layer.borderColor = QMUITheme().themeTextColor().cgColor
        confirmButton.layer.borderWidth = 1.0
        confirmButton.layer.cornerRadius = 4
        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return confirmButton
    }()

    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 15

        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = QMUITheme().foregroundColor()
        view.register(YXOrderMutipleConditionsFilterCell.self,
                      forCellWithReuseIdentifier: NSStringFromClass(YXOrderMutipleConditionsFilterCell.self))
        view.register(YXOrderMutipleConditionsFilterHeaderView.self,
                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                      withReuseIdentifier: NSStringFromClass(YXOrderMutipleConditionsFilterHeaderView.self))

        return view
    }()

    @objc init(frame: CGRect, type: YXOrderFilterType) {
        super.init(frame: frame)

        contentViewHeight = type == .smartOrder ? 475 : 396

        self.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            self?.hidden()
        }).disposed(by: bag)

        confirmButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.didSelectConditionBlock?(self.selectedSecurityType, self.selectedOrderStatus, self.selectedOrderType)
        }).disposed(by: bag)

        self.backgroundColor = QMUITheme().shadeLayerColor()

        switch type {
        case .smartOrder:
            conditions = [.securityType(type), .orderStatus(type), .smartOrderType]
        default:
            conditions = [.securityType(type), .orderStatus(type)]
        }

        let cancelBtnAndConfirmBtnStackView = UIStackView.init(arrangedSubviews: [cancelButton, confirmButton])
        cancelBtnAndConfirmBtnStackView.alignment = .fill
        cancelBtnAndConfirmBtnStackView.axis = .horizontal
        cancelBtnAndConfirmBtnStackView.distribution = .fillEqually
        cancelBtnAndConfirmBtnStackView.spacing = 21

        containerView.addSubview(collectionView)
        containerView.addSubview(cancelBtnAndConfirmBtnStackView)
        addSubview(containerView)

        collectionView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview()
        }

        cancelBtnAndConfirmBtnStackView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(42)
            make.top.equalTo(collectionView.snp.bottom).offset(20)
        }

        containerView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(-contentViewHeight)
            make.height.equalTo(contentViewHeight)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let maskPath = UIBezierPath(
            roundedRect: CGRect.init(x: 0, y: 0, width: self.bounds.width, height: contentViewHeight),
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: 20, height: 20)
        )

        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        self.containerView.layer.mask = shape
    }

    func show(
        withSecurityType securityType: YXOrderSecurityFilterType,
        orderStatus: YXOrderFilterStatus,
        orderType: YXSmartOrderFilterType?
    ) {
        selectedSecurityType = securityType
        selectedOrderStatus = orderStatus
        selectedOrderType = orderType

        self.isHidden = false
        collectionView.reloadData()

        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.snp.updateConstraints { (make) in
                make.top.equalToSuperview()
            }
            self.layoutIfNeeded()
        })
    }

    func hidden() {
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.snp.updateConstraints { (make) in
                make.top.equalToSuperview().offset(-self.contentViewHeight)
            }
            self.layoutIfNeeded()
        }) { (finished) in
            self.isHidden = true
            self.didHideBlock?(finished)
        }
    }
}

extension YXOrderMutipleConditionsFilterView:
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        conditions.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        conditions[section].items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: NSStringFromClass(YXOrderMutipleConditionsFilterCell.self),
            for: indexPath
        ) as! YXOrderMutipleConditionsFilterCell

        let item = conditions[indexPath.section].items[indexPath.row]
        cell.titleLabel.text = item.title

        if YXUserManager.isENMode(), let item = item as? YXSmartOrderFilterType, item == .stockHandicap {
            cell.titleLabel.numberOfLines = 2
        } else {
            cell.titleLabel.numberOfLines = 1
        }

        var isChoosed = false

        switch conditions[indexPath.section] {
        case .securityType:
            isChoosed = selectedSecurityType == (item as! YXOrderSecurityFilterType)
        case .orderStatus(_):
            isChoosed = selectedOrderStatus == (item as! YXOrderFilterStatus)
        case .smartOrderType:
            isChoosed = selectedOrderType == (item as! YXSmartOrderFilterType)
        }

        cell.isChoosed = isChoosed

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: NSStringFromClass(YXOrderMutipleConditionsFilterHeaderView.self),
                for: indexPath
            ) as! YXOrderMutipleConditionsFilterHeaderView

            let condition = conditions[indexPath.section]
            header.titleLabel.text = condition.title

            return header
        }
        return UICollectionReusableView()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: (collectionView.width - 30) / 3, height: 32)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: collectionView.size.width, height: 55)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let condition = conditions[indexPath.section]
        let item = condition.items[indexPath.row]

        switch conditions[indexPath.section] {
        case .securityType:
            selectedSecurityType = (item as! YXOrderSecurityFilterType)
        case .orderStatus(_):
            selectedOrderStatus = (item as! YXOrderFilterStatus)
        case .smartOrderType:
            selectedOrderType = (item as! YXSmartOrderFilterType)
        }

        collectionView.reloadData()
    }
}
