//
//  YXUserCenterViewController.swift
//  uSmartOversea
//
//  Created by mac on 2019/3/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MJRefresh

class YXUserCenterViewController: YXHKViewController, HUDViewModelBased {
    
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    var viewModel: YXUserCenterViewModel!
    
    
    var userHeaderHeight: CGFloat {
//        if YXUserManager.shared().userBanner?.dataList?.count ?? 0 > 0 {
//            return 80
//            return 60
//        }else {
//            return 80
//        }
        
//        return 88
//        if YXUserManager.isLogin() {
//            return 110
//        }else {
//            return 80
//        }
        if YXUserManager.isLogin() {
            return 76
        }else {
           return 60
        }
    }
    
    var imageBannerHeight: CGFloat {
        
        return uniVerLength(75)
    }
    
    var imageBannerWidth: CGFloat {
        
        return uniVerLength(345)
    }
    
    var headViewHeight: CGFloat {
        var height = userHeaderHeight
        if YXUserManager.shared().userBanner?.dataList?.count ?? 0 > 0 {
            height = userHeaderHeight + imageBannerHeight + 12
        }else {
            height =  userHeaderHeight
        }
        height += YXAccountLevelView.height
        return height
    }
    
    let oneViewCellID = "YXMineConfigOneColCell"
    
    
    var userHeaderView: YXUserCenterHeaderView = {
        let view = YXUserCenterHeaderView()
        return view
    }()
    
    lazy var accountTypeView:YXAccountLevelView = {
        let view = YXAccountLevelView.init(frame: .zero)
        return view
    }()
    
    var headView : UIView = {
        let view = UIView()
        return view
    }()
    
    
//    lazy var uerBannerView:YXMineBannerView = {
//        let view = YXMineBannerView.init(frame: .zero)
//        view.adSize = CGSize.init(width: self.imageBannerWidth, height: self.imageBannerHeight)
//        return view
//    }()
    
    //广告视图
    lazy var imageBannerView: YXImageBannerView = {
        let rect = CGRect.init(x: 0, y: 0, width: YXConstant.screenWidth-32, height:(YXConstant.screenWidth-32)*imageBannerHeight/imageBannerWidth)
        let banner = YXImageBannerView(frame: rect, delegate: self, placeholderImage: UIImage(named: "placeholder_4bi1"))!
//        banner.layer.cornerRadius = 4
        banner.clipsToBounds = true
        banner.autoScrollTimeInterval = 3
        
        let closeButton = UIButton.init(type: .custom)
        closeButton.setImage(UIImage.init(named: "icon_banner_close"), for: .normal)
        banner.addSubview(closeButton)

        closeButton.snp.makeConstraints({ (make) in
            make.right.equalTo(banner).offset(-8)
            make.top.equalTo(banner).offset(8)
            make.height.equalTo(20)
            make.width.equalTo(20)
        })
        
        closeButton.rx.tap.asControlEvent().takeUntil(rx.deallocated).subscribe(onNext: { [weak self] (_) in
            YXUserManager.shared().userBanner = nil
            UIView.animate(withDuration: 0.5, animations: {
                guard let `self` = self else { return }
                self.imageBannerView.snp.updateConstraints { make in
                    make.height.equalTo(0)
                }
                self.userHeaderView.snp.updateConstraints { make in
                    make.height.equalTo(self.userHeaderHeight)
                }
                self.headView.height = self.headViewHeight

//                self?.view.layoutIfNeeded()
                self.imageBannerView.isHidden = true
                self.tableView.reloadData()
                self.userHeaderView.refreshUI()
                self.updateHeaderView()
            }, completion: { (finished) in
               if finished {
                   self?.viewModel.closeOtherAd()
               }
            })
        }).disposed(by: disposeBag)
        
        return banner
    }()
    
    
    var tableView: UITableView = {
        
        let view = UITableView.init(frame: .zero, style: .plain)
        view.separatorStyle = .none
        return view
    }()
    
    override func didInitialize() {
        super.didInitialize()
        hidesBottomBarWhenPushed = false
    }
    override var pageName: String {
           return "Me"
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        bindViewModel()
        bindHUD()
        YXPopManager.shared.checkPop(with: YXPopManager.showPageUserCenter, vc:self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      //  headerRereshing()//进行头部更新
        //检查Pop的弹窗状态
        YXPopManager.shared.checkPopShowStatus(with: YXPopManager.showPageUserCenter, vc: self)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        headerRereshing()//进行头部更新
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)        
    }
    
