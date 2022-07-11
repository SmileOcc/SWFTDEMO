//
//  YXSmartPushSettingsCell.swift
//  uSmartOversea
//
//  Created by youxin on 2019/3/29.
//  Copyright © 2019年 RenRenDai. All rights reserved.
//

import UIKit

class YXSmartPushSettingsCell: UITableViewCell {
    
    typealias SwitchBlockCallback = (_ result: Bool, _ cell: YXSmartPushSettingsCell) -> ()
    
    var handleCallBack: SwitchBlockCallback?
    
    func reloadData(_ indexPath: IndexPath, _ model: YXSmartPushSettingSignal) {
       
        detailLabel.isHidden = true

        titleLabel.text = model.signalName != nil ? model.signalName! : ""
        if let isOn = model.defult, isOn > 0 {
            customSwtich.isOn = true
        } else {
            customSwtich.isOn = false
        }
        
        textField.isHidden = titleLabel.text == "郵件地址" ? false : true
        customSwtich.isHidden = titleLabel.text == "郵件地址" ? true : false
    }
    
    fileprivate func handleSwitchBlock() {
        customSwtich.valueChangeHandle = {
         [unowned self] (isOn) in
            self.handleCallBack?(isOn, self)
        }
    }
    
    //MARK: initialization Method
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        initializeViews()
        handleSwitchBlock()
        
    }
    
    func initializeViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(customSwtich)
        contentView.addSubview(lineView)
        contentView.addSubview(textField)
        
        let margin: CGFloat = 18
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(margin)
            make.centerY.equalToSuperview()
            make.width.equalTo(contentView.snp.width).multipliedBy(2.0/3.0)
        }
        
        detailLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-margin)
            make.centerY.equalToSuperview()
            make.width.equalTo(contentView.snp.width).multipliedBy(1.0/3.0)
        }
        
        customSwtich.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-margin)
            make.centerY.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(20)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(margin)
            make.right.equalToSuperview().offset(-margin)
            make.height.equalTo(1)
        }
        
        textField.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-margin)
            make.centerY.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(26)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Lazy setter and getter
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = QMUITheme().textColorLevel1()
        label.textAlignment = .left
        return label
    }()
    
    lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel3()
        label.textAlignment = .right
        return label
    }()
    
    
    lazy var customSwtich: YXCustomSwitch = {
        let aSwitch = YXCustomSwitch.init()
        return aSwitch
    }()
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().separatorLineColor()
        return view
    }()
    
    lazy var textField: UITextField = {
        let textField = SmartMailTextField()
        textField.textAlignment = .right
        textField.placeholder = "請輸入您的郵箱地址"
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = QMUITheme().textColorLevel1()
        textField.placeHolderLabel.textColor = QMUITheme().separatorLineColor()
        return textField
    }()
    
}

fileprivate class SmartMailTextField: UITextField {
    
    var placeHolderLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    override var placeholder: String? {
        didSet {
            placeHolderLabel.text = placeholder
        }
    }
    
    override var attributedPlaceholder: NSAttributedString? {
        didSet {
            placeHolderLabel.text = attributedPlaceholder?.string
        }
    }

    override var textAlignment: NSTextAlignment {
        didSet {
            placeHolderLabel.textAlignment = textAlignment
        }
    }
    
    override var font: UIFont? {
        didSet {
            placeHolderLabel.font = font
        }
    }
    
    @objc func textFieldDidChange(_ textfield : UITextField) {
        if let txt = text , !txt.isEmpty {
            placeHolderLabel.isHidden = true
        } else {
            placeHolderLabel.isHidden = false
        }
    }
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    deinit {
        self.removeTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    fileprivate func setup() {
        borderStyle = UITextField.BorderStyle.none
        // Set up title label
        addSubview(placeHolderLabel)
        addSubview(lineView)
        self.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        lineView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        placeHolderLabel.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(lineView.snp.top)
        }
    }
    
    private lazy var lineView: UIView = {
       let view = UIView()
        view.backgroundColor = QMUITheme().separatorLineColor()
        return view
    }()
}
