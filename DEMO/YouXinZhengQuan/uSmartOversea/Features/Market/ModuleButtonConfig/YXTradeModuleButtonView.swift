//
//  YXTradeModuleButtonView.swift
//  YouXinZhengQuan
//
//  Created by suntao on 2021/4/25.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXTradeModuleButtonView: UIView {
    @objc var tapItemAction: ((_ index: Int) -> Void)?
    var buttonViews: [YXConfigButtonView] = []

    @objc var datas: [[String : Any]] = [] {
        didSet {
        
            setupUI()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        for item in self.subviews {
            item.removeFromSuperview()
        }
        buttonViews.removeAll()
        let unitWidth: CGFloat = (YXConstant.screenWidth - 24) / 5
        for ( index,dic) in datas.enumerated() {
            let itemView = YXConfigButtonView()
            if let iconName = dic["iconName"] as? String {
                if let networkIcon = dic["networkIcon"] as? String, networkIcon == "1", let url = URL(string: iconName) {
                    itemView.icon.sd_setImage(with: url, placeholderImage: UIImage(named: "module_default_icon"), options: [], context: nil)
                } else {
                    itemView.icon.image = UIImage.init(named: iconName)
                }
            }
            if let title = dic["title"] as? String {
                itemView.titleLabel.text = title
            }
            itemView.tag = index + 4000
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapItem(gesture:)))
            itemView.addGestureRecognizer(tap)
            
            addSubview(itemView)
            buttonViews.append(itemView)
        }
        
        var itemHeight:CGFloat = 60
        if YXUserManager.isENMode() {
            itemHeight = 70
        }
        if buttonViews.count > 1 {
            buttonViews.snp.distributeSudokuViews(fixedItemWidth: unitWidth, fixedItemHeight: itemHeight, warpCount: 5, edgeInset: UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12))
        }else{
            buttonViews.first?.snp.makeConstraints({ (make) in
                make.left.equalToSuperview().offset(12)
                make.top.equalToSuperview().offset(10)
                make.bottom.equalToSuperview().offset(-10)
                make.width.equalTo(unitWidth)
            })
        }
       
      
    }
    
    @objc func tapItem(gesture: UITapGestureRecognizer) {
        if let tagValue = gesture.view?.tag {
            let index: Int = tagValue - 4000
            self.tapItemAction?(index)
        }
    }

  
}
