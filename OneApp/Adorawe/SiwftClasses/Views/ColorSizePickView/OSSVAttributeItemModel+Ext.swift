//
//  OSSVAttributeItemModel+Ext.swift
//  Adorawe
//
//  Created by fan wang on 2021/11/2.
//  Copyright © 2021 starlink. All rights reserved.
//

import Foundation


extension OSSVAttributeItemModel{
    
    var groupIdsSet:Set<String>{
        var set = Set<String>()
        self.group_goods_id?.forEach({ goodsId in
            if let goodsId = goodsId as? String {
                set.insert(goodsId)
            }
        })
        return set
    }
}
