//
//  ColorSectionController.swift
//  Adorawe
//
//  Created by fan wang on 2021/10/29.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import IGListKit
import RxSwift
import RxRelay

class ColorSectionController: ListSectionController {
    let disposeBag = DisposeBag()
    weak var goodIdPub:PublishSubject<OSSVAttributeItemModel>?
    
    
    private var data: ColorSizeModel?
    
    override func didUpdate(to object: Any) {
        data = object as? ColorSizeModel
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        CGSize(width: 50, height: 50)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(of: VIVColorPicCell.self, for: self, at: index)
        if let cell = cell as? VIVColorPicCell,
           let model = data?.colorBrothers?[index,true]{
            ///test
//            model.is_hot = 1
            cell.currentSizeAttr = data?.currentOtherAttr
            cell.model = model
           
        }
        return cell
    }
    
    override func numberOfItems() -> Int {
        data?.colorBrothers?.count ?? 0
    }
    
    
    override func didSelectItem(at index: Int) {
        if  let model = data?.colorBrothers?[index,true] {
            goodIdPub?.onNext(model)
        }
    }
    
    override var minimumLineSpacing: CGFloat{
        get{
            return 4
        }
        set{
            
        }
    }
    
    
    override var minimumInteritemSpacing: CGFloat{
        get{
            return 4
        }
        set{
            
        }
    }
    
}
