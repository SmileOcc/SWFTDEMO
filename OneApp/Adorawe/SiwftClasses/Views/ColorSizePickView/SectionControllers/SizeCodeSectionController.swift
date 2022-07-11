//
//  SizeCodeSectionController.swift
//  Adorawe
//
//  Created by fan wang on 2021/10/29.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import IGListKit
import SwiftyJSON
import RxSwift
import RxRelay

class SizeCodeSectionController: ListSectionController {
    private var data: ColorSizeModel?{
        didSet{
            
        }
    }
    
    weak var sizeCodeIndex:BehaviorRelay<Int>?
    
    override func didUpdate(to object: Any) {
        data = object as? ColorSizeModel
    }
    
    override func numberOfItems() -> Int {
        return data?.sizeMapItem?.count ?? 0
    }
    
    override func didSelectItem(at index: Int) {
        sizeCodeIndex?.accept(index)
        ///保存preference
        if let itemData = data?.sizeMapItem?[index,true],
           let code = itemData.code{
            STLPreference.setObject(code, key: STLPreference.keySelectedSizeCode)
        }
        
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        if let itemData = data?.sizeMapItem?[index,true],
           let code = itemData.code{
            let temp = UILabel()
            temp.text = code
            temp.font = UIFont.boldSystemFont(ofSize: 14)
            let size = temp.sizeThatFits(CGSize(width: .max, height: 17))
            return CGSize(width: size.width, height: 30)
            
        }
        return CGSize(width: 100, height: 30)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(of: SizeCodeCell.self, for: self, at: index)
        if let cell = cell as? SizeCodeCell,
           let itemData = data?.sizeMapItem?[index,true]{
            if sizeCodeIndex?.value == index{
                itemData.is_default = true
            }
            cell.data = itemData
        }
        return cell
    }
        
    override var minimumLineSpacing: CGFloat{
        get{
            return 10
        }
        set{
            
        }
    }
    
    
    override var minimumInteritemSpacing: CGFloat{
        get{
            return 10
        }
        set{
            
        }
    }
}
