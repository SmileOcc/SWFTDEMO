//
//  Refreshable.swift
//  uSmartOversea
//
//  Created by ellison on 2019/4/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import RxDataSources
import RxSwift
import RxCocoa

protocol RefreshViweModelBased: ViewModelBased where ViewModelType: RefreshViewModel {
    
    var refreshHeader: YXRefreshHeader { get }
    var refreshFooter: YXRefreshAutoNormalFooter? { get }
}

extension RefreshViweModelBased where Self: YXHKTableViewController {
    func setupRefreshHeader(_ scrollView: UIScrollView) {
        scrollView.mj_header = refreshHeader;
        viewModel.endHeaderRefreshStatus = viewModel.bindHeaderRefresh(dependency: (headerRefresh: refreshHeader.rx.refreshing.asDriver(), disposeBag: rx.disposeBag))
        viewModel.endHeaderRefreshStatus?.drive(refreshHeader.rx.endRefreshStatus).disposed(by: rx.disposeBag)
        viewModel.endHeaderRefreshStatus?.drive(onNext: { [weak self] (status) in
            guard let strongSelf = self else { return }
            
            switch status {
            case .error:
                strongSelf.showErrorEmptyView()
            case .noData:
                strongSelf.showNoDataEmptyView()
            case .noMoreData,
                 .hasDataWithError:
                strongSelf.hideEmptyView()
            default:
                strongSelf.hideEmptyView()
                
                if scrollView.mj_footer == nil {
                    strongSelf.setupRefreshFooter(scrollView)
                }
            }
            
        }).disposed(by: rx.disposeBag)
    }
    
    func setupRefreshFooter(_ scrollView: UIScrollView) {
        guard refreshFooter != nil else { return }
        scrollView.mj_footer = refreshFooter;
        viewModel.endHeaderRefreshStatus = viewModel.bindFooterRefresh(dependency: (footerRefresh: refreshFooter!.rx.refreshing.asDriver(), disposeBag: rx.disposeBag))
        viewModel.endHeaderRefreshStatus?.drive(refreshFooter!.rx.endRefreshStatus).disposed(by: rx.disposeBag)
    }
    
}

extension RefreshViweModelBased where Self: YXHKViewController {
    func setupRefreshHeader(_ scrollView: UIScrollView) {
        scrollView.mj_header = refreshHeader;
        viewModel.endHeaderRefreshStatus = viewModel.bindHeaderRefresh(dependency: (headerRefresh: refreshHeader.rx.refreshing.asDriver(), disposeBag: rx.disposeBag))
        viewModel.endHeaderRefreshStatus?.drive(refreshHeader.rx.endRefreshStatus).disposed(by: rx.disposeBag)
        viewModel.endHeaderRefreshStatus?.drive(onNext: { [weak self] (status) in
            guard let strongSelf = self else { return }
            
            switch status {
            case .error:
                strongSelf.showErrorEmptyView()
            case .noData:
                strongSelf.showNoDataEmptyView()
            case .noMoreData,
                 .hasDataWithError:
                strongSelf.hideEmptyView()
            default:
                strongSelf.hideEmptyView()
                
                if scrollView.mj_footer == nil {
                    strongSelf.setupRefreshFooter(scrollView)
                }
            }
            
        }).disposed(by: rx.disposeBag)
    }
    
    func setupRefreshFooter(_ scrollView: UIScrollView) {
        guard refreshFooter != nil else { return }
        scrollView.mj_footer = refreshFooter;
        viewModel.endHeaderRefreshStatus = viewModel.bindFooterRefresh(dependency: (footerRefresh: refreshFooter!.rx.refreshing.asDriver(), disposeBag: rx.disposeBag))
        viewModel.endHeaderRefreshStatus?.drive(refreshFooter!.rx.endRefreshStatus).disposed(by: rx.disposeBag)
    }
    
}

enum EndRefreshStatus {
    case error
    case hasDataWithError
    case noData
    case endHeaderRefresh
    case endFooterRefresh
    case noMoreData
}

extension Reactive where Base: MJRefreshComponent {
    
    var refreshing: ControlEvent<Void> {
        let source: Observable<Void> = Observable.create {
            [weak control = self.base] observer  in
            if let control = control {
                control.refreshingBlock = {
                    observer.on(.next(()))
                }
            }
            return Disposables.create()
        }
        return ControlEvent(events: source)
    }
    
//    var endRefreshing: Binder<Bool> {
//        return Binder(base) { refresh, isEnd in
//            if isEnd {
//                refresh.endRefreshing()
//            }
//        }
//    }
    
    var endRefreshStatus: Binder<EndRefreshStatus> {
        return Binder(base) { refresh, status in
            switch status {
            case .noData,
                 .error,
                 .hasDataWithError:
                refresh.endRefreshing()
                break
            case .endHeaderRefresh,
                 .endFooterRefresh:
                refresh.endRefreshing()
                break
            case .noMoreData:
                if let refresh = refresh as? MJRefreshFooter {
                    refresh.endRefreshingWithNoMoreData()
                } else {
                    refresh.endRefreshing()
                }
            }
        }
    }
}
