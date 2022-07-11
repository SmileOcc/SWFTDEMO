//
//  OSSVOSSVTimeNavigateSectionController.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/28.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import IGListKit
import RxSwift

class OSSVOSSVTimeNavigateSectionController: ListSectionController,ListSupplementaryViewSource {
    
    private var loadMoreSubject = PublishSubject<OSSVNewInLoadMoreResultModel>()
    
    var loadMoreUpdate:Observable<OSSVNewInLoadMoreResultModel> {
        return loadMoreSubject.asObserver()
    }
    
    private var groupedItem:OSSVProtoGene?
    
    weak var adapter: ListAdapter!
    weak var collecctionView:UICollectionView!
    
    var loadMoreDisposeBag = DisposeBag()
    var reloadDisposeBag = DisposeBag()
    var timeRangeDisposeBag = DisposeBag()
    
    var currentTimeSelectIndex = 0
    
    var newInPage:[String:Int] = [:]
    var totalPage:[String:Int] = [:]
    
    weak var rootInfo:OSSVNewChannelResult?
    
    var disposeBag = DisposeBag()
    
    weak var dragLoadMore:Observable<String?>!{
        didSet{
            dragLoadMore.subscribe(onNext:{[weak self] _ in
                if !(self?.isLastSection ?? false){
                    return
                }
                self?.viewMoreNewInGoods(endRefresh: { hasMore in
                    if hasMore {
                        self?.collecctionView.mj_footer?.endRefreshing()
                    }else{
                        self?.collecctionView.mj_footer?.endRefreshingWithNoMoreData()
                    }
                })
            }).disposed(by: disposeBag)
        }
    }
    
    override func didUpdate(to object: Any) {
        groupedItem = object as? OSSVProtoGene
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let ratio = CGFloat(196.29 / 122)
        let width = (CGFloat.screenWidth - 12 * 4) / 3
        return CGSize(width: width, height: ratio * width)
    }
    
    override var inset: UIEdgeInsets{
        get{
            return UIEdgeInsets(top: 0, left: 12, bottom: 24, right: 12)
        }
        set{
            super.inset = newValue
        }
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(of: OSSVNewInTimeRangeItemCell.self, for: self, at: index)
        if let cell = cell as? OSSVNewInTimeRangeItemCell,
           let goodsItem = groupedItem?.date?.new_in_day?[currentTimeSelectIndex,true]?.goodsList?[index,true],
           let model = STLHomeCGoodsModel.yy_model(with: goodsItem.toJSON())
        {
            model.flash_sale = goodsItem.flashSale
            cell.setHomeCGoodsModel(model)
        }
        return cell
    }
    
    override func numberOfItems() -> Int {
        groupedItem?.date?.new_in_day?[currentTimeSelectIndex,true]?.goodsList?.count ?? 0
    }
    
    override var minimumLineSpacing: CGFloat{
        get{
            return 12
        }
        set{}
    }
    
    override func didSelectItem(at index: Int) {
        if let item = groupedItem?.date?.new_in_day?[currentTimeSelectIndex].goodsList?[index]{
            let detailVC = OSSVDetailsVC()
            detailVC.wid = item.wid
            detailVC.goodsId = item.goods_id
            detailVC.coverImageUrl = item.goods_img
            viewController?.navigationController?.pushViewController(detailVC, animated: true)
            let itemGA = GAEventItems(item_id: item.goods_id ?? "", item_category: item.cat_id ?? "", item_variant: "1", price: item.shop_price , currency: "USD")
            GATools.logNewInListImpression(itemListId: item.goods_id ?? "", itemListName: "", items: [itemGA], isclick: true)
        }
    }
    
    override var supplementaryViewSource: ListSupplementaryViewSource?{
        get{
            return self
        }
        set{}
    }
    
