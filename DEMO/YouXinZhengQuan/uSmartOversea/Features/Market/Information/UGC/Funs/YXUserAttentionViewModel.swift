//
//  YXUserAttentionViewModel.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/6/1.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXUserAttentionViewModel: YXTableViewModel {
    
    var request: YXRequest?
    var itemList:[YXUserAttentionItemModel] = []
    @objc var target_uid:String = ""
    
    @objc var isAttention:Bool = false  //是关注还是粉丝
    let publishSub = PublishSubject<Bool>()
    var notShowLoading: Bool = false
    
    override func initialize() {
        super.initialize()
        self.page = 1
        self.shouldPullToRefresh = true
        self.shouldInfiniteScrolling = true
        if let uid = self.params?["target_uid"] as? String, let isAttention = self.params?["isAttention"] as? Bool {
            self.target_uid = uid
            self.isAttention = isAttention
        }
        
        
        self.didSelectCommand = RACCommand.init(signal: { [weak self] (indexPath) -> RACSignal<AnyObject> in
            guard let `self` = self else { return RACSignal.empty()}
            if let indexPath = indexPath {
                if let item = self.dataSource[indexPath.section][indexPath.row] as? YXUserAttentionItemModel {

                    YXUGCCommentManager.gotoUserCenter(uid: item.uid)
                }
            }

            return RACSignal.empty()
        })
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
        
        if self.isAttention {
            return reqAttentionsData(page: page)
        }else{
            return reqFunsData(page: page)
        }
       
        
    }
    
    func reqAttentionsData(page:UInt) -> RACSignal<AnyObject> {
        return RACSignal.createSignal { [weak self](subscriber) -> RACDisposable? in
            
            guard let strongSelf = self else { return nil }
            if let request = strongSelf.request {
                request.stop()
                strongSelf.request = nil
            }
            
            let requestModel = YXQueryConcernListReq()
            requestModel.offset = Int((page - 1 ) * 20)
            requestModel.limit = 20
            requestModel.target_uid = strongSelf.target_uid
            
            let request = YXRequest.init(request:requestModel)
            
            if !strongSelf.notShowLoading {
               let _ = YXProgressHUD.showLoading("", in: UIViewController.current().view)
            }

            request.startWithBlock(success: { [weak self](model) in
                guard let `self` = self else { return }
               
                YXProgressHUD.hide(for: UIViewController.current().view, animated: true)
                
                
                guard let modelData = model as? YXUserAttentionModel else {
                    return
                }
                if page == 1 {
                    self.itemList = modelData.list
  
                }else{
                    if (self.itemList.count ) > 0 {
                        self.itemList.append(contentsOf: modelData.list )
                    }
                    self.loadNoMore = (modelData.list.count < 20)
                }
                self.publishSub.onNext((self.itemList.count > 0))
                self.dataSource = [self.itemList]
                subscriber.sendNext(nil)
                subscriber.sendCompleted()
                self.notShowLoading = false
            }, failure: { [weak self] (request) in
                guard let `self` = self else { return }
                self.notShowLoading = false
            })
            return nil
        }
    }
    
    func reqFunsData(page:UInt) -> RACSignal<AnyObject> {
        return RACSignal.createSignal { [weak self](subscriber) -> RACDisposable? in
            
            guard let strongSelf = self else { return nil }
            if let request = strongSelf.request {
                request.stop()
                strongSelf.request = nil
            }
            
            let requestModel = YXQueryFunsListReq()
            requestModel.offset = Int((page - 1 ) * 20)
            requestModel.limit = 20
            requestModel.target_uid = self?.target_uid ?? ""
            
            let request = YXRequest.init(request:requestModel)
            if !strongSelf.notShowLoading {
               let _ = YXProgressHUD.showLoading("", in: UIViewController.current().view)
            }
            
            request.startWithBlock(success: { [weak self](model) in
                guard let `self` = self else { return }
          
                YXProgressHUD.hide(for: UIViewController.current().view, animated: true)
                
                guard let modelData = model as? YXUserAttentionModel else {
                    return
                }
                if page == 1 {
                    self.itemList = modelData.list
  
                }else{
                    if (self.itemList.count ) > 0 {
                        self.itemList.append(contentsOf: modelData.list )
                    }
                    self.loadNoMore = (modelData.list.count < 20)
                }
              
                self.publishSub.onNext((self.itemList.count > 0))
                
                self.dataSource = [self.itemList]
                subscriber.sendNext(nil)
                subscriber.sendCompleted()
                self.notShowLoading = false
            }, failure: { [weak self] (request) in
                guard let `self` = self else { return }
                self.notShowLoading = false
            })
            return nil
        }
    }

}
