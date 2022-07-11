//
//  YXOptionalHeaderView.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/12/18.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import NSObject_Rx
import RxCocoa
import RxSwift

class YXOptionalHeaderView: UIView {
    
    let sortType = BehaviorRelay<YXStockRankSortType>(value: .now)
    let sortState = BehaviorRelay<YXSortState>(value: .normal)
    
    lazy var stateButton: QMUIButton = {
        let button = QMUIButton()
        button.setImage(UIImage(named: "sort_normal"), for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 3)
        button.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .light)
        button.imagePosition = .right
        button.spacingBetweenImageAndTitle = 0

        button.rx.tap.subscribe(onNext: { [weak self] () in
            guard let strongSelf = self else { return }

            switch strongSelf.sortState.value {
            case .normal:
                strongSelf.sortState.accept(.descending)
            case .descending:
                strongSelf.sortState.accept(.ascending)
            case .ascending:
                strongSelf.sortState.accept(.normal)
            }
        }).disposed(by: rx.disposeBag)
        return button
    }()

//    lazy var rotateButton: QMUIButton = {
//        let button = QMUIButton()
//        button.setImage(UIImage(named: "optional_rotate"), for: .normal)
//        return button
//    }()
    
    lazy var selectButton:QMUIButton = {
        let button = QMUIButton()
        button.layer.cornerRadius = 2
        button.layer.borderColor = QMUITheme().textColorLevel4().cgColor
        button.setTitle("ALL", for: .normal)
        button.clipsToBounds = true
        button.imagePosition = .right
        button.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        button.layer.borderWidth = 1
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.setImage(UIImage.init(named: "icon_allow_donw"), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets.init(top: 4, left: 4, bottom: 4, right: 4)
        return button
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = QMUITheme().foregroundColor()
        
//        let nameLabel = UILabel()
//        nameLabel.text = YXLanguageUtility.kLang(key: "stock_manager")
//        nameLabel.textColor = QMUITheme().textColorLevel3()
//        nameLabel.font = .systemFont(ofSize: 14, weight: .light)
//        addSubview(nameLabel)
//
//        nameLabel.snp.makeConstraints { (make) in
//            make.left.equalTo(16)
//            make.bottom.equalToSuperview().offset(-3)
//        }
        
        addSubview(selectButton)
        selectButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.height.equalTo(22)
            make.left.equalTo(16)
        }
        
        addSubview(stateButton)
        stateButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalTo(selectButton)
            make.height.equalTo(40)
        }

        sortType.subscribe(onNext: { [weak self] (type) in
            self?.stateButton.setTitle(type.title, for: .normal)
        }).disposed(by: rx.disposeBag)

        sortState.subscribe(onNext: { [weak self] (state) in
            self?.stateButton.setImage(yxSortImage(state: state), for: .normal)
        }).disposed(by: rx.disposeBag)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
