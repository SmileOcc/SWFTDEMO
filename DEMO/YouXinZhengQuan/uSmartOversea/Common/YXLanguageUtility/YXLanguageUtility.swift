//
//  YXLanguageUtility.swift
//  uSmartOversea
//
//  Created by mac on 2019/3/25.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

var bundle:Bundle?
class YXLanguageUtility: NSObject {
    
    
    @objc public class func kLang(key: String) -> String {
        NSLocalizedString(key, tableName: "Localizable", bundle: bundle!, value: "", comment: "")
    }
    
    @objc class func initUserLanguage() {
        let language = YXUserManager.curLanguage()
        let path = Bundle.main.path(forResource: language.identifier, ofType: "lproj")
        bundle = Bundle(path: path ?? "")
    }
    
    @objc class func resetUserLanguage(_ type: YXLanguageType) {
        let path = Bundle.main.path(forResource: type.identifier, ofType: "lproj")
        bundle = Bundle(path: path ?? "")        
    }
    
    @objc class func identifier() -> String {
        return YXUserManager.curLanguage().identifier
    }
}


