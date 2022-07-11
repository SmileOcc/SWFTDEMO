//
//  OSSVScrollFocusedImgSectionController.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/28.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import IGListKit

class OSSVScrollFocusedImgSectionController: ListSectionController {
    private var groupedItem:OSSVProtoGene?
    
    override func didUpdate(to object: Any) {
        groupedItem = object as? OSSVProtoGene
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        var ratio = CGFloat(200.0 / 351)
        if let img0 = groupedItem?.modeImg?[0,true] {
            ratio =  CGFloat(img0.imagesHeight ?? 1) / CGFloat(img0.imagesWidth ?? 1)
        }
        return CGSize(width: CGFloat.screenWidth, height: CGFloat.screenWidth * ratio)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        
        ///给个不重复的reuseId 防止重用会出现的bug
        let cell = collectionContext!.dequeueReusableCell(of: OSSVHomeAdvBannerCCell.self, withReuseIdentifier: UUID().uuidString, for: self, at: index)
        if let cell = cell as? OSSVHomeAdvBannerCCell,
           let bannerItem = groupedItem?.modeImg {
            var advItem:[OSSVAdvsEventsModel?] = bannerItem.map { imgItem in
                let model = STLAdvEventSpecialModel.yy_model(with: imgItem.toJSON())
                let advEvent = OSSVAdvsEventsModel(whtiSpecialModel: model)
                return advEvent
            }
            advItem = advItem.filter({ item in
                return item != nil
            })
            cell.setEventArr((advItem as! [OSSVAdvsEventsModel]))
            cell.delegate = self
        }
        return cell
    }
    
    override func numberOfItems() -> Int {
        1
    }
}

extension OSSVScrollFocusedImgSectionController:STLHomeBannerCCellDelegate{
    func stl_HomeBannerCCell(_ cell: OSSVHomeAdvBannerCCell!, advEventModel model: OSSVAdvsEventsModel!, index: Int) {
        bannerClicked(attr_node_2: "new_rolling")
        OSSVAdvsEventsManager.advEventTarget(viewController, withEventModel:model)
        //埋点
        
        if model != nil{
            GATools.logNewInTopBanner(promotionId: model.bannerId ?? "", promotionName: model.name ?? "", creativeName: model.name ?? "", creativeSlot: "Top Banner_\(index)", items: [],isclick: true)
        }
       
    }
    
    func stl_HomeBannerCCell(_ cell: OSSVHomeAdvBannerCCell!, advEventModel model: OSSVAdvsEventsModel!, showCellIndex index: Int) {
        //埋点
        bannerViewed(attr_node_2: "new_rolling")
        if model != nil{
            GATools.logNewInTopBanner(promotionId: model.bannerId ?? "", promotionName: model.name ?? "", creativeName: model.name ?? "", creativeSlot: "Top Banner_\(index)", items: [])
        }
       
    }
}
