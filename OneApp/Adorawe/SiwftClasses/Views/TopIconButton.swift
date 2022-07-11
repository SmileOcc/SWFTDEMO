//
//  TopIconButton.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/5.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import SnapKit

class TopIconButton: UIControl {
    
    weak var imgView:UIImageView?
    weak var label:UILabel?
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        let imgView = UIImageView(frame: .zero)
        let label = UILabel(frame: .zero)
        addSubview(imgView)
        addSubview(label)
        
        imgView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.top.equalTo(0)
            make.centerX.equalTo(self.snp.centerX)
        }
        label.snp.makeConstraints { make in
            make.height.equalTo(12)
            make.leading.equalTo(0)
            make.trailing.equalTo(0)
            make.bottom.equalTo(0)
        }
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        
        self.imgView = imgView
        self.label = label
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
