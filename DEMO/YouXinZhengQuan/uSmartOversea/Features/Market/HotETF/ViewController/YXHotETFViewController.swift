//
//  YXHotETFViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2020/5/20.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXHotETFViewController: YXViewController {
    
    override var pageName: String {
        return YXLanguageUtility.kLang(key: "market_hot_ETF")
      }
    
    var disposeBag = DisposeBag()
    
    var etfViewModel: YXHotETFViewModel {
        let vm = viewModel as! YXHotETFViewModel
        return vm
    }
    

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        let collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = QMUITheme().foregroundColor()
        
        collectionView.register(YXHotETFItemCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(YXHotETFItemCollectionViewCell.self))
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionFooter, withReuseIdentifier: NSStringFromClass(UICollectionReusableView.self))
        collectionView.register(YXMarketCommonHeaderCell.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(YXMarketCommonHeaderCell.self))
        
        let refreshHeader = YXRefreshHeader()
        refreshHeader.refreshingBlock = { [weak self, weak refreshHeader] in
            guard let `self` = self else { return }
            self.etfViewModel.getETF().subscribe(onSuccess: { (res) in
                self.collectionView.reloadData()
                refreshHeader?.endRefreshing()
            }) { (err) in
                refreshHeader?.endRefreshing()
            }.disposed(by: self.disposeBag)
        }
        
        collectionView.mj_header = refreshHeader
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = YXLanguageUtility.kLang(key: "market_hot_ETF")
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            make.left.right.bottom.top.equalToSuperview()
//            make.top.equalTo(yx_navigationbar.snp.bottom)
        }
        
        self.etfViewModel.getETF().subscribe(onSuccess: { [weak self](res) in
            self?.collectionView.reloadData()
        }).disposed(by: disposeBag)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func sectionInfo(section: Int) -> [String: Any]? {
        if section < self.etfViewModel.etfSectionInfo?.item?.list.count ?? 0 {
            let dic = self.etfViewModel.etfSectionInfo?.item?.list[section]
            return dic//YXMarketDetailSecu.yy_model(withJSON: dic as Any)
        }
        return nil
    }
    
    func sectionList(section: Int) -> [[String: Any]]? {
        if let dic = self.etfViewModel.etfSectionInfo?.item?.list[section] {
            if let key = dic["secuCode"] as? String {
                let detailModel = self.etfViewModel.section_listDic[key]
                return detailModel?.item?.list
            }
        }
        
        return nil
    }
    
    func goToETFList(sectionInfo: [String: Any], sectionList: [[String: Any]], selectedTab: Int) {
        let vm = YXHotETFListViewModel.init(services: self.etfViewModel.services,
                                            params:["market": self.etfViewModel.market,
                                                    "sectionInfo": sectionInfo,
                                                    "sectionList": sectionList,
                                                    "selectedTab": selectedTab
                                            ])
        self.etfViewModel.services.push(vm, animated: true)
    }
}


//MARK:数据源
extension YXHotETFViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        self.etfViewModel.etfSectionInfo?.item?.list.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        self.sectionList(section: section)?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: NSStringFromClass(UICollectionReusableView.self), for: indexPath)
            return footerView
        }else if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(YXMarketCommonHeaderCell.self), for: indexPath) as! YXMarketCommonHeaderCell
            
            if let dic = self.sectionInfo(section: indexPath.section), let sectionList = self.sectionList(section: indexPath.section) {
                if let name = dic["chsNameAbbr"] as? String {
                    headerView.title = name
                }
                
                headerView.action = { [weak self] in
                    self?.goToETFList(sectionInfo: dic, sectionList: sectionList, selectedTab: 0)
                }

            }else {
                headerView.title = "--"
            }
            
            return headerView
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXHotETFItemCollectionViewCell.self), for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let itemCell = cell as! YXHotETFItemCollectionViewCell
        if let list = self.sectionList(section: indexPath.section) {
            let dic = list[indexPath.item]
            itemCell.info = dic
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let sectionInfo = self.sectionInfo(section: indexPath.section), let sectionList = self.sectionList(section: indexPath.section) {
            self.goToETFList(sectionInfo: sectionInfo, sectionList: sectionList, selectedTab: indexPath.item+1) // 因为列表页插入了“全部”tab，所以此处+1
        }
    }
}

//MARK:布局
extension YXHotETFViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let collectionViewWidth = YXConstant.screenWidth
        return CGSize.init(width: floor((collectionViewWidth-48)/3.0), height: 40)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets.init(top: 8, left: 16, bottom: 24, right: 16)
    }
    
    // 行间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        8
    }
    
    // 列间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        8
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize.init(width: collectionView.frame.size.width, height: 40)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        CGSize.init(width: collectionView.frame.size.width, height: 0)
    }
}
