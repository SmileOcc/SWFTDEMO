//
//  YXStockFilterViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/2.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum YXStockFilterActionType {
    case selectedItem(item: YXStockFilterItem, selectedValueIndexs: [Int])
    case unSelectedItem(item: YXStockFilterItem)
    case customInput(item: YXStockFilterItem, lowValue: Double, upValue: Double, showText: String)
    case selectedIndustry(item: YXStockFilterItem, selecteds: [Any])
    case unSelectedAll
    case edit
}

class YXStockFilterViewController: YXViewController {
    
    var disposeBag = DisposeBag()
    
    let uiRatio = YXConstant.screenWidth/375.0
    let cellHeight = 40.0*YXConstant.screenWidth/375.0
    
    var sectionSpreads: [Bool] = []
    
    var filterViewModel: YXStockFilterViewModel {
        let vm = viewModel as! YXStockFilterViewModel
        return vm
    }
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: YXStockFilterFlowLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = QMUITheme().backgroundColor()
        collectionView.showsVerticalScrollIndicator = false;
        collectionView.showsHorizontalScrollIndicator = false;
        if #available(iOS 11.0, *){
            collectionView.contentInsetAdjustmentBehavior = .automatic
        } else {
            collectionView.contentInset = .zero
        }
        
        collectionView.register(YXStockFilterCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(YXStockFilterCollectionViewCell.self))

        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionFooter, withReuseIdentifier: NSStringFromClass(UICollectionReusableView.self))
        collectionView.register(YXStockFilterCollectionHeaderView.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(YXStockFilterCollectionHeaderView.self))
        
        
//        let refreshHeader = YXRefreshHeader()
//        refreshHeader.refreshingBlock = { [weak self, weak refreshHeader] in
//            self?.getData()
//            refreshHeader?.endRefreshing()
//        }
//        collectionView.mj_header = refreshHeader
        
        return collectionView
    }()
    
    lazy var bottomView: YXStockFilterBottomView = {
        let view = YXStockFilterBottomView()
        view.infoButton.setAttributedTitle(self.filterViewModel.resultAttrStr(conditionCount: 0, stockCount: 0), for: .normal)
        view.selectedConditionListView.didDeleteConditionAction = { [weak self](actionType) in
            self?.conditionChanged(changeType: actionType)
        }
        view.selectedConditionListView.didClickItemAction = { [weak self](item) in
            guard let `self` = self else { return }
            self.showSelectView(withFilterItem: item)
        }
        view.startButton.rx.tap.subscribe(onNext: { [weak self](e) in
            self?.filterViewModel.startFilterStock()
        }).disposed(by: disposeBag)
        
        return view
    }()
    
    lazy var pickerView: YXStockFilterPickerView = {
        
        let view = YXStockFilterPickerView()
        view.sureAction = { [weak self](actionType) in
            self?.conditionChanged(changeType: actionType)
        }
        
        view.customAction = { [weak self, weak view] (item) in
            guard let `self` = self else { return }
            view?.hide()
            self.customInputView.customInputCachDic = self.filterViewModel.customInputCachDic
            self.customInputView.filterItem = item
            self.customInputView.lowTextField.becomeFirstResponder()
        }

        return view
    }()
    
    lazy var customInputView: YXStockFilterRangeInputView = {
        let view = YXStockFilterRangeInputView()
        view.sureAction = { [weak self](actionType) in
            self?.conditionChanged(changeType: actionType)
        }
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        view.addSubview(bottomView)
        view.addSubview(customInputView)
        
        collectionView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
        }
        
        bottomView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(50 + YXConstant.safeAreaInsetsBottomHeight())
            //            if #available(iOS 11.0, *) {
            //                make.bottom.equalTo(view.safeAreaLayoutGuide)
            //            } else {
            //                make.bottom.equalToSuperview()
            //            }
            make.bottom.equalToSuperview()
        }
        
        customInputView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        getData()
        
        filterViewModel.sectionSelectedCountBlock = { [weak self](indexPath, count) in
            let sectionHeader = self?.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: indexPath) as? YXStockFilterCollectionHeaderView
            if let header = sectionHeader {
                header.countLabel.text = String(format: YXLanguageUtility.kLang(key: "items_selected"), count)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    deinit {
        
    }
    
    func getData() {
        filterViewModel.getFilterItems().subscribe(onSuccess: { [weak self](data) in
            guard let `self` = self else { return }
            self.collectionView.reloadData()
            self.sectionSpreads = Array(repeating: true, count: self.filterViewModel.model?.groups.count ?? 0)
            if self.filterViewModel.operationType == .edit {
                self.conditionChanged(changeType: .edit)
            }
        }).disposed(by: disposeBag)
    }
    
    func conditionChanged(changeType: YXStockFilterActionType) {
        
        filterViewModel.changeState(withActionType: changeType).drive { [weak self](e) in
            guard let `self` = self else { return }
            self.collectionView.reloadData()
            // 更新数据,刷新已选条件列表
            self.bottomView.selectedDatas = self.filterViewModel.selectedConditionDatas
            // 请求筛选结果
            self.filterViewModel.getFilterResult().drive(self.bottomView.infoButton.rx.attributedTitle(for: .normal)).disposed(by: disposeBag)
        }
    }
    
    func showSelectView(withFilterItem item: YXStockFilterItem) {
        if YXStockFilterEnumUtility.shared.enumFromString(item.key ?? "") == .industry {

            let vm = YXStockFilterIndustryViewModel()
            vm.industryItem = item
            vm.market = filterViewModel.market
            vm.selectItems = self.filterViewModel.industrySelectedItems
            vm.didSelectedAction = {[weak self](item, selecteds) in
                self?.conditionChanged(changeType: .selectedIndustry(item: item, selecteds: selecteds))
                self?.filterViewModel.industrySelectedItems = selecteds
            }

            self.viewModel.services.pushPath(.filterIndustry, context: vm, animated: true)
        }else {
            pickerView.show(withFilterItem: item, inView: self.view)
        }

    }
}

