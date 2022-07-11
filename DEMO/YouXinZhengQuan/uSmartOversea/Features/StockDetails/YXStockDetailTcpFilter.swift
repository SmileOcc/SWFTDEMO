//
//  YXStockDetailTcpFilter.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2021/5/17.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

let kTcpFilterInterval: TimeInterval = 0.5

class YXStockDetailTcpFilter<T: Codable>: NSObject {
    
    let publishSubject = PublishSubject<T>()

    init(interval: TimeInterval, excute: ((_ model: T) -> Void)?) {
        super.init()
        
        publishSubject.throttle(interval, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                model in
                
                excute?(model)
            }).disposed(by: self.rx.disposeBag)
    }
    
    func onNext(_ model: T) {
        publishSubject.onNext(model)
    }

}

class YXStockDetailTcpTimer: NSObject {
    
    var tcpTimer: Timer?
    
    @objc var model: Any?
    
    @objc var scheme: Scheme = .tcp
    
    private var needRefresh = false
    var interval: TimeInterval = 0

    var excute: ((_ model: Any, _ scheme: Scheme) -> Void)?
    @objc init(interval: TimeInterval = kTcpFilterInterval, excute: ((_ model: Any, _ scheme: Scheme) -> Void)?) {
        super.init()
        self.interval = interval
        self.excute = excute
    }
    
    @objc func refreshData() {
        if let model = self.model {
            excute?(model, self.scheme)
            self.model = nil
        }
    }
    
    private var task: DispatchQueue.Task?
    @objc func onNext(_ model: Any, scheme: Scheme = .tcp) {
        self.model = model
        self.scheme = scheme
        if scheme == .http {
            refreshData()
        } else {
            if task == nil {
                task = DispatchQueue.delay(interval, task: { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.refreshData()
                    strongSelf.task = nil
                })
            }
        }
    }



    
    @objc func invalidate() {
        DispatchQueue.cancel(task)
        task = nil
    }
}
