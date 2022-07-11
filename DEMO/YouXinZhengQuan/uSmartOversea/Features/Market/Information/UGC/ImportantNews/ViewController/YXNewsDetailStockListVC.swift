//
//  YXNewsDetailStockListVC.swift
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/5/31.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import IGListKit
import IGListSwiftKit

class YXNewsDetailStockListModel: NSObject {
    
    @objc var list: [YXV2Quote]?
}

extension YXNewsDetailStockListModel: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return isEqual(object)
    }
}


class YXNewsDetailStockListBottomCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
//        QMUITheme().separatorLineColor()
        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().separatorLineColor()
        addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(0.5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



class YXNewsDetailStockListVC: ListSectionController, ListSupplementaryViewSource {

    override init() {
        super.init()
        supplementaryViewSource = self
    }
    
    private var object: YXNewsDetailStockListModel?

    func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        switch elementKind {
        case UICollectionView.elementKindSectionFooter:
            return CGSize(width: collectionContext!.containerSize.width, height: 30)
        default:
            fatalError()
        }
    }
    
    func supportedElementKinds() -> [String] {
        return [UICollectionView.elementKindSectionFooter]
    }
    
    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        switch elementKind {
        case UICollectionView.elementKindSectionFooter:
            return userFooterView(atIndex: index)
        default:
            fatalError()
        }
    }
    
    private func userFooterView(atIndex index: Int) -> UICollectionReusableView {
        let view: YXNewsDetailStockListBottomCell = collectionContext.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, forSectionController: self, atIndex: index)
        return view
    }

    
    override func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext!.containerSize.width
        

        return CGSize(width: width, height: 32)
    }
    
    override func numberOfItems() -> Int {
        return object?.list?.count ?? 0
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: YXNewsStockCell = collectionContext.dequeueReusableCell(for: self, at: index)
        cell.quote = object?.list?[index]
        
        return cell
    }
    
    override func didSelectItem(at index: Int) {
        guard let quote = object?.list?[index] else { return }
        if (quote.type2?.value ?? 0) == 202 {
            YXWebViewModel.pushToWebVC(YXH5Urls.YX_FUND_DETAIL_PAGE_URL((quote.market ?? "") + (quote.symbol ?? "")))
        } else {
            let input = YXStockInputModel.init()
            input.symbol = quote.symbol ?? ""
            input.market = quote.market ?? ""
            input.name = quote.name ?? ""
            YXSquareManager.getTopService()?.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [input], "selectIndex" : 0])
        }
    }

    override func didUpdate(to object: Any) {
        self.object = object as? YXNewsDetailStockListModel
    }


}
