//
//  YXSmartViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/4/10.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import URLNavigator
import YXKit

class YXSmartViewModel: HUDServicesViewModel {
    
    typealias Services = SmartService
    var navigator: NavigatorServicesType!
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    let alertSubject = PublishSubject<Bool>()
    //类型，自选股 - 2, 持仓 - 1
    var smartType: YXSmartType = .stockPosition
    //数据源
    var dataSource: [[YXSmartMyStockSmartStare]] = []
    var hzDataSource: [YXV2Quote] = []
    var stockNameSource: [Secu] = []
    var stockNameSort: [String] = []
    var stockRocSource: [String : Int] = [:]
    //响应回调
    var stockResultResponse: YXResultResponse<YXSmartMyStockModel>?
    //Rx代理回调
    typealias resultType = (isSuccess: Bool, noMoreData: Bool, msg: String?)
    typealias hzResultType = (isSuccess: Bool, msg: String?)
    let stockResultSubject = PublishSubject<resultType>()
    //更新状态
    var isRefeshing: Bool = false
    var isPulling: Bool = false
    var needReloadData: Bool = false
    
    var perPageCount: Int = 20

    //锁
    let semaphore = DispatchSemaphore(value: 1)
    
    var services: Services! {
        didSet {
            addBlockResponse()
        }
    }
    
    func addBlockResponse() {
        addStockResultResponse()
    }
    
