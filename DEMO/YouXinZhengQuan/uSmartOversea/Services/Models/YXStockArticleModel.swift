//
//  YXStockArticleModel.swift
//  uSmartOversea
//
//  Created by Kelvin on 2019/5/5.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

struct  YXStockArticleModel: Codable {

    var newsList: [YXStockArticleDetailModel]?
    
    enum CodingKeys: String, CodingKey {
        case newsList = "news_list"
    }
    
}

struct YXStockArticleDetailModel: Codable {
    
    var newsId: String?
    var tag: String?
    var title: String?
    var source: String?
    var releaseTime: Int?
    var pictureUrl: [String]?
    let pictureShowmode: Int?
    
    enum CodingKeys: String, CodingKey {
        case newsId = "newsid"
        case tag
        case title
        case source
        case releaseTime = "release_time"
        case pictureUrl = "picture_url"
        case pictureShowmode = "picture_showmode"
    }
    
    func getCellHeight() -> CGFloat {
        
        var cellHeight: CGFloat = 44
        if let pictureUrl = self.pictureUrl, pictureUrl.count > 0 {
            cellHeight = 130
        } else {
            let height = YXToolUtility.getStringSize(with: self.title ?? "", andFont: UIFont.systemFont(ofSize: 16), andlimitWidth: Float(YXConstant.screenWidth - 36 - 30), andLineSpace: 5).height
            if height > 60 {
                cellHeight = 60
            }
            cellHeight += 60
        }
        
        return cellHeight
    }
}
