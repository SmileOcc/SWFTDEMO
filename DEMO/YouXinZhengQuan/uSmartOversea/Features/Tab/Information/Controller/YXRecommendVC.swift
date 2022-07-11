//
//  YXRecommendVC.swift
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2019/9/6.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXRecommendVC: YXHKTableViewController, HUDViewModelBased {

    typealias ViewModelType = YXRecommendViewModel
    var viewModel: YXRecommendViewModel!
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    
    let reuseIdentifier = "newsInfosCellIdentifier"

    let bannerView = YXCycleScrollView.init(frame: CGRect.init(x: 0, y: 0, width: YXConstant.screenWidth, height: 150 * YXConstant.screenWidth / 375))
        
    var refreshTabCallBack: ((_ tag: NSInteger) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.bindModel()
        initUI()
        loadRecommendData()
//        queryBannerInfo()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override init() {
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func initUI() {
        self.bannerView.bannerImageViewContentMode = .scaleAspectFill
        self.bannerView.titleLabelHeight = 22
        self.bannerView.titleLabelTextFont = UIFont.boldSystemFont(ofSize: 14)
        self.bannerView.titleLabelTextColor = QMUITheme().foregroundColor()
        self.bannerView.titleLabelBackgroundColor = .clear
        self.bannerView.delegate = self
        self.bannerView.autoScrollTimeInterval = 5
        let image = UIImage.qmui_image(with: QMUITheme().foregroundColor().withAlphaComponent(0.3), size: CGSize.init(width: 8, height: 2), cornerRadius: 0)
        self.bannerView.pageDotImage = image
        let curImage = UIImage.qmui_image(with: QMUITheme().separatorLineColor(), size: CGSize.init(width: 8, height: 2), cornerRadius: 0)
        self.bannerView.currentPageDotImage = curImage
        self.bannerView.pageControlDotSize = CGSize.init(width: 8, height: 2)
        self.bannerView.showBackView = true
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = QMUITheme().foregroundColor()
        tableView.estimatedRowHeight = 50
        tableView.register(YXInfomationCell.self, forCellReuseIdentifier: reuseIdentifier)
        self.tableView.mj_header = YXRefreshHeader.init { [weak self] in
            self?.viewModel.status = 1
            self?.viewModel.cmd = 1
            self?.viewModel.isTop = true
            self?.viewModel.lastTime = nil
            self?.viewModel.last_score = nil
            self?.loadRecommendData()

//            self?.queryBannerInfo()
        }
        
        self.tableView.mj_footer =
            YXRefreshAutoNormalFooter.init(refreshingBlock: { [weak self] in
            self?.viewModel.status = 2
            self?.viewModel.cmd = 2
            self?.viewModel.isTop = false
            self?.loadRecommendData()
        })
    }
    
    //广告页
    func queryBannerInfo() {
        self.viewModel.services.newsService.request(.userBanner(id: .infomationChannel), response: self.viewModel.bannerResponse).disposed(by: self.disposeBag)
    }
    //MARK: 推荐接口
    func loadRecommendData() {
        /* http://szshowdoc.youxin.com/web/#/23?page_id=481 -->
//        news-recommend --> 港版推荐资讯列表  --> news-recommend/api/v1/gethkrecommend */
//        var lanType: Int = 0
//        if YXUserManager.isENMode() {
//            lanType = info_language
//        }
//        self.viewModel.services.infomationService.request(.recommend(self.viewModel.cmd, self.viewModel.isTop, self.viewModel.lastTime, lanType, self.viewModel.market_str), response: self.viewModel.recommendResponse).disposed(by: self.disposeBag)
        
        //新接口文档 http://showdoc.yxzq.com/web/#/23?page_id=2453
        //http://yxzq.com/news-recommend/api/v1/recommendnewsbylang

        let lanType = news_selected_language
        self.viewModel.lang = lanType
        self.viewModel.services.infomationService.request(.recommendnewsbylang(self.viewModel.isTop, self.viewModel.last_score, 30, self.viewModel.lang, nil), response: self.viewModel.recommendResponse).disposed(by: self.disposeBag)

        
    }
    
    func bindModel() {
        
        self.bindHUD()
        self.viewModel.bannerSubject.subscribe(onNext: { [weak self] (model) in
            guard let `self` = self else { return }
            
            if let list = self.viewModel.bannerList {
                var arr = [String]()
                var titleArr = [String]()
                var labelArr = [String]()
                for news in list {
                    arr.append(news.pictureURL ?? "")
                    titleArr.append(news.bannerTitle ?? "")
                    labelArr.append(news.tag ?? "")
                }
                self.bannerView.imageURLStringsGroup = arr
                self.bannerView.titlesGroup = titleArr
                self.bannerView.labelsGroup = labelArr
                self.tableView.tableHeaderView = self.bannerView
            } else {
                self.tableView.tableHeaderView = nil
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        
        self.viewModel.recommendSubject.subscribe(onNext: { [weak self] (list) in
            guard let `self` = self else { return }
            
            // 下拉
            if self.viewModel.status == 1 {
                self.tableView.mj_header?.endRefreshing()
                self.tableView.mj_footer?.resetNoMoreData()
                if self.viewModel.list.count == 0 {
                    self.showNoDataEmptyView()
                } else {
                    self.hideEmptyView()
                }
            } else if self.viewModel.status == 2 {
                // 上拉
                if list == nil {
                    if self.viewModel.list.count == 0 {
                        self.showNoDataEmptyView()
                        self.tableView.mj_footer?.endRefreshing()
                    } else {
                        self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                    }
                } else {
                    self.tableView.mj_footer?.endRefreshing()
                    if self.viewModel.list.count == 0 {
                        self.showNoDataEmptyView()
                    } else {
                        self.hideEmptyView()
                    }
                }
            } else if self.viewModel.status == 0 {
                self.tableView.mj_header?.endRefreshing()
                self.tableView.mj_footer?.resetNoMoreData()
                if self.viewModel.list.count == 0 {
                    self.showNoDataEmptyView()
                } else {
                    self.hideEmptyView()
                }
            }
            
            UIView.performWithoutAnimation {
                self.tableView.reloadData()
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        self.viewModel.refreshSubject.subscribe(onNext: { [weak self] list in
            guard let `self` = self else { return }
            let cells = self.tableView.visibleCells
            for cell in cells {
                if let cell = cell as? YXInfomationCell, let model = cell.stockArticleData {
                    if let model = model.stocks?.first {
                        cell.updateRoc(with: model)
                    }
                }
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
}



// MARK: UITableViewDelegate
extension YXRecommendVC {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.list.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return tableView.qmui_heightForCell(withIdentifier: reuseIdentifier, cacheBy: indexPath, configuration: { [weak self] (tableCell) in
            guard let `self` = self else { return }
            if let cell = tableCell as? YXInfomationCell {
                cell.stockArticleData = self.viewModel.list[indexPath.row]
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath) as! YXInfomationCell
        let infoModel = self.viewModel.list[indexPath.row]
        // 添加newsId至曝光的新闻列表中
//        if let newsid = infoModel.newsid {
//            YXSensorsAnalyticsService.addExposeInfoId(newsid, algorithm: infoModel.alg ?? "undefined")
//        }
        
        cell.stockArticleData = infoModel
        cell.clickStockCallBack = { [weak self] model in
            if let market = model.market, let symbol = model.symbol {
                if let type2 = model.type2, type2 == 202 {
                    let dic = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_FUND_DETAIL_PAGE_URL(market + symbol)]
                    self?.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                } else {
                    let input = YXStockInputModel()
                    input.market = market
                    input.symbol = symbol
                    input.name = model.name ?? ""
                    self?.viewModel.navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [input], "selectIndex" : 0])
                }
            }
        }
        // 刷新
        cell.refreshCallBack = { [weak self] in
            self?.tableView.mj_header?.beginRefreshing()
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let model = self.viewModel.list[indexPath.row]
        if !model.isRead {
            model.isRead = true
            // 保存状态
            if let newsId = model.newsid {
                YXTabInfomationTool.saveReadStatus(with: newsId)
            }
        }
        tableView.reloadRows(at: [indexPath], with: .none)
//        let context = YXNavigatable(viewModel: YXInfoDetailViewModel(dictionary: [
//            "newsId" : model.newsid ?? "",
//            "type" : YXInfomationType.Normal,
//            "source" : YXPropInfoSourceValue.infoStock,
//            "newsTitle" : model.title ?? ""
//            ]))
//        self.viewModel.navigator.push(YXModulePaths.infoDetail.url, context: context)
        if model.alg == "kol" {
            let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.kolArticleDetail(postId: model.postid ?? "")]
            NavigatorServices.shareInstance.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        } else {
            let viewModel = YXImportantNewsDetailViewModel.init(services: self.viewModel.navigator, params: ["cid": model.newsid ?? ""])
            self.viewModel.navigator.push(viewModel, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView.init()
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 6;
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let cells = self.tableView.visibleCells
        var arr = [YXInfomationModel]()
        for cell in cells {
            if let cell = cell as? YXInfomationCell, let model = cell.stockArticleData {
                arr.append(model)
            }
        }
        // 刷新
        self.viewModel.loadQuota(with: arr)
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let cells = self.tableView.visibleCells
        var arr = [YXInfomationModel]()
        for cell in cells {
            if let cell = cell as? YXInfomationCell, let model = cell.stockArticleData {
                arr.append(model)
            }
        }
        // 刷新
        self.viewModel.loadQuota(with: arr)
    }
}


extension YXRecommendVC: YXCycleScrollViewDelegate {
    func cycleScrollView(_ cycleScrollView: YXCycleScrollView!, didSelectItemAt index: Int) {
        guard let list = self.viewModel.bannerList, list.count > 0 else { return }
        let model = list[index]
        if let url = model.jumpURL, url.count > 0 {
            let type = model.newsJumpType
            if type == .Native {
                // 内部
                YXGoToNativeManager.shared.gotoNativeViewController(withUrlString: url)
                
            } else if type == .Normal || type == .Recommend {
                // 资讯
                let context = YXNavigatable(viewModel: YXInfoDetailViewModel(dictionary: [
                    "newsId" : model.newsID ?? "",
                    "type" : YXInfomationType.Normal,
                    "source" : YXPropInfoSourceValue.infoStock,
                    "newsTitle" : model.bannerTitle ?? ""
                    ]))
                self.viewModel.navigator.push(YXModulePaths.infoDetail.url, context: context)
                
            } else if type == .Internal || type == .External {
                // 普通
                let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: url,
                                          YXWebViewModel.kWebViewModelTitle: model.bannerTitle ?? ""]
                self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            }

        }
    }
}
