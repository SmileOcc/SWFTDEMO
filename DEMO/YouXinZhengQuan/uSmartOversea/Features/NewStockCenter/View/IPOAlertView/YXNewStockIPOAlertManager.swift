//
//  YXNewStockIPOAlertManager.swift
//  YouXinZhengQuan
//
//  Created by Mac on 2020/2/11.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXNewStockIPOAlertManager: NSObject {
    @objc static let shared = YXNewStockIPOAlertManager()

    let newStockService = YXNewStockService()
    let disposeBag = DisposeBag()
    var ipoShowed: Bool = false
    var ipoCacheList: [YXNewStockCenterPreMarketStockModel]? //暂时缓存
    let ipoNewStockSubject = PublishSubject<Bool>()
    var isHttpResponsed: Bool = false
    override init() {
        super.init()
    }

    @objc func checkIPOAlert(with vc: UIViewController) {
        if isHttpResponsed {
            self.ipoNewStockSubject.onNext(true)
            return
        }
        if ipoShowed {
            ipoCacheList = nil
            self.ipoNewStockSubject.onNext(true)
            return
        }
        //市场(0-港股,5-美股，50-查询港美股，不传默认港股-兼容老版本app)
        
        let api: YXNewStockAPI = .ipoList(orderBy: "latest_endtime", orderDirection: 1, pageNum: 1, pageSize: 30, pageSizeZero: true, status: 0, exchangeType: 50)
        
        newStockService.request(api, response: { [weak self] (response) in
            
            guard let `self` = self else { return }
          
            switch response {
            case .success(let result, let code):
                if code == .success, let model = result.data {
                    if let list = model.list, list.count > 0 {
                        
                        let dataCacheKey = "YXSystemIPODataCache"
                        var count = list.count
                        if 3 < count {
                            count = 3
                        }
                        let newList = list[0 ..< count] //获取前3只股票
                        
                        //一天只展示一次
                        let (sameDay,_) = YXUserManager.isTheSameDay(with: YXUserManager.YXSystemIPOAlertDateCache)
                        if sameDay == false {
                            YXPopManager.shared.addLaunchPopType(type:.ipoNewStock)
                            self.ipoCacheList = list
//                            self.showIPOAlertView(with: list,vc: vc)
                        }
                        else {

                            //获取缓存的数据
                            let oldList = self.getCacheData(with: dataCacheKey)

                            if oldList.count != newList.count {
                                YXPopManager.shared.addLaunchPopType(type:.ipoNewStock)
                                self.ipoCacheList = list
//                                self.showIPOAlertView(with: list,vc: vc)
                            } else {
                                for newModel in newList {
                                    ///1. 新增股票 - 判断是否有新的ipoId
                                    ///如果有则展示，如果没有则继续判断
                                    var matched: Bool = false //是否匹配成功

                                    var sameChange: Bool = false

                                    for oldModel in oldList {
                                        if oldModel.ipoId == newModel.ipoId {
                                            matched = true
                                            //1.杠杆倍数
                                            if oldModel.ordinaryFinancingMultiple != newModel.ordinaryFinancingMultiple {
                                                sameChange = true
                                            }
                                            //2.一手起购资金
                                            //市场类型(0-港股, 5-us)
                                            if newModel.exchangeType == 0,
                                                oldModel.leastAmount != newModel.leastAmount {
                                                sameChange = true
                                            } else if newModel.exchangeType == 5,
                                                oldModel.ecmLeastAmount != newModel.ecmLeastAmount {
                                                sameChange = true
                                            }
                                            //3.股票名称、股票代码
                                            if oldModel.stockName != newModel.stockName ||
                                                oldModel.stockCode != newModel.stockCode {
                                                sameChange = true
                                            }
                                            break
                                        }
                                    }
                                    if matched == false {
                                        YXPopManager.shared.addLaunchPopType(type:.ipoNewStock)
                                        self.ipoCacheList = list
//                                        self.showIPOAlertView(with: list,vc: vc)
                                        break
                                    }
                                    if sameChange {
                                        YXPopManager.shared.addLaunchPopType(type:.ipoNewStock)
                                        self.ipoCacheList = list
//                                        self.showIPOAlertView(with: list,vc: vc)
                                        break
                                    }
                                }
                            }
                        }
                        //缓存
                        self.saveData(with: newList, key: dataCacheKey)
                                                
                    }
                  
                }
                self.ipoNewStockSubject.onNext(true)
            case .failed(let error):
                self.ipoNewStockSubject.onNext(true)
                log(.error, tag: kNetwork, content: "\(error)")
            }
            
        } as YXResultResponse<YXNewStockCenterPreMarketModel>).disposed(by: self.disposeBag)
    }
    
    //获取缓存数据
    private func getCacheData(with key: String) -> [YXNewStockCenterPreMarketStockModel] {
        var cacheList = [YXNewStockCenterPreMarketStockModel]()
                
        if let tempData = MMKV.default().data(forKey: key),
            let jsonObject = try? JSONSerialization.jsonObject(with: tempData, options: []) {
            
            if let tempOldList = jsonObject as? [[String: Any]] {
                for dict in tempOldList {
                    if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: []), let model = try? JSONDecoder().decode(YXNewStockCenterPreMarketStockModel.self, from: jsonData) {
                        
                        cacheList.append(model)
                    }
                }
                
            }
        }
        
        return cacheList
    }
    
    //缓存数据
    private func saveData(with list: ArraySlice<YXNewStockCenterPreMarketStockModel>,key:String) {
        var dictArr = [[String: Any]]()
        for model in list {
            var dict = [String: Any]()
            dict["ipoId"] = model.ipoId
            dict["ordinaryFinancingMultiple"] = model.ordinaryFinancingMultiple
            dict["exchangeType"] = model.exchangeType
            dict["leastAmount"] = model.leastAmount
            dict["ecmLeastAmount"] = model.ecmLeastAmount
            dict["stockName"] = model.stockName
            dict["stockCode"] = model.stockCode
            dictArr.append(dict)
        }
        //缓存
        if let data = try? JSONSerialization.data(withJSONObject: dictArr, options: []) {
            MMKV.default().set(data, forKey: key)
        }
    }
    
    func showIPOAlertView(with list: [YXNewStockCenterPreMarketStockModel], vc:UIViewController) {

        guard              
              UIViewController.current().isKind(of: YXStockSTWebviewController.self) else {
           return
        }
        guard let cacheList = self.ipoCacheList  else {
            return
        }
        
        self.ipoShowed = true
        //背景
        let bgView = UIView()
        bgView.backgroundColor = .clear
        let alertView = YXNewStockIPOAlertView(frame: CGRect.zero, premarketList:cacheList)
        bgView.addSubview(alertView)
        alertView.nowBuyBlock = {[weak bgView] in
            YXPopManager.shared.removeTypeInPops(type: .ipoNewStock)
            bgView?.hide()
            if let root = UIApplication.shared.delegate as? YXAppDelegate {
                let navigator = root.navigator
                
                let context: [String : Any] = [
                    "market" : YXMarketType.HK.rawValue
                ]
                navigator.push(YXModulePaths.newStockCenter.url, context: context)

            }
        }
        
        //关闭按钮
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "pop_close"), for: .normal)
        bgView.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.width.height.equalTo(30)
            make.top.equalTo(alertView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        bgView.frame = UIScreen.main.bounds
        UIView.hideOldShowAlertView()
        bgView.showInWindow()
        
        //关闭响应
        button.rx.tap.asObservable().subscribe(onNext: {[weak bgView] (_) in
            YXPopManager.shared.removeTypeInPops(type: .ipoNewStock, needShowNextPop: true)
            bgView?.hide()
        
        }).disposed(by: self.disposeBag)
    }
}
