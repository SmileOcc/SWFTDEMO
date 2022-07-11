//
//  YXWarrantsHomeViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/22.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class YXWarrantsHomeViewController: YXViewController {

    override var pageName: String {
         "HK Warrants"
     }
    
    var disposeBag = DisposeBag()
    
    var warrantsViewModel: YXWarrantsHomeViewModel {
        return self.viewModel as! YXWarrantsHomeViewModel
    }
    
    var entranceTitles = [YXWarrantsEntranceType.warrantsCBBC.title, YXWarrantsEntranceType.marketMakerScore.title]
    var entranceIcons = [YXWarrantsEntranceType.warrantsCBBC.image, YXWarrantsEntranceType.marketMakerScore.image]
    
    lazy var collectionView: UICollectionView = {
        
        let collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = QMUITheme().foregroundColor()//QMUITheme().backgroundColor()
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
//        if #available(iOS 11.0, *){
//            collectionView.contentInsetAdjustmentBehavior = .automatic
//        } else {
//            collectionView.contentInset = .zero
//        }
        
        collectionView.register(YXNewWarrantsDealCell.self, forCellWithReuseIdentifier: NSStringFromClass(YXNewWarrantsDealCell.self))
        collectionView.register(YXNewWarrantsStreetCell.self, forCellWithReuseIdentifier: NSStringFromClass(YXNewWarrantsStreetCell.self))
        collectionView.register(YXNewWarrantsFundFlowCell.self, forCellWithReuseIdentifier: NSStringFromClass(YXNewWarrantsFundFlowCell.self))
//        collectionView.register(YXNewWarrantsSubFundFlowCell.self, forCellWithReuseIdentifier: NSStringFromClass(YXNewWarrantsSubFundFlowCell.self))
        collectionView.register(YXQuickEntryCell.self, forCellWithReuseIdentifier: NSStringFromClass(YXQuickEntryCell.self))

        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionFooter, withReuseIdentifier: NSStringFromClass(UICollectionReusableView.self))
        collectionView.register(YXMarketCommonHeaderCell.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(YXMarketCommonHeaderCell.self))
        
        
        let refreshHeader = YXRefreshHeader()
        refreshHeader.refreshingBlock = { [weak self, weak refreshHeader] in
            self?.getData()
            refreshHeader?.endRefreshing()
        }
        collectionView.mj_header = refreshHeader
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = YXLanguageUtility.kLang(key: "market_hk_warrants")
        
        let rightBarItem = UIBarButtonItem.init(customView: helpButton)
        self.navigationItem.rightBarButtonItems = [rightBarItem]
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.getData()
    }
    
    lazy var helpButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.init(named: "help"), for: .normal)
        button.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self](e) in
            guard let `self` = self else { return }
            
            let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "warrants_help_tip"),messageAlignment:.center)
            alertView.clickedAutoHide = false
            
            alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_confirm"), style: .default, handler: {[weak alertView] action in
                
                alertView?.hide()
            }))
            alertView.showInWindow()

        })
        return button
    }()
    
    func getData() {
        Observable.of(warrantsViewModel.getDeal(), warrantsViewModel.getFundFlow(), warrantsViewModel.getCBBCTop()).merge().subscribe { [weak self](e) in
            self?.collectionView.reloadData()
        }.disposed(by: disposeBag)
    }

}

//MARK:数据源
extension YXWarrantsHomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  self.warrantsViewModel.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionType = self.warrantsViewModel.sections[section]
        
        switch sectionType {
        case .deal:
            return 1
        case .entrance:
            return entranceTitles.count
        case .street:
            return warrantsViewModel.streetTopModel?.items.count ?? 0
        case .fundFlow:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: NSStringFromClass(UICollectionReusableView.self), for: indexPath)
            footerView.backgroundColor = QMUITheme().backgroundColor()
            return footerView
        }else if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(YXMarketCommonHeaderCell.self), for: indexPath) as! YXMarketCommonHeaderCell
            
            let sectionType = self.warrantsViewModel.sections[indexPath.section]
            header.titleLabel.text = sectionType.title
            header.arrowView.isHidden = false
            
            switch sectionType {
            case .entrance:
                header.arrowView.isHidden = true
                header.action = nil
            case .street:
                header.action = { [weak self] in
                    self?.warrantsViewModel.gotoCBBC(market: kYXMarketHK, symbol: kYXIndexHSI, name: "--")
                }
                
            case .fundFlow:
                header.action = { [weak self] in
                    guard let `self` = self else { return }
                    let vm = YXWarrantsFundFlowDetailViewModel.init(services: self.warrantsViewModel.services, params: nil)
                    self.warrantsViewModel.services.push(vm, animated: true)
                }
            default:
                break
            }
            
            return header
        }
            
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let sectionType = self.warrantsViewModel.sections[indexPath.section]
        
        switch sectionType {
        case .deal:
            return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXNewWarrantsDealCell.self), for: indexPath)
        case .entrance:
            return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXQuickEntryCell.self), for: indexPath)
        case .street:
            return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXNewWarrantsStreetCell.self), for: indexPath)
        case .fundFlow:
            return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXNewWarrantsFundFlowCell.self), for: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let sectionType = self.warrantsViewModel.sections[indexPath.section]
        
        switch sectionType {
        case .deal:
            let cell = cell as! YXNewWarrantsDealCell
            cell.data = warrantsViewModel.dealModel
        case .entrance:
            let cell = cell as! YXQuickEntryCell
            cell.titleLabel.text = entranceTitles[indexPath.item]
            cell.imageView.image = entranceIcons[indexPath.item]
        case .street:
            let cell = cell as! YXNewWarrantsStreetCell
            let data = warrantsViewModel.streetTopModel?.items[indexPath.item]
            cell.data = data
        case .fundFlow:
            let cell = cell as! YXNewWarrantsFundFlowCell
            cell.data = warrantsViewModel.fundFlowModel
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let sectionType = self.warrantsViewModel.sections[indexPath.section]
        
        switch sectionType {
        case .entrance:
            if indexPath.item == 0 {
                (YXNavigationMap.navigator as? NavigatorServices)?.push(YXModulePaths.warrantsAndStreet.url, context: [:])
                trackViewClickEvent(name: "Warrants_Tab")
            }else if indexPath.item == 1 {
                let vm = YXMarketMakerRankViewModel.init(services: self.viewModel.services, params: nil)
                self.viewModel.services.push(vm, animated: true)
                trackViewClickEvent(name: "Issuer Rating_Tab")
            }
        case .street:
            let data = warrantsViewModel.streetTopModel?.items[indexPath.item]
            if let market = data?.asset?.market, let symbol = data?.asset?.symbol {
                warrantsViewModel.gotoCBBC(market: market, symbol: symbol, name: data?.asset?.name ?? "")
            }
            break
        default:
            break
        }
    }
}

