//
//  YXAutoScrollToRectTool.swift
//  YouXinZhengQuan
//
//  Created by 覃明明 on 2022/4/24.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import Foundation
import UIKit

extension YXStockListHeaderView {
    @objc func scrollToMobileBrief1Type(type: YXMobileBrief1Type, animate: Bool) {
        var rect = CGRect.zero
        for btn in self.buttons {
            if let b = btn as? YXSortButton, b.mobileBrief1Type == type {
                rect = b.superview?.frame ?? CGRect.zero
                break
            }
        }
        
        var offsetX = rect.maxX - self.scrollView.frame.size.width
        if offsetX < 0 {
            offsetX = 0
        }
        
        if animate {
            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut) {
                self.scrollView.contentOffset = CGPoint(x: offsetX, y: 0)
            }
        }else {
            self.scrollView.contentOffset = CGPoint(x: offsetX, y: 0)
        }
    }
}
