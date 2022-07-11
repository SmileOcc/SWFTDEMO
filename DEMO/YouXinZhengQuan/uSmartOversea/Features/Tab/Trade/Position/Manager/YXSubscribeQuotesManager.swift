//
//  YXSubscribeQuotesManager.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2021/7/20.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXSubscribeQuotesManager: NSObject {

    var allQuoteRequests: [YXQuoteRequest] = []
    var assetModel: YXAccountAssetResModel?
    var assetModelCallBack: ((YXAccountAssetResModel?) -> Void)?

    lazy var tcpFilter: YXStockDetailTcpTimer = {
        let filter = YXStockDetailTcpTimer.init(interval: 0.5, excute: { [weak self] result, scheme in
            guard let `self` = self else { return }
            if let assetModel = result as? YXAccountAssetResModel {
                self.assetModelCallBack?(assetModel)
            }
        })
        
        return filter
    }()

    @objc func subAllMarketQuotes(_ tempAssetModel: YXAccountAssetResModel?, callBack:((YXAccountAssetResModel?) -> Void)?) {
        invalidate()

        self.assetModel = tempAssetModel
        self.assetModelCallBack = callBack

        // 1.构建 secus
        var secus: [Secu] = []

        tempAssetModel?.assetSingleInfoRespVOS.forEach({ assetData in
            secus.append(contentsOf: assetData.allSecus())
        })

        // 2.处理订阅（期权单独处理）
        var normalSecus = [Secu]() // 普通股票
        var options = [Secu]() // 期权
        for secu in secus {
            if secu.market == "usoption" {
                options.append(secu)
            } else {
                normalSecus.append(secu)
            }
        }

        let levelSecus = LevelSecus(secus: normalSecus, allHKSecus: [])

        var quoteRequests = [YXQuoteRequest]()

        for i in 0..<6 {
            var array = [Secu]()
            var level = QuoteLevel.delay

            switch i {
            case 0:
                array = levelSecus.delay
                level = .delay
            case 1:
                array = levelSecus.bmp
                level = .bmp
            case 2:
                array = levelSecus.level1
                level = .level1
            case 3:
                array = levelSecus.level2
                level = .level2
            case 4:
                array = levelSecus.none
                level = .none
            case 5:
                array = levelSecus.usNation
                level = .usNational
            default:
                break
            }

            if array.count > 0 {
                let request = YXQuoteManager.sharedInstance.subRtSimpleQuote(secus: array, level: level, handler: { [weak self] (quotes, scheme) in
                    guard let `self` = self else { return }
                    self.assetModel?.refreshQuotes(quotes)
                    self.tcpFilter.onNext(self.assetModel as Any, scheme: scheme)
                })
                quoteRequests.append(request)
            }
        }

        if options.count > 0, YXUserHelper.currentUSOptionLevel() == .usLevel1 {
            let request = YXQuoteManager.sharedInstance.subRtSimpleQuote(secus: options, level: .level1, handler: { [weak self] (quotes, scheme) in
                guard let `self` = self else { return }
                self.assetModel?.refreshQuotes(quotes)
                self.tcpFilter.onNext(self.assetModel as Any, scheme: scheme)
            })
            quoteRequests.append(request)
        }

        self.allQuoteRequests = quoteRequests
    }

    @objc func invalidate() {
        for quoteRequest in allQuoteRequests {
            quoteRequest.cancel()
        }
        allQuoteRequests.removeAll()

        tcpFilter.invalidate()

        self.assetModelCallBack = nil
        self.assetModel = nil
    }

}
