//
//  YXStockFilterView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/4/26.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXStockFilterView: UIControl {
    
    @objc weak var parentViewController: UIViewController?
    
    @objc var didHideBlock: ((Bool) -> Void)?

    let bag = DisposeBag()
    
    
    @objc func setDailyMargin(_ value: Int) {
        searchViewModel.dailyMargin = value
    }
    
    @objc func setSearchTypes(_ types: [String]) {
        searchViewModel.types = types.compactMap{ YXSearchType(rawValue: $0) }
    }
    
    let contentViewHeight: CGFloat = 128
    
//    lazy var titleLabel: UILabel = {
//        let label = UILabel()
//        label.text = "搜索股票"
//        label.font = .systemFont(ofSize: 16)
//        label.textColor = QMUITheme().textColorLevel1()
//
//        return label
//    }()
    
    @objc lazy var allStockButton: QMUIButton = {
        let button = QMUIButton()
        button.setImage(UIImage.init(named: "edit_uncheck2"), for: .normal)
        button.setImage(UIImage.init(named: "edit_checked"), for: .selected)
        button.imagePosition = .left
        button.spacingBetweenImageAndTitle = 5
        button.setTitle(YXLanguageUtility.kLang(key: "orderfilter_all_stock"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.isSelected = true
        button.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        button.setTitleColor(QMUITheme().textColorLevel3(), for: .selected)

        return button
    }()
    
    lazy var searchBar: YXNewSearchBar = {
        let searchBar = YXNewSearchBar()

        return searchBar
    }()
    
    lazy var searchViewModel: YXNewSearchViewModel = {
        let searchViewModel = YXNewSearchViewModel()
        if let appDelegate = YXConstant.sharedAppDelegate as? YXAppDelegate {
            searchViewModel.services = appDelegate.appServices
        }
        
        return searchViewModel
    }()
    
    lazy var resultController: YXSearchListController = {
        let viewController = UIStoryboard.init(name: "YXSearchViewController", bundle: nil).instantiateViewController(withIdentifier: "YXSearchListController") as! YXSearchListController
        viewController.newType = true
        viewController.viewModel = self.searchViewModel.resultViewModel
        viewController.viewModel?.types = self.searchViewModel.types
        viewController.ishiddenLikeButton = true

        return viewController
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()
    
    func setupSearchBar() {
        
//        searchBar.cameraBtn.isHidden = true
        searchBar.textField.snp.updateConstraints { (make) in
            make.right.equalToSuperview().offset(0)
        }
        
        searchBar.textField.placeholder = YXLanguageUtility.kLang(key: SearchLanguageKey.placeholder.rawValue)
        
        _ = searchBar.cancelBtn.rx.tap.asControlEvent().takeUntil(rx.deallocated).subscribe(onNext: { [weak self](_) in
            self?.hidden()
        })
        
        _ = searchBar.textField.rx.controlEvent(.editingDidEndOnExit).takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] (e) in
            if let count = self?.searchViewModel.resultViewModel.list.value?.count(), count == 1 {
                self?.searchViewModel.resultViewModel.cellTapAction(at: 0)
            }
        })
        
        _ = searchBar.textField.rx.text.throttle(0.5, scheduler: MainScheduler.instance).takeUntil(self.rx.deallocated).filter({ (text) -> Bool in
            text != nil
        }).subscribe(onNext: { [weak self](text) in
            if let text = text,text != "" {
                _ = self?.searchViewModel.search(text: text)
            } else {
                self?.hideResultView()
            }
        })
        
        //监听搜索结果
        _ = searchViewModel.resultViewModel.list.asObservable().filter({ (list) -> Bool in
            list != nil
        }).takeUntil(self.rx.deallocated).subscribe(onNext: {[weak self] (list) in
            self?.showResultView()
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let maskPath = UIBezierPath(
            roundedRect: CGRect.init(x: 0, y: 0, width: self.bounds.width, height: resultController.view.isHidden ? 128 : self.frame.size.height),
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: 20, height: 20))

        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        self.containerView.layer.mask = shape
    }
    
    func show() {
        self.isHidden = false
        
        self.searchBar.textField.text = ""
        self.hideResultView()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.snp.updateConstraints { (make) in
                make.top.equalToSuperview()
            }
            self.layoutIfNeeded()
        })
    }
    
    func hidden() {
        // 收起键盘
        self.endEditing(true)
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.snp.updateConstraints { (make) in
                let h = self.resultController.view.isHidden ? 128 : self.frame.size.height
                make.top.equalToSuperview().offset(-h)
            }
            self.layoutIfNeeded()
        }) { (finished) in
            self.isHidden = true
            self.didHideBlock?(finished)
        }
    }
    
    func showResultView() {
        self.resultController.view.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.containerView.snp.updateConstraints { (make) in
                make.height.equalTo(self.frame.size.height)
            }
            self.layoutIfNeeded()
        }
    }
    
    func hideResultView() {
        self.resultController.view.isHidden = true
        UIView.animate(withDuration: 0.3) {
            self.containerView.snp.updateConstraints { (make) in
                make.height.equalTo(128)
            }
            self.layoutIfNeeded()
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            self?.hidden()
        }).disposed(by: bag)
        
        self.backgroundColor = QMUITheme().shadeLayerColor()
        
         addSubview(containerView)
        
        containerView.addSubview(allStockButton)
        containerView.addSubview(searchBar)
        containerView.addSubview(resultController.view)
        
        if let parentVC = self.parentViewController {
            parentVC.addChild(resultController)
        }
       
        
        containerView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(-128)
            make.height.equalTo(128)
        }
        
        allStockButton.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().offset(14)
        }
        
        searchBar.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(14)
            make.top.equalTo(allStockButton.snp.bottom).offset(14)
            make.right.equalToSuperview().offset(-14)
            make.height.equalTo(38)
        }
        
        resultController.view.snp.makeConstraints { (make) in
            make.top.equalTo(searchBar.snp.bottom).offset(10)
            make.bottom.left.right.equalToSuperview()
        }
        
        setupSearchBar()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
