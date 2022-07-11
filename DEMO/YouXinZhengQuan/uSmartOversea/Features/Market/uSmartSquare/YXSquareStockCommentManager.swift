//
//  YXSquareStockCommentManager.swift
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/5/10.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXSquareStockCommentManager: NSObject {
    
    typealias SuccessClosure = (()->())
    typealias FailClosure = (()->())
    
    @objc public static let shared = YXSquareStockCommentManager.init()
    @objc var requsetList = [""]
    
    @objc var commentData = [String: [YXSquareCommentModel]]()
    
    var commentRequest: YXRequest?
    
    @objc func getCommentData(with list: [String], success: SuccessClosure?, fail: FailClosure?) {
        
        commentRequest?.stop()
                
        let requsetModel = YXSquareStockeCommentRequestModel.init()
        requsetModel.stock_id_list = list
        let request = YXRequest.init(request: requsetModel)
        commentRequest = request
        
        request.startWithBlock(success: { response in
            if response.code == .success {
                // 转化数据
                if let data = response.data?["stock_post_map"] as? [String: [[AnyHashable : Any]]] {
                    for (key, value) in data {
                        let model = NSArray.yy_modelArray(with: YXSquareCommentModel.self, json: value)
                        if let model = model as? [YXSquareCommentModel] {
                            for item in model {
                                if key.count > 2 {
                                    let a = key.prefix(2)
                                    item.market = String(a)
                                    let b = key.suffix(key.count - 2)
                                    item.symbol = String(b)
                                }
                            }
                            
                            self.commentData[key] = model
                        }
                    }
                }
                success?()
            } else {
                fail?()
            }
            
        }, failure: { request in
            fail?()
        })
    }
    
        
    
}


