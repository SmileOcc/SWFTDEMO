//
//  MyStrategyListManager.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/9.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class MyStrategyListManager: NSObject {

    static let sharedInstance = MyStrategyListManager()

    private(set) var subscribedStrategyList: [SubscribedStrategyModel] = []

    /// 获取已订阅的策略
    /// - Parameter completion: 完成回调
    func getSubscribedStrategyList(completion: (() -> Void)?) {
        let requestModel = SubscribedStrategyListRequestModel()
        let request = YXRequest(request: requestModel)
        request.startWithBlock { [weak self] responseModel in
            guard let `self` = self, let responseModel = responseModel as? SubscribedStrategyListReponseModel else {
                return
            }
            self.subscribedStrategyList = responseModel.list
            completion?()
        } failure: { request in
        }
    }

    /// 是否已订阅
    /// - Parameters:
    ///   - strategyId: 策略 ID
    ///   - type: 策略类型
    /// - Returns: Bool 值
    func contains(_ strategyId: Int, withType type: Int) -> Bool {
        return self.subscribedStrategyList.contains { item in
            item.strategyId == strategyId && item.type == type
        }
    }

    /// 订阅策略
    /// - Parameters:
    ///   - strategyId: 策略 ID
    ///   - type: 策略类型
    ///   - completion: 完成回调
    func subscribe(_ strategyId: Int, withType type: Int, completion: ((Bool) -> Void)?) {
        let hud = YXProgressHUD.showLoading("")

        let requestModel = SubscribStrategyRequestModel()
        requestModel.subscribe = 1
        requestModel.strategy_id = strategyId
        requestModel.strategy_type = type

        let request = YXRequest(request: requestModel)
        request.startWithBlock { [weak self] responseModel in
            hud.hide(animated: false)

            if responseModel.code == .success {
                if let `self` = self, !self.contains(strategyId, withType: type) {
                    let strategy = SubscribedStrategyModel()
                    strategy.strategyId = strategyId
                    strategy.type = type
                    self.subscribedStrategyList.append(strategy)
                }

                completion?(true)
            } else if responseModel.code.rawValue == 80000 {
                // 升级权限
            } else {
                completion?(false)
            }
        } failure: { request in
            hud.hide(animated: false)
            completion?(false)
        }
    }

    /// 取消订阅策略
    /// - Parameters:
    ///   - strategyId: 策略 ID
    ///   - type: 策略类型
    ///   - completion: 完成回调
    func unsubscribe(_ strategyId: Int, withType type: Int, completion: ((Bool) -> Void)?) {

        let hud = YXProgressHUD.showLoading("")

        let requestModel = SubscribStrategyRequestModel()
        requestModel.subscribe = 0
        requestModel.strategy_id = strategyId
        requestModel.strategy_type = type

        let request = YXRequest(request: requestModel)
        request.startWithBlock { [weak self] responseModel in
            hud.hide(animated: false)

            if responseModel.code == .success {
                self?.subscribedStrategyList.removeAll(where: { item in
                    return item.strategyId == strategyId && item.type == type
                })

                completion?(true)
            } else {
                completion?(false)
            }
        } failure: { request in
            hud.hide(animated: false)
            completion?(false)
        }
    }

}
