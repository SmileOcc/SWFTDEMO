//
//  OSSVNewChannelViewController.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/9.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import YYImage
import SwiftyJSON

import IGListKit
import FirebasePerformance

class OSSVNewChannelViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    var reloadDisposeBag = DisposeBag()
    
    lazy var skeleton:YYAnimatedImageView = {
        let image = YYAnimatedImageView(image: UIImage(named: "new_in_skeleton"))
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    lazy var adapter: ListAdapter = {
            return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
        }()
    
    var groupedData:[OSSVProtoGene]?{
        didSet{
            adapter.reloadData(completion: nil)
        }
    }
    
    weak var collectionView:UICollectionView?
    weak var topBar:OSSVHomeNavBar?
    
    var isLoading:Bool = true
    
    var rootInfo:OSSVNewChannelResult?
    
    weak var timeNavigateSection:OSSVOSSVTimeNavigateSectionController?
    weak var oncolumnPageSection:OSSVOneColumnPagedGoodsSectionController?
    ///上拉加载更多事件
    lazy private var dragLoadMoreSubject:PublishSubject<String?> = {
         let result = PublishSubject<String?>()
        result.subscribe(onNext:{[weak self] _ in
            let hasmore = self?.groupedData?.filter({ element in
                if let type = element.type,
                   let groupType = ChannelDataType(rawValue: type)
                {
                    
                    switch groupType {
                    case .OneColumnPagedGoods:
                        return self?.oncolumnPageSection?.isLastSection == true
                    case .TimeNavigate:
                        return self?.timeNavigateSection?.isLastSection == true
                    default:
                        return false
                    }
                    
                }
                return false
            })
            
            if let hasmore = hasmore,
               !hasmore.isEmpty{
                
            }else{
                self?.collectionView?.mj_footer?.endRefreshingWithNoMoreData()
            }
        }).disposed(by: disposeBag)
        
        return result
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = OSSVThemesColors.col_F5F5F5()
        
        ///顶部视图添加
        fd_prefersNavigationBarHidden = true
        
        setupViews()
        
        setupSkeleton()

        requestRootData()
        requestHotSearchWords()
    }
    
    func setupSkeleton(){
        collectionView!.addSubview(skeleton)
        
        let height = CGFloat.screenWidth * 2845.0 / 1107.0
        skeleton.snp.makeConstraints { make in
            //1107 × 2854
            make.top.leading.trailing.equalTo(self.collectionView!)
            make.height.equalTo(height)
            make.width.equalTo(CGFloat.screenWidth)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        topBar?.showCartOrMessageCount()
    }
    
    func setupViews() {
        
        let topBar = OSSVHomeNavBar()
        topBar.stl_showBottomLine(false)
        topBar.delegate = self
        topBar.navBarActionBlock = {[weak self] actionType in
            switch actionType {
            case HomeNavBarLeftSearchAction:
                self?.actionSearch()
                break
            case HomeNavBarRightCarAction:
                self?.actionCart()
                break
            case HomeNavBarRighMessageAction:
                self?.actionMessage()
                break
            default:
                break
            }
        }
        self.topBar = topBar
        view.addSubview(topBar)
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionHeadersPinToVisibleBounds = false
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        view.addSubview(collectionView)
        self.collectionView = collectionView
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(topBar.snp.bottom)
            make.leading.trailing.equalTo(view)
            make.bottom.equalTo(view.snp_bottomMargin)
        }

        adapter.collectionView = collectionView
        
        adapter.dataSource = self
        
        let refreshHeader = MJRefreshNormalHeader {[weak self] in
            self?.requestRootData(isFromPull: true)
        }
        refreshHeader.lastUpdatedTimeLabel?.isHidden = true
        refreshHeader.stateLabel?.isHidden = true
        collectionView.mj_header = refreshHeader
        
        let footer = OSSVRefreshsAutosNormalFooter(refreshingBlock: {[weak self] in
            self?.dragLoadMoreSubject.onNext(nil)
        })
        collectionView.mj_footer = footer
        
        collectionView.emptyDataSetDelegate = self
        collectionView.emptyDataSetSource = self
    }
    
}

