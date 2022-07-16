//
//  HCHomeModel.swift
//  URLDEMO
//
//  Created by odd on 7/16/22.
//

import Foundation

struct HCHomeModel: Codable {
    let banner:[HCHomeBanner]?
    let slideImgArray:[HCHomeImgModel]?
    let marquee: [HCMarquee]?
    let noConentKey: String?
    let blocklist: [HCBlocklist]?
    
    enum CodingKeys: String, CodingKey {
        case banner,marquee,noConentKey,blocklist
        case slideImgArray = "slide_img"
    }
}


struct HCHomeBanner: Codable {
    let heigth: String?
    let actionType: String?
    let id: String?
    let image_url: String?
    let width: String?
    let name: String?
    let url: String


}

struct HCHomeImgModel: Codable {
    let heigth: String?
    let actionType: String?
    let id: String?
    let image_url: String?
    let width: String?
    let name: String?
    let url: String?

}

struct HCMarquee: Codable {
    let heigth: String?
    let image_url: String?
    let width: String?
    let name: String?
    let url: String?

}



class HCBlocklist: NSObject, Codable {
    let type: String?
    let images: [HCSlideImages]?
}

class HCSlideImages: NSObject, Codable {
    var type: String?
    let heigth: CGFloat?
    let imageUrl: String?
    let width: CGFloat?
    let name: String?
    let url: String?
    
    enum CodingKeys: String, CodingKey {
        case type,heigth,width,name
        case url
        case imageUrl = "image_url"
    }
}
