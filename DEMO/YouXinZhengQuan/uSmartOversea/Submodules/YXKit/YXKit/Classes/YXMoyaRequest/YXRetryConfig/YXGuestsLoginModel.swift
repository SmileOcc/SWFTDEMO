//
//  YXGuestsLoginModel.swift
//  Alamofire
//
//  Created by 井超 on 2019/11/7.
//

import UIKit

@objcMembers public class YXGuestsLoginModel: NSObject ,Codable {
    let uuid: NumberInt64?
    
    enum CodingKeys: String, CodingKey {
        case uuid = "uuid"
    }
}
