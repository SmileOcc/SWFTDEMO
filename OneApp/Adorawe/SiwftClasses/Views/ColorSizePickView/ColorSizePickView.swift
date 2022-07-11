//
//  ColorSizePickView.swift
//  Adorawe
//
//  Created by fan wang on 2021/10/29.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import SnapKit
import IGListKit
import RxSwift
import RxRelay
import zhPopupController

class ColorSizePickView: UIView {
    
    @objc weak var addButton:UIButton?
    
    @objc weak var delegate:OSSVSizeDidSelectProtocol?
    lazy var updateSizeTipPub:PublishSubject<OSSVAttributeItemModel?> = {
        let pub = PublishSubject<OSSVAttributeItemModel?>()
        pub.subscribe(onNext:{[weak self] attr in
            if let sizeInfo = self?.goodsInfo?.size_info,
               let attr = attr{
                self?.delegate?.updateSizeTipView(with: sizeInfo, itemModel: attr)
            }
        }).disposed(by:disposeBag)
        return pub
    }()
    
    @objc func setFirstIntoSelectSize(_ firstInto:Bool){
        firstIntoDetail.accept(firstInto)
    }
    
    ///同一商品详情下的 弹窗与 外露的属性
    @objc weak var siblingView:ColorSizePickView?
    
    var currentSizeAttr:OSSVAttributeItemModel?
    var currentColorAttr:OSSVAttributeItemModel?
    
    lazy var firstIntoDetail:BehaviorRelay<Bool> = {
        let beh = BehaviorRelay(value: false)
        return beh
    }()
    
    @objc private(set) weak var sizeCollectView:UICollectionView?
    
    @objc var didSelectedGoodsId:((OSSVAttributeItemModel)->Void)?
    
    @objc var onlyNeedSize:Bool = false{
        didSet{
            let colorH:CGFloat = onlyNeedSize ? 0 : 104
            colorContainer.isHidden = onlyNeedSize
            colorContainer.snp.updateConstraints({ make in
                make.height.equalTo(colorH)
            })
            
            pleaseSelectSizeLbl.isHidden = !onlyNeedSize
            pleaseSelectSizeLbl.snp.updateConstraints { make in
                make.height.equalTo(onlyNeedSize ? 28 : 0)
            }
        }
    }
    
    private weak var colorContainer:UIView!
    private weak var sizeContainer:UIView!
    private weak var sizeTitle:UILabel!
    private weak var sizeChatButton:UIButton!
    private weak var sizeTipView:UILabel!
    
