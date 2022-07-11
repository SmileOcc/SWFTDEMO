//
//  YXStatementTimeRangeView.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/7/17.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXStatementTimeRangeView<E: EnumTextProtocol & Equatable>: UIView {

    private var typeArr: [E]! {
        didSet {
            if oldValue != typeArr {

            }
        }
    }
    
    var selectedType: E! {
        didSet {
            updateUI()
        }
    }
    
    private var selectedBlock: ((E) -> Void)?
    
    var buttons:[QMUIButton] = []
    
    lazy var titleLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .normalFont16()
        label.text = YXLanguageUtility.kLang(key: "history_time_limit")
        return label
    }()
    
    lazy var buttonView: UIView = {
        let view = UIView()

        return view
    }()
    
    convenience init(typeArr: [E], selected: E? = nil, selectedBlock:((E) -> Void)?) {
        self.init()
        
        self.typeArr = typeArr
        self.selectedBlock = selectedBlock
        
        if let type = selected, self.typeArr.contains(type) {
            self.selectedType = type
        } else {
            self.selectedType = typeArr.first
        }
        
        initUI()
        updateUI()

    }
    
    private func initUI() {
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(12)
        }
        addSubview(buttonView)
        
        var hang:Int = self.typeArr.count / 3
        let row:Int = self.typeArr.count % 3
        if row > 0 {
            hang = hang + 1
        }
        
        buttonView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo( hang * 32 + ( hang - 1) * 8)
        }
       
        for (index,type) in self.typeArr.enumerated() {
            let btn = createButton(title: type.text, tag: index)
            btn.addTarget(self, action: #selector(clickAction(_ :)), for: .touchUpInside)
            buttonView.addSubview(btn)
            buttons.append(btn)

        }

        if buttons.count == 1 {
            buttons.first?.snp.makeConstraints({ make in
                make.left.equalToSuperview()
                make.width.equalTo(105)
                make.height.equalTo(32)
            })
        }else{
            let unitwidth:CGFloat = ( YXConstant.screenWidth - 24 - 17 * 2 ) / 3
            buttons.snp.distributeSudokuViews(fixedItemWidth: unitwidth, fixedItemHeight: 32, warpCount: 3)
        }
    }
    

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
  
    @objc func clickAction(_ sender:UIButton) {
        let index:Int = sender.tag
        let type = typeArr[index]
      
        self.selectedType = type
        updateUI()
        self.selectedBlock?(selectedType)
    }
    
    private func updateUI() {
        
        for btn in self.buttons {
            if btn.titleLabel?.text == self.selectedType.text  {
                btn.isSelected = true
                btn.backgroundColor = QMUITheme().themeTextColor()
            }else{
                btn.isSelected = false
                btn.backgroundColor = QMUITheme().foregroundColor()
            }
        }
    }
    
    func resetButtons() {
        for btn  in self.buttons {
            btn.isSelected = false
            btn.backgroundColor = QMUITheme().foregroundColor()
        }
    }
    
    func createButton(title: String, tag: Int) -> QMUIButton {
        let btn = QMUIButton()
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        btn.setTitleColor(.white, for: .selected)
        btn.backgroundColor = QMUITheme().foregroundColor()
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.titleLabel?.minimumScaleFactor = 0.3
        btn.titleLabel?.baselineAdjustment = .alignCenters
        btn.tag = tag
        btn.layer.cornerRadius = 2
        btn.layer.masksToBounds = true
        btn.layer.borderColor = QMUITheme().textColorLevel1().withAlphaComponent(0.05).cgColor
        btn.layer.borderWidth = 0.5
        
        return btn
    }

}



class YXStatementFilterButton: QMUIButton {
   
   
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
   
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didInitialize() {
        super.didInitialize()
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = 4.0
        self.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.layer.borderColor = QMUITheme().textColorLevel1().withAlphaComponent(0.5).cgColor
        self.layer.borderWidth = 1.0
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.layer.borderColor = QMUITheme().themeTextColor().cgColor
                self.backgroundColor = QMUITheme().themeTextColor().withAlphaComponent(0.05)
            } else {
                self.layer.borderColor = QMUITheme().textColorLevel1().withAlphaComponent(0.5).cgColor
                self.backgroundColor = UIColor.clear
            }
        }
    }
}
