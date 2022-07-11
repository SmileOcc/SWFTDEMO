//
//  YXWarrantsSearchViewController.swift
//  uSmartOversea
//
//  Created by 井超 on 2019/8/5.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import Reusable
import RxSwift

class YXWarrantsSearchBar: UIView {
    @IBOutlet weak var cancelBtn :UIButton!
    @IBOutlet weak var textField :UITextField!
    @IBOutlet weak var bgView: UIView!
    
    override var intrinsicContentSize: CGSize {
        self.bounds.size
    }
}

class YXWarrantsSearchViewController: YXHKViewController, StoryboardBased {

    var viewModel = YXWarrantsSearchViewModel()
    
    private var resultContorller :YXWarrantsSearchListController?
    private var historyContorller :YXWarrantsSearchListController?
    
    @IBOutlet weak var searchBar: YXWarrantsSearchBar!
    
    @IBOutlet weak var emptyImageView: UIImageView!
    @IBOutlet weak var resultView :UIView!
    @IBOutlet weak var historyView :UIView!
    
    @IBOutlet weak var innerEmptyView :UIView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var isFromBullBearAssetSearch: Bool = false
    weak var bullBearAssetListViewModel: YXBullBearAssetListViewModel?
    
    var didTouchedCancel :(()->())?
    var didSelectedItem :((YXSearchItem)->())?
    var didSelectedAll :((Bool)->())?
    
    override var pageName: String {
        
        if viewModel.warrantType == .optionChain {
            return "options Search"
        } else {
            return "warrant Search"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        
        resultContorller?.tableView.backgroundColor = QMUITheme().foregroundColor()
        historyContorller?.tableView.backgroundColor = QMUITheme().foregroundColor()
        
        self.view.backgroundColor = QMUITheme().foregroundColor()
        resultContorller?.warrantType = viewModel.warrantType
        historyContorller?.warrantType = viewModel.warrantType
        searchBar.cancelBtn.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        searchBar.backgroundColor = QMUITheme().foregroundColor()
        searchBar.bgView.backgroundColor = QMUITheme().blockColor()
        searchBar.textField.textColor = QMUITheme().textColorLevel1()
        if isFromBullBearAssetSearch || viewModel.warrantType == .optionChain {
            resultContorller?.hideAllBtn()
            historyContorller?.hideAllBtn()
        }
        viewModel.historyViewModel.warrantType = viewModel.warrantType

        if viewModel.warrantType == .optionChain {

            let rightItemButton = QMUIButton()
            rightItemButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            rightItemButton.setTitle(YXLanguageUtility.kLang(key: "options_101"), for: .normal)
            rightItemButton.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
            rightItemButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            rightItemButton.rx.tap.subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }

                let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.OPTION_COLLEGE_URL()]
                self.viewModel.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))

            }).disposed(by: rx.disposeBag)
