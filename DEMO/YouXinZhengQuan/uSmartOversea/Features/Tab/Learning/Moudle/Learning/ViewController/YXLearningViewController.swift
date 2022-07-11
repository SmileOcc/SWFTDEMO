//
//  YXLearningViewController.swift
//  uSmartOversea
//
//  Created by usmart on 2021/12/15.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

//学习模块首页
class YXLearningViewController: YXHKViewController, ViewModelBased {
    var viewModel: YXLearningViewModel!
    public static let subPageTabFollowBtn        = "subPageTabFollowBtn"       //子页面点击了关注
    var networkingHUD: YXProgressHUD = YXProgressHUD()

    //MARK: 懒加载
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()//hkLayout
//        layout.estimatedItemSize = CGSize(width: YXConstant.screenWidth, height: 64)
        
        let collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        collectionView.backgroundColor = QMUITheme().foregroundColor()
        collectionView.showsVerticalScrollIndicator = false;
        collectionView.showsHorizontalScrollIndicator = false;
        
        let allCellClass: [AnyClass] = [YXLearningChatRoomCell.self,
                                        YXLearningMasterCell.self,
                                        YXLearningCourseCell.self,
                                        YXLearningAskCell.self]
        allCellClass.forEach { (cellClass) in
            collectionView.register(cellClass, forCellWithReuseIdentifier: NSStringFromClass(cellClass))
        }
        
        let allHeaderViewClass: [AnyClass] = [YXLearningCommonHeaderReusableView.self]
        allHeaderViewClass.forEach { (headerClass) in
            collectionView.register(headerClass, forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(headerClass))
        }
        
        let allFooterViewClass: [AnyClass] = [YXLearningMasterFooterReusableView.self,
                                              YXLearningAskLineFooterReusableView.self]
        allFooterViewClass.forEach { (footClass) in
            collectionView.register(footClass, forSupplementaryViewOfKind:UICollectionView.elementKindSectionFooter, withReuseIdentifier: NSStringFromClass(footClass))
        }

        
        let refreshHeader = YXRefreshHeader()
        refreshHeader.refreshingBlock = { [weak self] in
            self?.viewModel.masterPageNum = 1
            self?.viewModel.refreshMasterPageNum = 1
            self?.requestData()
        }
        collectionView.mj_header = refreshHeader
        
        return collectionView
    }()
    
    //MARK: 生命周期
    override func didInitialize() {
        super.didInitialize()
        hidesBottomBarWhenPushed = false
    }
    
    override var pageName: String {
          return "Learning"
    }
    
    override func viewDidLoad() {
        titleView?.titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        titleView?.titleLabel.textColor = QMUITheme().textColorLevel1()
        titleView?.title = YXLanguageUtility.kLang(key: "tab_learning")
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.bindViewModel()
        self.networkingHUD.showLoading("", in: self.view)
        self.requestData()
    }
    
    func bindViewModel() {
        //更新用户信息 通知
        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: YXLearningViewController.subPageTabFollowBtn))
            .takeUntil(self.rx.deallocated) //页面销毁自动移除通知监听
            .subscribe(onNext: { [weak self] noti in
                guard let strongSelf = self else { return }
                strongSelf.requestData()
            })
        
        NotificationCenter.default.rx.notification(Notification.Name(rawValue: "onCommandSetAskStockLocation"), object: nil).subscribe (onNext: { [weak self] noti in
                guard let `self` = self else { return }
            if let regionNo = noti.object {
                self.viewModel.regionNo = regionNo as! Int
                self.requestData()
            }
        }).disposed(by: disposeBag)
        
        _ = NotificationCenter.default.rx
            .notification(NSNotification.Name.init(YXUserManager.notiSkinChange))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: {[weak self] _ in
                guard let strongSelf = self else { return }
                self?.collectionView.reloadData()
            })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setTabbarVisibleIfNeed()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.mj_header.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        collectionView.mj_header.isHidden = true
    }
}