//MARK:数据源
extension YXStockFilterViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filterViewModel.model?.groups.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let group = filterViewModel.model?.groups[section]
        let isSpread = self.sectionSpreads[section]
        if isSpread {
            return group?.items.count ?? 0
        }else {
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: NSStringFromClass(UICollectionReusableView.self), for: indexPath)
            footerView.backgroundColor = QMUITheme().backgroundColor()
            return footerView
        }else if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(YXStockFilterCollectionHeaderView.self), for: indexPath) as! YXStockFilterCollectionHeaderView
            
            let stockFilterType = filterViewModel.model?.groups[indexPath.section]
            header.titleLabel.text = stockFilterType?.name
            header.isSpread = self.sectionSpreads[indexPath.section]
            header.action = { [weak self, weak header]() in
                guard let `self` = self else { return }
                self.sectionSpreads[indexPath.section] = !self.sectionSpreads[indexPath.section]
                header?.isSpread = self.sectionSpreads[indexPath.section]
                self.collectionView.reloadSections(NSIndexSet(index: indexPath.section) as IndexSet)
                
            }
            
            let count = filterViewModel.selectedCountForSection(section: indexPath.section)
            if count > 0 {
                header.countLabel.text = String(format: YXLanguageUtility.kLang(key: "items_selected"), count)
            }else {
                header.countLabel.text = nil
            }
            
            return header
        }
            
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXStockFilterCollectionViewCell.self), for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let group = filterViewModel.model?.groups[indexPath.section]
        let groupItem = group?.items[indexPath.item]
        let filterCell = cell as! YXStockFilterCollectionViewCell
        filterCell.model = groupItem
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        let group = filterViewModel.model?.groups[indexPath.section]
        let groupItem = group?.items[indexPath.item]
        if let item = groupItem {
            showSelectView(withFilterItem: item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
}

//MARK:布局
extension YXStockFilterViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let height = self.sectionHeights[indexPath.section]
        return CGSize.init(width: 109.0*uiRatio, height: 40.0*uiRatio)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets.init(top: 0, left: 12, bottom: 12, right: 12)
    }
    
    // 行间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    // 列间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize.init(width: collectionView.frame.size.width, height: 52)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize.init(width: collectionView.frame.size.width, height: 10)
    }
}

class YXStockFilterFlowLayout: UICollectionViewFlowLayout {
    
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
            
            if item.representedElementKind == UICollectionView.elementKindSectionHeader {
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

class YXStockFilterSectionBgView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = QMUITheme().foregroundColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

