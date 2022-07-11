//
//  RefreshBased.swift
//  uSmartOversea
//
//  Created by ellison on 2019/4/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import RxDataSources
import RxSwift
import RxCocoa
import NSObject_Rx


protocol DataSourceViewModel: ServicesViewModel where Self: AnyObject {
    associatedtype IdentifiableModel: IdentifiableType
    
    var dataSourceSingle: Single<[IdentifiableModel]> { get }
    var dataSource: BehaviorRelay<[IdentifiableModel]> { get }
}

extension DataSourceViewModel {
    func requestRemote() -> Driver<[IdentifiableModel]?> {
        requestRemote(atOnce: false)
    }
    
    func requestRemote(atOnce: Bool) -> Driver<[IdentifiableModel]?> {
        let observable = Observable<[IdentifiableModel]?>.create { [weak self] observer -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            
            return strongSelf.dataSourceSingle.subscribe(onSuccess: { (models) in
                observer.onNext(models)
                observer.onCompleted()
            }) { (error) in
                observer.onNext(nil)
                observer.onError(error)
            }
        }
        
        let driver = observable.asDriver(onErrorDriveWith: Driver.empty())
        
        if atOnce {
            _ = driver.drive(onNext: { [weak self] items in
                if let data = items {
                    self?.dataSource.accept(data)
                }
            })
        }
        
        return driver
    }
}


protocol RefreshViewModel: DataSourceViewModel {
    
    var endHeaderRefreshStatus: Driver<EndRefreshStatus>? { get set }
    var endFooterRefreshStatus: Driver<EndRefreshStatus>? { get set }
    
    var page: Int { get set }
    var offset: Int { get set }
    var perPage: Int { get set }
    var total: Int? { get set}
}

extension RefreshViewModel where Self: AnyObject {
    func offsetForPage(_ page: Int) -> Int {
        return (page - 1) * perPage
    }
    
    func bindHeaderRefresh(dependency: (headerRefresh: Driver<Void>, disposeBag: DisposeBag)) -> Driver<EndRefreshStatus>  {
        let headerRefreshData = dependency.headerRefresh.flatMapLatest {
            return self.requestFirstPage()
        }

        headerRefreshData.drive(onNext: { [weak self] items in
            if let data = items {
                self?.dataSource.accept(data)
            }
        }).disposed(by: dependency.disposeBag)
        
        return headerRefreshData.map({ [weak self] (list) -> EndRefreshStatus in
            if let array = list {
                if array.count > 0 {
                    if let total = self?.total, array.count >= total  {
                        return .noMoreData
                    }
                    return .endHeaderRefresh
                } else {
                    return .noData
                }
            } else {
                if let dataSource = self?.dataSource.value, dataSource.count > 0 {
                    return .hasDataWithError
                }
                return .error 
            }
        })
    }
    
    func bindFooterRefresh(dependency: (footerRefresh: Driver<Void>, disposeBag: DisposeBag)) -> Driver<EndRefreshStatus>  {
        let footerRefreshData = dependency.footerRefresh.flatMapLatest {
            return self.requestNextPage()
        }
        
        footerRefreshData.drive(onNext: { [weak self] items in
            guard let strongSelf = self else { return }
            
            strongSelf.dataSource.accept(strongSelf.dataSource.value + (items ?? []))
        }).disposed(by: dependency.disposeBag)
        
        return dataSource.asDriver().map({ [weak self] (array) -> EndRefreshStatus in
            if let total = self?.total, array.count >= total {
                return .noMoreData
            } else {
                return .endFooterRefresh
            }
        })
    }
    
    func requestFirstPage() -> Driver<[IdentifiableModel]?> {
        page = 1
        offset = offsetForPage(page)
        
        return requestRemote()
    }
    
    func requestNextPage() -> Driver<[IdentifiableModel]?> {
        page += 1
        offset = offsetForPage(page)
        
        return requestRemote()
    }
}
