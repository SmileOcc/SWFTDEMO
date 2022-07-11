//
//  OSSVDetailsBaseInfoModel+ext.swift
//  Adorawe
//
//  Created by fan wang on 2021/11/2.
//  Copyright © 2021 starlink. All rights reserved.
//

import Foundation


extension OSSVDetailsBaseInfoModel{
    func fillDataToSizePickAttr(){
        goodsSpecs.forEach { specModel in
            specModel.brothers?.forEach { attr in
                if attr.goods_id == goodsId{
                    if let number = Int(goodsNumber) {
                        attr.goodsNumber = NSNumber(value: number)
                    }
                    attr.isOnSale = NSNumber(value: isOnSale)
                }
            }
        }
    }
    
    ///所展示的国际尺码
    func showSizeText()->String{
        
       
        
        let sizeData = goodsSpecs.filter { spec in
            spec.spec_type == "2"
        }.first?.brothers
        
        let sizeAttr = sizeData?.filter({ attr in
            attr.goods_id == goodsId
        }).first
        
        //不映射
        if let key = sizeAttr?.size_name.uppercased(){
            return key
        }
        //不映射
        
        var mapItems:[SizeMappingItem] = []
        size_mapping_list.forEach{ itemDic in
            if let itemDic = itemDic as? [String:Any],
            let item = SizeMappingItem(JSON: itemDic, context: nil) {
                mapItems.append(item)
            }
        }
        
        var matchLocal = false
        var sizeCodeIndex = 0
        if let savedCode = STLPreference.object(forKey: STLPreference.keySelectedSizeCode) as? String{
            for (index,item) in mapItems.enumerated() {
                if let code = item.code{
                    if code == savedCode{
                        matchLocal = true
                        sizeCodeIndex = index
                        break
                    }
                }
            }
        }
        
        
        if matchLocal == false{
            let defaultItem = mapItems.filter { element in
                return element.is_default == true
            }.first
            
            if let _ = defaultItem {
                for (index,item) in mapItems.enumerated() {
                    if item.is_default == true{
                        sizeCodeIndex = index
                    }
                }
            }
        }
        
        
        if let key = sizeAttr?.size_name.uppercased(){
            let value = mapItems[sizeCodeIndex,true]?.contentMap?[key] as? String ?? key
            return value
        }
        
        return ""
    }
}