//MARK:布局
extension YXWarrantsHomeViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionType = self.warrantsViewModel.sections[indexPath.section]
        
        switch sectionType {
        case .deal:
            return CGSize.init(width: collectionView.width-32.0, height: 218)
        case .entrance:
            // 当有4个cell时，解决当UICollectionViewCell的size不为整数时，UICollectionViewFlowLayout在布局计算时，可能会调整Cell的frame.origin，使Cell按照最小物理像素（渲染像素）对齐，导致出现缝隙
            // https://blog.csdn.net/ayuapp/article/details/80360745
//            var width = collectionView.width / 4.0;
//            if indexPath.item == 0 || indexPath.item == 4 {
//                //第一列的width比其他列稍大一些，消除item之间的间隙
//                width = collectionView.width - floor(width) * 3;
//            }else{
//                width = floor(width);
//            }
            return CGSize.init(width: collectionView.width * 164.0/375.0, height: 40)
        case .street:
            return CGSize.init(width: collectionView.width, height: 68)
        case .fundFlow:
            return CGSize.init(width: collectionView.width, height: 295)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let sectionType = self.warrantsViewModel.sections[section]
        
        switch sectionType {
        case .deal:
            return UIEdgeInsets.init(top: 8, left: 16, bottom: 40, right: 16)
        case .entrance:
            return UIEdgeInsets.init(top: 8, left: 16, bottom: 30, right: 16)
        case .street:
            return UIEdgeInsets.init(top: 8, left: 0, bottom: 40, right: 0)
        case .fundFlow:
            return UIEdgeInsets.init(top: 0, left: 0, bottom: 10, right: 0)
        default:
            return UIEdgeInsets.zero
        }
        
    }
    
    // 行间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    // 列间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let sectionType = self.warrantsViewModel.sections[section]
        
        switch sectionType {
        case .entrance:
            return 15
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let sectionType = self.warrantsViewModel.sections[section]
        
        switch sectionType {
        case .deal:
            return CGSize.zero
        case .street, .fundFlow, .entrance:
            return CGSize.init(width: collectionView.width, height: 40)
        }
        
    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
//        return CGSize.init(width: collectionView.frame.size.width, height: 6)
//    }
}


class YXWarrantsHomeFlowLayout: UICollectionViewFlowLayout {
    let sections: [YXNewWarrantsSectionType]
    
    init(sections: [YXNewWarrantsSectionType]) {
        self.sections = sections
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let decorationViewKind = "sectionDecorationView"
    
    override func prepare() {
        super.prepare()
        self.register(YXStockFilterSectionBgView.self, forDecorationViewOfKind: decorationViewKind)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let array = super.layoutAttributesForElements(in: rect)
        
        guard var arr = array else {
            return nil
        }
        
        for item in arr {
            let sectionType = self.sections[item.indexPath.section]
            if sectionType == .fundFlow, item.representedElementKind == UICollectionView.elementKindSectionHeader {
                // 装饰视图
                let decorationViewArrtributes = UICollectionViewLayoutAttributes.init(forDecorationViewOfKind: decorationViewKind, with: item.indexPath)
                let footerArrtribute = collectionView?.layoutAttributesForSupplementaryElement(ofKind: UICollectionView.elementKindSectionFooter, at: item.indexPath)
                decorationViewArrtributes.zIndex = -1
                decorationViewArrtributes.frame = CGRect.init(x: 0, y: item.frame.maxY, width: collectionView?.frame.size.width ?? 0, height: (footerArrtribute?.frame.minY ?? 0.0) - item.frame.maxY)
                arr.append(decorationViewArrtributes)
            }
        }

        return arr
    }
}
