//
//  YXFaceIdIDCardQualityProtocol.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2018/12/28.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import Foundation

@objc protocol YXFaceIdIDCardQualityProtocol {
    @objc optional func detectFinish(portraitImage: UIImage?);
    @objc optional func detectFinish(emblemImage: UIImage?);
}
