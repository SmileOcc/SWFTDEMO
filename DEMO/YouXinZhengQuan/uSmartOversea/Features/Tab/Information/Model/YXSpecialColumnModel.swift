//
//  YXSpecialColumnModel.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/9/6.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation

// MARK: - YXSpecialColumnListModel
struct YXSpecialColumnListModel: Codable {
    let newsList: [YXSpecialColumnModel]?
    
    enum CodingKeys: String, CodingKey {
        case newsList = "news_list"
    }
}

// MARK: - NewsList
struct YXSpecialColumnModel: Codable {
    let newsid, title, authorID, authorTag: String?
    let authorLogo: String?
    let authorName, tag: String?
    let pictureURL: [String]?
    let content: String?
    let videoPictureURL: String?
    let releaseTime: Int?
    let newsType: Int?      //文章分类（0专栏，1研选)
    let authorType: Int?    //作者分类（0专栏，1研选）
    let accountPro: Int?    //用户权限（0游客，1普通用户，2大陆高级用户，3香港高级用户）
    
    enum CodingKeys: String, CodingKey {
        case newsid, title
        case authorID = "author_id"
        case authorTag = "author_tag"
        case authorLogo = "author_logo"
        case authorName = "author_name"
        case tag
        case pictureURL = "picture_url"
        case content
        case videoPictureURL = "video_picture_url"
        case releaseTime = "release_time"
        case newsType = "news_type"
        case authorType = "author_type"
        case accountPro = "account_pro"
    }
}
