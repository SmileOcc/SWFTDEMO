//
//  YXNewsRecommendListVC.swift
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/6/1.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import IGListKit
import IGListSwiftKit

class YXNewsRecommendListHeaderCell: UICollectionViewCell {
    
    let titleLabel = UILabel.init(text: "", textColor: QMUITheme().textColorLevel1(), textFont: UIFont.systemFont(ofSize: 18, weight: .medium))!
    
    let lineView = UIView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        
        let topView = UIView.init()
        topView.backgroundColor = UIColor.qmui_color(withHexString: "#191919")?.withAlphaComponent(0.05)
        
        lineView.backgroundColor = QMUITheme().separatorLineColor()
        contentView.addSubview(topView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(lineView)
        
        topView.snp.makeConstraints { make in
            make.top.right.left.equalToSuperview()
            make.height.equalTo(6)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom).offset(16)
            make.height.equalTo(20)
            make.left.equalToSuperview().offset(12)
        }
        lineView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}


class YXNewsRecommendListModel: NSObject {
    
    @objc var list: [YXListNewsModel]?
}

extension YXNewsRecommendListModel: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return isEqual(object)
    }
}


class YXNewsRecommendListVC: ListSectionController, ListSupplementaryViewSource {

    private var object: YXNewsRecommendListModel?
    
    override init() {
        super.init()
        supplementaryViewSource = self
    }
    func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            return CGSize(width: collectionContext!.containerSize.width, height: 58)
        case UICollectionView.elementKindSectionFooter:
            return CGSize(width: collectionContext!.containerSize.width, height: 20)
        default:
            fatalError()
        }
    }
    
    func supportedElementKinds() -> [String] {
        return [UICollectionView.elementKindSectionHeader, UICollectionView.elementKindSectionFooter]
    }
    
    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            return userHeaderView(atIndex: index)
        case UICollectionView.elementKindSectionFooter:
            return userFootView(atIndex: index)
        default:
            fatalError()
        }
    }
    private func userHeaderView(atIndex index: Int) -> UICollectionReusableView {
        let view: YXNewsRecommendListHeaderCell = collectionContext.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, forSectionController: self, atIndex: index)
        view.titleLabel.text = YXLanguageUtility.kLang(key: "related_recommend")        
        return view
    }
    
    private func userFootView(atIndex index: Int) -> UICollectionReusableView {
        let view: UICollectionViewCell = collectionContext.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, forSectionController: self, atIndex: index)
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }
    
    override func numberOfItems() -> Int {
        return object?.list?.count ?? 0
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext!.containerSize.width
           
        if let model = object?.list?[index] {
            return CGSize(width: width, height: model.cellHeight)
        } else {
            return CGSize(width: width, height: 1)
        }
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell: YXNewsRecommendCell = collectionContext.dequeueReusableCell(for: self, at: index)
        
        cell.model = object?.list?[index] ?? YXListNewsModel.init()
        
        cell.tagClickCallBack = { tagModel in
            if tagModel.jump_type == 1 {
                YXWebViewModel.pushToWebVC(tagModel.jump_addr)
            } else if tagModel.jump_type == 2 {
                YXGoToNativeManager.shared.gotoNativeViewController(withUrlString: tagModel.jump_addr)
            }
        }
        
        cell.stockClickCallBack = { [weak self] in
            guard let `self` = self else { return }
            guard let service = YXSquareManager.getTopService() else { return }
            guard let model = self.object?.list?[index] else { return }
            guard let quote = model.stockArr.first else {return}
                        
            if quote.type2 == 202 {
                YXWebViewModel.pushToWebVC(YXH5Urls.YX_FUND_DETAIL_PAGE_URL(quote.market + quote.symbol))
            } else {
                let input = YXStockInputModel.init()
                input.symbol = quote.symbol
                input.market = quote.market
                input.name = quote.name                                
                YXSquareManager.getTopService()?.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [input], "selectIndex" : 0])
            }
        }
        
        return cell
    }
    
    override func didSelectItem(at index: Int) {
        guard let service = YXSquareManager.getTopService() else { return }
        guard let model = self.object?.list?[index] else { return }
        let viewModel = YXImportantNewsDetailViewModel.init(services: service, params: ["cid": model.newsId])
        service.push(viewModel, animated: true)
    }

    override func didUpdate(to object: Any) {
        self.object = object as? YXNewsRecommendListModel
    }


}
