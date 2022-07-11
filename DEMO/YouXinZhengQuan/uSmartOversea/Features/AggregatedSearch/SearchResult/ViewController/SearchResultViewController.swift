//
//  SearchResultViewController.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/2/28.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import JXSegmentedView

class SearchResultViewController: YXViewController {

    var searchWord: String = "" {
        didSet {
            if let vc = listContainerView.validListDict[segmentedView.selectedIndex] as? SearchResultListViewController {
                vc.searchWord = searchWord
            }
        }
    }

    private lazy var segmentedDataSource: JXSegmentedBaseDataSource? = {
        let titles = SearchType.allCases.map { $0.title }
        let titleDataSource = JXSegmentedTitleDataSource()
        titleDataSource.titles = titles
        titleDataSource.titleNormalColor = QMUITheme().textColorLevel2()
        titleDataSource.titleSelectedColor = QMUITheme().textColorLevel1()
        titleDataSource.titleNormalFont = .normalFont16()
        titleDataSource.titleSelectedFont = .mediumFont16()
        titleDataSource.itemSpacing = 24
        return titleDataSource
    }()

    private lazy var segmentedView: JXSegmentedView = {
        let view = JXSegmentedView()
        view.contentEdgeInsetLeft = 16
        view.contentEdgeInsetRight = 40
        view.isContentScrollViewClickTransitionAnimationEnabled = false
        view.delegate = self

        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorWidth = 20
        indicator.indicatorHeight = 4
        indicator.indicatorCornerRadius = 2
        indicator.indicatorColor = QMUITheme().themeTextColor()
        indicator.verticalOffset = 5
        view.indicators = [indicator]

        return view
    }()

    private lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()

    lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer: CAGradientLayer = CAGradientLayer.init()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 40, height: 44)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 0.15)

        var color: UIColor = UIColor.white
        if YXThemeTool.isDarkMode() {
            color = UIColor.qmui_color(withHexString: "#101014")!
        }
        gradientLayer.colors = [color.cgColor, color.cgColor, color.withAlphaComponent(0).cgColor]

        gradientLayer.locations = [0, 0.77, 1]
        gradientLayer.startPoint = CGPoint(x: 0.99, y: 0.27)
        gradientLayer.endPoint = CGPoint(x: 0.27, y: 0.27)
        gradientLayer.rasterizationScale = UIScreen.main.scale
        return gradientLayer
    }()

    lazy var gradientView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.layer.addSublayer(gradientLayer)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = QMUITheme().foregroundColor()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = gradientView.bounds
    }

    override func initSubviews() {
        //segmentedViewDataSource一定要通过属性强持有！！！！！！！！！
        segmentedView.dataSource = segmentedDataSource
        view.addSubview(segmentedView)

        segmentedView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(strongNoticeView.snp.bottom)
            make.height.equalTo(50)
        }

        segmentedView.listContainer = listContainerView
        view.addSubview(listContainerView)
        listContainerView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(segmentedView.snp.bottom)
        }

        view.addSubview(gradientView)
        gradientView.snp.makeConstraints { make in
            make.top.right.equalTo(segmentedView)
            make.height.equalTo(44)
            make.width.equalTo(40)
        }
    }

    override func preferredNavigationBarHidden() -> Bool {
        true
    }

    override func bindViewModel() {
        super.bindViewModel()

        _ = NotificationCenter.default.rx.notification(Notification.Name(rawValue: "SearchTypeDidChangedNotification"))
            .subscribe(onNext: { [weak self] notification in
                guard let `self` = self, let searchType = notification.object as? SearchType else { return }

                self.segmentedView.selectItemAt(index: searchType.tabIndex)

                if let vc = self.listContainerView.validListDict[self.segmentedView.selectedIndex] as? SearchResultListViewController {
                    vc.resetSearchType(searchType: searchType)
                }
            }).disposed(by: rx.disposeBag)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        var color: UIColor = UIColor.white
        if YXThemeTool.isDarkMode() {
            color = UIColor.qmui_color(withHexString: "#101014")!
        }
        gradientLayer.colors = [color.cgColor, color.cgColor, color.withAlphaComponent(0).cgColor]
    }

}

extension SearchResultViewController: JXSegmentedViewDelegate {

    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        if let vc = listContainerView.validListDict[self.segmentedView.selectedIndex] as? SearchResultListViewController {
            vc.searchWord = searchWord
        }
    }

}

extension SearchResultViewController: JXSegmentedListContainerViewDataSource {

    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }

    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        let searchType = SearchType.allCases[index]
        let vm = SearchResultListViewModel(services: self.viewModel.services, params: ["type": searchType])
        vm.searchWord = searchWord
        let vc = SearchResultListViewController(viewModel: vm)
        return vc
    }

}
