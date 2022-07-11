//
//  YXStockAnalyzeWarrantCbbcScoreModel.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2020/10/12.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXStockAnalyzeWarrantCbbcScoreModel: YXModel {

    @objc var score: Int = 0  //综合评分
    @objc var moneynessScore: Int = 0 //价内、价外评分
    @objc var outstandingScore: Int = 0 //街货占比评分
    @objc var spreadScore: Int = 0  //买卖价差评分
    @objc var maturityDateScore: Int = 0 //到期日评分
    @objc var rank: Int = 0  //排名
    @objc var rankBase: Int = 0  //参与排名的数目

    @objc override class func modelCustomPropertyMapper() -> [String : Any] {
        return [:]
    }

}
