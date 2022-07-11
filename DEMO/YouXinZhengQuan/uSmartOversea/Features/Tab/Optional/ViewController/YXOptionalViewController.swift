//
//  YXOptionalViewController.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/12/16.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit
class YXOptionalViewController: YXHKViewController, ViewModelBased {
    var viewModel: YXOptionalViewModel!
    var bannerShowed = false
    
    lazy var headerView: UIView = {
        let view = UIView()
        return view
    }()
    var bannerViewCloseBtn: UIButton?

    var bannerView: YXOptionalBannerView?
    var bannerList: [Banner] = []
    var newBannerList: [BannerList] = []
    
    private var isCardBannerIsClose : Bool{
        set{
            let mmkv = MMKV.default()
            mmkv.set(newValue, forKey: YXUserManager.YXCardBannerIsClose)
        }
        get{
            let mmkv = MMKV.default()
            return mmkv.bool(forKey: YXUserManager.YXCardBannerIsClose)
        }
    }
    
    lazy var editButton: UIButton = {
        let iamge = UIImage(named: "optional_setting") ?? UIImage()
        let button = UIButton.init(type: .custom, image: iamge, target: self, action: nil)//UIBarButtonItem.qmui_item(with: UIImage(named: "optional_setting") ?? UIImage(), target: self, action: nil)
//        button.setImage(UIImage(named: "optional_setting"), for: .normal)
        button?.rx.tap.subscribe(onNext: { [weak self] () in
            guard let `self` = self else { return }

            if YXUserManager.isLogin() {
                let vm = YXGroupManageViewModel()

                let vc = YXGroupManageViewController.instantiate(withViewModel: vm, andServices: self.viewModel.services as! YXGroupManageViewModel.Services, andNavigator: self.viewModel.navigator)
                self.bottomSheet.titleLabel.text = YXLanguageUtility.kLang(key: "group_pop_title")
                self.bottomSheet.showViewController(vc: vc)

            } else {
                let context = YXNavigatable(viewModel: YXLoginViewModel(callBack:nil, vc: nil))
                self.viewModel.navigator.push(YXModulePaths.defaultLogin.url, context: context)
            }

            
        }).disposed(by: disposeBag)
        
        return button!
    }()
    
    lazy var bottomSheet: YXBottomSheetViewTool = {
        let sheet = YXBottomSheetViewTool()
        sheet.rightButton.isHidden = true
        return sheet
    }()
    
