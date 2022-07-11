//
//  SearchRecommendViewModel.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/7.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class SearchRecommendViewModel: YXViewModel {

    var loadRecommendCommand: RACCommand<AnyObject, AnyObject>?

    var stockList: [SearchSecuModel] = []

    override func initialize() {
        super.initialize()

        self.loadRecommendCommand = RACCommand(signal: { _ in
            return self.requestRecommend()
        })
    }

    private func requestRecommend() -> RACSignal<AnyObject>! {
        return RACSignal.createSignal { [weak self] subscriber -> RACDisposable? in
            let requestModel = SeachRecommendRequestModel()

            let request = YXRequest(request: requestModel)
            request.startWithBlock { [weak self] responseModel in
                guard let `self` = self else { return }

                self.constructListData(with: responseModel)

                subscriber.sendNext(nil)
                subscriber.sendCompleted()
            } failure: { request in
                subscriber.sendNext(nil)
                subscriber.sendCompleted()
            }

            return nil
        }
    }

    /// 构造列表数据
    /// - Parameter searchResult: 搜索结果
    private func constructListData(with responseModel: YXResponseModel?) {
        guard let responseModel = responseModel as? SearchRecommendModel else {
            self.stockList = []
            return
        }

        self.stockList = responseModel.stockList
    }

}
