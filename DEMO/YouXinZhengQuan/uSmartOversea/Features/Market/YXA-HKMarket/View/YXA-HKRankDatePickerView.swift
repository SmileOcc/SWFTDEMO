//
//  YXA-HKRankDatePickerView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/3/24.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXA_HKRankDatePickerView: UIView {
    
    var dataSource: [String]? {
        didSet {
            if let arr = dataSource, arr.count > 0 {
                pickerView.reloadAllComponents()
            }
        }
    }
    
    var didSelectedValue: String?
    var selectedDateSubject = PublishSubject<String>()

    lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView.init()
        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
    }()
    
    lazy var sureButton: UIButton = {
        let button = UIButton()
        button.setTitle(YXLanguageUtility.kLang(key: "common_confirm"), for: .normal)
        button.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        
        _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] in
            if let value = self?.didSelectedValue {
                self?.selectedDateSubject.onNext(value)
            }
            self?.hide()
        })
        return button
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(YXLanguageUtility.kLang(key: "common_cancel"), for: .normal)
        button.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] in
            self?.hide()
        })
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = QMUITheme().foregroundColor()
        self.addSubview(pickerView)
        
        self.addSubview(sureButton)
        self.addSubview(cancelButton)
        
        pickerView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(50)
        }
        
        sureButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-12)
        }
        
        cancelButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(12)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension YXA_HKRankDatePickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        dataSource?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let text = dataSource?[row]
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = QMUITheme().textColorLevel1()
        label.text = text
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        didSelectedValue = dataSource?[row]
    }
    
}
