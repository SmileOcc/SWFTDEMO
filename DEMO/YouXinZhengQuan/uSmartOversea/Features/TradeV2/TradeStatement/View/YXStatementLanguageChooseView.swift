//
//  YXStatementLanguageChooseView.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/7/19.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import YXKit
import QMUIKit

class YXStatementLanguageChooseView: UIControl {

    var selectedBlock:((_ type:TradeStatementLanguageType) -> Void)?
    
    lazy var container: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().foregroundColor()
        view.layer.cornerRadius = 15
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = true
        
        return view
    }()
    
    var selectType:TradeStatementLanguageType  = .chinese {
        didSet {
            self.selectView.updateSeleted(type: selectType)
        }
    }
    var firstSelectType:TradeStatementLanguageType = .chinese
    
    lazy var selectView:YXStatementSheetView<TradeStatementLanguageType> = {
        let view = YXStatementSheetView<TradeStatementLanguageType>(typeArr: types, selected: firstSelectType) { [weak self] type in
            guard let `self` = self else { return }
            self.selectedBlock?(type)
            self.hideFilterCondition()
        }
        
        return view
    }()

    var types:[TradeStatementLanguageType] = []
    
    init(frame: CGRect, types:[TradeStatementLanguageType], selected:TradeStatementLanguageType) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.backgroundColor = QMUITheme().shadeLayerColor()
        
        self.rac_signal(for: .touchUpInside).subscribeNext { [weak self] (filterView) in
            guard let `self` = self else { return }
            
            self.hideFilterCondition()
        }
        
        let selectHeight = 52 * types.count
        self.addSubview(self.container)
        self.container.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(CGFloat(selectHeight + 52 + 60) + YXConstant.safeAreaInsetsBottomHeight())
        }
        
        self.types = types
        
        self.firstSelectType = selected
        container.addSubview(self.selectView)
        self.selectView.snp.makeConstraints { make in
            make.top.equalTo(60)
            make.left.right.equalToSuperview()
            make.height.equalTo(selectHeight)
        }
        
        let titleLabel = UILabel()
        titleLabel.text = YXLanguageUtility.kLang(key: "statement_select_language")
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.textColor = QMUITheme().textColorLevel1()
        container.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(60)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(60)
        }
        
        let cancelButton = UIButton()
        cancelButton.setTitle(YXLanguageUtility.kLang(key: "common_cancel"), for: .normal)
        cancelButton.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16)
        container.addSubview(cancelButton)
        
        cancelButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-YXConstant.safeAreaInsetsBottomHeight())
            make.height.equalTo(52)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        cancelButton.qmui_tapBlock = { [weak self] _ in
            self?.hideFilterCondition()
        }
        
        let line = UIView.line()
        container.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(cancelButton)
            make.height.equalTo(0.5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showFilterCondition(completion: ((Bool) -> Void)? = nil) -> Void {
        self.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.container.snp.updateConstraints { (make) in
                make.bottom.equalToSuperview()
            }
            self.layoutIfNeeded()
        }) { (finished) in
            if (completion != nil) {
                completion!(finished)
            }
        }
    }
    
    func hideFilterCondition(completion: ((Bool) -> Void)? = nil) -> Void {
        let selectHeight = 52 * types.count
        UIView.animate(withDuration: 0.3, animations: {
            self.container.snp.updateConstraints { (make) in
                make.bottom.equalToSuperview().offset(CGFloat(selectHeight + 52 + 60) + YXConstant.safeAreaInsetsBottomHeight())
            }
            self.layoutIfNeeded()
        }) { (finished) in
            self.isHidden = true
            if (completion != nil) {
                completion!(finished)
            }
        }
    }

}


