//
//  YXFaceIdDetectError.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/1/2.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import MGFaceIDLiveDetect

struct YXFaceIdDetectError: Swift.Error {
    
    public let code: MGFaceIDLiveDetectErrorType
    
    public let errorMessageStr: String
    
    public init(_ code: MGFaceIDLiveDetectErrorType, errorMessageStr: String) {
        self.code = code
        self.errorMessageStr = errorMessageStr
    }
}