extension YXLearningViewController {
    func requestData() {
        self.viewModel.resultList.drive { [weak self] value in
            let (chatRoomres, masterRes) = value
            self?.networkingHUD.hideHud()
            self?.collectionView.mj_header.endRefreshing()
            if let list = chatRoomres?.chatGroupList { //chatroom和ask返回
                self?.viewModel.chatRoomList = list
            }
            if let list = chatRoomres?.activityBannerList {
                self?.viewModel.courseList = list
            }
            if let list = chatRoomres?.askRecommendList { //文章返回
                self?.viewModel.askList = list
            }
            if let r = masterRes { //master的返回
                self?.viewModel.masterTotalPage = r.pageCount
                self?.viewModel.masterList = r.items
            }
            
//            self?.viewModel.chatRoomList = res?.askRecommendList
            self?.viewModel.dataSource = self?.viewModel.creatDataSource()
            self?.collectionView.reloadData()
        }.disposed(by: disposeBag)
        
        
    }
}

//MARK: UICollectionViewDataSource & UICollectionViewDelegate
extension YXLearningViewController: UICollectionViewDataSource,UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionType = viewModel.dataSource[section]["sectionType"] as! YXLearningSectionType
        switch sectionType {
            //使用chatRoom、master等YXLearningSectionType类型枚举，方便界面扩展，将来此模块还需要继续跌打时候，可以增加枚举值扩充界面
        case .chatRoom:
            return 1
        case .master:
            if let items = viewModel.dataSource[section]["list"] as? Array<Any> {
                return (items as Array<Any>).count
            }
        case .course:
            return 1
        case .ask:
            if let items = viewModel.dataSource[section]["list"] as? Array<Any> {
                return (items as Array<Any>).count
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionType = viewModel.dataSource[indexPath.section]["sectionType"] as! YXLearningSectionType
        let list = viewModel.dataSource[indexPath.section]["list"]

        switch sectionType {
        case .chatRoom:
            let learningChatRoomCell: YXLearningChatRoomCell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXLearningChatRoomCell.self), for: indexPath) as! YXLearningChatRoomCell

            learningChatRoomCell.dataSource = list as! [YXRecommendChatResModel]
            return learningChatRoomCell
        case .master:
            let learningMasterCell: YXLearningMasterCell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXLearningMasterCell.self), for: indexPath) as! YXLearningMasterCell
            
            let items = list as! Array<YXSpecialKOLItem>
            let item = items[indexPath.item]
