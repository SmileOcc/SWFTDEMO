//
//  YXUpdateData.swift
//  uSmartOversea
//
//  Created by ellison on 2019/5/23.
//  Copyright © 2019 RenRenDai. All rights reserved.
//


struct YXUpdateData: Codable {
    let update: Bool?
    let filePath: String?
    let versionNo: String?
    let updateMode: Int32?
    let times: Int32?
    let systemTime: Int64?
    let seconds: Int32?
    let title: String?
    let content: String?
    let md5: String?
    let fileUrl: String?
}