    override func preferredNavigationBarHidden() -> Bool {
        return true
    }
    func initUI() {
        self.view.backgroundColor = QMUITheme().foregroundColor()
                
        view.addSubview(tableView)
        headView.addSubview(userHeaderView)
      //  headView.addSubview(uerBannerView)
        headView.addSubview(imageBannerView)
        headView.addSubview(accountTypeView)
        
        
        tableView.register(YXMineConfigOneColCell.self, forCellReuseIdentifier: oneViewCellID)

        tableView.mj_header = YXRefreshHeader.init(refreshingTarget: self, refreshingAction: #selector(headerRereshing))
        
        tableView.snp.remakeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(0)
            make.top.equalTo(self.view.safeArea.top)
        }

        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        
        headView.frame = CGRectFlatMake(0, 0, YXConstant.screenWidth, headViewHeight)
        userHeaderView.snp.makeConstraints { (make) in
            make.top.left.equalTo(0)
            make.width.equalToSuperview()
            make.height.equalTo(userHeaderHeight)
        }
        
        accountTypeView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(userHeaderView.snp.bottom)
            make.height.equalTo(0)
        }

//        uerBannerView.snp.makeConstraints { (make) in
//            make.top.equalTo(userHeaderView.snp.bottom)
//            make.width.equalToSuperview()
//            make.height.equalTo(0)
//        }
        
        imageBannerView.snp.makeConstraints { (make) in
            make.top.equalTo(accountTypeView.snp.bottom).offset(12)
           // make.width.equalToSuperview()
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(0)
        }
        
        tableView.tableHeaderView = headView

    }
    
    func bindViewModel() {
        //登陆
        _ = NotificationCenter.default.rx
            .notification(NSNotification.Name.init(YXUserManager.notiLogin))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: {[weak self] _ in
                self?.updateHeaderView()
                self?.viewModel.hasCheckMessage = false
            })
        //退出登陆
        _ = NotificationCenter.default.rx
            .notification(NSNotification.Name.init(YXUserManager.notiLoginOut))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: {[weak self] _ in
                self?.updateHeaderView()
                self?.viewModel.hasCheckMessage = false
            })
        
        //更新用户信息
        _ = NotificationCenter.default.rx
            .notification(NSNotification.Name.init(YXUserManager.notiUpdateUserInfo))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: {[weak self] _ in
                guard let `self` = self else { return }
                self.updateHeaderView()

//                if let list = YXUserManager.shared().userBanner?.bannerList {
//                    var arr = [String]()
//                    for model in list {
//                        arr.append(model.pictureURL ?? "")
//                    }
//                    self.imageBannerView.imageURLStringsGroup = arr
//                    self.tableView.reloadData()
//                }

            })
        
        _ = NotificationCenter.default.rx
            .notification(NSNotification.Name.init("goLogin"))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: {[weak self] _ in
                guard let strongSelf = self else { return }
                let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: nil, vc: strongSelf))
                strongSelf.viewModel.navigator.push(YXModulePaths.defaultLogin.url, context: context)
            })
        
        //MARK:headerView 的响应
        
        userHeaderView.loginClickCallBack = { [weak self] in
            self?.accountImgViewClick()
        }
        
        self.viewModel.accountTypeSubject.subscribe{ [weak self] accType in
            YXAccountLevelView.accountType = accType.element ?? .unkonw
            self?.accountTypeView.type = accType.element ?? .unkonw
            self?.updateHeaderView()
        }.disposed(by: disposeBag)
        
        accountTypeView.onClick = { type in
            self.trackViewClickEvent(name: "account center_tab")
            YXWebViewModel.pushToWebVC(type.jampUrl())
        }

      //  头像添加点击
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(accountImgViewClick))
        userHeaderView.iconView.addGestureRecognizer(singleTapGesture)
        userHeaderView.iconView.isUserInteractionEnabled = true

    }
    
    //头部更新
    @objc func headerRereshing() {
        if YXUserManager.isLogin() {
            //获取用户信息
            YXUserManager.getUserInfo { [weak self] in
                self?.tableView.mj_header?.endRefreshing()
            }
            

            YXUserManager.getUserBanner {[weak self] in
                self?.tableView.mj_header?.endRefreshing()
                self?.updateHeaderView() //更新头部视图
            }
            
            self.viewModel.getAccountType()
            
        }else {
            tableView.mj_header.endRefreshing()
            accountTypeView.type = .unkonw
            updateHeaderView()
            //获取用户banner  v1/query/banner_advertisement
            YXUserManager.getUserBanner {[weak self] in
                self?.tableView.mj_header?.endRefreshing()
                self?.updateHeaderView() //更新头部视图
            }
            

        }

        
//       let request: YXGlobalConfigAPI = .otherAdvertisement(YXOtherAdvertisementShowPage.activityOutBanner.rawValue)
//
//        self.viewModel.services.globalConfigService.request(request, response: self.viewModel.actCenterResponse).disposed(by: disposeBag)
        
        
      //  self.viewModel.services.userService.request(.queryCopyWriting, response: self.viewModel.wordResponse).disposed(by: disposeBag)
    }
    
    func updateHeaderView() {

        //更新头部视图
//        self.userHeaderView.updateView()

        imageBannerView.snp.updateConstraints { make in
            make.height.equalTo(YXUserManager.shared().userBanner?.dataList?.count ?? 0 > 0 ? imageBannerHeight : 0)
        }
        if YXUserManager.shared().userBanner == nil {
            imageBannerView.isHidden = true
        }
        
        accountTypeView.snp.updateConstraints { make in
            make.height.equalTo(YXAccountLevelView.height)
        }
        
        self.userHeaderView.snp.updateConstraints { make in
            make.height.equalTo(userHeaderHeight)
        }
        
        self.headView.height = headViewHeight
        if let list = YXUserManager.shared().userBanner?.dataList {
            var arr = [String]()
            for model in list {
                arr.append(model.pictureURL ?? "")
            }
            self.imageBannerView.imageURLStringsGroup = arr
        }
       
        self.tableView.reloadData()
        self.userHeaderView.refreshUI()
    }
    
    //跳去个人资料
    @objc func accountImgViewClick() {
        if YXUserManager.isLogin() {
            let context = YXNavigatable(viewModel: YXPersonalDataViewModel())
            self.viewModel.navigator.push(YXModulePaths.personalData.url, context: context)
        } else {
            let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: nil, vc: self))
            self.viewModel.navigator.push(YXModulePaths.defaultLogin.url, context: context)
        }
        
    }
}