    func supportedElementKinds() -> [String] {
        return [UICollectionView.elementKindSectionHeader,UICollectionView.elementKindSectionFooter]
    }
    
    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        
        switch elementKind{
        case UICollectionView.elementKindSectionFooter:
            if !isLastSection && (groupedItem?.hasMore ?? false){
                if let footer = collectionContext?.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, for: self, class: OSSVNewInViewMoreFooterView.self, at: index) as? OSSVNewInViewMoreFooterView{
                    loadMoreDisposeBag = DisposeBag()
                    footer.viewMoreBtn?.rx.tap.subscribe(onNext:{[weak self] in
                        self?.viewMoreNewInGoods(endRefresh: { hasMore in
                            if !hasMore{
                                HUDManager.showHUD(withMessage: STLLocalizedString_("noGoods"))
                            }
                        })
                    }).disposed(by: loadMoreDisposeBag)
                    return footer
                }
            }
            break
        case UICollectionView.elementKindSectionHeader:
            let header = collectionContext!.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, for: self, class: OSSVTimeRangeSelectView.self, at: index)
            if let header = header as? OSSVTimeRangeSelectView,
               let arrs = groupedItem?.date?.new_in_day{
                header.currentIndex = self.currentTimeSelectIndex
                header.datas = arrs
                timeRangeDisposeBag = DisposeBag()
                header.indexSelectPub.subscribe(onNext:{[weak self] timeIndex in
                    self?.switchTimeNavigate(timeIndex:timeIndex)
                }).disposed(by: timeRangeDisposeBag)
            }
            return header
        default:
            break
        }
        
        return collectionContext!.dequeueReusableSupplementaryView(ofKind: elementKind, for: self, class: UICollectionReusableView.self, at: index)
        
    }
    
    func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        switch elementKind{
        case UICollectionView.elementKindSectionHeader:
            return CGSize(width: 100, height: 58 + 20 + 12)
        case UICollectionView.elementKindSectionFooter:
            if !isLastSection && (groupedItem?.hasMore ?? false){
                return CGSize(width: 100, height: 60)
            }
            break
        default:
            break
        }
        return .zero
    }
    
    
    ///切换时间导航
    private func switchTimeNavigate(timeIndex:Int){
        currentTimeSelectIndex = timeIndex
        //是否目标时间有数据
        guard let srcDatas = groupedItem?.date?.new_in_day?[currentTimeSelectIndex],
              ((srcDatas.goodsList?.count ?? 0) == 0) else{//没有数据才请求
            UIView.performWithoutAnimation {
                adapter.updater.reload(collecctionView, sections: IndexSet(integer: section))
            }
            return
        }
        
        //加载更多
        self.viewMoreNewInGoods(endRefresh: { hasMore in
            if !hasMore{
                HUDManager.showHUD(withMessage: STLLocalizedString_("noGoods"))
            }
        })
    }
    
    
    ///加载更多三列商品
    func viewMoreNewInGoods(endRefresh:((Bool)->Void)?) {
        
        GATools.logNewInloadMore()

        let defaultPage = currentTimeSelectIndex == 0 ? 1 : 0
        if let timeItem = groupedItem,
           let currentDay = timeItem.date?.new_in_day?[currentTimeSelectIndex,true],
           let date = currentDay.date{
            let pageSize = Int(timeItem.date?.goods_num ?? "9") ?? 9
            let api = OSSVNewInLoadMoreAPI(specialId:rootInfo?.id ?? "", type: ChannelDataType.TimeNavigate.rawValue, date: date, page: (newInPage[date] ?? defaultPage) + 1, pageSize: pageSize)
            if let accessory = STLRequestAccessory(apperOn: viewController!.view){
                api.accessoryArray.add(accessory)
            }
            STLNetworkStateManager.shared().networkState {
                api.start {[weak self] req in
                    
                    if let reqJson = OSSVNSStringTool.desEncrypt(toString: req),
                       let resp = OSSVNewInLoadMoreResp(JSONString: reqJson),
                       let timeIndex = self?.currentTimeSelectIndex,
                       let section = self?.section,
                       let reslut = resp.result{
                        let hasMoreDatas = reslut.hasMore
                        self?.newInPage[date] = (reslut.currentPage ?? 0)
                        self?.totalPage[date] = reslut.totalPage
                        timeItem.hasMore = hasMoreDatas
                        endRefresh?(hasMoreDatas)
                        reslut.section = section
                        reslut.timeIndex = timeIndex
                        self?.loadMoreSubject.onNext(reslut)
                        
                    }else{
                        endRefresh?(false)
                    }
                } failure: { req, err in
                    endRefresh?(false)
                    HUDManager.showHUD(withMessage: String.errorMsg)
                }
            } exception: {
                endRefresh?(false)
                HUDManager.showHUD(withMessage: String.errorMsg)
            }
        }else{
            endRefresh?(false)
        }
    }
    
    override var displayDelegate: ListDisplayDelegate?{
        get{
            self
        }
        set{}
    }
    
}

extension OSSVOSSVTimeNavigateSectionController:ListDisplayDelegate{
    func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController) {
        
    }
    
    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController) {
        
    }
    
    func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController, cell: UICollectionViewCell, at index: Int) {
        ///商品曝光
        if let goods = groupedItem?.date?.new_in_day?[currentTimeSelectIndex,true]?.goodsList?[index,true],
           !goods.isImpressioned {
            goodsImpression(goods: goods)
            goods.isImpressioned = true
            
            
            let item = GAEventItems(item_id: goods.goods_id ?? "", item_category: goods.cat_id ?? "", item_variant: "1", price: goods.shop_price , currency: "USD")
            GATools.logNewInListImpression(itemListId: goods.goods_id ?? "", itemListName: "", items: [item])
        }
    }
    
    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController, cell: UICollectionViewCell, at index: Int) {
        
    }
}




