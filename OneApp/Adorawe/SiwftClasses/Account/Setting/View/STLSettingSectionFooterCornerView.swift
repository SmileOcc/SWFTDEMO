//
//  STLSettingSectionFooterCornerView.swift
// XStarlinkProject
//
//  Created by odd on 2021/9/14.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

class STLSettingSectionFooterCornerView: UIView {

    @objc init(rect:CGRect, size: CGSize) {
        super.init(frame: rect)
        self.backgroundColor = OSSVThemesColors.stlClearColor()
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: .screenWidth-24, height: 12))
        view.backgroundColor = OSSVThemesColors.stlWhiteColor()
        view.stlAddCorners(UIRectCorner(rawValue: UIRectCorner.bottomLeft.rawValue | UIRectCorner.bottomRight.rawValue), cornerRadii: size)
        self.addSubview(view)
        
        view.snp.makeConstraints { make in
            make.leading.equalTo(self.snp.leading).offset(12)
            make.trailing.equalTo(self.snp.trailing).offset(-12)
            make.top.equalTo(self).offset(-6)
            make.height.equalTo(12)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
