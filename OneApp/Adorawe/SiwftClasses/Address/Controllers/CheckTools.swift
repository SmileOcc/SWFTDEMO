//
//  CheckTools.swift
//  Adorawe
//
//  Created by fan wang on 2021/12/9.
//  Copyright © 2021 starlink. All rights reserved.
//

import Foundation

class CheckTools{
    static var isJpSite = STLWebsitesGroupManager.shared().currentWebsitesModel.site_code == "vivaia_jp"
    static func checkCountry(text:String?)->(Bool,String?){
        guard let text = text,
        !text.isEmpty else{
            return (false,STLLocalizedString_("user_address_country_empty"))
        }
        return (true,nil)
    }
    
    static func checkStreet(text:String?)->(Bool,String?){
        guard let text = text ,
              !text.isEmpty else{
            return (false,STLLocalizedString_("user_address_street_empty"))
        }
        if OSSVNSStringTool.streetAddressIsIncludeSpecialCharacterString(text){
            return (false,.StreetValidMsg)
        }
        return (true,nil)
    }
    
    static func checkFirstName(text:String?)->(Bool,String?){
        guard let text = text,
              !text.isEmpty else{
            return (false,STLLocalizedString_("FirstnameEmpytMsg"))
        }
        if isJpSite {
            return (true,nil)
        }
        if text.count < 2{
            
            return (false,.FirstnameMinLengthMsg)
        }
        return (true,nil)
    }
    
    static func checkLastName(text:String?)->(Bool,String?){
        guard let text = text ,
              !text.isEmpty else{
            return (false,STLLocalizedString_("LastnameEmptyMsg"))
        }
        if isJpSite {
            return (true,nil)
        
        }
        if text.count < 2{
            return (false,.LastnameMinLengthMsg)
        }
        return (true,nil)
    }
    
    ///需要才校验
    static func checkZipCode(text:String?)->(Bool,String?) {
        guard let text = text,
        !text.isEmpty else {
            return (false,isJpSite ? STLLocalizedString_("ZipEmptyMsgJp") : STLLocalizedString_("ZipEmptyMsg"))
        }
        if isJpSite {
            //日本7位
            if text.count != 7{
                return (false,STLLocalizedString_("ZipEmptyMsgJp"))
            }else{
                return (true,nil)
            }
        }
        
        if text.count < 2 {
            return (false,.ZipMinLengthMsg)
        }else if text.count > 10 {
            return (false,.ZipMaxLengthMsg)
        }
        return (true,nil)
    }
    
    static func checkIdNum(text:String?,country_Code:String?)->(Bool,String?){
        if let countryCode = country_Code {
            if (countryCode == .JO || countryCode == .QA) {
                guard let text = text ,
                      !text.isEmpty else{
                    return (false,STLLocalizedString_("fillIdNumber"))
                }
                
                if text.isContainArabic || text.isAllSameNumber{
                    return (false,STLLocalizedString_("id_num_format_err"))
                }
                
                if countryCode == .JO{
                    if text.count != 10 || !text.isPureNumber{
                        return (false,.warningStringFor10)
                    }
                }
                if countryCode == .QA || !text.isPureNumber{
                    if text.count != 11{
                        return (false,.warningStringFor11)
                    }
                }
            }
        }
        return (true,nil)
    }
    
    static func checkCity(text:String?,cityId:String?)->(Bool,String?){
        if cityId != nil {
            return (true,nil)
        }
        
        guard let text = text,
              !text.isEmpty else{
            return (false,STLLocalizedString_("CityEmptyMsg"))
        }
        
        if text.isPureNumber{
            return (false,STLLocalizedString_("CityVaildMsg"))
        }else if text.count > 50{
            return (false,STLLocalizedString_("CityMaxLengthMsg"))
        }
        
        return (true,nil)
    }
    
    static func checkState(text:String?,stateId:String?)->(Bool,String?){
        if stateId != nil {
            return (true,nil)
        }
        
        guard let text = text,
              !text.isEmpty else{
            return (false,STLLocalizedString_("StateEmptyMsg"))
        }
        
        if text.isPureNumber{
            return (false,STLLocalizedString_("StateEmptyMsg"))
        }else if text.count > 50{
            return (false,STLLocalizedString_("StateEmptyMsg"))
        }
        
        return (true,nil)
    }
    
    ///只校验格式 不请求网络
    static func checkPhoneBasic(text:String?)->(Bool,String?){
        guard let text = text ,
              !text.isEmpty else{
            return (false,STLLocalizedString_("PhoneEmptyMsg"))
        }
        
        if text.isContainArabic || text.isAllSameNumber{
            return (false,STLLocalizedString_("id_num_format_err"))
        }
        
        return (true,nil)
    }
    
    static func checkEmail(text:String?)->(Bool,String?){
        if let email = text {
            if(!OSSVNSStringTool.isValidEmailString(email)){
                return (false,STLLocalizedString_("Arrival_Notify_Email_Err"))
            }
            return (true,nil)
        }else{
            return (false,STLLocalizedString_("emailEmptyMsg"))
        }
    }
}