    private weak var pleaseSelectSizeLbl:UILabel!
    
    

    
    ///选中颜色切换商品id的事件
    lazy var colorGoodIdPub:PublishSubject<OSSVAttributeItemModel> = {
        let sub = PublishSubject<OSSVAttributeItemModel>()
        sub.subscribe(onNext:{[weak self] goodsAttr in
            var goodsId = goodsAttr.goods_id ?? ""
            let oldColorAttr = self?.currentColorAttr
            self?.currentColorAttr = goodsAttr
            let colorSet = goodsAttr.groupIdsSet
            let sizeSet =  self?.currentSizeAttr?.groupIdsSet
            let resultId = sizeSet?.intersection(colorSet).first ?? goodsId
            
            if let currentColorId = oldColorAttr?.goods_id,
                resultId == currentColorId{
                return
            }
            if let didSelectedGoodsId = self?.didSelectedGoodsId {
                goodsAttr.goods_id = resultId
                didSelectedGoodsId(goodsAttr)
            }
            

            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotif_GoodsDetailColorTap), object: resultId)
        })
        .disposed(by: disposeBag)
        return sub
    }()
    
    ///选中尺码切换商品id的事件
    lazy var sizeGoodIdPub:PublishSubject<OSSVAttributeItemModel> = {
        let sub = PublishSubject<OSSVAttributeItemModel>()
        sub.subscribe(onNext:{[weak self] goodsAttr in
//            var goodsId = goodsAttr.goods_id ?? ""
            let oldSizeAttr = self?.currentSizeAttr
            let sizeSet = goodsAttr.groupIdsSet
            let colorSet = self?.currentColorAttr?.groupIdsSet
            var resultId = colorSet?.intersection(sizeSet).first //?? goodsId
            
            if let currentSizeId = oldSizeAttr?.goods_id,
               self?.firstIntoDetail.value != true,
                resultId == currentSizeId{
                return
            }
            
            if self?.goodsInfo?.isHasColorItem == false {
                resultId = sizeSet.first
            }
            if resultId == nil{
                return
            }
            
            STLPreference.setObject([:], key: "shortOfGoods")
            self?.currentSizeAttr = goodsAttr
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotif_GoodsDetailSizeTap), object: resultId)
            if let didSelectedGoodsId = self?.didSelectedGoodsId {
                goodsAttr.goods_id = resultId
                didSelectedGoodsId(goodsAttr)
            }
            self?.siblingView?.firstIntoDetail.accept(false)
//            if let sizeChatInfo = self?.goodsInfo?.size_info {
//                self?.delegate?.updateSizeTipView(with: sizeChatInfo, itemModel: goodsAttr)
//            }
            
        })
        .disposed(by: disposeBag)
        return sub
    }()

    
    lazy var sizeCodeIndex:BehaviorRelay<Int> = {        
        let beh = BehaviorRelay<Int>(value: 0)
        beh.subscribe(onNext:{[weak self] index in
            self?.sizeAdapter.reloadData(completion: nil)
            self?.sizeCodeAdapter.reloadData(completion: nil)
            
            self?.siblingView?.sizeCodeIndex.accept(index)
//            self?.siblingView?.sizeAdapter.reloadData(completion: nil)
//            self?.siblingView?.sizeCodeAdapter.reloadData(completion: nil)
        })
        .disposed(by: disposeBag)
        return beh
    }()
    
    let disposeBag = DisposeBag()
    
    
    @objc var goodsInfo:OSSVDetailsBaseInfoModel?{
        didSet{
            colorContainer.snp.updateConstraints { make in
                make.height.equalTo(self.onlyNeedSize ? 0 : 104)
            }
            sizeContainer.snp.updateConstraints { make in
                make.height.equalTo(110)
            }
            
            goodsInfo?.fillDataToSizePickAttr()
            
            ///展示SizeTitle
            self.sizeTitle.isHidden = false
            if let sizeMappingList = goodsInfo?.size_mapping_list,
               !sizeMappingList.isEmpty {
                self.sizeTitle.isHidden = true
            }
            
            
            //获取颜色信息
            colorData = []
            sizeData = []
            if let goodsSpecs = goodsInfo?.goodsSpecs {
                if goodsSpecs.count == 2 {//颜色尺码都有
                    var selectedColor,selectedSize : OSSVAttributeItemModel?
                    for spec in goodsSpecs {
                        if spec.spec_type == "1" {//颜色
                            if(spec.brothers != nil){
                                let model = ColorSizeModel()
                                model.colorBrothers = spec.brothers
                                colorData.append(model)
                                
                                selectedColor = spec.brothers?.filter { item in
                                    item.checked == true
                                }.first
                            }else{
                                colorContainer.isHidden = true
                                colorContainer.snp.updateConstraints { make in
                                    make.height.equalTo(0)
                                }
                                selectedColor = OSSVAttributeItemModel()
                            }
                        }
                        
                        if spec.spec_type == "2"{//尺码
                            if spec.brothers != nil{
                                sizeData.append(createSizeModel(goodsSpecModel: spec))
                                selectedSize = spec.brothers?.filter { item in
                                    item.checked == true
                                }.first
                                setsizeChatTitleWith(spec: spec)
                            }else{
                                sizeContainer.isHidden = true
                                sizeContainer.snp.updateConstraints { make in
                                    make.height.equalTo(0)
                                }
                            }
                            
                        }
                    }
                    sizeContainer.isHidden = false
                    colorContainer.isHidden = colorContainer.isHidden || self.onlyNeedSize
                    colorData.first?.currentOtherAttr = selectedSize
                    sizeData.first?.currentOtherAttr = selectedColor
                    self.currentColorAttr = selectedColor
                    self.currentSizeAttr = selectedSize
                }else if goodsSpecs.count == 1 {//只有一个
                    let goodsSpecModel = goodsSpecs.first!
                    let selectAttr = goodsSpecModel.brothers?.filter { item in
                        item.checked == true
                    }.first
                    if goodsSpecModel.spec_type == "1" && goodsSpecModel.brothers != nil{//颜色
                        let model = ColorSizeModel()
                        model.colorBrothers = goodsSpecModel.brothers
                        colorData.append(model)
//                        sizeViewHeight = 104
                        sizeContainer.isHidden = true
                        colorContainer.isHidden = false || self.onlyNeedSize
                        sizeContainer.snp.updateConstraints { make in
                            make.height.equalTo(0)
                        }
                        self.currentColorAttr = selectAttr
                    }
                    if goodsSpecModel.spec_type == "2" && goodsSpecModel.brothers != nil{//尺码
                        sizeData.append(createSizeModel(goodsSpecModel: goodsSpecModel))
//                        sizeViewHeight = 102
                        setsizeChatTitleWith(spec: goodsSpecModel)
                        colorContainer.isHidden = true
                        sizeContainer.isHidden = false
                        colorContainer.snp.updateConstraints { make in
                            make.height.equalTo(0)
                        }
                        self.currentSizeAttr = selectAttr
                        
                    }
                }else if goodsSpecs.count == 0{
                    colorContainer.isHidden = true
                    sizeContainer.isHidden = true
                }
            }
            
            //刷新数据
            colorAdapter.reloadData(completion: nil)
            sizeAdapter.reloadData(completion: nil)
            sizeCodeAdapter.reloadData(completion: nil)
            
//            if goodsInfo?.isHasColorItem == false{
//                firstIntoDetail.accept(false)
//            }
        }
    }
    
    
    var sizeChatUrl:String?
    var sizeChatTitle:String?
    func setsizeChatTitleWith(spec:OSSVSpecsModel){
        if let sizeUrl = spec.size_chart_url,
           !sizeUrl.isEmpty,
           let sizeTitle = spec.size_chart_title,
           !sizeTitle.isEmpty
        {
            sizeChatButton.setAttributedTitle(NSString.underLineSizeChat(titleStr: sizeTitle), for: .normal)
            sizeChatUrl = sizeUrl
            sizeChatTitle = sizeTitle
            sizeChatButton.isHidden = false
        }else{
            sizeChatButton.isHidden = true
        }
    }
    
    @objc func sizeChatAction(){
        let activity = STLActivityWWebCtrl()
        activity.strUrl = self.sizeChatUrl
        activity.isIgnoreWebTitle = true
        activity.isModalPresent = true
        activity.title = sizeChatTitle ?? ""
        activity.modalPresentationStyle = .pageSheet
        window?.backgroundColor = OSSVThemesColors.stlBlackColor()
        let nav = OSSVNavigationVC(rootViewController: activity)
        nav.modalPresentationStyle = .pageSheet
        UIViewController.currentTop().present(nav, animated: true, completion: nil)
    }
    
    
    
    
    private var colorData:[ColorSizeModel] = []
    private var sizeData:[ColorSizeModel] = []
        
    
    ///颜色adapter
    lazy var colorAdapter: ListAdapter = {
            return ListAdapter(updater: ListAdapterUpdater(), viewController: nil)
        }()
    
    lazy var sizeCodeAdapter: ListAdapter = {
            return ListAdapter(updater: ListAdapterUpdater(), viewController: nil)
        }()
    
    lazy var sizeAdapter: ListAdapter = {
            return ListAdapter(updater: ListAdapterUpdater(), viewController: nil)
        }()

    override init(frame: CGRect){
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func firstNotifySizeCodeSelect(data:ColorSizeModel?){
        if let sizeItems = data?.sizeMapItem {
            var matchLocal = false
            if let savedCode = STLPreference.object(forKey: STLPreference.keySelectedSizeCode) as? String{
                for (index,item) in sizeItems.enumerated() {
                    if let code = item.code{
                        if code == savedCode{
                            sizeCodeIndex.accept(index)
                            matchLocal = true
                        }
                    }
                }
            }
            
            if matchLocal == false{
                let defaultItem = sizeItems.filter { element in
                    return element.is_default == true
                }.first
                
                if let _ = defaultItem {
                    for (index,item) in sizeItems.enumerated() {
                        if item.is_default == true{
                            sizeCodeIndex.accept(index)
                        }
                    }
                }else{//没有defaul 发第一个
                    if sizeItems.count > 0{
                        sizeCodeIndex.accept(0)
                    }
                }
            }
        }
    }
    
    func createSizeModel(goodsSpecModel:OSSVSpecsModel)->ColorSizeModel{
        let model = ColorSizeModel()
        model.sizeBrothers = goodsSpecModel.brothers
        
        //获取国际尺码信息
        var mapItems:[SizeMappingItem] = []
        goodsInfo?.size_mapping_list.forEach{ itemDic in
            if let itemDic = itemDic as? [String:Any],
            let item = SizeMappingItem(JSON: itemDic, context: nil) {
                mapItems.append(item)
            }
        }
        model.sizeMapItem =  mapItems
        firstNotifySizeCodeSelect(data: model)
        return model
    }
    
    func setupView(){
        
        let colorContianer = UIView()
        addSubview(colorContianer)
        colorContianer.snp.makeConstraints { make in
            make.leading.trailing.equalTo(0)
            make.height.equalTo(104)
            make.top.equalTo(0)
        }
        
        let colorLbl = UILabel()
        colorLbl.text = STLLocalizedString_("Color")
        colorLbl.font = UIFont.boldSystemFont(ofSize: 14)
        colorLbl.textColor = OSSVThemesColors.col_000000(1.0)
        colorContianer.addSubview(colorLbl)
        colorLbl.snp.makeConstraints { make in
            make.top.equalTo(9.5)
            make.leading.equalTo(0)
            make.height.equalTo(36)
        }
        
        let colorCollect = createCollectionView(parent: colorContianer)
        colorCollect.snp.makeConstraints { make in
            make.leading.equalTo(0)
            make.trailing.equalTo(0)
            make.top.equalTo(colorLbl.snp.bottom)
            make.height.equalTo(50)
        }
        colorAdapter.collectionView = colorCollect
        colorAdapter.dataSource = self
        
        
        let sizeContianer = UIView()
        addSubview(sizeContianer)
        sizeContianer.snp.makeConstraints { make in
            make.leading.trailing.equalTo(0)
            make.height.equalTo(110)
            make.top.equalTo(colorContianer.snp.bottom)
//            make.bottom.equalTo(0)
        }
        
        let button = UIButton()
        sizeChatButton = button
        sizeContianer.addSubview(sizeChatButton)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setImage(UIImage(named: "detail_size"), for: .normal)
//        button.tintColor = OSSVThemesColors.
        if OSSVSystemsConfigsUtils.isRightToLeftShow(){
            sizeChatButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        }else{
            sizeChatButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        }
        button.setAttributedTitle(NSString.underLineSizeChat(titleStr: nil), for: .normal)
        if app_type == 3{
            let sizeDashline = UIView()
            let color = UIColor(patternImage: UIImage(named: "spic_dash_line_black")!)
            sizeDashline.backgroundColor = color
            button.addSubview(sizeDashline)
            sizeDashline.snp.makeConstraints { make in
                make.leading.equalTo(20)
                make.trailing.equalTo(-4)
                make.bottom.equalTo(-10)
                make.height.equalTo(1)
            }
        }
        
        sizeChatButton.snp.makeConstraints { make in
            make.trailing.equalTo(0)
            make.top.equalTo(0)
            make.height.equalTo(35)
        }
        sizeChatButton.addTarget(self, action: #selector(sizeChatAction), for: .touchUpInside)
        
        let sizeCodeCollect = createCollectionView(parent: sizeContianer)
        sizeCodeCollect.snp.makeConstraints { make in
            make.leading.equalTo(0)
            make.trailing.equalTo(sizeChatButton.snp.leading)
            make.top.equalTo(0)
            make.height.equalTo(36)
        }
        sizeCodeAdapter.collectionView = sizeCodeCollect
        sizeCodeAdapter.dataSource = self
        
        let sizeTitle = UILabel()
        sizeContianer.addSubview(sizeTitle)
        self.sizeTitle = sizeTitle
        sizeTitle.snp.makeConstraints { make in
            make.leading.equalTo(0)
//            make.bottom.equalTo(sizeChatButton.snp.bottom)
            make.centerY.equalTo(sizeChatButton.snp.centerY)
        }
        sizeTitle.text = STLLocalizedString_("size")
        sizeTitle.font = UIFont.boldSystemFont(ofSize: 14)
        
        let pleaseSelectSize = UILabel()
        pleaseSelectSize.text = STLLocalizedString_("selectSize")
        pleaseSelectSize.font = UIFont.systemFont(ofSize: 14)
        pleaseSelectSize.textColor = OSSVThemesColors.col_B62B21()
        sizeContianer.addSubview(pleaseSelectSize)
        self.pleaseSelectSizeLbl = pleaseSelectSize
        pleaseSelectSize.snp.makeConstraints { make in
            make.leading.equalTo(0)
            make.top.equalTo(sizeCodeCollect.snp.bottom)
            make.height.equalTo(28)
        }
        
        
        let sizeCollect = createCollectionView(parent: sizeContianer)
        self.sizeCollectView = sizeCollect
        sizeCollect.snp.makeConstraints { make in
            make.leading.equalTo(0)
            make.trailing.equalTo(0)
            make.top.equalTo(pleaseSelectSize.snp.bottom).offset(0)
            make.height.equalTo(43)
        }
        sizeAdapter.collectionView = sizeCollect
        sizeAdapter.dataSource = self
        
        self.colorContainer = colorContianer
        self.sizeContainer = sizeContianer
        
    }
    
    func createCollectionView(parent:UIView)->UICollectionView{
        let layout = HorizontalCollectionFlowLauout()
        layout.scrollDirection = .horizontal
        layout.sectionHeadersPinToVisibleBounds = false
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 1)
        collectionView.backgroundColor = UIColor.clear
        parent.addSubview(collectionView)
        return collectionView
    }
}

extension ColorSizePickView:ListAdapterDataSource{
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        if listAdapter == self.colorAdapter{
            return colorData as [ListDiffable]
        }
        
        switch listAdapter{
        case self.colorAdapter:
            return colorData as [ListDiffable]
        case self.sizeCodeAdapter:
            return sizeData as [ListDiffable]
        case self.sizeAdapter:
            return sizeData as [ListDiffable]
        default:
            return []
        }
        
       
        
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        
        switch listAdapter{
        case self.colorAdapter:
            let controller = ColorSectionController()
            controller.goodIdPub = colorGoodIdPub
            return controller
        case self.sizeCodeAdapter:
            let controller = SizeCodeSectionController()
            controller.sizeCodeIndex = sizeCodeIndex
            return controller
        case self.sizeAdapter:
            let controller = SizeSectionController()
            controller.sizeCodeIndex = sizeCodeIndex
            controller.goodIdPub = sizeGoodIdPub
            controller.firstIntoDetail = firstIntoDetail
            controller.updateSizeTipPub = updateSizeTipPub
            return controller
        default:
            return ListSectionController()
        }
        
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        nil
    }
    
    
    override func updateConstraints(){
        super.updateConstraints()
    }
    
}
