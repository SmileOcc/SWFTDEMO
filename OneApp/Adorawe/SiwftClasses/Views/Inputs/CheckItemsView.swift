//
//  CheckItemsView.swift
//  Adorawe
//
//  Created by fan wang on 2021/10/26.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import SnapKit

@objcMembers class CheckItemsView : UIControl{
    weak var checkMark: UIImageView!
    weak var describleLbl : UILabel!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        let checkMark = UIImageView()
        addSubview(checkMark)
        self.checkMark = checkMark
        self.snp.makeConstraints { make in
            make.height.equalTo(30)
        }
        checkMark.snp.makeConstraints { make in
            make.width.height.equalTo(18)
            make.top.equalTo(6)
            make.bottom.equalTo(-6)
            make.leading.equalTo(0)
        }
        if (app_type == 3) {
            checkMark.image = UIImage(named: "sign_up_opt_uncheck")
            checkMark.highlightedImage = UIImage(named: "sign_up_opt_checked")
        }else{
            checkMark.image = UIImage(named: "Shopping_UnSelect")
            checkMark.highlightedImage = UIImage(named: "Shopping_Selected")
        }
       
        
        
        
        let descLbl = UILabel()
        descLbl.font = UIFont.systemFont(ofSize: 12)
        descLbl.textColor = OSSVThemesColors.col_000000(0.7)
        addSubview(descLbl)
        self.describleLbl = descLbl
        descLbl.numberOfLines = 0
        descLbl.snp.makeConstraints { make in
            make.leading.equalTo(checkMark.snp.trailing).offset(4)
            make.centerY.equalTo(checkMark.snp.centerY)
            make.trailing.equalTo(0)
        }
        descLbl.convertTextAlignmentWithARLanguage()
        
        isSelected = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool{
        didSet{
            checkMark.isHighlighted  = isSelected
        }
    }
    
    @objc var text:String? {
        didSet{
            describleLbl.text = text
        }
    }
    
    
    
}
