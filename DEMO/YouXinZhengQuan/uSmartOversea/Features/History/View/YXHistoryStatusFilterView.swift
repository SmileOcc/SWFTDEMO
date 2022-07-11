//
//  YXHistoryStatusFilterView.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2020/4/26.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXHistoryStatusFilterView: UIControl {
    
    let bag = DisposeBag()
    
    var contentViewHeight: CGFloat = 235
    
    var selectedButton: YXHistoryStatusButton!
    
    var filter:((_ status: YXHistoryFilterStatus) -> Void)?

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = YXLanguageUtility.kLang(key: "common_status_title")
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = QMUITheme().textColorLevel1()
        
        return label
    }()
    
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
        confirmButton.addTarget(self, action: #selector(clickConfirmButton), for: .touchUpInside)
        return confirmButton
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()

    lazy var filterButtonView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    
    fileprivate var titleColor: UIColor? {
        get {
            QMUITheme().textColorLevel1()
        }
    }
    
    fileprivate var selectedTitleColor: UIColor? {
        get {
            QMUITheme().themeTextColor()
        }
    }
    
    func show(selectedStatus: YXHistoryFilterStatus) {
        self.isHidden = false
        for filterButton in filterButtonView.subviews {
            if let button = filterButton as? YXHistoryStatusButton {
                if button.status == selectedStatus {
                    button.isSelected = true
                    selectedButton = button
                }else {
                     button.isSelected = false
                }
            }
        }
        
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
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            self?.hidden()
        }).disposed(by: bag)
        
        self.backgroundColor = QMUITheme().shadeLayerColor()
        
        let filters: [YXHistoryFilterStatus] = YXHistoryFilterStatus.allCases

        let cancelBtnAndConfirmBtnStackView = UIStackView.init(arrangedSubviews: [cancelButton, confirmButton])
        cancelBtnAndConfirmBtnStackView.alignment = .fill
        cancelBtnAndConfirmBtnStackView.axis = .horizontal
        cancelBtnAndConfirmBtnStackView.distribution = .fillEqually
        cancelBtnAndConfirmBtnStackView.spacing = 26
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(filterButtonView)
        containerView.addSubview(cancelBtnAndConfirmBtnStackView)
        addSubview(containerView)
        
        cancelBtnAndConfirmBtnStackView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-24)
            make.height.equalTo(48)
        }
        
        var buttonViewHeight: CGFloat = 32
        if filters.count > 3 {
            var rows: Int = filters.count / 3
            if filters.count % 3 > 0 {
                rows = rows + 1
            }
            buttonViewHeight = CGFloat((rows - 1) * 16 + 32 * rows)
        }
        filterButtonView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.height.equalTo(buttonViewHeight)
        }
        var views: [UIButton] = []
        
        for (index, filterType) in filters.enumerated() {
            let button = YXHistoryStatusButton.init(style: .white)
            button.setTitle(filterType.title, for: .normal)
            button.setTitleColor(self.titleColor, for: .normal)
            button.setTitleColor(self.selectedTitleColor, for: .selected)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.3
            button.addTarget(self, action: #selector(tapFilterButton(button:)), for: .touchUpInside)
            button.titleLabel?.numberOfLines = 2
            button.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: 3, bottom: 0, right: 3)
            button.status = filterType
            if index == 0 {
                button.isSelected = true
                selectedButton = button
            }
            views.append(button)
            filterButtonView.addSubview(button)
        }
        views.snp.distributeSudokuViews(fixedLineSpacing: 16, fixedInteritemSpacing: 16, warpCount: 3)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(24)
            make.left.top.equalToSuperview().offset(16)
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
            cornerRadii: CGSize(width: 20, height: 20))

        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        self.containerView.layer.mask = shape
    }

    @objc func tapFilterButton(button: YXHistoryStatusButton) {
        selectedButton.isSelected = false
        button.isSelected = true
        selectedButton = button
    }

    @objc func clickConfirmButton() {
        hidden()
        filter?(selectedButton.status)
    }
}

class YXHistoryStatusButton: YXDateFilterButton {
    var status: YXHistoryFilterStatus!
    
    override func didInitialize() {
        super.didInitialize()
    }
}
