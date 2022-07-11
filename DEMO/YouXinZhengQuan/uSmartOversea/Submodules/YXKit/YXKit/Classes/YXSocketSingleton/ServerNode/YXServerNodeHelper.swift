//
//  YXServerNodeHelper.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2019/4/19.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import MMKV

@objcMembers public class ServerNode: NSObject {
    @objc public static func requestServerNode() {
        YXServerNodeHelper.shareInstane.isCancel = false
        if (YXSocketSingleton.shareInstance().connecting == false) {
            YXServerNodeHelper.shareInstane.requestServerNode()
        }
    }
    
    @objc public class func cancelRemoteRequest() {
        YXServerNodeHelper.shareInstane.cancelRequest()
    }
}

class YXServerNodeHelper: NSObject {
    
    let disposeBag = DisposeBag()
    let serverNode = YXServerNodeAPI.hzBaseUrl
    var isCancel = false
    
    static let shareInstane = YXServerNodeHelper()
    
    let kServerNodeKey = "masterAddr"
    func requestServerNode() {
        isCancel = false
        YXSocketSingleton.shareInstance().urls = YXUrlRouterConstant.socketBaseUrl()
        YXSocketSingleton.shareInstance().getServerNode { [weak self] (compelte) in
            guard let strongSelf = self, strongSelf.isCancel == false else { return }
            strongSelf.traversingNodes(node: strongSelf.serverNode, completion: {
                if let node = MMKV.default().object(of: NSString.self, forKey: strongSelf.kServerNodeKey), let serverNode = node as? String, serverNode.count > 0 {
                    var serverURL: URL
                    if serverNode.hasPrefix("http") {
                        serverURL = URL(string: serverNode)!
                    } else {
                        serverURL = URL(string: ("http://" + serverNode))!
                    }
                    
                    compelte(serverURL)
                } else {
                    
                    if let ipUrl = YXGlobalConfigManager.tcpIpUrl(), let url = URL(string: ipUrl) {
                        compelte(url)
                    } else {
                        compelte(nil)
                    }
                }
            })
        }
        
    }
    
    func traversingNodes(node: YXServerNodeAPI, completion: @escaping()->()) {
        
        if self.isCancel { return }
        if node == .none {
            completion()
            return
        }
        YXServerNodeProvider.rx.request(node).map(YXResult<YXServerNodeModel>.self).subscribe(onSuccess: { [weak self] (response) in
            guard let strongSelf = self, strongSelf.isCancel == false else { return }
            
            if response.code == YXResponseCode.success.rawValue, let model = response.data, let node = model.masterAddr, node.count > 0 {
                MMKV.default().set(node, forKey: strongSelf.kServerNodeKey)
                completion()
            } else {
                strongSelf.traversingNodes(node: node.selfAdd(), completion: {
                    completion()
                })
            }
            
            }, onError: { [weak self] error in
                guard let strongSelf = self, strongSelf.isCancel == false else { return }
                strongSelf.traversingNodes(node: node.selfAdd(), completion: {
                    completion()
                })
                
        }).disposed(by: disposeBag)
    }
    
    func cancelRequest() {
        self.isCancel = true
        YXServerNodeProvider.session.cancelAllRequests()
    }
    
}


class YXServerNodeModel: Codable {
    var masterAddr: String?
}
