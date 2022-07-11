//
//  UIView+SnapKit.swift
//  YouXinZhengQuan
//
//  Created by mac on 2019/3/23.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import SnapKit

public extension UIView {
    var safeArea: ConstraintBasicAttributesDSL {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.snp
        }
        return self.snp
    }
}
