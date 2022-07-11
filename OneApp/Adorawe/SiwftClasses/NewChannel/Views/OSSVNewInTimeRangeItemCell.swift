//
//  OSSVNewInTimeRangeItemCell.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/17.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

class OSSVNewInTimeRangeItemCell: OSSVMultiPGoodsSPecialCCell {

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 0
    }
    
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        activityStateView.isHidden = true
    }
}
