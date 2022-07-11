//
//  PhoneCodeRulesModel.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/7.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

class PhoneCodeRulesModel: NSObject,YYModel {

    @objc var country_area_code:String?
    @objc var phone_rule:PhoneRules?
}

class PhoneRules:NSObject,YYModel{
    @objc var error_text_en:String?
    @objc var error_text_ar:String?
    @objc var phone_number_header:String?
    @objc var remain_number_length:String?
    @objc var mobile_operators_head_number:String?
    @objc var phone_number_length:String?
}
