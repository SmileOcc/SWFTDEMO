//
//  YXStockFilterBottomView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/4.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXStockFilterBottomView: UIView {
    
    var selectedDatas: [YXStockFilterItem] = [] {
        didSet {
            if self.isSpread {
                self.selectedConditionListView.reload(withDatas: selectedDatas)
            }
            
            if selectedDatas.count > 0 {
                startButton.isEnabled = true
            }else {
                startButton.isEnabled = false
            }
        }
    }
    
    var spreadAction: ((_ isSpread: Bool) -> Void)?
    
    var isSpread = false // 是否处于展开状态
    
    var title: String = "" {
        didSet {
            
        }
    }
    
    lazy var selectedConditionListView: YXStockFilterSelectedConditionView = {
        let view = YXStockFilterSelectedConditionView()
        view.hideAction = { [weak self] in
            self?.spread()
        }
        return view
    }()
    
    lazy var tipLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "down_arrow_grey")
        imageView.transform = CGAffineTransform.init(rotationAngle: .pi)
        return imageView
    }()
    
    lazy var infoButton: QMUIButton = {
        let button = QMUIButton()
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.3
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.setTitle(String(format: YXLanguageUtility.kLang(key: "total_selected_prefix"), 0), for: .normal)
        
        _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self](e) in
            guard let `self` = self else { return }
    
            self.spread()
        })
        return button
    }()
    
    lazy var startButton: QMUIButton = {
        let button = QMUIButton()
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.3
        button.setTitle(YXLanguageUtility.kLang(key: "start_stock_scanner"), for: .normal)
        button.setBackgroundImage(UIImage.qmui_image(with: QMUITheme().themeTextColor()), for: .normal)
        button.setBackgroundImage(UIImage.qmui_image(with: QMUITheme().separatorLineColor()), for: .disabled)
        button.setTitleColor(UIColor.white, for: .normal)
        button.isEnabled = false
        return button
    }()
    
    func spread() {
        var angle: CGFloat = 0.0
        if isSpread {
            angle = .pi
        }
        
        UIView.animate(withDuration: 0.3) {
            self.arrowImageView.transform = CGAffineTransform.init(rotationAngle: angle)
        }
        
        self.isSpread = !self.isSpread
        
        if self.isSpread {
            self.selectedConditionListView.show(withDatas: self.selectedDatas, inView: self.superview!)
            self.superview?.bringSubviewToFront(self)
        }else {
            self.selectedConditionListView.hide()
        }
    }
    
    var infoText: NSAttributedString? {
        didSet {
            if let str = infoText {
                infoButton.setAttributedTitle(str, for: .normal)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        backgroundColor = QMUITheme().foregroundColor()
        
        let line = UIView.line()
        
        addSubview(line)
        addSubview(infoButton)
        addSubview(arrowImageView)
        addSubview(startButton)
        
        line.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        infoButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(startButton)
            make.left.equalToSuperview().offset(12)
            make.right.equalTo(arrowImageView.snp.left).offset(-1)
        }
        
        arrowImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(infoButton).offset(2)
            make.height.width.equalTo(15)
            make.right.lessThanOrEqualTo(startButton.snp.left).offset(-10)
        }
        
        startButton.snp.makeConstraints { (make) in
            make.right.top.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(50)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
