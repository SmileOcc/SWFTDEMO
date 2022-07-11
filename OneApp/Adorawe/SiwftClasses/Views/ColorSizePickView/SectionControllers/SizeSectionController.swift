//
//  SizeSectionController.swift
//  Adorawe
//
//  Created by fan wang on 2021/10/29.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import IGListKit
import RxSwift
import RxRelay

class SizeSectionController: ListSectionController {
    private var data: ColorSizeModel?
    weak var updateSizeTipPub:PublishSubject<OSSVAttributeItemModel?>?
    weak var delegate:OSSVSizeDidSelectProtocol?
    
    let disposeBag = DisposeBag()
    
    weak var goodIdPub:PublishSubject<OSSVAttributeItemModel>?
    weak var sizeCodeIndex:BehaviorRelay<Int>?
    weak var firstIntoDetail:BehaviorRelay<Bool>?
    
    override func didUpdate(to object: Any) {
        data = object as? ColorSizeModel
//        print(object)
    }
    
    override func numberOfItems() -> Int {
        data?.sizeBrothers?.count ?? 0
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let sizeCodeIndex = sizeCodeIndex?.value ?? 0 ///国际尺码Code 先固定为0
        if let itemData = data?.sizeBrothers?[index,true],
           let sizeText = data?.sizeText(sizeBrother: itemData, sizeCodeIndex: sizeCodeIndex){
            let temp = UILabel()
            temp.text = sizeText
            temp.font = UIFont.systemFont(ofSize: 14)
            var width = temp.sizeThatFits(CGSize(width: .max, height: 44)).width + 28
            width = max(width, 64)
            
            return CGSize(width: width, height: 43)
        
        }
        return CGSize(width: 100, height: 43)
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
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(of: SizePickCell.self, for: self, at: index)
        if let cell = cell as? SizePickCell,
           let itemData = data?.sizeBrothers?[index,true]{
            cell.firstIntoDetail = firstIntoDetail
            cell.currentColorAttr = data?.currentOtherAttr
            cell.updateSizeTipPub = updateSizeTipPub
            cell.model = itemData
            let sizeCodeIndex = sizeCodeIndex?.value ?? 0 ///国际尺码Code 先固定为0
            cell.sizeText = data?.sizeText(sizeBrother: itemData, sizeCodeIndex: sizeCodeIndex)
        }
        return cell
    }
    
    override func didSelectItem(at index: Int) {
        if  let model = data?.sizeBrothers?[index,true] {
            let sizeCodeIndex = sizeCodeIndex?.value ?? 0
            model.sizeLocalName = data?.sizeText(sizeBrother: model, sizeCodeIndex: sizeCodeIndex)
            goodIdPub?.onNext(model)
            firstIntoDetail?.accept(false)
        }
    }
    
}
