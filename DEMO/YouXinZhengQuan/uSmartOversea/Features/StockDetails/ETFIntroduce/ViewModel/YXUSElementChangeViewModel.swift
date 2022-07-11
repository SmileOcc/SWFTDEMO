//
//  YXUSElementChangeViewModel.swift
//  uSmartOversea
//
//  Created by suntao on 2021/3/4.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXUSElementChangeViewModel: YXTableViewModel {
    
    var elementList:[YXUSElementChangeItemModel] = []
    var model: YXUSElementChangeResModel?
    @objc var uniqueSecuCode: String? //证券唯一编码
    var request: YXRequest?
    
    override func initialize() {
        super.initialize()
        self.page = 1
        self.shouldPullToRefresh = true
        self.shouldInfiniteScrolling = true
    }
    
    override var perPage: UInt {
        get {
            20
        }
        set {
            
        }
    }
    
    override func requestRemoteDataSignal(withPage page: UInt) -> RACSignal<AnyObject>! {
        self.page = page
        if self.page == 1 {
            self.loadNoMore = false;
        }
        return RACSignal.createSignal { [weak self](subscriber) -> RACDisposable? in
            
            guard let strongSelf = self else { return nil }
            if let request = strongSelf.request {
                request.stop()
                strongSelf.request = nil
            }
            
            let requestModel = YXUSGetElementChangeRequestModel()
            requestModel.start = Int((page - 1 ) * 20)
            requestModel.count = 20
            requestModel.uniqueSecuCode = self?.uniqueSecuCode ?? ""
            
            let request = YXRequest.init(request:requestModel)
            let loadingHud = YXProgressHUD.showLoading("")
            
            request.startWithBlock(success: { [weak self](response) in
                loadingHud.hide(animated: true)
                guard let `self` = self else { return }
                if response.code == YXResponseStatusCode.success {
                    
                    self.model = YXUSElementChangeResModel.yy_model(withJSON:response.data as Any)
                    if page == 1 {
                        self.elementList = self.model?.list ?? []
                    }else{
                        if (self.model?.list.count ?? 0) > 0 {
                            self.elementList.append(contentsOf: self.model?.list ?? [])
                        }
                        self.loadNoMore = (self.model?.list.count ?? 0 < 20)
                    }
                }
                self.dataSource = [self.elementList]
                subscriber.sendNext(nil)
                subscriber.sendCompleted()
                
            }, failure: { (request) in
                loadingHud.hide(animated: true)
            })
            return nil
        }
    }
    
}
