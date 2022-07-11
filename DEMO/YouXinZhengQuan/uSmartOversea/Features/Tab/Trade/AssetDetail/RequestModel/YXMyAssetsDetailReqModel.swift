//
//  YXMyAssetsDetailReqModel.swift
//  uSmartOversea
//
//  Created by Evan on 2022/5/5.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXMyAssetsDetailReqModel: YXJYBaseRequestModel {

    @objc var myAssetsDetailMode: YXMyAssetsDetailMode = .category
    @objc var moneyType = ""
    @objc var refreshCache = false

    override func yx_requestMethod() -> YTKRequestMethod {
        return .POST
    }

    override func yx_requestUrl() -> String {
        switch myAssetsDetailMode {
        case .category:
            return "/asset-center-dolphin/api/query-multiAssetInfoKind/v1"
        case .market:
            return "/asset-center-dolphin/api/query-multiAssetInfoMarket/v1"
        }
    }

    override func yx_responseModelClass() -> AnyClass {
        switch myAssetsDetailMode {
        case .category:
            return YXMyAssetsDetailViaCategoryResModel.self
        case .market:
            return YXMyAssetsDetailViaMarketResModel.self
        }
    }

}