extension OSSVNewChannelViewController:ListAdapterDataSource{
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        let empty:[OSSVProtoGene] = []
        return (groupedData ?? empty) as [ListDiffable]
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if let obj = object as? OSSVProtoGene,
            let type = obj.type,
           let groupType = ChannelDataType(rawValue: type){
            switch groupType {
            case .OneRowImg:
                return OSSVOneRowImgSectionController()
            case .ScrollFocusedImg:
                return OSSVScrollFocusedImgSectionController()
            case .OneColumnPagedGoods:
                let oneColumController = OSSVOneColumnPagedGoodsSectionController()
                oneColumController.collecctionView = collectionView
                oneColumController.adapter = adapter
                oneColumController.loadMoreUpdate.subscribe(onNext:{[weak self] result in
                    if let groupItem = self?.groupedData?[result.section,true],
                       let collectionView = self?.collectionView
                    {
                        if groupItem.goodsList == nil{
                            groupItem.goodsList = []
                        }
                        groupItem.goodsList?.append(contentsOf: result.goodsList ?? [])
                        groupItem.hasMore = result.hasMore
                        groupItem.ranking = result.ranking
                        self?.adapter.updater.reload(collectionView, sections: IndexSet(integer: result.section))
                    }
                }).disposed(by: disposeBag)
                oneColumController.rootInfo = rootInfo
                oneColumController.dragLoadMore = self.dragLoadMoreSubject.asObservable()
                self.oncolumnPageSection = oneColumController
                //加载第一页单列商品
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.dragLoadMoreSubject.onNext(nil)
                }
                return oneColumController
            case .TimeNavigate:
                let timeSectionColtroller = OSSVOSSVTimeNavigateSectionController()
                timeSectionColtroller.adapter = adapter
                timeSectionColtroller.collecctionView = collectionView
                timeSectionColtroller.loadMoreUpdate.subscribe(onNext:{[weak self] result in
                    //追加数据到列表
                    if let groupItem = self?.groupedData?[result.section,true],
                       let collectionView = self?.collectionView
                    {
                        if groupItem.date?.new_in_day?[result.timeIndex,true]?
                        .goodsList == nil {
                            groupItem.date?.new_in_day?[result.timeIndex,true]?
                            .goodsList = []
                        }
                        groupItem.date?.new_in_day?[result.timeIndex]
                            .goodsList?.append(contentsOf: result.goodsList ?? [])
                        groupItem.hasMore = result.hasMore
                        self?.adapter.updater.reload(collectionView, sections: IndexSet(integer: result.section))
                    }
                }).disposed(by: disposeBag)
                self.timeNavigateSection = timeSectionColtroller
                timeSectionColtroller.dragLoadMore = self.dragLoadMoreSubject.asObservable()
                timeSectionColtroller.rootInfo = rootInfo
                return timeSectionColtroller
            default:
                break
            }
        }
        return ListSectionController()
    }

    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        nil
    }
    
    
}

//MARK: 界面跳转
extension OSSVNewChannelViewController:HomeNavigationBarDelegate{
    
    func jumpToSearch(withKey searchKey: String!) {
        let searchVC = OSSVSearchVC()
        searchVC.enterName = "NewIn"
        searchVC.searchTitle = searchKey
        navigationController?.pushViewController(searchVC, animated: true)
        
        OSSVAnalyticsTool.analyticsGAEvent(withName: "top_function", parameters: ["screen_group":"New","button_name":"Search_box"])
    }
    
    func actionSearch() {
        let searchVC = OSSVSearchVC()
        searchVC.enterName = "NewIn"
        navigationController?.pushViewController(searchVC, animated: true)

    }
    
    func actionMessage() {
        if !OSSVAccountsManager.shared().isSignIn {
            let signVc = SignViewController()
            signVc.modalPresentationStyle = .fullScreen
            signVc.modalBlock = {[weak self] in
                self?.jumpToMessage()
            }
            present(signVc, animated: true)
        }else{
            jumpToMessage()
        }
        OSSVAnalyticsTool.analyticsGAEvent(withName: "top_function", parameters: ["screen_group":"New","button_name":"Message"])
    }
    
