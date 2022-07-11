//
//  YXStockFilterPickerView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/4.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXStockFilterPickerView: UIView {

    var didSelectedRowArr: [Int] = []
    var filterItem: YXStockFilterItem?
    var customValue: YXStokFilterListItem?
    var dataSources: [[YXStokFilterListItem]] = []
    var sureAction: ((_ actionType: YXStockFilterActionType) -> Void)?
    var customAction: ((_ item: YXStockFilterItem) -> Void)?
    
    lazy var contentContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()

    lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView.init()
        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
    }()
    
    lazy var sureButton: UIButton = {
        let button = UIButton()
        button.setTitle(YXLanguageUtility.kLang(key: "common_confirm"), for: .normal)
        button.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            
            if let item = self.filterItem {
                self.sureAction?(.selectedItem(item: item, selectedValueIndexs: self.didSelectedRowArr))
            }
            
            self.hide()
        })
        return button
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ad_close"), for: .normal)
        _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] in
            self?.hide()
        })
        return button
    }()
    
    lazy var customButton: QMUIButton = {
        let button = QMUIButton()
        button.imagePosition = .left
        button.spacingBetweenImageAndTitle = 2
        button.setTitle(YXLanguageUtility.kLang(key: "history_custom_date"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        let image = UIImage(named: "add_blue")?.qmui_image(withTintColor: QMUITheme().themeTextColor())
        button.setImage(image, for: .normal)
        button.isHidden = true
        
        _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self](e) in
            guard let `self` = self else { return }
            if let item = self.filterItem {
                self.customAction?(item)
            }
        })

        return button
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = QMUITheme().textColorLevel2()
        return label
    }()
    
    func show(withFilterItem item: YXStockFilterItem, inView view: UIView) {
        // 自定义的item也会在列表里返回，展示时需要把它过滤掉，并把自定义item缓存，用于定义界面展示
        filterItem = item
        customValue = nil
        customButton.isHidden = true
        titleLabel.text = item.name
        
        dataSources = []
        didSelectedRowArr = []
        for listItem in item.queryValueList {
            var selectedIndex = 0
            var arr: [YXStokFilterListItem] = []
            for (index, item) in listItem.list.enumerated() {
                if item.key != "custom" {
                    if item.isSelected {
                        selectedIndex = index
                    }
                    arr.append(item)
                }else {
                    customValue = item
                    customButton.isHidden = false
                }
            }
            dataSources.append(arr)
            didSelectedRowArr.append(selectedIndex)
        }
        
        pickerView.reloadAllComponents()
        
        for (index, value) in didSelectedRowArr.enumerated() {
            pickerView.selectRow(value, inComponent: index, animated: true)
        }
        
        view.addSubview(self)
        
        self.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.bottom.equalToSuperview()
            }
        }
        
        self.layoutIfNeeded()
        
        contentContainerView.snp.remakeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(YXConstant.safeAreaInsetsBottomHeight()+250)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    override func hide() {
        contentContainerView.snp.remakeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.snp.bottom)
            make.height.equalTo(YXConstant.safeAreaInsetsBottomHeight()+250)
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
        }) { (isFinish) in
            self.removeFromSuperview()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        let tap = UITapGestureRecognizer.init { [weak self](tap) in
            self?.hide()
        }
        
        self.addGestureRecognizer(tap)
        
        let grayView = UIView()
        grayView.backgroundColor = QMUITheme().backgroundColor()
        
        let graySeparateView = UIView()
        graySeparateView.backgroundColor = QMUITheme().backgroundColor()
        
        grayView.addSubview(cancelButton)
        grayView.addSubview(titleLabel)
        grayView.addSubview(customButton)
        cancelButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(12)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        customButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-12)
        }
        
        contentContainerView.addSubview(grayView)
        contentContainerView.addSubview(graySeparateView)
        
        contentContainerView.addSubview(pickerView)
        contentContainerView.addSubview(sureButton)
        
        self.addSubview(contentContainerView)
        
        grayView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(40)
        }
        
        pickerView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(grayView.snp.bottom)
            make.bottom.equalTo(graySeparateView.snp.top)
        }
        
        graySeparateView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(5)
            make.bottom.equalTo(sureButton.snp.top)
        }
        
        sureButton.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(50)
        }
        
        contentContainerView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.snp.bottom)
            make.height.equalTo(YXConstant.safeAreaInsetsBottomHeight()+250)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


extension YXStockFilterPickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return dataSources.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSources[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let list = dataSources[component]
        let item = list[row]
        
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18)
        label.textColor = QMUITheme().textColorLevel1()
        label.text = item.name
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50.0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if didSelectedRowArr.count > component {
            didSelectedRowArr[component] = row
        }
        
    }
    
}
