//
//  YXOrderHeaderView.swift
//  YouXinZhengQuan
//
//  Created by ellison on 2019/1/16.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

@objc enum YXTodayOrderFilterType: Int {
    case all
    case processing
    case traded
    case cancelled
    
    var text: String {
        switch self {
        case .all:
            return YXLanguageUtility.kLang(key: "order_all")
        case .processing:
            return YXLanguageUtility.kLang(key: "order_processing")
        case .traded:
            return YXLanguageUtility.kLang(key: "order_traded")
        case .cancelled:
            return YXLanguageUtility.kLang(key: "order_other")
        }
    }
}

class YXOrderHeaderView: UIView {
    
    @objc var orderFilterAction: ((_ filterType: YXTodayOrderFilterType) -> Void)?
    @objc var marketFilterAction: ((_ filterType: YXMarketFilterType) -> Void)?
    
    @objc var model: YXOrderResponseModel? {
        didSet {
            if let m = model {
                let total = m.tradedNum + m.processingNum + m.cancellNum
                let nums = [total, m.processingNum, m.tradedNum, m.cancellNum]
                var titles = filterItemNames
                for (index, title) in filterItemNames.enumerated() {
                    titles[index] = title + "(\(nums[index]))"
                }
                
                orderFilerPopButton.titles = titles
            }
        }
    }
    
    let filterItems: [YXTodayOrderFilterType] = [.all, .processing, .traded, .cancelled]
    
    @objc lazy var filterItemNames: [String] = {
        return filterItems.map({ item in
            return item.text
        })
    }()
    
    let marketItems: [YXMarketFilterType] = [.all, .us, .hk, .sg]
    
    @objc lazy var marketItemNames: [String] = {
        return marketItems.map({ item in
            return item.title
        })
    }()
    
    @objc lazy var orderFilerPopButton: YXStockPopoverButton = {
        let btn = creatPopButton(titles: filterItemNames)
        btn.clickItemBlock = { [weak self ,weak btn] index in
            guard let `self` = self else { return }
            self.orderFilterAction?(self.filterItems[index])
            let title = self.filterItemNames[index]
            btn?.setTitle(title, for: .normal)
        }
        return btn
    }()
    
    lazy var currencyPopButton: YXStockPopoverButton = {
        let btn = creatPopButton(titles: marketItemNames)
        btn.clickItemBlock = { [weak self] index in
            guard let `self` = self else { return }
            self.marketFilterAction?(self.marketItems[index])
        }
        return btn
    }()
    
    func creatPopButton(titles: [String]) -> YXStockPopoverButton {
        let button = YXStockPopoverButton.init(titles: titles)
        button.menuRowHeight = 48
        button.imagePosition = .right
        button.setImage(UIImage(named: "pull_down_arrow_20"), for: .normal)
        button.spacingBetweenImageAndTitle = 4
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        button.setTitle(titles.first, for: .normal)
        return button
    }

    fileprivate lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        label.text =  YXLanguageUtility.kLang(key: "market_codeName")
        
        return label
    }()
    
    fileprivate lazy var avgLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        label.text = YXLanguageUtility.kLang(key: "entrust_and_avg")
        label.textAlignment = .right
        label.numberOfLines = 2
        return label
    }()
    
    fileprivate lazy var turnoverLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        label.text = YXLanguageUtility.kLang(key: "entrust_and_success")
        label.textAlignment = .right
        label.numberOfLines = 2
        return label
    }()
    
    fileprivate lazy var stateLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        label.text = YXLanguageUtility.kLang(key: "order_direction")
        label.textAlignment = .right;
        
        return label
    }()

    lazy var margin: Int  = {
        return 9;
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = QMUITheme().foregroundColor()
        
        let lineView = UIView.line()
        
        let filterContainerView = UIView()
        filterContainerView.addSubview(orderFilerPopButton)
        filterContainerView.addSubview(currencyPopButton)
        filterContainerView.addSubview(lineView)
        
        orderFilerPopButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(30)
        }
        
        currencyPopButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(30)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.height.equalTo(0.5)
            make.left.right.bottom.equalToSuperview()
        }

        addSubview(filterContainerView)
        addSubview(nameLabel)
        addSubview(avgLabel)
        addSubview(turnoverLabel)
        addSubview(stateLabel)
        
        filterContainerView.snp.makeConstraints { (make) in
            make.height.equalTo(45)
            make.top.left.right.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.top.equalTo(filterContainerView.snp.bottom).offset(16)
        }
        
        stateLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-16)
            make.width.equalTo(margin + 41+20)
            make.centerY.equalTo(nameLabel)
        }
        
        turnoverLabel.snp.makeConstraints { (make) in
            make.right.equalTo(stateLabel.snp.left).offset(-margin)
            make.width.equalTo(80)
            make.centerY.equalTo(nameLabel)
        }
        
        avgLabel.snp.makeConstraints { (make) in
            make.right.equalTo(turnoverLabel.snp.left).offset(-margin)
            make.width.equalTo(80)
            make.centerY.equalTo(nameLabel)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
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
