//
//  YXSwipeViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2019/4/4.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit


struct YXSwipeBarConfig {
    var segmentViewHeight = CGFloat(40)
    var lineHeight = CGFloat(2)
    var lineWidth = CGFloat(46)
    var lineBottomMargin = CGFloat(0)
    var lineColor = QMUITheme().themeTextColor()
    var normalTitleColor = QMUITheme().textColorLevel1()
    var selectTitleColor = QMUITheme().themeTextColor()
    var normalTitleFont = UIFont.systemFont(ofSize: 16)
    var selectTitleFont = UIFont.systemFont(ofSize: 16)
    
    init(segmentViewHeight: CGFloat = 40, lineHeight: CGFloat = 2, lineWidth: CGFloat = 46, lineBottomMargin: CGFloat = 0, lineColor: UIColor = QMUITheme().themeTextColor(), normalTitleColor: UIColor = QMUITheme().textColorLevel1(), selectTitleColor: UIColor = QMUITheme().themeTextColor(), normalTitleFont: UIFont =  UIFont.systemFont(ofSize: 16),  selectTitleFont: UIFont = UIFont.systemFont(ofSize: 16)) {
        self.segmentViewHeight = segmentViewHeight
        self.lineHeight = lineHeight
        self.lineWidth = lineWidth
        self.lineColor = lineColor
        self.lineBottomMargin = lineBottomMargin
        self.normalTitleFont = normalTitleFont
        self.normalTitleColor = normalTitleColor
        self.selectTitleFont = selectTitleFont
        self.selectTitleColor = selectTitleColor
    }
}


class YXSwipeViewController: YXHKViewController {
    
    var viewControllersArray = [UIViewController]() {
        didSet {
            refreshUI()
        }
    }
    
    var config: YXSwipeBarConfig! = YXSwipeBarConfig() {
        didSet {
            refreshUI()
        }
    }
    
    var titlesArray = [String]() {
        didSet {
            refreshUI()
        }
    }
    
    var currentPageIndex: Int = 0

    fileprivate var isFirst: Bool = true
    
    fileprivate var pageController = UIPageViewController.init(transitionStyle: UIPageViewController.TransitionStyle.scroll, navigationOrientation: UIPageViewController.NavigationOrientation.horizontal, options: nil)
    
    fileprivate var viewWidth = CGFloat(YXConstant.screenWidth)
    fileprivate var buttons = [UIButton]()
    fileprivate var isPageScrollingFlag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = QMUITheme().foregroundColor()
        self.view.addSubview(segmentBar)
        segmentBar.addSubview(lineView)
        setPageController()
    }
    
    func setPageController() {
        
        self.view.addSubview(pageController.view)
        self.addChild(pageController)
        pageController.dataSource = self
        
        for view in pageController.view.subviews {
            if let view = view as? UIScrollView {
                view.isScrollEnabled = false
            }
        }
    }
    
    func setCurrentPage(pageIndex: Int) {
        
        guard pageIndex < viewControllersArray.count else {
            return
        }
        currentPageIndex = pageIndex
        pageController.setViewControllers([viewControllersArray[pageIndex]], direction: .forward, animated: true, completion: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if isFirst {
            isFirst = false
            refreshUI()
        }
    }
    
    //MARK: SegmentBar View
    lazy var segmentBar: UIView = {
        let view = UIView()
        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().separatorLineColor()
        view.addSubview(lineView)
        lineView.snp.makeConstraints({ (make) in
            make.left.right.bottom.equalTo(view)
            make.height.equalTo(1)
        })
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()
    
    lazy var lineView: UIView = {
        let view = UIView()
        return view
    }()
    
    func refreshUI() {
        
        guard viewControllersArray.count > 0 && titlesArray.count > 0 && viewControllersArray.count == titlesArray.count else {
            return
        }
        
        var topMargin = CGFloat(0)
        if let naviBar = self.navigationController, naviBar.isNavigationBarHidden == false {
            topMargin = YXConstant.navBarHeight()
        }
        segmentBar.frame = CGRect(x: 0, y: topMargin, width: viewWidth, height: config.segmentViewHeight)
        lineView.frame = CGRect(x: 0, y: config.segmentViewHeight - config.lineBottomMargin - config.lineHeight, width: config.lineWidth, height: config.lineHeight)
        lineView.backgroundColor = config.lineColor
        lineView.layer.cornerRadius = config.lineHeight/2.0
        pageController.view.frame = CGRect(x: 0, y: segmentBar.frame.height + topMargin, width: self.view.frame.width, height:(YXConstant.screenHeight - segmentBar.frame.height - YXConstant.navBarHeight()))
        pageController.setViewControllers([viewControllersArray[currentPageIndex]], direction: .forward, animated: false, completion: nil)

        addSegmentButton()
    }
    
    func addSegmentButton() {
        
        for view in segmentBar.subviews {
            if view is UIButton {
                view.removeFromSuperview()
            }
        }
        
        let buttonWidth = segmentBar.frame.width / CGFloat(viewControllersArray.count)
        let buttonHeight = segmentBar.frame.height
        
        for index in 0..<viewControllersArray.count {
            let button = UIButton()
            button.backgroundColor = QMUITheme().foregroundColor()
            button.frame = CGRect(x: CGFloat(index) * buttonWidth, y: 0, width: buttonWidth, height: buttonHeight)
            button.tag = index + 1024
            button.setTitleColor(config.normalTitleColor, for: .normal)
            button.setTitleColor(config.selectTitleColor, for: .selected)
            button.titleLabel?.font = config.normalTitleFont
            button.setTitle(titlesArray[index], for: .normal)
            button.addTarget(self, action: #selector(segmentBarClick(sender:)), for: .touchUpInside)
            segmentBar.addSubview(button)
            if index == currentPageIndex {
                button.isSelected = true
                self.lineView.center = CGPoint(x: button.center.x, y: self.lineView.center.y)
            }
        }
        
        segmentBar.addSubview(lineView)
        segmentBar.bringSubviewToFront(self.lineView)
    }
    
    @objc func segmentBarClick(sender: UIButton) {
        
        let tag = sender.tag - 1024
        if (currentPageIndex == tag || isPageScrollingFlag == true) {
            return
        }
        let forward: Bool = tag > currentPageIndex
        sender.isSelected = !sender.isSelected
        if let lastButton = self.view.viewWithTag(self.currentPageIndex + 1024) as? UIButton {
            lastButton.isSelected = false
        }
        UIView.animate(withDuration: 0.1) {
            self.lineView.center = CGPoint(x: sender.center.x, y: self.lineView.center.y)
        }
        
        pageController.setViewControllers([viewControllersArray[tag]], direction: forward ? .forward : .reverse, animated: true) { [weak self] (complete) in
            guard let `self` = self else { return }
            if complete {
                self.updateCurrentPageIndex(tag)
            }
        }
    }
    
    func updateCurrentPageIndex(_ index: Int) {
        currentPageIndex = index
    }
    
}

extension YXSwipeViewController: UIPageViewControllerDataSource {
    
    func  pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = viewControllersArray.firstIndex(of: viewController) else {return nil}
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 && viewControllersArray.count > previousIndex else {return nil}
        
        return viewControllersArray[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = viewControllersArray.firstIndex(of: viewController) else {return nil}
        let nextIndex = viewControllerIndex + 1
        guard viewControllersArray.count > nextIndex else {return nil}
        
        return viewControllersArray[nextIndex]
    }
}
