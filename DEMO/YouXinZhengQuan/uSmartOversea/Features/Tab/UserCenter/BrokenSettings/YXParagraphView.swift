//
//  YXParagraphView.swift
//  uSmartOversea
//
//  Created by ysx on 2021/7/16.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXParagraphView: UIView {
    let numLabel = YYLabel()
    let paragraphLabel = YYLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func initSubview()  {
        isUserInteractionEnabled = true
        numLabel.textColor = QMUITheme().textColorLevel3()
        numLabel.font = .systemFont(ofSize: 14)
        
        paragraphLabel.font = .systemFont(ofSize: 14)
        paragraphLabel.textColor = QMUITheme().textColorLevel3()
        paragraphLabel.numberOfLines = 0
        
        addSubview(numLabel)
        addSubview(paragraphLabel)
        
        numLabel.snp.makeConstraints { (make) in
            make.top.left.equalTo(0)
        }
        
        paragraphLabel.snp.makeConstraints { (make) in
            make.left.equalTo(numLabel.snp.right).offset(4)
            make.top.equalTo(numLabel.snp.top)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        paragraphLabel.preferredMaxLayoutWidth = YXConstant.screenWidth - 36
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
