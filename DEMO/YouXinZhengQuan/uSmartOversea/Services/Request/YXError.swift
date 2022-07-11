//
//  YXError.swift
//  uSmartOversea
//
//  Created by ZhiYun Huang on 2019/4/25.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation

enum YXError : LocalizedError {
    
    case internalError(code : Int , message : String?)
    case businessError(code : Int , message : String?)
    
    var errorDescription: String? {
        switch self {
        case .internalError(let code, let message) ,
             .businessError(let code, let message):
            guard let message = message else {
                return ""
            }
            return "\(message)(\(code))"
        }
    }
    
    var code: Int {
        switch self {
        case .internalError(let code, _) ,
             .businessError(let code, _):
            return code
        }
    }
}
