//
//  YXNewsPublishTimeVC.swift
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/8/25.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import IGListKit
import IGListSwiftKit

class YXNewsPublishTimeCell: UICollectionViewCell {
    
    let label = UILabel.init(with: QMUITheme().textColorLevel3(), font: UIFont.systemFont(ofSize: 12, weight: .regular), text: "")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initUI() {
        label.numberOfLines = 1
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.bottom.equalToSuperview()
        }
    }
}


class YXNewsPublishTimeVC: ListSectionController {

    override init() {
        super.init()
    }
    
    private var object: String?

    
    override func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext!.containerSize.width
        
        return CGSize(width: width, height: 35)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: YXNewsPublishTimeCell = collectionContext.dequeueReusableCell(for: self, at: index)
        cell.label.text = object
                
        return cell
    }

    override func didUpdate(to object: Any) {
        self.object = object as? String
    }

}
