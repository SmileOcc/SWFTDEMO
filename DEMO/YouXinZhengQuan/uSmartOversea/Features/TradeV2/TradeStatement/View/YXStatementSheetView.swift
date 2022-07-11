//
//  YXStatementSheetView.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/7/20.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXStatementSheetView<E: EnumTextProtocol & Equatable>: UIView {

    private var typeArr: [E]! {
        didSet {
            if oldValue != typeArr {

            }
        }
    }
    
    private var selectedType: E!
    
    private var selectedBlock: ((E) -> Void)?
    
    var buttons:[QMUIButton] = []
    
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

        self.selectedBlock?(self.selectedType)
    }
    
    private func initUI() {
       
        for (index,type) in self.typeArr.enumerated() {
            let btn = createButton(title: type.text, tag: index)
            btn.addTarget(self, action: #selector(clickAction(_ :)), for: .touchUpInside)
            addSubview(btn)
        
//            let line = UIView()
//            line.backgroundColor = QMUITheme().textColorLevel1().withAlphaComponent(0.05)
//         
//            btn.addSubview(line)
//            line.snp.makeConstraints { make in
//                make.bottom.left.right.equalToSuperview()
//                make.height.equalTo(1)
//            }
            buttons.append(btn)

        }
        if buttons.count == 1 {
            buttons.first?.snp.makeConstraints({ make in
                make.edges.equalToSuperview()
            })
        }else{
            
            buttons.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
            }
            buttons.snp.distributeViewsAlong(axisType: .vertical, fixedSpacing: 0, leadSpacing: 0, tailSpacing: 0)
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
            }else{
                btn.isSelected = false
            }
        }
    }
    
    func updateSeleted(type:E) {
        self.selectedType = type
        updateUI()
    }
    
    func createButton(title: String, tag: Int) -> QMUIButton {
        let btn = QMUIButton()
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        btn.setTitleColor(QMUITheme().themeTextColor(), for: .selected)
        btn.backgroundColor = QMUITheme().foregroundColor()
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.tag = tag
      
        return btn
    }

}