    lazy var searchButton: UIButton = {
        let iamge = UIImage(named: "market_search") ?? UIImage()
        let button = UIButton.init(type: .custom, image: iamge, target: self, action: nil)//UIBarButtonItem.qmui_item(with: UIImage(named: "market_search") ?? UIImage(), target: self, action: nil)
        button?.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            self.viewModel.navigator.present(YXModulePaths.search.url, animated: false)
        }.disposed(by: self.disposeBag)
        return button!
    }()
    
    lazy var tabView: YXTabView = {
        let tabLayout = YXTabLayout.default()
        tabLayout.lineHidden = false
        tabLayout.lrMargin = 4
        tabLayout.tabMargin = 0
        tabLayout.tabPadding = 8
        tabLayout.lineHeight = 4
        tabLayout.leftAlign = true
        tabLayout.lineCornerRadius = 2
        tabLayout.lineColor = QMUITheme().mainThemeColor()
        tabLayout.lineWidth = 16
        tabLayout.titleFont = .systemFont(ofSize: 16)
        tabLayout.titleSelectedFont = .systemFont(ofSize: 22, weight: .medium)
        tabLayout.titleColor = QMUITheme().textColorLevel2()
        tabLayout.titleSelectedColor = QMUITheme().textColorLevel1()
        tabLayout.isGradientTail = true
        tabLayout.gradientTailColor = QMUITheme().foregroundColor()
        let tabView = YXTabView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: 44), with: tabLayout)
        tabView.pageView = pageView;
        tabView.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        
        return tabView
    }()
    
    lazy var pageView: YXPageView = {
        let pageView = YXPageView(frame: view.bounds)
        pageView.parentViewController = self
        return pageView
    }()
    
    lazy var customRightBarbuttonView: UIView = {
        let view = UIView()
        view.addSubview(editButton)
        view.addSubview(searchButton)
        let array = [editButton, searchButton]
        array.snp.makeConstraints { make in
            make.width.height.equalTo(35)
            make.top.bottom.equalToSuperview()
        }
        
        array.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
        return view
    }()
    
     var adImageUrls: [String]?
     var adTexts: [String]?
     
     var adList: [YXAdListModel]?
     
    //自选顶部广告视图容器 存放轮播banner和卡券banner
     lazy var adView: UIView = {
         let view = UIView()
        view.backgroundColor = QMUITheme().foregroundColor()
//         view.layer.cornerRadius = 10
//         view.layer.qmui_maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
         

         view.addSubview(cycleScrollView)
        view.addSubview(freeCardAdvertisementView)

         cycleScrollView.snp.makeConstraints({ (make) in
             make.left.top.equalTo(view)
             make.height.equalTo(uniVerLength(76))
             make.right.equalTo(view).offset(20)
         })
        
        freeCardAdvertisementView.snp.makeConstraints({ (make) in
            make.left.top.right.equalTo(view)
            make.height.equalTo(kaquanBannerHeight)
        })
        
        let closeButton = UIButton.init(type: .custom)
        closeButton.setImage(UIImage.init(named: "icon_banner_close"), for: .normal)
        view.addSubview(closeButton)

        closeButton.snp.makeConstraints({ (make) in
            make.right.equalTo(view).offset(-8)
            make.top.equalTo(view).offset(8)
            make.height.equalTo(20)
            make.width.equalTo(20)
        })
        
        closeButton.rx.tap.asControlEvent().takeUntil(rx.deallocated).subscribe(onNext: { [weak self] (_) in
            UIView.animate(withDuration: 0.5, animations: {
                self?.adView.snp.updateConstraints({ (make) in
                    make.height.equalTo(0)
                })
                self?.adView.isHidden = true
                self?.view.layoutIfNeeded()
            }, completion: { (finished) in
               if finished {
                   self?.viewModel.closeOtherAd()
                   //self?.getBanner()
               }
            })
        }).disposed(by: disposeBag)
        self.bannerViewCloseBtn = closeButton
         return view
     }()
         
    //轮播banner视图
    lazy var cycleScrollView: YXImageBannerView = {
        let rect = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: uniVerLength(76))
        let banner = YXImageBannerView(frame: rect, delegate: self, placeholderImage: UIImage(named: "placeholder_4bi1"))!
        banner.autoScrollTimeInterval = 3
        return banner
    }()
    
    //卡券广告视图 优先级在轮播banner之上
    lazy var freeCardAdvertisementView:YXFreeCardAdvertisementView = {
        let view = YXFreeCardAdvertisementView.init()
        view.backgroundColor = QMUITheme().foregroundColor()
        view.clickCallBack = { [weak self] (isSelected) in
            if isSelected { //选中的话，卡券被收起，则显示"展开"
                self?.adView.snp.updateConstraints { make in
                    make.height.equalTo(40) //这里的40需要去看卡券view的布局。头部是40高
                }
                
                self?.freeCardAdvertisementView.snp.updateConstraints({ (make) in
                    make.height.equalTo(40)
                })
                
                self?.isCardBannerIsClose = true
                
            } else {
                self?.adView.snp.updateConstraints { make in
                    make.height.equalTo(kaquanBannerHeight) //整体是kaquanBannerHeight，需要修改的话进入YXFreeCardAdvertisementView修改
                }
                
                self?.freeCardAdvertisementView.snp.updateConstraints({ (make) in
                    make.height.equalTo(kaquanBannerHeight)
                })
                
                self?.isCardBannerIsClose = false

            }
            self?.view.layoutIfNeeded()
            self?.pageView.needLayout = true
            self?.pageView.reloadData()
        }
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        setupViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setTabbarVisibleIfNeed()
        YXSecuGroupManager.shareInstance().checkLatestTrade()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        YXSecuGroupManager.shareInstance().transactCheckHold()
        //检查Pop的弹窗状态
//        YXPopManager.shared.checkPopShowStatus(with: YXPopManager.showPageOptional, vc: self)
        //先请求优先级高的卡券banner,有数据的话不再需要请求轮播banner
        viewModel.loadfreeCardData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        shadowScrollView.cancelTask()
    }
    
    
    func setupUI() {
        
        navigationItem.titleView = tabView
        let rightbarItem = UIBarButtonItem.init(customView: customRightBarbuttonView)
        navigationItem.rightBarButtonItem = rightbarItem
        
        view.addSubview(adView)
        view.addSubview(pageView)
        view.addSubview(declarationDragView)
                
        pageView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.adView.snp.bottom)
        }
        
        adView.isHidden = true
        adView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(0)
        }
        
        if YXToolUtility.needFinishQuoteNotify() {
            declarationDragView.isHidden = false
        } else {
            declarationDragView.isHidden = true
        }
    }
    
    func setupViewModel() {
        viewModel.titles.distinctUntilChanged().asObservable().bind(to: tabView.rx.titles).disposed(by: disposeBag)
        viewModel.viewControllers.distinctUntilChanged().asObservable().bind(to: pageView.rx.viewControllers).disposed(by: disposeBag)
        
        viewModel.adListRelay.asDriver().skip(1).drive(onNext: { [weak self] (adList) in
            if adList.count > 0 {
                self?.newBannerList = adList
                
                self?.cycleScrollView.isHidden = false
                self?.adView.snp.updateConstraints { make in
                    make.height.equalTo(uniVerLength(76))
                }
                self?.adView.isHidden = false


                var adImageUrls = [String]()
                let adTexts = [String]()
                adList.forEach({ (model) in
                    adImageUrls.append(model.pictureURL ?? "")
                })
                self?.adImageUrls = adImageUrls
                self?.adTexts = adTexts
                self?.cycleScrollView.imageURLStringsGroup = adImageUrls
                self?.cycleScrollView.titlesGroup = adTexts

            } else {
                self?.cycleScrollView.isHidden = true
                self?.adView.isHidden = true
                self?.adView.snp.updateConstraints { make in
                    make.height.equalTo(0)
                }
                //self?.getBanner()
            }

        }).disposed(by: disposeBag)

        viewModel.freeCardListRelay.asDriver().skip(1).drive(onNext: { [weak self] (freeCardModel) in
            if freeCardModel?.list.count ?? 0 > 0 {
                //卡券banner没有关闭按钮
                self?.bannerViewCloseBtn?.isHidden = true
                self?.cycleScrollView.isHidden = true
                self?.adView.isHidden = false
                self?.freeCardAdvertisementView.isHidden = false
                self?.freeCardAdvertisementView.model = freeCardModel
                
                let (sameDay,_) = YXUserManager.isTheSameDay(with: YXUserManager.YXCardBannerDateCach)
                if sameDay == false { //需求是:每天记录用户的点击收起还是展开，第二天的时候又自动展开
                    self?.freeCardAdvertisementView.headView.preadOutBtn.isSelected = false
                    self?.isCardBannerIsClose = false
                    self?.adView.snp.updateConstraints { make in
                        make.height.equalTo(kaquanBannerHeight)
                    }
                    self?.freeCardAdvertisementView.snp.updateConstraints({ (make) in
                        make.height.equalTo(kaquanBannerHeight)
                    })
                } else {
                    self?.freeCardAdvertisementView.headView.preadOutBtn.isSelected = self?.isCardBannerIsClose ?? true
                    if self?.freeCardAdvertisementView.headView.preadOutBtn.isSelected == true {
                        self?.freeCardAdvertisementView.collectionView.isHidden = true
                        self?.adView.snp.updateConstraints { make in
                            make.height.equalTo(40)
                        }
                        self?.freeCardAdvertisementView.snp.updateConstraints({ (make) in
                            make.height.equalTo(40)
                        })
                    } else {
                        self?.freeCardAdvertisementView.collectionView.isHidden = false
                        self?.adView.snp.updateConstraints { make in
                            make.height.equalTo(kaquanBannerHeight)
                        }
                        self?.freeCardAdvertisementView.snp.updateConstraints({ (make) in
                            make.height.equalTo(kaquanBannerHeight)
                        })
                    }
                }
                self?.view.layoutIfNeeded()
                self?.pageView.needLayout = true
                self?.pageView.reloadData()
                
            } else {
                self?.bannerViewCloseBtn?.isHidden = false
                self?.freeCardAdvertisementView.isHidden = true
                self?.adView.snp.updateConstraints { make in
                    make.height.equalTo(0)
                }
                self?.adView.isHidden = true
                self?.viewModel.requestOptionalOtherAdData()
            }
            
        }).disposed(by: disposeBag)
        
    }

