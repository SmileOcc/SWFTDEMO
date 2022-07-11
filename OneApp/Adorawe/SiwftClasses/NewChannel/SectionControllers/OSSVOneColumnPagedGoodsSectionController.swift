//
//  OSSVOneColumnPagedGoodsSectionController.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/28.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import IGListKit
import SwiftyJSON
import RxSwift

class OSSVOneColumnPagedGoodsSectionController: ListSectionController,ListSupplementaryViewSource {
    
    
    private var loadMoreSubject = PublishSubject<OSSVNewInLoadMoreResultModel>()
    
    var loadMoreUpdate:Observable<OSSVNewInLoadMoreResultModel> {
        return loadMoreSubject.asObserver()
    }
    
    weak var collecctionView:UICollectionView!
    
    weak var adapter: ListAdapter!
    
    private var groupedItem:OSSVProtoGene?
    
    weak var rootInfo:OSSVNewChannelResult?
    
    var hotPage:Int = 0
    var totalPage:Int? = 0
    
    var disposeBag = DisposeBag()
    var loadMoreDisposeBag = DisposeBag()
    
    weak var dragLoadMore:Observable<String?>!{
        didSet{
            dragLoadMore.subscribe(onNext:{[weak self] specialId in
                if !(self?.isLastSection ?? false){
                    return
                }
                
                self?.viewMoreHotGoods(endRefresh: { hasMore in
                    if hasMore {
                        self?.collecctionView.mj_footer?.endRefreshing()
                    }else{
                        self?.collecctionView.mj_footer?.endRefreshingWithNoMoreData()
                    }
                }, specialId: specialId ?? "")
            }).disposed(by: disposeBag)
        }
    }
    
    override func didUpdate(to object: Any) {
        groupedItem = object as? OSSVProtoGene
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let ratio = CGFloat(140.0 / 351)
        return CGSize(width: CGFloat.screenWidth, height: CGFloat.screenWidth * ratio)
    }
    
    override var inset: UIEdgeInsets{
        get{
            return UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
        }
        set{
            super.inset = newValue
        }
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(of: OSSVNewInRankCell.self, for: self, at: index)
        if let cell = cell as? OSSVNewInRankCell,
           let goodsItem = groupedItem?.goodsList?[index,true],
           let model = STLHomeCGoodsModel.yy_model(with: goodsItem.toJSON())
        {
            model.ranking = groupedItem?.ranking ?? 0
            model.rankType = model.ranking
            model.rankIndex = index + 1
            model.flash_sale = goodsItem.flashSale
            cell.setHomeGoodsModel(model)
            cell.delegate = self
            
        }
        
        return cell
    }
    
    override func numberOfItems() -> Int {
        groupedItem?.goodsList?.count ?? 0
    }
    
    override func didSelectItem(at index: Int) {
        if let item = groupedItem?.goodsList?[index]{
            let detailVC = OSSVDetailsVC()
            detailVC.wid = item.wid
            detailVC.goodsId = item.goods_id
            detailVC.coverImageUrl = item.goods_img
            viewController?.navigationController?.pushViewController(detailVC, animated: true)
            let itemGA = GAEventItems(item_id: item.goods_id ?? "", item_category: item.cat_id ?? "", item_variant: "1", price: item.shop_price , currency: "USD")
            GATools.logNewInHotSale(itemListId: item.goods_id ?? "", itemListName: "", items: [itemGA],isclick: true)
        }
    }
    
    
//MARK: footer
    override var supplementaryViewSource: ListSupplementaryViewSource? {
        get{
            return self
        }
        set{}
    }
    
