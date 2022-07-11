//
//  String+Business.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/17.
//  Copyright © 2021 starlink. All rights reserved.
//

import Foundation

///业务相关字符串转化
extension NSString{
    
    ///四级地址显示
    @objc static func addressString(addres:OSSVAddresseBookeModel)->String{
        
        var addressItem:[String] = []
        
        if let country = addres.country {
            addressItem.append(country)
        }
        if let state = addres.state {
            addressItem.append(state)
        }
        if let city = addres.city {
            addressItem.append(city)
        }
        if let area = addres.area {
            addressItem.append(area)
        }
        if let district = addres.district {
            addressItem.append(district)
        }
        if let street = addres.street {
            addressItem.append(street)
        }
        if let streetMore = addres.streetMore {
            addressItem.append(streetMore)
        }
        
        
        
        addressItem = addressItem.filter { str in
            !str.isEmpty
        }

        if !OSSVSystemsConfigsUtils.isRightToLeftShow(){
            addressItem = addressItem.reversed()
        }
        
        if let zipPostNumber = addres.zipPostNumber {
            if !zipPostNumber.isEmpty{
                addressItem.append(zipPostNumber)
            }
        }
        
        var result = ""
        for (index,item) in addressItem.enumerated() {
            if index == addressItem.count - 1{
                result += item
                break
            }
            if item.isContainArabic {
                if result.hasSuffix("\n"){
                    result += "\(item),\n"
                }else{
                    result += "\n\(item),\n"
                }
                
            }else{
                result += "\(item),"
            }
            
        }
        
        return result
    }
}
