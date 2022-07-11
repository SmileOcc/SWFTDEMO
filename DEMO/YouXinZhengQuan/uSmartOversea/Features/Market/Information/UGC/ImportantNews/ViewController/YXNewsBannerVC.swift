//
//  YXNewsBannerVC.swift
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/5/26.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import IGListKit
import IGListSwiftKit

class YXNewsBannerVC: ListSectionController {

    private var object: YXBannerActivityModel?

    
    override func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext!.containerSize.width
        let height: CGFloat = (YXConstant.screenWidth - 32) / 4.0 + 32
        return CGSize(width: width, height: height)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: YXNewsBannerCell = collectionContext.dequeueReusableCell(for: self, at: index)
        cell.clipsToBounds = true
        cell.model = self.object
        
        cell.tapAction = { [weak self] tag in
            guard let `self` = self else { return }
            guard let jumpModel = self.object?.bannerList[tag] else { return }
            if let delegate = UIApplication.shared.delegate as? YXAppDelegate {
                delegate.navigator.gotoBanner(with: jumpModel)                
            }
        }
        
        return cell
    }

    override func didUpdate(to object: Any) {
        self.object = object as? YXBannerActivityModel
    }


}
