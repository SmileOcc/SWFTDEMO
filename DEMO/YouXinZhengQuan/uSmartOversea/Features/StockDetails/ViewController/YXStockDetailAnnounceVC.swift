//
//  YXStockDetailAnnounceVC.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/7/4.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit
import JXPagingView

class YXStockDetailAnnounceVC: YXHKTableViewController, HUDViewModelBased {
    
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXStockDetailAnnounceViewModel! = YXStockDetailAnnounceViewModel()
    let reuseIdentifier = "YXStockDetailAnnounceCell"
    private var pop: YXStockPopover?
    var isShowTotalButton = true
    var isShowEventReminder = false
    
    let categoryBtn: YXExpandAreaButton = YXExpandAreaButton.init()
    var kSectionHeaderHeight: CGFloat = 40
    var isLoaded = false

    var sectionView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindModel()
        isLoaded = true
        initUI()
        self.networkingHUD.showLoading("", in: self.view)
        refreshControllerData()
    }

    @objc func refreshControllerData() {
        if isLoaded {
            self.viewModel.loadDown()
        }
    }
    func initUI() {

        tableView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
        title = YXLanguageUtility.kLang(key: "stock_detail_announce_all")
        tableView.separatorStyle = .none
        tableView.backgroundColor = QMUITheme().foregroundColor()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        tableView.register(YXStockDetailAnnounceCell.self, forCellReuseIdentifier: "YXStockDetailAnnounceCell")
        tableView.register(YXAnnounceEventReminderCell.self, forCellReuseIdentifier: "YXAnnounceEventReminderCell")

        
        self.tableView.mj_footer = YXRefreshAutoNormalFooter.init(refreshingBlock: { [weak self] in
            self?.viewModel.loadUp()
        })
    }

    override func layoutTableView() {
         
    }
    
    
    override func jx_refreshData() {
        self.viewModel.loadDown()
    }
    
    func bindModel() {

        self.viewModel.quoteObservable.subscribe(onNext: {
            [weak self] _ in
            guard let `self` = self else { return }

            self.endRefreshCallBack?()
            self.networkingHUD.hide(animated: true)

            self.tableView.mj_footer?.resetNoMoreData()
            if self.viewModel.market == kYXMarketUS || self.viewModel.market == kYXMarketHK {

                if self.viewModel.list.count == 0, self.viewModel.eventReminderList.count == 0 {
                    // 无数据
                    self.showNoDataEmptyView()
                } else {
                    self.hideEmptyView()
                }
            } else {
                if self.viewModel.HSList.count == 0, self.viewModel.eventReminderList.count == 0 {
                    // 无数据
                    self.showNoDataEmptyView()
                } else {
                    self.hideEmptyView()
                }
            }
            self.tableView.reloadData()
        }).disposed(by: disposeBag)

        
        self.viewModel.loadUpSubject.subscribe(onNext: { [weak self] list in
            guard let `self` = self else { return }
            var count = 0
            if self.viewModel.market == kYXMarketUS || self.viewModel.market == kYXMarketHK {
                count = self.viewModel.list.count
            } else {
                count = self.viewModel.HSList.count
            }
            if list == nil {
                if count > 0 {
                    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                } else {
                    self.tableView.mj_footer?.removeFromSuperview()
                    self.tableView.mj_footer = nil
                }
            } else {
                self.tableView.mj_footer?.endRefreshing()
            }
            self.tableView.reloadData()
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    @objc func categoryBtnClick(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        // 旋转
        sender.imageView?.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi))

        var selectIndex = self.viewModel.type
        if self.viewModel.type == 9 {
            selectIndex = 5
        }
        let menuView = self.getMenuView()
        menuView.selectIndex = selectIndex
        self.pop = YXStockPopover.init()
        self.pop?.willDismissHandler = {
            [weak self] in
            guard let `self` = self else { return }
            self.categoryBtn.imageView?.transform = CGAffineTransform.init(rotationAngle: 0)
        }
        self.pop?.show(menuView, from: sender)
    }

    func getMenuView() -> YXStockLineMenuView {
        var titles = [String]()
        if self.viewModel.market == kYXMarketHK {
            titles = [YXLanguageUtility.kLang(key: "stock_detail_announce_all"), YXLanguageUtility.kLang(key: "stock_detail_announce_prospectus"), YXLanguageUtility.kLang(key: "stock_detail_announce_financial"), YXLanguageUtility.kLang(key: "stock_detail_announce_result"), YXLanguageUtility.kLang(key: "stock_detail_announce_meeting"), YXLanguageUtility.kLang(key: "stock_detail_announce_other")]
        } else if self.viewModel.market == kYXMarketUS {
            titles = [YXLanguageUtility.kLang(key: "stock_detail_announce_all"), YXLanguageUtility.kLang(key: "stock_detail_announce_prospectus"), YXLanguageUtility.kLang(key: "stock_detail_announce_financial"), YXLanguageUtility.kLang(key: "stock_important_event"), YXLanguageUtility.kLang(key: "stock_interim_report"), YXLanguageUtility.kLang(key: "stock_detail_announce_other")]
        } else {
            titles = [YXLanguageUtility.kLang(key: "stock_detail_announce_all"), YXLanguageUtility.kLang(key: "stock_detail_announce_prospectus"), YXLanguageUtility.kLang(key: "periodic_reports"), YXLanguageUtility.kLang(key: "stock_detail_announce_result"), YXLanguageUtility.kLang(key: "stock_detail_announce_meeting"), YXLanguageUtility.kLang(key: "deividend"), YXLanguageUtility.kLang(key: "stock_detail_announce_other")]
        }

        var maxWidth: CGFloat = 0
        for title in titles {
            let width = (title as NSString).boundingRect(with: CGSize(width: 1000, height: 30), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)], context: nil).size.width
            if maxWidth < width {
                maxWidth = width
            }
        }

        let view = YXStockLineMenuView.init(frame: CGRect(x: 0, y: 0, width: maxWidth + 30.0, height: CGFloat(titles.count) * 40.0), andTitles: titles)
        view.clickCallBack = {
            [weak self] sender in
            guard let `self` = self else { return }

            self.pop?.dismiss()
            if sender.isSelected {
                return
            }
            self.categoryBtn.setTitle(titles[sender.tag], for: .normal)
            self.categoryBtn.layoutIfNeeded()
            //港股:0-全部，1-招股文件，2-财报，3-业绩公告，4-股东大会，9-其他
            //美股: 全部, 招股文件, 财报, 重大事件, 临时报告, 其他
            //A股: 全部、招股文件、定期报告、业绩预告、股东大会、分红、其他
            if self.viewModel.market == kYXMarketUS || self.viewModel.market == kYXMarketHK {
                if sender.tag == 5 {
                    self.viewModel.type = 9
                } else {
                    self.viewModel.type = sender.tag
                }
            } else {
                self.viewModel.type = sender.tag
            }

            self.viewModel.loadDown()
        }

        return view
    }
    
    override func emptyRefreshButtonAction() {
        self.viewModel.loadDown()
    }

    override func showNoDataEmptyView() {

        if isEmptyViewShowing {
            return
        }

        if let emptyView = self.emptyView {
            self.tableView.addSubview(emptyView)
            self.tableView.sendSubviewToBack(emptyView)
            self.tableView.frame = self.view.bounds
            emptyView.frame = self.view.bounds
        }

        self.emptyView?.detailTextLabel.text = nil
        self.emptyView?.loadingView.isHidden = true
        self.emptyView?.actionButtonTitleColor = QMUITheme().textColorLevel3()
        self.emptyView?.textLabelTextColor = QMUITheme().textColorLevel3()
        self.emptyView?.textLabelFont = UIFont.systemFont(ofSize: 14)
        self.emptyView?.imageViewInsets = UIEdgeInsets(top: 0, left: 0, bottom: 14, right: 0)

        self.emptyView?.imageView.image = UIImage.init(named: "empty_noData")
        self.emptyView?.setTextLabelText(YXLanguageUtility.kLang(key: "common_string_of_emptyPicture"))
        self.emptyView?.setActionButtonTitle(nil)
        self.emptyView?.actionButton.removeTarget(nil, action: nil, for: .allEvents)
    }
}