    func supportedElementKinds() -> [String] {
        [UICollectionView.elementKindSectionFooter]
    }
    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        
        switch elementKind{
        case UICollectionView.elementKindSectionFooter:
            if !isLastSection && (groupedItem?.hasMore ?? false){
                if let footer = collectionContext?.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, for: self, class: OSSVNewInViewMoreFooterView.self, at: index) as? OSSVNewInViewMoreFooterView{
                    loadMoreDisposeBag = DisposeBag()
                    footer.viewMoreBtn?.rx.tap.subscribe(onNext:{[weak self] in
                        self?.viewMoreHotGoods(endRefresh: { hasMore in
                            if !hasMore{
                                HUDManager.showHUD(withMessage: STLLocalizedString_("noGoods"))
                            }
                        })
                    }).disposed(by: loadMoreDisposeBag)
                    return footer
                }
            }
            break
        default:
            break
        }
        
        return collectionContext!.dequeueReusableSupplementaryView(ofKind: elementKind, for: self, class: UICollectionReusableView.self, at: index)
        
    }
    
    func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        switch elementKind{
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
    
    
    
    ///收藏取消收藏
    private func collect(model:STLHomeCGoodsModel,index:Int) {
        STLNetworkStateManager.shared().networkState {[weak self] in
            var api:OSSVBasesRequests?
            if model.is_collect != 0 {
                api = OSSVDelCollectApi(addCollectGoodsId: model.goods_id, wid: model.wid)
            }else{
                api = OSSVAddCollectApi(addCollectGoodsId: model.goods_id, wid: model.wid)
            }
            api?.accessoryArray.add(STLRequestAccessory(apperOn: self?.viewController?.view)!)
            api?.start(blockSuccess: { req in
                if let reqJson = OSSVNSStringTool.desEncrypt(req),
                   let collectCount = self?.groupedItem?.goodsList?[index].collect_count,
                   let section = self?.section,
                   let collectionView = self?.collecctionView{
                    let result = JSON(reqJson)
                    if result["statusCode"] == 200{
                        self?.groupedItem?.goodsList?[index].is_collect = model.is_collect == 0 ? 1 : 0
                        self?.groupedItem?.goodsList?[index].collect_count = model.is_collect == 0 ? collectCount + 1 : collectCount - 1
                        let indexPath = IndexPath(item: index, section: section)
                        self?.adapter.updater.reloadItem(in: collectionView, from: indexPath, to: indexPath)
                    }else{
                        HUDManager.showHUD(withMessage: .errorMsg)
                    }
                }
            }, failure: { req, err in
                HUDManager.showHUD(withMessage: .errorMsg)
            })
            
        } exception: {
            HUDManager.showHUD(withMessage: .errorMsg)
        }

    }
    
    ///加载更多单列商品
    func viewMoreHotGoods(endRefresh:((Bool)->Void)?,specialId:String = "") {
        let api = OSSVNewInLoadMoreAPI(specialId: rootInfo?.id ?? specialId, type: ChannelDataType.OneColumnPagedGoods.rawValue, date: "", page: hotPage + 1, pageSize: 20)
        if let accessory = STLRequestAccessory(apperOn: viewController!.view){
            if endRefresh == nil{
                api.accessoryArray.add(accessory)
            }
        }
        STLNetworkStateManager.shared().networkState {
            api.start {[weak self] req in
                
                if let reqJson = OSSVNSStringTool.desEncrypt(toString: req),
                   let resp = OSSVNewInLoadMoreResp(JSONString: reqJson),
                   let section = self?.section,
                   let reslut = resp.result{
                    
                    let hasMoreDatas = reslut.hasMore
                    self?.hotPage = (reslut.currentPage ?? 0)
                    self?.totalPage = reslut.totalPage
                    if let hotPage = self?.hotPage{
                        if hotPage == 1 {
                            endRefresh?(true)
                        }else{
                            endRefresh?(hasMoreDatas)
                        }
                    }else{
                        endRefresh?(hasMoreDatas)
                    }
                    reslut.section = section
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
    }
    
    override var displayDelegate: ListDisplayDelegate?{
        get{
            self
        }
        set{}
    }
    
}

extension OSSVOneColumnPagedGoodsSectionController:STLThemeGoodsRankCCellDelegate{
    //单列商品，快速加购
    func stl_themeGoodsRankCCell(_ cell: OSSVThemeGoodsItesRankCCell, addCart model: STLHomeCGoodsModel) {
        FastAddManager.shared.requesData(goodsId: model.goods_id ?? "", wid: model.wid ?? "",specialID: model.specialId, controller: self.viewController!,collextionView: self.collecctionView)
        let item = GAEventItems(item_id: model.goods_id ?? "", item_category: model.cat_id ?? "", item_variant: "1", price: model.shop_price , currency: "USD")
        GATools.logNewInAddCart(value: model.shop_price ?? "0", items: [item])
        GATools.popGoodDetailView(goodTitle: model.goods_title ?? "")
    }
    
    func stl_themeGoodsRankCCell(_ cell: OSSVThemeGoodsItesRankCCell, addWishList model: STLHomeCGoodsModel) {
        
        if OSSVAccountsManager.shared().isSignIn {
            if let index = collectionContext?.index(for: cell, sectionController: self){
                collect(model: model, index: index)
            }
        }else{
            let signVC = SignViewController()
            signVC.modalPresentationStyle = .fullScreen
            signVC.modalBlock = {
                // 重新请求一下接口
                self.collecctionView.mj_header?.beginRefreshing()
            }
            viewController?.present(signVC, animated: true, completion: nil)
        }
    }
}

extension OSSVOneColumnPagedGoodsSectionController:ListDisplayDelegate{
    func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController) {
        
    }
    
    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController) {
        
    }
    
    func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController, cell: UICollectionViewCell, at index: Int) {
        ///商品曝光
        if let goods = groupedItem?.goodsList?[index],
            !goods.isImpressioned {
            goodsImpression(goods: goods)
            goods.isImpressioned = true
            
            let item = GAEventItems(item_id: goods.goods_id ?? "", item_category: goods.cat_id ?? "", item_variant: "1", price: goods.shop_price , currency: "USD")
            GATools.logNewInHotSale(itemListId: goods.goods_id ?? "", itemListName: "", items: [item])
            
        }
    }
    
    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController, cell: UICollectionViewCell, at index: Int) {
        
    }
}