    func addStockResultResponse() {
        stockResultResponse = { [weak self] (response) in
            
            guard let strongSelf = self else { return }
            if strongSelf.isRefeshing || strongSelf.isPulling {
                self?.hudSubject.onNext(.hide)
            }
            switch response {
            case .success(let result, let code):
                if code == .success {
                    
                    var noMoreData = false
                    DispatchQueue.global().async {
                        
                        strongSelf.semaphore.wait()
                        if let smartStareArray = result.data?.list?.smartStare {
                            if strongSelf.isPulling, smartStareArray.count < strongSelf.perPageCount {
                                noMoreData = true
                            }
                            strongSelf.handleStockData(smartStareArray)
                        }
                        strongSelf.semaphore.signal()
                        DispatchQueue.main.async {
                            strongSelf.stockResultSubject.onNext((true, noMoreData, nil))
                        }
                    }
                } else if code == .smartNoHoldStocks || code == .smartNoSelfStocks {
                    strongSelf.stockResultSubject.onNext((true, false, nil))
                } else if let msg = result.msg  {
                    strongSelf.stockResultSubject.onNext((false, true, msg))
                }
            case .failed(let error):
                
                log(.error, tag: kNetwork, content: "\(error)")
                strongSelf.stockResultSubject.onNext((false,true, YXLanguageUtility.kLang(key: "common_net_error")))
            }
        }
    }
    //持仓、自选股数据处理， 需要过滤所有数据，后按天倒序排列
    func handleStockData(_ smartStareArray: [YXSmartMyStockSmartStare]) {
        //当前请求数据的第一个数据的UnixTime
        var currentFirstUnixTime: Int64 = 0
        if let unixTime = smartStareArray.first?.unixTime {
            currentFirstUnixTime = unixTime
        }
        //self.dataSource首个数组的最后一个数据的UnixTime
        var lastUnixTime: Int64 = 0
        if let unixTime = self.dataSource.first?.last?.unixTime {
            lastUnixTime = unixTime
        }
        
        var leftSmartStare: [YXSmartMyStockSmartStare] = []
        var sortSmartStareArray: [YXSmartMyStockSmartStare] = []
        var isPull = false
        var tempDataSource = self.dataSource
        if self.isPulling, lastUnixTime > 0, currentFirstUnixTime <= lastUnixTime {
            //上拉
            isPull = true
            var mapSeaNum: Int64 = 0
            if let seqnum = tempDataSource.last?.last?.seqNum {
                mapSeaNum = seqnum
            }
            if tempDataSource.count > 0, let lastArray = tempDataSource.last {
                sortSmartStareArray = lastArray
                tempDataSource.removeLast()
            }
            
            for submodel in smartStareArray {
                
                if submodel.seqNum == mapSeaNum {
                    continue
                }
                leftSmartStare.append(submodel)
            }

            
        } else {
            //下拉
            
            var lastFirstUnixTime: Int64 = 0
            if let unixTime = tempDataSource.first?.first?.unixTime {
                lastFirstUnixTime = unixTime
            }
            
            var lastFirstSeqNum: Int64 = 0
            if let seqNum = tempDataSource.first?.first?.seqNum {
                lastFirstSeqNum = seqNum
            }
            
            if currentFirstUnixTime <= lastFirstUnixTime,
                let currentFirstSeqNum = smartStareArray.first?.seqNum, currentFirstSeqNum == lastFirstSeqNum {
                return
            }
            
            if tempDataSource.count > 0, let firstArray = tempDataSource.first {
                sortSmartStareArray = firstArray
                tempDataSource.removeFirst()
            }
            
            for submodel in smartStareArray {
                
                if submodel.unixTime >= lastFirstUnixTime {
                    if submodel.seqNum == lastFirstSeqNum {
                        break
                    }
                    leftSmartStare.append(submodel)
                }
            }
            
        }
        
        if leftSmartStare.count <= 0 {
            return
        }
        
        for submodel in leftSmartStare {
            
            //增加股票代码
            if let stockCode = submodel.stockCode, !self.stockNameSort.contains(stockCode) {
                
                self.stockNameSort.append(stockCode)
                var market = kYXMarketHK
                if stockCode.hasPrefix(kYXMarketUS) {
                    market = kYXMarketUS
                } else if stockCode.hasPrefix(kYXMarketChinaSH) {
                    market = kYXMarketChinaSH
                } else if stockCode.hasPrefix(kYXMarketChinaSZ) {
                    market = kYXMarketChinaSZ
                } else if stockCode.hasPrefix(kYXMarketChinaHS) {
                    market = kYXMarketChinaHS
                }
                self.stockNameSource.append(Secu(market: market, symbol: stockCode.replacingOccurrences(of: market, with: "")))
            }
        }

        
        if isPull {
            sortSmartStareArray += leftSmartStare
        } else {
            sortSmartStareArray = leftSmartStare + sortSmartStareArray
        }
      
        var currentSmartStare: [YXSmartMyStockSmartStare] = []
        var currentTimeInterval = unixTimeInterval(with: sortSmartStareArray.first!.unixTime)
        var tempNewDataSource: [[YXSmartMyStockSmartStare]] = []

        for (index, submodel) in sortSmartStareArray.enumerated() {

            if YXDateHelper.sameDay(currentTimeInterval, unixTimeInterval(with: submodel.unixTime)) {
                currentSmartStare.append(submodel)
                if index == sortSmartStareArray.count - 1 && currentSmartStare.count > 0 {
                    tempNewDataSource.append(currentSmartStare)
                }
            }  else {
                if currentSmartStare.count > 0 {
                    tempNewDataSource.append(currentSmartStare)
                }
                currentSmartStare = [YXSmartMyStockSmartStare]()
                currentSmartStare.append(submodel)
                currentTimeInterval = unixTimeInterval(with: submodel.unixTime)
                if index == sortSmartStareArray.count - 1 && currentSmartStare.count > 0 {
                    tempNewDataSource.append(currentSmartStare)
                }
            }
        }
        
        if isPull {
            self.dataSource = tempDataSource + tempNewDataSource
        } else {
            self.dataSource = tempNewDataSource + tempDataSource
        }
        
        tempNewDataSource.removeAll()
        tempDataSource.removeAll()
    }
    
    
}

func unixTimeInterval(with interval: Int64) -> TimeInterval {
    
    if String(interval).count >= 13 {
        return TimeInterval(interval / 1000)
    }
    return TimeInterval(interval)
}


struct SmartService:HasYXSmartService, HasYXQuotesDataService {
    let smartService: YXSmartService
    let quotesDataService: YXQuotesDataService
}
