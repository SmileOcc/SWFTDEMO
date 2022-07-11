//
//  YXCourseListViewController.swift
//  uSmartEducation
//
//  Created by 覃明明 on 2021/8/20.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import YXKit

class YXCourseListViewController: YXHKTableViewController {
    
    let viewModel = YXCourseListViewModel()
    
    var dataSource = [YXCourseListItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        getCourseList()
    }
    
    func setupUI() {
        tableView.register(YXCourseCell.self, forCellReuseIdentifier: NSStringFromClass(YXCourseCell.self))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
    
    func getCourseList() {
        viewModel.getCourseList().subscribe { [weak self]resModel in
           //self?.refreshHeader.endRefreshing()
            self?.hideEmptyView()
            if let list = resModel?.list {
                self?.dataSource = list
                self?.tableView.reloadData()
                if list.count == 0 {
                    self?.showNoDataEmptyView()
                }
            }
        } onError: { [weak self] err in
           // self?.refreshHeader.endRefreshing()
            self?.showErrorEmptyView()
        }.disposed(by: disposeBag)

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.dataSource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(YXCourseCell.self), for: indexPath) as! YXCourseCell
        cell.model = item
        cell.clickBlock = {[weak self] (item) in
            YXToolUtility.handleBusinessWithLogin { [weak self] in
                guard let `self` = self else { return }
                let item = self.dataSource[indexPath.row]
                if let courseId = item.courseId {
                    ///免费课程或者用户已付费，跳转详情页
                    if item.coursePaidType == 0 || item.coursePaidFlag == true {
                        let dic: [String: Any] = ["courseId":courseId]
                     YXNavigationMap.navigator.push(YXModulePaths.courseDetail.url, context: dic, from: nil, animated: true)
 //                    NavigatorServices.shareInstance.pushPath(YXModulePaths.courseDetail, context: dic, animated: true)
                    } else {
                        let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.courseUrl(courseId: courseId, lessonId: "")]
 //                    NavigatorServices.shareInstance.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                     YXNavigationMap.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic), from: nil, animated: true)
                    }
                }
            }
            
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 124
    }
       
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        let item = self.dataSource[indexPath.row]
        if let courseId = item.courseId {
            ///免费课程或者用户已付费，跳转详情页
            if item.coursePaidType == 0 || item.coursePaidFlag == true {
                let dic: [String: Any] = ["courseId":courseId]
                YXNavigationMap.navigator.push(YXModulePaths.courseDetail.url, context: dic, from: nil, animated: true)
                //                    NavigatorServices.shareInstance.pushPath(YXModulePaths.courseDetail, context: dic, animated: true)
            } else {
                let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.courseUrl(courseId: courseId, lessonId: "")]
                //                    NavigatorServices.shareInstance.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                YXNavigationMap.navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic), from: nil, animated: true)
            }
        }
    }

}

extension YXCourseListViewController {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let parent = self.parent as? YXCourseListTabViewController {
            parent.scrollCallBack?(scrollView)
        }
    }
}
