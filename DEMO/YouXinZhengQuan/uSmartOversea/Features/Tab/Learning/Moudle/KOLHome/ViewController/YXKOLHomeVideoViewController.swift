//
//  YXKOLHomeShortVideoViewController.swift
//  uSmartEducation
//
//  Created by usmart on 2022/2/18.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import Foundation
import UIKit
import YXKit
import RxSwift
import RxCocoa
import QMUIKit
import SnapKit

class YXKOLHomeVideoViewController: YXHKViewController {
    
    override var pageName: String {
        return "kol个人主页"
    }
    
    lazy var topline: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().separatorLineColor()
        return view
    }()
    
    let collectAction = PublishSubject<YXSpecialArticleItem?>()
    let kolId = BehaviorRelay<String>(value: "")
    let businessType = BehaviorRelay<YXKOLHomeContentType>(value: .video)
    var viewModel: YXKOLHomeContentViewModel!
    var scrollCallBack: YXTabPageScrollBlock?
    var nextPageNum = 2
    var dataSource: [YXKOLVideoResModel]? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    lazy var refreshHeader: YXRefreshHeader = {
        return YXRefreshHeader()
    }()
    
    lazy var refreshFooter: YXRefreshAutoNormalFooter = {
        let footer = YXRefreshAutoNormalFooter.init()
        footer.setStateTextColor(QMUITheme().textColorLevel3())
        footer.activityIndicatorViewStyle = .gray;
        return footer
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let itemWidth = (YXConstant.screenWidth - 42) / 3.0
        let itemHeight = (160/108)*itemWidth + 64
        layout.itemSize = CGSize(width: itemWidth, height: (209/109)*itemWidth)
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 20, left: 16, bottom: 16, right: 16)
        let collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.mj_footer = refreshFooter
        collectionView.isPrefetchingEnabled = false
        collectionView.backgroundColor = QMUITheme().foregroundColor()
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(YXKOLVideoCell.self, forCellWithReuseIdentifier: NSStringFromClass(YXKOLVideoCell.self))
        return collectionView
    }()
    
    init(kolId: String?) {
        super.init(nibName: nil, bundle: nil)
        self.kolId.accept(kolId ?? "")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didInitialize() {
        super.didInitialize()
        initInput()
    }
    
    func initInput() {
        
        let viewDidLoad = self.rx.methodInvoked(#selector(viewDidLoad)).map { e in
            return ()
        }.asDriver(onErrorJustReturn: ())
        
        let loadMore = self.refreshFooter.rx.refreshing.map { [weak self] _ in
            return self?.nextPageNum ?? 1
        }.asDriver(onErrorJustReturn: 1)
        
        
        viewModel = YXKOLHomeContentViewModel(input: (viewDidLoad: viewDidLoad,
                                                      kolId: kolId.asDriver(onErrorJustReturn: ""),
                                                      businessType:businessType.asDriver(onErrorJustReturn: .video),
                                                      collectAction: collectAction,
                                                      loadMore: loadMore,
                                                      reload: self.refreshHeader.rx.refreshing.asDriver()))
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.binding()
    }
    
    func setupUI() {
        view.addSubview(topline)
        view.addSubview(collectionView)

        topline.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(0)
            make.right.equalToSuperview().offset(0)
            make.top.equalToSuperview()
            make.height.equalTo(0.5)
        }
        view.addSubview(collectionView)
        emptyView?.verticalOffset = -YXConstant.screenHeight/5
        collectionView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(topline.snp.bottom)

        }
    }
    
    func binding() {
        
        viewModel.result.drive { [weak self] list in
            guard let `self` = self else { return }
            if let list = list as? [YXKOLVideoResModel] {
                self.dataSource = list
                if (list.count == 0) {
                    self.showNoDataEmptyView()
                    self.refreshFooter.isHidden = true
                } else {
                    self.hideEmptyView()
                    self.refreshFooter.isHidden = false
                }
            } else {
                self.hideEmptyView()
            }
            
        }.disposed(by: disposeBag)
        
        viewModel.loadMoreListResult.drive { [weak self] list in
            guard let `self` = self else { return }
            if let list = list as? [YXKOLVideoResModel] {
                if list.count == 0 {
                    self.refreshFooter.endRefreshingWithNoMoreData()
                } else {
                    self.refreshFooter.endRefreshing()
                    self.dataSource = (self.dataSource ?? [] ) + list
                    self.nextPageNum += 1
                }
            } else {
                self.refreshFooter.endRefreshing()
            }
        }.disposed(by: disposeBag)
        
    }
}

extension YXKOLHomeVideoViewController: UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXKOLVideoCell.self), for: indexPath) as! YXKOLVideoCell
        cell.model = dataSource?[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if YXUserManager.isLogin() {
            if let resModle = dataSource?[indexPath.row] {
                NavigatorServices.shareInstance.pushPath(YXModulePaths.kolShortVideoPlay, context: ["videoId":resModle.videoIdStr], animated: true)
                self.trackViewClickEvent(name: "短视频", other: [YXSensorAnalyticsPropsConstant.PROP_VIDEO_ID:resModle.videoIdStr ?? ""])
            }
        } else {
            YXToolUtility.handleBusinessWithLogin{
                
            }
        }

    }
}

extension YXKOLHomeVideoViewController:UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollCallBack?(scrollView)
    }
}

extension YXKOLHomeVideoViewController: YXTabPageScrollViewProtocol {
    func pageScrollView() -> UIScrollView {
        return collectionView
    }
    
    func pageScrollViewDidScrollCallback(_ callback: @escaping YXTabPageScrollBlock) {
        scrollCallBack = callback
    }
}
