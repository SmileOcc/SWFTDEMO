//
//  NewInLoadMoreFooterView.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/14.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

class OSSVNewInViewMoreFooterView: UICollectionReusableView {
    
    weak var viewMoreBtn:UIButton?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupSubViews() {
        let button = UIButton()
        addSubview(button)
        let tempLbl = UILabel()
        tempLbl.text = String.viewMoreText
        tempLbl.font = UIFont.systemFont(ofSize: 12)
        let width = tempLbl.sizeThatFits(CGSize(width: CGFloat.infinity, height: 28)).width + 51
        
        button.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.height.equalTo(28)
            make.top.equalTo(0)
            make.width.equalTo(width)
        }
        button.backgroundColor = OSSVThemesColors.col_0D0D0D()
        button.setTitleColor(.white, for: .normal)
        button.setTitle(String.viewMoreText, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        viewMoreBtn = button
    }
}

extension String{
    static let newInFooterReuseID = "NewInViewMoreFooterView"
}