//            learningMasterCell.imageView.image = UIImage(named: "icon")
//            learningMasterCell.titleLabel.text = "master"
            learningMasterCell.followBtn.setBackgroundImage(UIImage.init(color: QMUITheme().mainThemeColor()), for: .normal)
            learningMasterCell.followBtn.setBackgroundImage(UIImage.init(color:  UIColor.themeColor(withNormalHex: "#F8F9FC", andDarkColor: "#212129")), for: .selected)
            
            
            learningMasterCell.data = item
            
            let followAction = PublishSubject<(Int, String, Int?)>()
            
            followAction.asDriver(onErrorJustReturn: (0, "", nil)).flatMapLatest {[weak self] value in
                return self?.viewModel.follow(state: value.0, subscriptId: value.1, index: value.2) ?? Driver.empty()
            }.drive (onNext:{[weak self] (res, index) in
//                let format = "xxxxxxxxxxxxxxxxx点击" + String(format: "第%d行", (index ?? 999999))
//                print(format)
                if let res = res {
                    if res.code == .success {
                        let item = self?.viewModel.masterList?[index!]
                        item?.isFollowed = !(item!.isFollowed)
                        self?.viewModel.dataSource = self?.viewModel.creatDataSource()
                        self?.collectionView.reloadData()
                    } else {
                        YXProgressHUD.showError(res.msg)
                    }
                }

            }).disposed(by: learningMasterCell.disposeBag)
            
            
            learningMasterCell.followBtn.rx.tap.asDriver().drive (onNext: { [weak self] in
                if learningMasterCell.followBtn.isSelected {
                    YXAlertTool.commonAlert(title: "",
                                            message: YXLanguageUtility.kLang(key: "nbb_diolog_unfollow_msg"),
                                            leftTitle: YXLanguageUtility.kLang(key: "mine_no"),
                                            rightTitle: YXLanguageUtility.kLang(key: "mine_yes")) { [weak self] in
                        guard let `self` = self else { return }

                    } rightBlock: {
                        YXToolUtility.handleBusinessWithLogin {[weak self] in
                            followAction.onNext((1, item.subscriptId ?? "", indexPath.item))
                        }
                    }
                } else {
                    YXToolUtility.handleBusinessWithLogin {[weak self] in
                        followAction.onNext((0, item.subscriptId ?? "", indexPath.item))
                    }
                }
            }).disposed(by: learningMasterCell.disposeBag)
            
            return learningMasterCell

        case .course:
            let learningCourseCell: YXLearningCourseCell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXLearningCourseCell.self), for: indexPath) as! YXLearningCourseCell
            learningCourseCell.datas = list as! [YXActivityBannerModel]
            return learningCourseCell

        case .ask:
            let learningAskCell: YXLearningAskCell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXLearningAskCell.self), for: indexPath) as! YXLearningAskCell
            let items = list as! Array<YXRecommendAskResModel>
            let item = items[indexPath.item]
            learningAskCell.data = item
            learningAskCell.btn.rx.tap.subscribe { [weak self] rec in
                if let market = item.askStockInfoDTO?.market, let symbol = item.askStockInfoDTO?.symbol {
                    let input = YXStockInputModel()
                    input.market = market
                    input.symbol = symbol
                    self?.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [input], "selectIndex" : 0])
                }
            }.disposed(by: learningAskCell.disposeBag)
            
            return learningAskCell

        }
        return UICollectionViewCell()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView = UICollectionReusableView()
        if kind == UICollectionView.elementKindSectionFooter {
            let sectionType = viewModel.dataSource[indexPath.section]["sectionType"] as! YXLearningSectionType
            switch sectionType {
            case .master:
               let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: NSStringFromClass(YXLearningMasterFooterReusableView.self), for: indexPath) as! YXLearningMasterFooterReusableView
                
                footer.refreshbutton.rx.tap.do(onNext:{ [weak self] in
                     let anim = CABasicAnimation(keyPath: "transform.rotation")
                     anim.toValue = 2 * Double.pi
                     anim.duration = 0.5
                     anim.repeatCount = 1
                     anim.isRemovedOnCompletion = true
                    footer.refreshbutton.imageView?.layer.add(anim,forKey: "rotation")
                }).map { [weak self]_ in
                     guard let `self` = self else { return 1 }
                     if self.viewModel.refreshMasterPageNum < self.viewModel.masterTotalPage {
                         self.viewModel.refreshMasterPageNum += 1
                     }else {
                         self.viewModel.refreshMasterPageNum = 1
                     }
                     return self.viewModel.refreshMasterPageNum
                }.flatMapLatest ({ pageNum in
                    return YXSpecialAPI.getSgKolRecommendList(pageNum: pageNum, pageSize: self.viewModel.masterPageSize).request().map { res -> YXSpecialKOLListResModel? in
                     let model = YXSpecialKOLListResModel.yy_model(withJSON: res?.data ?? [:])
                     return model
                 }.asDriver(onErrorJustReturn: nil)
                }).subscribe { [weak self] res in
                 if let r = res { //master的返回
                     self?.viewModel.masterList = r.items
                     self?.viewModel.dataSource = self?.viewModel.creatDataSource()
                     DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                         self?.collectionView.reloadData()
                     }
                 }
                } onError: { error in
                 
                }.disposed(by:footer.disposeBag)
                
                reusableView = footer
            case .ask:
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: NSStringFromClass(YXLearningAskLineFooterReusableView.self), for: indexPath) as! YXLearningAskLineFooterReusableView
                reusableView = footer

            default:
                reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: NSStringFromClass(UICollectionReusableView.self), for: indexPath)
            }
            
            return reusableView
            
        } else if kind == UICollectionView.elementKindSectionHeader {
            let sectionType = viewModel.dataSource[indexPath.section]["sectionType"] as! YXLearningSectionType
            reusableView = commonHeaderView(collectionView: collectionView, indexPath: indexPath, sectionType: sectionType)
        }
        return reusableView
    }
    
    func commonHeaderView(collectionView: UICollectionView, indexPath: IndexPath, sectionType: YXLearningSectionType) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(YXLearningCommonHeaderReusableView.self), for: indexPath) as! YXLearningCommonHeaderReusableView
        headerView.title = sectionType.sectionName
        headerView.hideRedDot = true
        headerView.icon = nil
        headerView.arrowView.isHidden = false
        headerView.hideChangeBtn = true
        headerView.hideRightTitleBtn = true

              //sectionHead点击事件
        switch sectionType {
        case .chatRoom:
            headerView.button.rx.tap.subscribe {[weak self] _ in
                self?.trackViewClickEvent(name: "Chats_Tab")
                YXToolUtility.handleBusinessWithLogin {[weak self] in
                    let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.chatList()]
//                    NavigatorServices.shareInstance.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                    self?.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                }
            }.disposed(by:headerView.disposeBag)
            break
        case .master:
            headerView.hideRightTitleBtn = false
            headerView.rightTitleLabel.text = YXLanguageUtility.kLang(key: "nbb_tab_myfollow")
          
            
            
            headerView.button.rx.tap.subscribe {[weak self] _ in
                self?.trackViewClickEvent(name: "My following_Tab")
                YXToolUtility.handleBusinessWithLogin {[weak self] in
                    let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.myALLSubscribeKOL()]
//                    NavigatorServices.shareInstance.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                    self?.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                }
            }.disposed(by:headerView.disposeBag)
            
        case .course:
            headerView.button.rx.tap.subscribe {[weak self] _ in
                self?.trackViewClickEvent(name: "Course_Tab")
                self?.viewModel.navigator.push(YXModulePaths.courseList.url, context: nil)
                
            }.disposed(by:headerView.disposeBag)
        case .ask:
            headerView.button.rx.tap.subscribe {[weak self] _ in
                self?.trackViewClickEvent(name: "Ask_Tab")
//                YXToolUtility.handleBusinessWithLogin {[weak self] in
//                    let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.askList()]
////                    NavigatorServices.shareInstance.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
//                    self?.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
//                }
                let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.askList()]
//                    NavigatorServices.shareInstance.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                self?.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            }.disposed(by:headerView.disposeBag)
        default:
            break
        }
        
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sectionType = viewModel.dataSource[indexPath.section]["sectionType"] as! YXLearningSectionType
        let list = viewModel.dataSource[indexPath.section]["list"]
        switch sectionType {
        
        case .chatRoom:
            break
        case .master:
            let items = list as! Array<YXSpecialKOLItem>
            let item = items[indexPath.row]
            if let id = item.subscriptId {
                YXToolUtility.handleBusinessWithLogin { [weak self] in
                    self?.viewModel.navigator.push(YXModulePaths.kolHome.url,context:["kolId":id])
                }
            }
            break
        case .course:
            break
        case .ask:
            let items = list as! Array<YXRecommendAskResModel>
            let item = items[indexPath.item]
//            YXToolUtility.handleBusinessWithLogin { [weak self] in
//                let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.askDetail(questionId: item.questionId ?? "")]
//                NavigatorServices.shareInstance.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
//            }
            let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.askDetail(questionId: item.questionId ?? "")]
            NavigatorServices.shareInstance.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            
            break
        default:
            break
        }
        
    }
}

