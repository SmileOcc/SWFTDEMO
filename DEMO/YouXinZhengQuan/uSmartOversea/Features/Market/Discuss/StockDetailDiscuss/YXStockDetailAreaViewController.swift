//
//  StockDetailGuessUpOrDownSectionController.swift
//  uSmartOversea
//
//  Created by lennon on 2022/5/26.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import IGListKit
import IGListSwiftKit

class YXStockDetailAreaCell: UICollectionViewCell {
    
    
    lazy var areaView: YXCommunityHeaderView = {
        let view = YXCommunityHeaderView()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        contentView.addSubview(areaView)
        areaView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

class YXStockDetailAreaViewController: ListSectionController {
 
    @objc var selectCallBack: ((_ selectIndex: Int) -> ())?

    
    override func numberOfItems() -> Int {
        return 1
    }

    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize.init(width: collectionContext!.containerSize.width, height: 45)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {

        let cell: YXStockDetailAreaCell = collectionContext.dequeueReusableCell(for: self, at: index)
        cell.areaView.selectCallBack = { [weak self] index in
            self?.selectCallBack?(index)
        }
        return cell
    }
    
}

