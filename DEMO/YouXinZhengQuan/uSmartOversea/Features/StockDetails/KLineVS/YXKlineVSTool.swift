//
//  YXKlineVSTool.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2021/2/3.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXKlineVSTool: NSObject {

    @objc static let shared = YXKlineVSTool()

    @objc var cacheList: [YXVSSearchModel] = []
    @objc var selectList: [YXVSSearchModel] = []

    let semaphore = DispatchSemaphore(value: 1)

    @objc class func isSecuEqual(left: YXSecu, right: YXSecu) -> Bool {
        return (left.market == right.market && left.symbol == right.symbol)
    }

    @objc func removeCache() {
        cacheList.removeAll()
        selectList.removeAll()
    }

    @objc func removeItem(_ item: YXSecu) {
        semaphore.wait()
        var list = self.selectList
        for (index, model) in self.selectList.enumerated() {
            if model.secu.market == item.market, model.secu.symbol == item.symbol {
                list.remove(at: index)
                break
            }
        }

        self.selectList = list
        semaphore.signal()
    }

    @objc func addItem(_ item: YXSecu) {
        semaphore.wait()
        var isExist = false
        for model in self.selectList {
            if model.secu.market == item.market, model.secu.symbol == item.symbol {
                isExist = true
                break
            }
        }
        if !isExist {
            let model = YXVSSearchModel()
            model.secu = item
            self.selectList.append(model)
        }
        semaphore.signal()
    }

    @objc var secuList: [YXSecu] {
        var list: [YXSecu] = []
        for model in self.selectList {
            list.append(model.secu)
        }
        return list
    }


    @objc func calculateKlineData(_ model: YXVSSearchModel?, klineData: YXKLineData) {

        if let list = klineData.list {
//            let listRange = model?.closePriceKlineList[(220 - list.count)...]
//            model?.closePriceKlineList.replaceSubrange(listRange, with: list)
//            model?.closePriceKlineList = list
            
            model?.closePriceKlineList.replaceSubrange(Range.init(NSRange.init(location: 220 - list.count, length: list.count))!, with: list)
            
            let priceBase = klineData.priceBase?.value ?? 0
            let priceBasic = CGFloat(pow(10.0, Double(priceBase)))
            model?.priceBase = Int(priceBase)
            model?.priceBasic = priceBasic

            if let time = list.first?.latestTime?.value {
                model?.startTime = time
            }

            if let time = list.last?.latestTime?.value {
                model?.endTime = time
            }

            var priceArray: [CGFloat] = []
            for lineData in list {
                if let close = lineData.close?.value {
                    priceArray.append(CGFloat(close) / priceBasic)
                }
            }

            model?.closePriceList = priceArray

            let price = priceArray.first ?? 0.0
            model?.firstPrice = price

            if let maxHigh = priceArray.max() {

                if price != 0 {
                    model?.highestRatio = (maxHigh - price) / price
                }
            }

            if let minLow = priceArray.min() {
          
                if price != 0 {
                    model?.lowestRatio = (minLow - price) / price
                }
            }

            if let last = priceArray.last, price != 0 {

                model?.historyRatio = (last - price) / price
            }
        }
    }
    
    //处理价格数据
    @objc func calculatelSelectList() {
        var nodes = YXKlineVSTool.shared.selectList
        //计算当前对比k线中最大的时间的数据
        //构建新的数据价格数组
        
        //通过map创建存储YXKLine的多维数组
        var newList : [[YXKLine?]] = nodes.map { _ in [YXKLine?]() }
        
        //通过map已选择的三组价格数据(数组)，形成三组以各自数量为索引的数组 如 indexArray = [219,219,219]
        var indexArray = nodes.map { item -> Int in
            if item.closePriceKlineList.count > 0 {
                return item.closePriceKlineList.count - 1
            } else {
                return 0
            }
        }
        
        var flag = true
        while flag {
            var maxTime:UInt64 = 0
            //获取数组的索引区间，index = 0，1，2
            for index in indexArray.indices {
                //取出nodes数组中第index项中的数据集(220个价格点)中的第indexArray[index]第220个点，即取最后一个时间比较三组数据中哪组的时间最大，就可以拿到最大的时间跨度
                if let time = nodes[index].closePriceKlineList[safe:indexArray[index]]??.latestTime {
                    if time.value > maxTime {
                        maxTime = time.value
                    }
                }
            }
            
            //获取数组的索引区间，index = 0，1，2
            for index1 in indexArray.indices {
                //取出indexArray即[219,219,219]数组中对应的closePriceKlineList数组中的indexArray[index1]项的收盘价
                let klineData = nodes[index1].closePriceKlineList[safe:indexArray[index1]]
                //一次循环取出三个组数据中，各自最后一项的收盘价，没有最大时间的，就在新数组中插入nil数据，有最大时间的就插入取出的那个数据
                let time = klineData??.latestTime
                if maxTime == 0 {
                    //最后一个时间为空，才可以跳过最后一个点位，即indexArray[index1] - 1
                    newList[index1].insert(nil, at: 0)
                    indexArray[index1] = indexArray[index1] - 1
                    continue
                }
                if time?.value != maxTime {
                    //最后一个时间不为空，不可以indexArray[index1] - 1，这个点的时间下一次循环还要用来构建数据
                    newList[index1].insert(nil, at: 0)
                } else {
                    newList[index1].insert(klineData as! YXKLine, at: 0)
                    //插入之后，indexArray[index1] - 1，即indexArray = [219-1，219-1，219-1]，下一次循环可以取到下一个点位去对比
                    indexArray[index1] = indexArray[index1] - 1
                }
            }
            
            //indexArray[index] 219个点都便利完了之后推出while循环，成功构建新的收盘价数组
            for index in indexArray.indices {
                if indexArray[index] < 0 {
                    flag = false
                    break
                }
            }
        }
        
        for (index ,i) in nodes.enumerated() {
            i.closePriceAfterCalculateKlineList = newList[index]
        }
        for item in nodes {
            self.reCalculateKlineData(item)
        }
    }
    
    //用新的closePriceAfterCalculateKlineList数组去计算
    @objc func reCalculateKlineData(_ model: YXVSSearchModel?) {

        if let list = model?.closePriceAfterCalculateKlineList {
            let priceBasic = model?.priceBasic ?? 1.0

            if let time = list.first??.latestTime?.value {
                model?.startTime = time
            }

            if let time = list.last??.latestTime?.value {
                model?.endTime = time
            }

            var priceArray: [CGFloat] = []
            for lineData in list {
                if let close = lineData?.close?.value {
                    priceArray.append(CGFloat(close) / priceBasic)
                }
            }

            model?.closePriceList = priceArray

            let price = priceArray.first ?? 0.0
            model?.firstPrice = price

            if let maxHigh = priceArray.max() {

                if price != 0 {
                    model?.highestRatio = (maxHigh - price) / price
                }
            }

            if let minLow = priceArray.min() {
          
                if price != 0 {
                    model?.lowestRatio = (minLow - price) / price
                }
            }

            if let last = priceArray.last, price != 0 {

                model?.historyRatio = (last - price) / price
            }
        }
    }

    
    @objc func requestKlineData(item: YXSecu, completion:((_ success: Bool) -> Void)?) {

        let userLevel = YXUserManager.shared().getLevel(with: item.market)

        var direction: OBJECT_QUOTEKLineDirection = .kdForward
        let type = YXKLineConfigManager.shareInstance().adjustType
        if type == .notAdjust {
            direction = .kdNone
        } else if type == .preAdjust {
            direction = .kdForward
        } else {
            direction = .kdBackward
        }

        //self.addItem(item)

        YXQuoteManager.sharedInstance.onceKLineQuote(secu: Secu(market: item.market, symbol: item.symbol), type: .ktDay, direction: direction, level: userLevel, count: 220, handler: { [weak self] (klineData, scehme) in
            guard let `self` = self else { return }

            var klineModel: YXVSSearchModel?
            for model in self.selectList {
                if model.secu.market == item.market, model.secu.symbol == item.symbol {
                    klineModel = model
                    break
                }
            }

            if klineModel != nil {
                //klineModel?.klineData = klineData
                self.calculateKlineData(klineModel, klineData: klineData)
            }

            completion?(true)
        }, failed: {
            completion?(false)
        })
    }


}

extension Array {
    subscript (safe index: Int) -> Element? {
        return (0 ..< count).contains(index) ? self[index] : nil
    }
}