extension YXUserCenterViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell = tableView.dequeueReusableCell(withIdentifier: oneViewCellID, for: indexPath) as! YXMineConfigOneColCell
        let row = self.viewModel.rows[indexPath.row]
        cell.titleLabel.text = row.title()
        cell.iconView.image = UIImage(named: row.imageName())
        cell.lineView.isHidden = row.lineHidden()
        if row == .message {
            cell.redDotView.isHidden = YXMessageButton.brokerRedIsHidden
        }else {
            cell.redDotView.isHidden = true
        }
      
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = self.viewModel.rows[indexPath.row]
        
        if !YXUserManager.isLogin() && ( row != .about && row != .help && row != .setting ){
            let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: nil, vc: self))
            self.viewModel.navigator.push(YXModulePaths.defaultLogin.url, context: context)
            return
        }
        
        switch row {
        case .quotation:
            self.trackViewClickEvent(name: "My quotation_tab")
            YXWebViewModel.pushToWebVC(YXH5Urls.myQuotesUrl())
        case .message:
           // self.viewModel.hasCheckMessage = true
            self.trackViewClickEvent(name: "Message_tab")
            YXWebViewModel.pushToWebVC(YXH5Urls.YX_BROKERS_MSG_CENTER_URL())
            //self.tableView.reloadData()
        case .activity:
            self.trackViewClickEvent(name: "Activity Center_tab")
            if YXConstant.appTypeValue == .OVERSEA {
                YXWebViewModel.pushToWebVC(YXH5Urls.YX_ACTIVITY_CENTER_URL())
            }else if YXConstant.appTypeValue == .OVERSEA_SG {
                YXWebViewModel.pushToWebVC(YXH5Urls.YX_SG_ACTIVITY_CENTER_URL())
            }
        case .rewards:
            self.trackViewClickEvent(name: "Rewards_tab")
            YXWebViewModel.pushToWebVC(YXH5Urls.YX_AWARD_CENTER_URL())
        case .setting:
            self.trackViewClickEvent(name: "Settings_tab")
            self.viewModel.navigator.push(YXModulePaths.userCenterSet.url, context: nil)
        case .help:
            self.trackViewClickEvent(name: "Help Center_tab")
            YXWebViewModel.pushToWebVC(YXH5Urls.YX_HELP_URL())
        case .about:
            self.trackViewClickEvent(name: "About_tab")
            self.viewModel.navigator.push(YXModulePaths.userCenterAbout.url, context: nil)
        case .invite:
            YXWebViewModel.pushToWebVC(YXH5Urls.inviteFriendsUrl())
        case .subscribes:
            YXWebViewModel.pushToWebVC(YXH5Urls.mineSubscribeURL())
        }
    }
}



extension YXUserCenterViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let contentOffset = scrollView.contentOffset
//        if contentOffset.y >= 0 {
//            self.userHeaderView.mj_y = YXConstant.navBarHeight()
//        } else {
//            self.userHeaderView.mj_y = YXConstant.navBarHeight() - contentOffset.y
//        }
//        var frame = self.layerView.frame
//        frame.size.height = self.defaultLayerHeight - contentOffset.y
//        if frame.size.height < self.defaultLayerHeight {
//            frame.size.height = self.defaultLayerHeight
//        }
//        self.layerView.frame = frame
//        self.userHeaderView.layerView.isHidden = (contentOffset.y < 10.0)
    }
}


extension YXUserCenterViewController: YXCycleScrollViewDelegate {
    func cycleScrollView(_ cycleScrollView: YXCycleScrollView!, didSelectItemAt index: Int) {
        if let list = YXUserManager.shared().userBanner?.dataList, list.count > 0 {
            let banner = list[index]
            if let bannerID = banner.bannerID{
                self.trackViewClickEvent(name: "Banner_Tab",other:["banner_id":String(bannerID)])
            }
            YXBannerManager.goto(withBanner: banner, navigator: self.viewModel.navigator)
        }
    }
}
