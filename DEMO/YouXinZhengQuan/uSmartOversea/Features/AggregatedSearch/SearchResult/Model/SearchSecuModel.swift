//
//  SearchSecuModel.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/4.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

/// 行情
@objcMembers class SearchSecuModel: YXSecu {

    var pctChng: NSNumber? // 涨跌幅

}

extension SearchSecuModel {

    /// 涨跌幅格式化字符串
    @objc func pctChngString() -> String {
        guard  let pctChng = self.pctChng else  {
            return "--"
        }

        var str = ""
        if pctChng.floatValue > 0 {
            str += "+"
        }
        str += String(format: "%.2f", pctChng.floatValue / 100)
        str += "%"
        return str
    }

}
