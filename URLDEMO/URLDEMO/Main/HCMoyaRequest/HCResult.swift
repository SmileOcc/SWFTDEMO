//
//  HCResult.swift
//  URLDEMO
//
//  Created by odd on 7/3/22.
//

import Foundation

public struct HCResult<C: Codable>: Codable {
    public let code: Int
    public let msg: String?
    public let data: C?
    
}
