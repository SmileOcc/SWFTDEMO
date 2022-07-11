//
//  ColorSizeModel.swift
//  Adorawe
//
//  Created by fan wang on 2021/10/29.
//  Copyright © 2021 starlink. All rights reserved.
//

import Foundation
import IGListKit
import ObjectMapper


class ColorSizeModel:ListDiffable{
    let idStr = UUID().uuidString as NSString
    
    func diffIdentifier() -> NSObjectProtocol {
        idStr
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let obj = object as? ColorSizeModel else{
            return false
        }
        return obj.idStr == idStr
    }
    
    
    var colorBrothers: [OSSVAttributeItemModel]? = nil
    var sizeBrothers: [OSSVAttributeItemModel]? = nil
    
    ///颜色<--->尺码 相对应的当前
    var currentOtherAttr:OSSVAttributeItemModel?
    
    var sizeMapItem:[SizeMappingItem]?
    
    ///映射对应尺码展示数据
    func sizeText(sizeBrother:OSSVAttributeItemModel,sizeCodeIndex:Int)->String{
        if let key = sizeBrother.size_name?.uppercased(){
            let value = sizeMapItem?[sizeCodeIndex,true]?.contentMap?[key] ?? key
            return value as! String
        }
        return ""
    }
    
}

class SizeMappingItem:Mappable{
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        code <- map["code"]
        cate_id <- map["cate_id"]
        is_default <- map["is_default"]
        content <- map["content"]
    }
    
    var code:String?
    var cate_id:String?
    var is_default:Bool?
    var content:[[String:String]]?
    ///计算属性
    var contentMap:[AnyHashable:Any]?{
        var resultmap:[AnyHashable:Any] = [:]
        content?.forEach { smallMap in
            if let key = smallMap["realSize"]?.uppercased() {
                resultmap[key] = smallMap["labelSize"]
            }
           
        }
        return resultmap
    }
}