//MARK:布局
extension YXLearningViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionType = viewModel.dataSource[indexPath.section]["sectionType"] as! YXLearningSectionType
        let list = viewModel.dataSource[indexPath.section]["list"]

        var size: CGSize = CGSize.zero
        let collectionViewWidth = collectionView.frame.size.width
        switch sectionType {
        case .chatRoom:
            let items = list as! [YXRecommendChatResModel]
            if items.count == 0 {
                size = CGSize.init(width: collectionViewWidth, height: 1)
            } else {
                size = CGSize.init(width: collectionViewWidth, height: 115)
            }
        case .master:
            // 解决当UICollectionViewCell的size不为整数时，UICollectionViewFlowLayout在布局计算时，可能会调整Cell的frame.origin，使Cell按照最小物理像素（渲染像素）对齐，导致出现缝隙
            // https://blog.csdn.net/ayuapp/article/details/80360745
//            let width = collectionViewWidth/5.0
//            if indexPath.item == 0 {
//                width = collectionViewWidth - floor(width)*3
//            }else {
//                width = floor(width)
//            }
            size = CGSize.init(width: collectionViewWidth, height: 64)
        case .course:
            let items = list as! [YXActivityBannerModel]
            if items.count == 0 {
                size = CGSize.init(width: collectionViewWidth, height: 1)
            } else {
                size = CGSize.init(width: collectionViewWidth, height: 138)
            }
        case .ask:
            let items = list as! [YXRecommendAskResModel]
            if items[indexPath.item] != nil {
                let h = self.getCellHeight(item: items[indexPath.item])
                return CGSize.init(width: collectionViewWidth, height: h)
            }
            
        default:
            size = CGSize.zero
        }
        
        return size
    }
    
    func getCellHeight(item:YXRecommendAskResModel?) -> CGFloat {
        guard let model = item else {
            return 140
        }
//        let questionDetailStr = (item?.questionDetail ?? "") as NSString
        let questionDetailStr = (item?.questionDetail ?? "") as NSString
        var replyDetailStr = "" as NSString
        if let reply = item?.replyDTOList?.first {
            replyDetailStr = (reply.replyDetail ?? "") as NSString
        }
        
        let questionDetailStrHeight = questionDetailStr.height(for: UIFont.systemFont(ofSize: 16, weight: .medium), width: 303)
        let replyDetailStrHeight = replyDetailStr.height(for: UIFont.systemFont(ofSize: 14, weight: .regular), width: 303)
        var askStockInfoDTOHeight = item?.askStockInfoDTO?.stockName?.count ?? 0 > 0 ? 20 : 0
        
        if questionDetailStrHeight >= 50 {
            if replyDetailStrHeight > 20 {
                return 140 + 30 + 20
            } else {
                return 140 + 30
            }
        } else {
            if replyDetailStrHeight > 20 {
                return 140 + 20
            } else {
                return 140
            }
        }
    }
    
    
    func fixedCollectionCellSize(size: CGSize) -> CGSize {
        let scale = UIScreen.main.scale
        return CGSize.init(width: round(scale * size.width) / scale, height: round(scale * size.height) / scale)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let sectionType = viewModel.dataSource[section]["sectionType"] as! YXLearningSectionType
        let list = viewModel.dataSource[section]["list"]

        switch sectionType {
        case .chatRoom:
            return UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        case .master:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        case .course:
            return UIEdgeInsets(top: 0, left: 0, bottom: 32, right: 0)
        case .ask:
            return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        default:
            return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    // 行间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let sectionType = viewModel.dataSource[section]["sectionType"] as! YXLearningSectionType
        switch sectionType {
        default:
            return 0
        }
    }
    
    // 列间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let sectionType = viewModel.dataSource[section]["sectionType"] as! YXLearningSectionType
        switch sectionType {
        default:
            return 0
        }
    }
    
    // header高度
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let sectionType = viewModel.dataSource[section]["sectionType"] as! YXLearningSectionType
        return CGSize.init(width: collectionView.frame.size.width, height: 40)

    }
    
    // footer高度
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let sectionType = viewModel.dataSource[section]["sectionType"] as! YXLearningSectionType
        switch sectionType {
        case .master:
            if let items = viewModel.dataSource[section]["list"] as? Array<Any> {
                if items.count > 0 {
                    return CGSize.init(width: collectionView.frame.size.width, height: 66)
                }
            }
            return CGSize.zero
        case .ask:
            if let items = viewModel.dataSource[section]["list"] as? Array<Any> {
                if items.count > 0 {
                    return CGSize.init(width: collectionView.frame.size.width, height: 41)
                }
            }
            return CGSize.zero
        default:
            return CGSize.zero
        }
    }
}


//MARK: 学习模块各section的枚举值
enum YXLearningSectionType {
    case chatRoom
    case master
    case course
    case ask
    
    var sectionName: String {
        switch self {
        case .chatRoom:
            return YXLanguageUtility.kLang(key: "nbb_title_chatroom")
        case .master:
            return YXLanguageUtility.kLang(key: "nbb_tab_master")
        case .course:
            return YXLanguageUtility.kLang(key: "nbb_course")
        case .ask:
            return YXLanguageUtility.kLang(key: "nbb_title_ask")
        }
    }
    
    var sectionAPICode: Int {
        switch self {
        case .chatRoom:
            return 100
        case .master:
            return 101
        case .course:
            return 102
        case .ask:
            return 103
        }
    }
}