    func jumpToMessage() {
        let messageVc = OSSVMessageVC()
        navigationController?.pushViewController(messageVc, animated: true)
    }
    
    
    func actionCart() {
        let cartVc = OSSVCartVC()
        navigationController?.pushViewController(cartVc, animated: true)
        
        OSSVAnalyticsTool.analyticsGAEvent(withName: "top_function", parameters: ["screen_group":"New","button_name":"Cart"])

    }
}


//MARK: 网络请求
extension OSSVNewChannelViewController{
    
    
    func cleanData(){
        //清空分页信息
        self.collectionView?.mj_footer?.endRefreshing()
    }
    
    
///请求热搜词， 用于顶部搜索框文案滚动

    func requestHotSearchWords(){
        let groupId = "index"
        let api = OSSVHotsSearchsWordsAip(groupId: groupId, cateId: "")
        api?.start(blockSuccess: {[weak self] req in
            if let requestJSON = OSSVNSStringTool.desEncrypt(req) as? NSDictionary{
                let result = JSON(requestJSON)
                let message = result["message"].string
                if result["statusCode"] == 200{
                    let arr = NSArray.yy_modelArray(with: OSSVHotsSearchWordsModel.self, json: requestJSON["result"] as? [NSDictionary] ?? [])
                    self?.topBar?.hotWordsArray = arr
                }else{
                    HUDManager.showHUD(withMessage: message)
                    self?.topBar?.hotWordsArray = []
                }
            }
            
        }, failure: {[weak self] req, err in
            HUDManager.showHUD(withMessage: STLLocalizedString_("networkNotAvailable"))
            self?.topBar?.hotWordsArray = []
        })
   }
    
    func requestRootData(isFromPull:Bool = false){
        
        isLoading = true
        adapter.reloadData(completion: nil)
        
        
        STLNetworkStateManager.shared().networkState {[weak self] in
            let api = OSSVNewInApi()
            let trace = Performance.startTrace(name: "special/newin")
            if !isFromPull &&  (self?.skeleton.isHidden ?? true) {
                if let accessory = STLRequestAccessory(apperOn: self?.view){
                    api.accessoryArray.add(accessory)
                }
            }
            api.start {[weak self] req in
                trace?.stop()
                self?.cleanData()
                self?.skeleton.isHidden = true
                self?.isLoading = false
                self?.collectionView?.mj_header?.endRefreshing()
                if let reqJson = OSSVNSStringTool.desEncrypt(toString: req),
                   let resp = OSSVNewChannelRespModel(JSONString: reqJson),
                   let result = resp.result?.mutiProtogene{
                    let result = result.sorted { obj1, obj2 in
                        (Int(obj1.sort ?? "0") ?? 0) < (Int(obj2.sort ?? "0") ?? 0)
                    }
                    
                    result.last?.isLast = true
                    
                    self?.groupedData = result
                    self?.rootInfo = resp.result
                    if let colorStr = resp.result?.color{
                        if !colorStr.isEmpty{
                            self?.view.backgroundColor = UIColor(hexString: colorStr)
                        }
                    }
                }else{
                    HUDManager.showHUD(withMessage: String.errorMsg)
                    self?.adapter.reloadData(completion: nil)
                }
            } failure: {[weak self] req, err in
                trace?.stop()
                HUDManager.showHUD(withMessage: String.errorMsg)
                self?.collectionView?.mj_header?.endRefreshing()
                self?.isLoading = false
                self?.adapter.reloadData(completion: nil)
                self?.skeleton.isHidden = true
            }
        } exception: { [weak self] in
            self?.skeleton.isHidden = true
            self?.isLoading = false
            self?.collectionView?.mj_header?.endRefreshing()
            HUDManager.showHUD(withMessage: String.errorMsg)
            self?.adapter.reloadData(completion: nil)
        }
    }
}

///EmptySet
extension OSSVNewChannelViewController:DZNEmptyDataSetDelegate,DZNEmptyDataSetSource{

    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
        reloadDisposeBag = DisposeBag()
        let view = OSSVNewInEmptyView()
        view.actionBtn.rx.tap.subscribe(onNext:{[weak self] in
            self?.requestRootData()
        }).disposed(by: reloadDisposeBag)
        return view
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        (groupedData?.count ?? 0) <= 0 && !isLoading
    }

}

