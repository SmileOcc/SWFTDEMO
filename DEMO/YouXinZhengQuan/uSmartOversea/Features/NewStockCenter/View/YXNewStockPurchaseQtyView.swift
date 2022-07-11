//
//  YXNewStockPurchaseQtyView.swift
//  uSmartOversea
//
//  Created by 裴艳东 on 2019/5/8.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class YXNewStockPurchaseQtyView: UIView {
    
    typealias SelectTypeBlock = (YXNewStockQtyAndChargeModel) -> Void
    
    var selectBlock: SelectTypeBlock?
    var qtyAndCharges: [YXNewStockQtyAndChargeModel] = []
    var selectedIndex: Int = 0
    var orginIndex: Int = 0
    var applyType: YXNewStockSubsType = .financingSubs {
        didSet {
            self.tableZoneView.frame = CGRect(x: 0, y: YXConstant.screenHeight, width: YXConstant.screenWidth, height: self.kTableZoneViewHeight)
        }
    }

    
    var isFirst: Bool = false
    func handleActionEvent() {
        cancelButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.selectedIndex = self.orginIndex
                self.hide()
            }).disposed(by: rx.disposeBag)
        
        confirmButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.hide()
                if strongSelf.qtyAndCharges.count > 0, strongSelf.selectedIndex < strongSelf.qtyAndCharges.count {
                    strongSelf.selectBlock?(strongSelf.qtyAndCharges[strongSelf.selectedIndex])
                }
            }).disposed(by: rx.disposeBag)
        
        tapButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.selectedIndex = self.orginIndex
                self.hide()
            }).disposed(by: rx.disposeBag)
    }
    
    func setQtyAndCharges(qtyAndCharges: [YXNewStockQtyAndChargeModel], financeModify: Bool) {

        if financeModify {
            var tempQtyAndCharges: [YXNewStockQtyAndChargeModel] = []
            //融资改单，只展示大于之前认购数量的选项
            for model in qtyAndCharges {
                if let sharedApplied = model.sharedApplied,
                    let purchaseNum = model.purchaseNum,
                    sharedApplied >= purchaseNum {
                    tempQtyAndCharges.append(model)
                }
            }
            self.qtyAndCharges = tempQtyAndCharges
        } else {
            self.qtyAndCharges = qtyAndCharges
        }
    
        for (index, model) in self.qtyAndCharges.enumerated() {
            if let purchaseNum = model.purchaseNum, purchaseNum > 0,
                let shared_applied = model.sharedApplied, purchaseNum == shared_applied {
                selectedIndex = index
                break
            }
        }

        if !isFirst {
            isFirst = true
            initUI()
            handleActionEvent()
        }
        self.tableZoneView.frame = CGRect(x: 0, y: YXConstant.screenHeight, width: YXConstant.screenWidth, height: self.kTableZoneViewHeight)
        self.pickView.selectRow(selectedIndex, inComponent: 0, animated: false)
        pickView.reloadAllComponents()
    }
    
    func show() {
        self.isHidden = false
        UIView.animate(withDuration: 0.2) {
            self.tableZoneView.frame = CGRect(x: 0, y: YXConstant.screenHeight - self.tableZoneView.frame.height, width: YXConstant.screenWidth, height: self.tableZoneView.frame.height)
        }
        orginIndex = selectedIndex
        self.pickView.selectRow(selectedIndex, inComponent: 0, animated: false)
        pickView.reloadAllComponents()
    }
    
    override func hide() {
        UIView.animate(withDuration: 0.2, animations: {
            self.tableZoneView.frame = CGRect(x: 0, y: YXConstant.screenHeight, width: YXConstant.screenWidth, height: self.tableZoneView.frame.height)
        }) { (_) in
            self.isHidden = true
        }
    }
    
    func resetToFirst() {
        selectedIndex = 0
        self.pickView.selectRow(selectedIndex, inComponent: 0, animated: false)
        if self.qtyAndCharges.count > 0, self.selectedIndex < self.qtyAndCharges.count {
            self.selectBlock?(self.qtyAndCharges[self.selectedIndex])
        }
    }
    
    override func layoutSubviews() {
        
        let maskPath = UIBezierPath.init(roundedRect: tableZoneView.bounds, byRoundingCorners: [UIRectCorner.topLeft, .topRight], cornerRadii: CGSize(width: 20, height: 20))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = tableZoneView.bounds
        maskLayer.path = maskPath.cgPath
        tableZoneView.layer.mask = maskLayer
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isHidden = true
        self.backgroundColor = QMUITheme().textColorLevel1().withAlphaComponent(0.2)
    }
    
    func initUI() {
        addSubview(tapButton)
        addSubview(tableZoneView)
        tableZoneView.addSubview(cancelButton)
        tableZoneView.addSubview(confirmButton)
        tableZoneView.addSubview(lineView)
        tableZoneView.addSubview(pickView)
        
        tapButton.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        cancelButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.height.equalTo(20)
            make.top.equalToSuperview().offset(13)
        }
        
        confirmButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(20)
            make.top.equalToSuperview().offset(13)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalToSuperview().offset(45)
        }
        
        pickView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-YXConstant.tabBarPadding())
            make.top.equalTo(lineView.snp.bottom).offset(10)
        }
    }
    
    var kTableZoneViewHeight: CGFloat {
        5.0 * kCellHeight + YXConstant.tabBarPadding() + 45
    }
    var kCellHeight: CGFloat {
        if self.applyType == .cashSubs {
            return 50
        } else {
            return 60
        }
    }
    
    lazy var tableZoneView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().textColorLevel1()
        return view
    }()
    
    lazy var cancelButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setTitle(YXLanguageUtility.kLang(key: "common_cancel"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        return button
    }()
    
    lazy var confirmButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setTitle(YXLanguageUtility.kLang(key: "common_confirm2"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        return button
    }()
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.qmui_color(withHexString: "#070B14")?.withAlphaComponent(0.1)
        return view
    }()
    
    lazy var tapButton: QMUIButton = {
        let button = QMUIButton()
        button.setTitle("", for: .normal)
        return button
    }()
    
    lazy var pickView: UIPickerView = {
        let view = UIPickerView()
        view.delegate = self
        view.dataSource = self
        view.showsSelectionIndicator = true
        return view
    }()

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension YXNewStockPurchaseQtyView: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        self.qtyAndCharges.count
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        YXConstant.screenWidth
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        kCellHeight
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: pickerView.rowSize(forComponent: component).width, height: pickerView.rowSize(forComponent: component).height)
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 10.0 / 14.0
        label.textAlignment = .center
        
        label.textColor = QMUITheme().textColorLevel1()
        
        let model = self.qtyAndCharges[row]
        
        var unitString = YXToolUtility.moneyUnit(2)
        if let moneyType = model.moneyType {
            unitString = YXToolUtility.moneyUnit(moneyType)
        }
        
        let prefixString = String(format: "%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(model.sharedApplied ?? 0), YXLanguageUtility.kLang(key: "newStock_stock_unit"))
        let suffixString = String(format: "%@%@", YXNewStockMoneyFormatter.shareInstance.formatterMoney(model.appliedAmount ?? 0), unitString)

        if self.applyType == .cashSubs {
            let handleFee = model.cashHandlingFee ?? 0.0
            if let availableAmount = model.availableAmount,
                let applied_amount = model.appliedAmount,
                availableAmount < (applied_amount + handleFee) {
                //可用现金不足
                label.text = String(format: "%@ (%@, %@)", prefixString, suffixString, YXLanguageUtility.kLang(key: "newStock_certified_funds_short"))
            } else {
                //可用现金充足
                label.text = String(format: "%@ (%@)", prefixString, suffixString)
            }
            
        } else {
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineSpacing = 3.0
            paragraph.alignment = .center
        
            let attributes = [NSAttributedString.Key.paragraphStyle : paragraph, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1()]
            if let availableAmount = model.availableAmount {
           
                let leastAmount = model.leastCash ?? 0
                if availableAmount < leastAmount {

                    var leverage = ""
                    if let multiple = model.financingMultiple, multiple > 0 {
                        leverage = "(\(String(format: YXLanguageUtility.kLang(key: "newStock_bank_finance_tag"), multiple)))"
                    }
                    let secondLineText = String(format: "%@%@%@%@, %@", YXLanguageUtility.kLang(key: "newStock_finance_least_cash"), YXNewStockMoneyFormatter.shareInstance.formatterMoney(leastAmount), unitString, leverage, YXLanguageUtility.kLang(key: "newStock_certified_funds_short"))
        
                    //可用现金不足
                    label.attributedText = NSAttributedString.init(string: String(format: "%@ (%@)\n%@", prefixString, suffixString, secondLineText), attributes: attributes)
                } else {

                    //可用现金充足
                    label.attributedText = NSAttributedString.init(string: String(format: "%@ (%@)", prefixString, suffixString), attributes: attributes)
                }
        
            } else {
                //可用现金充足
                label.attributedText = NSAttributedString.init(string: String(format: "%@ (%@)", prefixString, suffixString), attributes: attributes)
            }
        }

        changeSeperatorLineColor()
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIndex = row
        pickerView.selectRow(row, inComponent: component, animated: true)
    }
    
    func changeSeperatorLineColor() {
        for view in pickView.subviews {
            if view.frame.size.height < 1 {
                view.backgroundColor = QMUITheme().separatorLineColor()
            }
        }
    }
}

@objcMembers class YXExpandAreaButton: QMUIButton {

    var expandX: CGFloat = 5
    var expandY: CGFloat = 5
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if self.isHidden || !self.isUserInteractionEnabled {
            return false
        }
        let bounds = self.bounds.inset(by: UIEdgeInsets(top: -abs(expandY), left: -abs(expandX), bottom: -abs(expandY), right: -abs(expandX)))
        return bounds.contains(point)
    }
}