// MARK: UITableViewDelegate
extension YXStockDetailAnnounceVC {


    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0 {
//            return self.viewModel.eventReminderList.count
//        } else {
//            if self.viewModel.market == kYXMarketUS || self.viewModel.market == kYXMarketHK {
//                return self.viewModel.list.count
//            } else {
//                return self.viewModel.HSList.count
//            }
//        }
        if self.viewModel.market == kYXMarketUS || self.viewModel.market == kYXMarketHK {
            return self.viewModel.list.count
        } else {
            return self.viewModel.HSList.count
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if section == 0 {
//            if self.viewModel.eventReminderList.count > 0 {
//                return kSectionHeaderHeight
//            } else {
//                return 0.1
//            }
//        } else {
//            return kSectionHeaderHeight
//        }
//
        return 0.1
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if section == 0 {
//            if self.viewModel.eventReminderList.count > 0 {
//                let headerView = UIView()
//                headerView.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: kSectionHeaderHeight)
//                headerView.backgroundColor = QMUITheme().foregroundColor()
//                let label = UILabel()
//                label.textColor = QMUITheme().textColorLevel1()
//                label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
//                label.text = YXLanguageUtility.kLang(key: "event_reminder")
//                label.textAlignment = .left
//                headerView.addSubview(label)
//                label.snp.makeConstraints { (make) in
//                    make.left.equalToSuperview().offset(18)
//                    make.centerY.equalToSuperview()
//                }
//
//                let imageView = UIImageView()
//                imageView.image = UIImage(named: "right_arrow16")
//                headerView.addSubview(imageView)
//                imageView.snp.makeConstraints { (make) in
//                    make.right.equalToSuperview().offset(-8)
//                    make.width.height.equalTo(16)
//                    make.centerY.equalToSuperview()
//                }
//
//                headerView.rx.tapGesture().subscribe(onNext: { [weak self] (ges) in
//                    guard let `self` = self else { return }
//                    if ges.state == .ended  {
//                        let dic: [String: Any] = [
//                            YXWebViewModel.kWebViewModelUrl: YXH5Urls.EVENT_REMINDER_URL(self.viewModel.market + self.viewModel.symbol)
//                        ]
//                        self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
//                    }
//                }).disposed(by: rx.disposeBag)
//
//
//                return headerView
//            } else {
//                return UIView()
//            }
//        } else {
//
//            if self.sectionView == nil {
//                let headerView = UIView()
//                headerView.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: kSectionHeaderHeight)
//                headerView.backgroundColor = QMUITheme().foregroundColor()
//
//                let label = UILabel()
//                label.textColor = QMUITheme().textColorLevel1()
//                label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
//                label.text = YXLanguageUtility.kLang(key: "stock_detail_announcement")
//                label.textAlignment = .left
//                headerView.addSubview(label)
//                label.snp.makeConstraints { (make) in
//                    make.left.equalToSuperview().offset(18)
//                    make.centerY.equalToSuperview()
//                }
//
//                if YXUserManager.curLanguage() != .EN, isShowTotalButton {
//                    self.categoryBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
//                    self.categoryBtn.setImage(UIImage(named: "icon_pull_down"), for: .normal)
//                    self.categoryBtn.setTitle(YXLanguageUtility.kLang(key: "stock_detail_announce_filter"), for: .normal)
//                    self.categoryBtn.imagePosition = .right
//                    self.categoryBtn.spacingBetweenImageAndTitle = 8
//                    self.categoryBtn.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
//                    self.categoryBtn.addTarget(self, action: #selector(self.categoryBtnClick(_:)), for: .touchUpInside)
//                    headerView.addSubview(self.categoryBtn)
//                    categoryBtn.snp.makeConstraints { (make) in
//                        make.right.equalToSuperview().offset(-12)
//                        make.centerY.equalToSuperview()
//                    }
//                }
//
//                let lineView = UIView()
//                lineView.backgroundColor = QMUITheme().textColorLevel1()
//                headerView.addSubview(lineView)
//                lineView.snp.makeConstraints { (make) in
//                    make.left.right.equalToSuperview()
//                    make.height.equalTo(1)
//                    make.bottom.equalToSuperview()
//                }
//
//                self.sectionView = headerView
//            }
//
//            return self.sectionView
//        }
        
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

//        if indexPath.section == 0 {
//            let model = self.viewModel.eventReminderList[indexPath.row]
//
//            if model.openHeight == nil {
//                var conetent = model.eventContent ?? ""
//                if let url = model.detailUrl, !url.isEmpty {
//                    conetent += (" [\(YXLanguageUtility.kLang(key: "webview_detailTitle"))]")
//                }
//
//                var titleHeight: CGFloat = 0
//                if let eventTitle = model.eventTitle, !eventTitle.isEmpty {
//                    titleHeight = (eventTitle as NSString).boundingRect(with: CGSize(width: YXConstant.screenWidth - 78.0 - 18.0, height: CGFloat.greatestFiniteMagnitude), options: [ .usesFontLeading, .usesLineFragmentOrigin ], attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)], context: nil).height + 2.0
//                }
//                model.titleHeight = titleHeight
//
//                let size = CGSize(width: YXConstant.screenWidth - 78.0 - 18.0, height: CGFloat.greatestFiniteMagnitude)
//
//                let layout = YYTextLayout(containerSize: size, text: NSAttributedString.init(string: conetent, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)]))
//                let height: CGFloat = (layout?.textBoundingSize.height ?? 0)
//                let fixHeight: CGFloat = 25.0 + ((model.showYear ?? false) ? 20 : 0)
//                if let rowCount = layout?.rowCount, rowCount > 3 {
//                    model.folderHeight = 46.0 + titleHeight + fixHeight
//                } else {
//                    model.folderHeight = height + titleHeight + fixHeight
//                }
//
//                model.openHeight = height + titleHeight + fixHeight
//            }
//
//            if let isExpand = model.isExpand, isExpand == true {
//                return model.openHeight ?? 0
//            } else {
//                return model.folderHeight ?? 0
//            }
//        } else {
//            if self.viewModel.market == kYXMarketUS || self.viewModel.market == kYXMarketHK {
//
//                let model = self.viewModel.list[indexPath.row]
//                var height = YXToolUtility.getStringSize(with: model.infoTitle ?? "", andFont: UIFont.systemFont(ofSize: 14), andlimitWidth: Float(YXConstant.screenWidth - 36), andLineSpace: 5).height
//                if height < 20 {
//                    height = 67
//                } else if height > 20 {
//                    height = height + 47
//                }
//                return height
//
//            } else {
//
//                let model = self.viewModel.HSList[indexPath.row]
//                var height = YXToolUtility.getStringSize(with: model.titleTxt ?? "", andFont: UIFont.systemFont(ofSize: 14), andlimitWidth: Float(YXConstant.screenWidth - 36), andLineSpace: 5).height
//                if height < 20 {
//                    height = 67
//                } else if height > 20 {
//                    height = height + 47
//                }
//                return height
//            }
//        }
        if self.viewModel.market == kYXMarketUS || self.viewModel.market == kYXMarketHK {

            let model = self.viewModel.list[indexPath.row]
            var height = YXToolUtility.getStringSize(with: model.infoTitle ?? "", andFont: UIFont.systemFont(ofSize: 14), andlimitWidth: Float(YXConstant.screenWidth - 36), andLineSpace: 5).height
            if height < 20 {
                height = 82
            } else if height > 20 {
                height = height + 62
            }
            return height

        } else {

            let model = self.viewModel.HSList[indexPath.row]
            var height = YXToolUtility.getStringSize(with: model.titleTxt ?? "", andFont: UIFont.systemFont(ofSize: 14), andlimitWidth: Float(YXConstant.screenWidth - 36), andLineSpace: 5).height
            if height < 20 {
                height = 82
            } else if height > 20 {
                height = height + 62
            }
            return height
        }

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

//        if indexPath.section == 0 {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "YXAnnounceEventReminderCell", for: indexPath) as! YXAnnounceEventReminderCell
//            let model = self.viewModel.eventReminderList[indexPath.row]
//            cell.model = model
//            cell.detailUrlClosure = {
//                [weak self] url in
//                guard let `self` = self else { return }
//
//                let dic: [String: Any] = [
//                    YXWebViewModel.kWebViewModelUrl: url
//                ]
//                self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
//            }
//            return cell
//        } else {
//            let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath) as! YXStockDetailAnnounceCell
//            if self.viewModel.market == kYXMarketUS || self.viewModel.market == kYXMarketHK {
//                let model = self.viewModel.list[indexPath.row]
//                cell.model = model
//            } else {
//                let model = self.viewModel.HSList[indexPath.row]
//                cell.HSModel = model
//            }
//            return cell
//        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath) as! YXStockDetailAnnounceCell
        if self.viewModel.market == kYXMarketUS || self.viewModel.market == kYXMarketHK {
            let model = self.viewModel.list[indexPath.row]
            cell.model = model
        } else {
            let model = self.viewModel.HSList[indexPath.row]
            cell.HSModel = model
        }
        return cell

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

//        if indexPath.section == 0 {
//            let model = self.viewModel.eventReminderList[indexPath.row]
////            if let eventId = model.eventId {
////                let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.EVENT_REMINDER_URL(self.viewModel.market + self.viewModel.symbol, eventId)]
////                let context = YXNavigatable(viewModel: YXWebViewModel(dictionary: dic))
////                self.viewModel.navigator.push(YXModulePaths.webView.url, context: context)
////            }
//            if model.isExpand ?? false {
//                model.isExpand = false
//            } else {
//                model.isExpand = true
//            }
//            tableView.reloadData()
//        } else {
//            if self.viewModel.market == kYXMarketUS || self.viewModel.market == kYXMarketHK {
//
//                let model = self.viewModel.list[indexPath.row]
//                if let url = model.website {
//                    let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: url, YXWebViewModel.kWebViewModelTitle: self.viewModel.name ?? ""]
//                    self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
//                }
//            } else {
//                let model = self.viewModel.HSList[indexPath.row]
//                if let url = model.annLink {
//                    let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: url, YXWebViewModel.kWebViewModelTitle: self.viewModel.name ?? ""]
//                    self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
//                }
//            }
//        }
        
        if self.viewModel.market == kYXMarketUS || self.viewModel.market == kYXMarketHK {

            let model = self.viewModel.list[indexPath.row]
            if let url = model.website {
                let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: url, YXWebViewModel.kWebViewModelTitle: self.viewModel.name ?? ""]
                self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            }
        } else {
            let model = self.viewModel.HSList[indexPath.row]
            if let url = model.annLink {
                let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: url, YXWebViewModel.kWebViewModelTitle: self.viewModel.name ?? ""]
                self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            }
        }

    }
}

extension YXStockDetailAnnounceVC: JXPagingViewListViewDelegate {
    
    func listScrollView() -> UIScrollView { self.tableView }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        listViewDidScrollCallback?(scrollView)
    }
}
