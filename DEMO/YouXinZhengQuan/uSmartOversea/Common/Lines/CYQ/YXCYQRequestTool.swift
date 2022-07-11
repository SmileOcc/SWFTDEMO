//
//  YXCYQRequestTool.swift
//  uSmartOversea
//
//  Created by youxin on 2020/6/2.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

@objcMembers class YXCYQRequestTool: NSObject {
    static let shared = YXCYQRequestTool()

    @objc var singleChipParam: [String : YXCYQModel]?
    @objc var batchChipParam: [String : YXCYQModel]?

    @objc var rights: Int = 0

    @objc func removeAllCache() {
        self.singleChipParam = nil
        self.batchChipParam = nil
    }

    func requestCYQData(_ stockId: String, timeInterval: UInt64, rights: Int, completion: @escaping (_ model: YXCYQModel?, _ timeInterval: UInt64) -> Void) {

        self.rights = rights
        let requestModel = YXCYQRequestModel()
        requestModel.id = stockId
        requestModel.nextPageRef = timeInterval
        requestModel.rights = rights
        let request = YXRequest.init(request: requestModel)
        request.startWithBlock(success: { [weak self] (responseModel) in
            guard let `self` = self else { return }
            if responseModel.code == YXResponseStatusCode.success,
                let data = responseModel.data {
                let model = YXCYQModel.yy_model(withJSON: data)
                if timeInterval == 0, let tempModel = model, let list = tempModel.list, list.count > 0, !stockId.isEmpty  {
                    self.singleChipParam = [stockId : tempModel]
                }
                completion(model, timeInterval)
            } else {
                completion(nil, timeInterval)
            }
        }, failure: { (tkRequest) in
            completion(nil, timeInterval)
        })
    }

    @objc func requestBatchCYQData(_ stockId: String, count: Int, completion: @escaping ((_ model: YXCYQModel?) -> Void)) {

        let requestModel = YXCYQRequestModel()
        requestModel.id = stockId
        requestModel.nextPageRef = 0
        requestModel.count = count
        requestModel.rights = YXKLineConfigManager.shareInstance().adjustType.rawValue
        let request = YXRequest.init(request: requestModel)
        request.startWithBlock(success: {  [weak self]  (responseModel) in
            guard let `self` = self else { return }
            if responseModel.code == YXResponseStatusCode.success,
                let data = responseModel.data {
                let model = YXCYQModel.yy_model(withJSON: data)
                if let tempModel = model, let list = tempModel.list, list.count > 0, !stockId.isEmpty {
                    self.batchChipParam = [stockId : tempModel]
                }
                completion(model)
            } else {
                completion(nil)
            }
            }, failure: { (tkRequest) in
                completion(nil)
        })
    }

}

