//
//  YXPictureToken.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/17.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

struct YXQCloudToken: Codable {
   
    let sessionToken, tmpSecretID, tmpSecretKey: String
    
    enum CodingKeys: String, CodingKey {
        case sessionToken
        case tmpSecretID = "tmpSecretId"
        case tmpSecretKey
    }
}
