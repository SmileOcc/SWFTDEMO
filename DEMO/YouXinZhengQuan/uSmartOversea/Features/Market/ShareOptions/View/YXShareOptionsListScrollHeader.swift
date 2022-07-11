//
//  YXShareOptionsListScrollHeader.swift
//  uSmartOversea
//
//  Created by youxin on 2020/12/8.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXShareOptionsListScrollHeader: UIView {
    
    let itemTypes: [YXShareOptinosItem] = [.latestPrice, .pctchng, .bidPrice, .askPrice, .netchng, .volume, .amount, .openInt, .impliedVolatility]//[.latestPrice, .pctchng, .openInt, .volume]
    
    let itemViewWidth: CGFloat = 80.0
    let spacing: CGFloat = 5.0
    
    // 全部 看涨 看跌
    var optionsType: YXShareOptionsType = .call {
        didSet {
            switch optionsType {
            case .all:
                label.textAlignment = .center
                addSubview(scrollView2)
                label.snp.remakeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.top.bottom.equalToSuperview()
                    make.width.equalTo(60)
                }
                scrollView.snp.remakeConstraints { (make) in
                    make.right.top.equalToSuperview()
                    make.bottom.equalToSuperview()
                    make.left.equalTo(label.snp.right)
                }
                scrollView2.snp.remakeConstraints { (make) in
                    make.left.top.bottom.equalToSuperview()
                    make.right.equalTo(label.snp.left)
                }
                
            case .call, .put:
                scrollView2.removeFromSuperview()
                label.snp.remakeConstraints { (make) in
                    make.top.bottom.equalToSuperview()
                    make.left.equalToSuperview()
                    make.width.equalTo(60)
                }
                scrollView.snp.remakeConstraints { (make) in
                    make.right.top.bottom.equalToSuperview()
                    make.left.equalTo(label.snp.right)
                }
            }
        }
    }
    
    lazy var itemViews: [YXShareOptionsItemView] = {
        return creatItemViews(itemTypes: itemTypes)
    }()
    
    lazy var itemViews2: [YXShareOptionsItemView] = {
        return creatItemViews(itemTypes: itemTypes.reversed(), textAlignment: .left)
    }()
    
    func creatItemViews(itemTypes: [YXShareOptinosItem], textAlignment: NSTextAlignment = .right) -> [YXShareOptionsItemView] {
        return itemTypes.map { (itemType) -> YXShareOptionsItemView in
            let itemView = YXShareOptionsItemView()
            itemView.type = itemType
            itemView.topLabel.text = "--"
            itemView.bottomLabel.text = "--"
            itemView.bottomLabel.isHidden = true
            itemView.topLabel.textAlignment = textAlignment
            itemView.bottomLabel.textAlignment = textAlignment
            
            return itemView
        }
    }
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel3()
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = creatScrollView(itemViews: itemViews)
        return scrollView
    }()
    
    lazy var scrollView2: UIScrollView = {
        let scrollView = creatScrollView(itemViews: itemViews2)
        return scrollView
    }()
    
    func creatScrollView(itemViews: [YXShareOptionsItemView]) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
//        scrollView.isUserInteractionEnabled = false
        itemViews.forEach { (view) in
            scrollView.addSubview(view)
        }
        itemViews.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: spacing, leadSpacing: spacing, tailSpacing: spacing)
        itemViews.snp.makeConstraints { (make) in
            make.height.equalToSuperview()
            make.width.equalTo(itemViewWidth)
        }
        return scrollView
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.text = YXShareOptinosItem.strikePrice.title
        
        itemViews.forEach { (view) in
            view.topLabel.text = view.type.title
            view.topLabel.textColor = QMUITheme().textColorLevel3()
            view.topLabel.font = .systemFont(ofSize: 12)
        }
        
        itemViews2.forEach { (view) in
            view.topLabel.text = view.type.title
            view.topLabel.font = .systemFont(ofSize: 12)
            view.topLabel.textColor = QMUITheme().textColorLevel3()
        }
        
        backgroundColor = QMUITheme().foregroundColor()
        addSubview(label)
        addSubview(scrollView)
//        addSubview(scrollView2)
//        
//        label.snp.makeConstraints { (make) in
//            make.centerX.equalToSuperview()
//            make.top.bottom.equalToSuperview()
//            make.width.equalTo(60)
//        }
//        scrollView.snp.makeConstraints { (make) in
//            make.right.top.equalToSuperview()
//            make.bottom.equalToSuperview()
//            make.left.equalTo(label.snp.right)
//        }
//        scrollView2.snp.makeConstraints { (make) in
//            make.left.top.bottom.equalToSuperview()
//            make.right.equalTo(label.snp.left)
//        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
