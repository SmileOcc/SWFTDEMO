//
//  YXHistoryFilterContainerView.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/1/8.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXHistoryFilterContainerView: UIView {

    var filters:[UIControl] = [UIControl]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addFilter(_ filter: UIControl) -> Void {
        filters.append(filter)
        self.addSubview(filter)
        self.layoutIfNeeded()
    }
    
    func relayoutFilters() -> Void {
        let count = filters.count
        let filterWidth = self.frame.size.width / CGFloat(count)
        for (index, filter) in filters.enumerated() {
            filter.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(filterWidth * CGFloat(index))
                make.width.equalTo(filterWidth)
                make.top.height.equalToSuperview()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        relayoutFilters()
    }
}
