//
//  YXStatementSelectView.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/7/17.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXHistoryBizTypeFilterButton: QMUIButton {
    var checkMark: UIImageView = {
        let checkMark = UIImageView.init(image: UIImage.init(named: "filter_selected"))
        checkMark.isHidden = true
        return checkMark
    }()
    
    override func didInitialize() {
        super.didInitialize()
        
        self.addSubview(self.checkMark)
        self.checkMark.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.width.equalTo(12)
            make.height.equalTo(9)
            make.trailing.equalToSuperview().offset(-14)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            self.checkMark.isHidden = !isSelected
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            self.alpha = 1
        }
    }
}


class YXStatementSelectView<E: EnumTextProtocol & Equatable>: UIView {

    private var typeArr: [E]! {
        didSet {
            if oldValue != typeArr {

            }
        }
    }
    
    private var selectedType: E!
    
    private var selectedBlock: ((E) -> Void)?
    
    var buttons:[YXHistoryBizTypeFilterButton] = []
    
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
    
    func createButton(title: String, tag: Int) -> YXHistoryBizTypeFilterButton {
        let btn = YXHistoryBizTypeFilterButton()
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        btn.setTitleColor(QMUITheme().themeTextColor(), for: .selected)
        btn.contentHorizontalAlignment = .left
        btn.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: 12, bottom: 0, right: 0)
        btn.backgroundColor = QMUITheme().foregroundColor()
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.tag = tag
      
        return btn
    }
}