//            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: rightItemButton)]

            self.navigationController?.navigationBar.isTranslucent = false
            self.navigationController?.navigationBar.barStyle = .default

            self.title = YXLanguageUtility.kLang(key: "options_options")
            self.searchBar.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width - 18 * 2, height: 38)
            self.view.addSubview(self.searchBar)
            self.searchBar.snp.remakeConstraints { (make) in
                make.left.equalToSuperview().offset(18)
                make.right.equalToSuperview().offset(-6)

                if #available(iOS 11.0, *) {
                    make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(4)
                } else {
                    make.top.equalTo(YXConstant.navBarHeight() + 4)
                }
                make.height.equalTo(38)
            }

            self.searchBar.cancelBtn.snp.updateConstraints { (make) in
                make.width.equalTo(0)
            }
            self.searchBar.cancelBtn.isHidden = true

            resultContorller?.view.snp.remakeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(self.searchBar.snp.bottom).offset(4)
            }

            historyContorller?.view.snp.remakeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(self.searchBar.snp.bottom).offset(4)
            }

        } else {
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)

            self.searchBar.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width - 18 * 2, height: 38)

            self.navigationItem.titleView = self.searchBar
            searchBar.cancelBtn.setTitle(YXLanguageUtility.kLang(key: "search_cancel"), for: .normal)
            _ = searchBar.cancelBtn.rx.tap.asControlEvent().takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self](_) in
                self?.didTouchedCancel?()
            })

        }

        
        //监听搜索结果
        _ = self.viewModel.historyViewModel.list.asObservable().filter({ (list) -> Bool in
            list != nil
        }).takeUntil(self.rx.deallocated).subscribe(onNext: {[weak self] (list) in
            if let count = list?.count(), count <= 0 {
                self?.showHistoryinnerEmptyView()
            }
        })
        
        //监听搜索结果
        _ = self.viewModel.resultViewModel.list.asObservable().filter({ (list) -> Bool in
            list != nil
        }).takeUntil(self.rx.deallocated).subscribe(onNext: {[weak self] (list) in
            self?.showResultView()
        })

        if (viewModel.warrantType == .optionChain) {
            searchBar.textField.placeholder = YXLanguageUtility.kLang(key: "option_search_placeholder")

            DispatchQueue.main.asyncAfter(deadline:.now() + 1.0, execute: {
                self.searchBar.textField.becomeFirstResponder()
            })
            
        } else {
            searchBar.textField.placeholder = YXLanguageUtility.kLang(key: SearchLanguageKey.placeholder.rawValue)

            DispatchQueue.main.asyncAfter(deadline:.now() + 0.5, execute: {
                self.searchBar.textField.becomeFirstResponder()
            })
        }
        
        _ = searchBar.textField.rx.text.throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance).takeUntil(self.rx.deallocated).filter({ (text) -> Bool in
            text != nil
        }).subscribe(onNext: { [weak self](text) in
            if let text = text,text != "" {
                _ = self?.viewModel.search(text: text)
                self?.trackViewClickEvent(name: "Search_Tab", other: ["options_content": text])
            } else {
                self?.showHistoryView()
            }
        })
        
        _ = searchBar.textField.rx.controlEvent(.editingDidEndOnExit).takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] (e) in
            if let count = self?.viewModel.resultViewModel.list.value?.count(), count == 1 {
                self?.viewModel.resultViewModel.cellTapAction(at: 0)
            }
        })
        
        _ = viewModel.resultViewModel.cellDidSelected.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self](item) in
            guard let `self` = self else { return }
            self.cellDidSelected(item: item)
        })
        
        _ = viewModel.historyViewModel.cellDidSelected.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self](item) in
            guard let `self` = self else { return }
            self.cellDidSelected(item: item)
        })
        
        _ = viewModel.historyViewModel.allDidSelected.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] (bool) in
            
            self?.didSelectedAll?(true)
            self?.dismiss(animated: true, completion: {
            })
        })
        
        _ = viewModel.resultViewModel.allDidSelected.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] (bool) in
            
            self?.didSelectedAll?(true)
            self?.dismiss(animated: true, completion: {
            })
        })
        
    }
    
    func cellDidSelected(item: YXSearchItem) {
        if self.isFromBullBearAssetSearch { // 从认股证和牛熊证页面进来的话，搜索后点击某只股票需检查该股票是否有相关认股证和牛熊证
            if self.bullBearAssetListViewModel?.isInAssetList(market: item.market, symbol: item.symbol) ?? false {
                self.didSelectedItem?(item)
                self.dismiss(animated: true, completion: {
                })
            }
        }else {
            self.didSelectedItem?(item)
            if (viewModel.warrantType == .optionChain) {

                YXSearchHistoryManager.shared.optionChainSearchItem = item
                if (self.viewModel.needPushOptionChain) {
                    let stockName = item.name ?? ""
                    let stockCode = (item.market ?? "") + (item.symbol ?? "")
                    self.trackViewClickEvent(name: "optionslist_item", other: ["stockCode": stockCode, "stockName": stockName])
                    if let array = self.navigationController?.viewControllers, array.count > 0 {
                        var vcArray = array
                        for (i,vc) in array.enumerated() {
                            if vc.isKind(of: YXWarrantsSearchViewController.self) {
                                vcArray.remove(at: i)
                                break;
                            }
                        }
                        self.navigationController?.viewControllers = vcArray
                    }
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                self.dismiss(animated: true, completion: {
                })
            }

        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    //
    private func showResultView() {
        
        resultView.isHidden = false
        
        if let count = self.viewModel.resultViewModel.list.value?.count(), count > 0 {
            hideResultinnerEmptyView()
        } else {
            showResultinnerEmptyView()
        }
        
        historyView.isHidden = true
    }
    
    private func showHistoryView() {
        
        historyView.isHidden = false
        
        if let count = self.viewModel.historyViewModel.list.value?.count(), count > 0 {
            hideHistoryinnerEmptyView()
            resultContorller?.tableView.bounces = true
            historyContorller?.tableView.bounces = true
        } else {
            showHistoryinnerEmptyView()
            resultContorller?.tableView.bounces = false
            historyContorller?.tableView.bounces = false
        }
        
        resultView.isHidden = true
    }
    
    private func showHistoryinnerEmptyView() {
        innerEmptyView.isHidden = false
        if viewModel.warrantType == .optionChain {
            emptyLabel.text = YXLanguageUtility.kLang(key: "option_search_empty_text")
        } else {
            emptyLabel.text = YXLanguageUtility.kLang(key: SearchLanguageKey.history_empty.rawValue)
        }

        resultContorller?.tableView.bounces = false
        historyContorller?.tableView.bounces = false
        emptyImageView.image = YXDefaultEmptyEnums.noHistory.image()
    }
    
    private func hideHistoryinnerEmptyView() {
        innerEmptyView.isHidden = true
        resultContorller?.tableView.bounces = true
        historyContorller?.tableView.bounces = true
    }
    
    private func showResultinnerEmptyView() {
        innerEmptyView.isHidden = false
        emptyLabel.text = YXLanguageUtility.kLang(key: SearchLanguageKey.result_empty.rawValue)
        
        resultContorller?.tableView.bounces = false
        historyContorller?.tableView.bounces = false
        emptyImageView.image = YXDefaultEmptyEnums.noSearch.image()
    }
    
    private func hideResultinnerEmptyView() {
        innerEmptyView.isHidden = true
        resultContorller?.tableView.bounces = true
        historyContorller?.tableView.bounces = true
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "history" {
            historyContorller = segue.destination as? YXWarrantsSearchListController
            viewModel.historyViewModel.loadDiskCache()
            historyContorller?.viewModel = viewModel.historyViewModel
        } else if segue.identifier == "result" {
            resultContorller = segue.destination as? YXWarrantsSearchListController
            resultContorller?.viewModel = viewModel.resultViewModel
        }
        
    }
    
    @IBAction func cameraBtnAction(_ sender: UIButton) {
        viewModel.navigator.push(YXModulePaths.importPic.url)
    }
    
    deinit {
        print(">>>>>>> \(NSStringFromClass(YXWarrantsSearchViewController.self)) deinit")
    }
}