//    lazy var shadowView: YXOptionalHotStockShadowView = {
//
//        let view = YXOptionalHotStockShadowView.init(contentView: shadowScrollView, headerView: UIView())
//        view.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: self.view.frame.height - YXConstant.tabBarHeight())
//        view.delegate = shadowScrollView
//        view.isHidden = true
//        return view
//    }()

    lazy var shadowScrollView: YXOptionalHotStockShadowScrollView = {
        let view = YXOptionalHotStockShadowScrollView()
        view.isHidden = true
        return view
    }()
    
    lazy var declarationDragView: OptionalDeclarationDragView = {
        let dragHeaderView = OptionalDeclarationHeaderView()
        dragHeaderView.backgroundColor = QMUITheme().foregroundColor()
        let view = OptionalDeclarationDragView.init(contentView: dragScrollView, headerView: dragHeaderView)
        view.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: self.view.frame.height - YXConstant.navBarHeight() - YXConstant.navBarPadding())
        view.delegate = dragScrollView
        view.didDisplayAction = { [weak self] state in
            guard let `self` = self else { return }
            if state == .minDisplay {
                self.dragScrollView.updateUI(hidden: false)
            } else {
                self.dragScrollView.updateUI(hidden: true)
            }
        }
        view.isHidden = true
        return view
    }()

    lazy var dragScrollView: OptionalDeclarationScrollView = {
        let view = OptionalDeclarationScrollView()
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.declarationGoBlock = { [weak self] in
            guard let `self` = self else { return }
            self.declarationDragView.displayMax()
        }
        self.addChild(view.dragVC)
        return view
    }()
    
    
    func getBanner() {
        if bannerView?.superview != nil {
            return
        }
        if bannerShowed == false {
            let requestModel = YXOptionalBannerRequestModel()
            let request = YXRequest(request: requestModel)
            request.startWithBlock(success: { [weak self] (responseModel) in
                guard let strongSelf = self else { return }
                if let response = responseModel as? YXOptionalBannerResponseModel {
                    if response.code == .success {
                        strongSelf.bannerList = []
                        var imageURLs: [String] = []
                        response.bannerList.forEach { (banner) in
                            if let item = banner as? Banner {
                                if let url = item.pictureUrl {
                                    imageURLs.append(url)
                                    strongSelf.bannerList.append(item)
                                }
                            }
                        }
                        strongSelf.bannerShowed = true
                        strongSelf.showBanner(with: imageURLs)

                    } else {
                        self?.hideBanner()
                    }
                }
            }, failure: { [weak self] (request) in
                self?.hideBanner()
            })
        } else {
            hideBanner()
        }
    }
    
    func showBanner(with imageUrls: [String]) {
        if imageUrls.count > 0 {
            if let bannerView = self.bannerView {
                bannerView.update(withImageURLs: imageUrls)
            } else {
                let bannerView = YXOptionalBannerView(frame: .zero, imageURLStringsGroup: imageUrls)
                bannerView.closeBlcok = { [weak self] in
                    guard let strongSelf = self else { return }

                    strongSelf.hideBanner()
                }
                bannerView.clickBannerBlock = { [weak self] (index) in
                    guard let strongSelf = self else { return }
                    let banner = strongSelf.bannerList[index]
                    let bannerLinst = BannerList(bannerID: banner.bannerID,
                                                 adType: banner.adType,
                                                 adPos: banner.adPos,
                                                 pictureURL: banner.pictureUrl,
                                                 originJumpURL: banner.jumpUrl,
                                                 newsID: banner.newsId,
                                                 bannerTitle: banner.title,
                                                 tag: banner.tag,
                                                 jumpType: YXInfomationType(rawValue: banner.newsJumpType)?.converNewType()
                                                )
                    YXBannerManager.goto(withBanner: bannerLinst, navigator: strongSelf.viewModel.navigator)
                }
                
                self.view.insertSubview(bannerView, belowSubview: adView)
                bannerView.snp.makeConstraints { (make) in
                    make.left.right.bottom.equalTo(pageView)
                    make.height.equalTo(pageView.width / 5)
                }
                
                self.bannerView = bannerView
            }

        } else {
            hideBanner()
        }
    }
    
    func hideBanner() {
        bannerView?.removeFromSuperview()
        bannerView = nil
//        addStareShadowView()
    }
    
    override func didInitialize() {
        super.didInitialize()        
    }
}

extension YXOptionalViewController: YXCycleScrollViewDelegate {
    func cycleScrollView(_ cycleScrollView: YXCycleScrollView!, didSelectItemAt index: Int) {
        if index < viewModel.adListRelay.value.count {
            let model = viewModel.adListRelay.value[index]
//            let type = model.jumpType ?? 0
            let url = model.jumpURL ?? ""
            if url.count > 0 {
                YXBannerManager.goto(withBanner: model, navigator: self.viewModel.navigator)
            }
        }
    }
}



