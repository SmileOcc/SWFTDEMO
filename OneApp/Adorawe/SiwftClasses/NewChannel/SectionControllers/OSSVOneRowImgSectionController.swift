//
//  OSSVOneRowImgSectionController.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/28.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import IGListKit

class OSSVOneRowImgSectionController: ListSectionController {
    
    private var groupedItem:OSSVProtoGene?
    
    override func didUpdate(to object: Any) {
        groupedItem = object as? OSSVProtoGene
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        if let imgType = groupedItem?.imgType,
           let columnType = OneRowImgChildColumn(rawValue: imgType),
           let imgItem = groupedItem?.modeImg?[index]{
            let ratio =  CGFloat(imgItem.imagesHeight ?? 1) / CGFloat(imgItem.imagesWidth ?? 1)
            switch columnType {
            case .OneColumn:
                return CGSize(width: CGFloat.screenWidth, height: ratio * CGFloat.screenWidth)
            case .ThreeColumn:
                let itemWidth = CGFloat.screenWidth / 3
                return CGSize(width: itemWidth,height: ratio * itemWidth)
            case .FourColumn:
                let itemWidth = CGFloat.screenWidth / 4
                return CGSize(width: itemWidth,height: ratio * itemWidth)

            }
        }
        return .zero
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(of: OSSVAsinglesAdvCCell.self, for: self, at: index)
        if let cell = cell as? OSSVAsinglesAdvCCell,
           let modeImg = groupedItem?.modeImg?[index,true],
           let model = STLAdvEventSpecialModel.yy_model(with: modeImg.toJSON()){
            cell.goodsImageView.grayView.isHidden = true
            cell.setAdvModel(model)
        }
        return cell
    }
    
    override func numberOfItems() -> Int {
        groupedItem?.modeImg?.count ?? 0
    }
    
    
    override func didSelectItem(at index: Int) {
        if let modeImg = groupedItem?.modeImg?[index],
           let model = STLAdvEventSpecialModel.yy_model(with: modeImg.toJSON()){
            OSSVAdvsEventsManager.advEventTarget(viewController, withEventModel:OSSVAdvsEventsModel(whtiSpecialModel: model))
            bannerClicked(attr_node_2: "new_venue_\(section)_\(index)")
        }
    }
    

    override var inset: UIEdgeInsets{
        get{
            return UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0)//top -1 去掉图片拼接不严
        }
        set{
            super.inset = newValue
        }
    }
    
    override var displayDelegate: ListDisplayDelegate?{
        get{
            self
        }
        set{}
    }
}

extension OSSVOneRowImgSectionController:ListDisplayDelegate{
    func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController) {
        
    }
    
    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController) {
        
    }
    
    func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController, cell: UICollectionViewCell, at index: Int) {
        if let imgType = groupedItem?.imgType,
           let columnType = OneRowImgChildColumn(rawValue: imgType){
            switch columnType {
            case .OneColumn:
                bannerViewed(attr_node_2: "new_venue_\(section)_\(index)")
                break
            default:
                break

            }
        }
    }
    
    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController, cell: UICollectionViewCell, at index: Int) {
        
    }
    
    
}
