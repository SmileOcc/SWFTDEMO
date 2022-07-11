//
//  YXOrderDetailViewModel.swift
//  YouXinZhengQuan
//
//  Created by ellison on 2019/5/20.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import URLNavigator
import NSObject_Rx

@objcMembers class YXOrderDetailViewModel: NSObject, HUDServicesViewModel, HasDisposeBag {
    typealias Services = HasYXTradeService
    
    var navigator: NavigatorServicesType!
    
    var hudSubject: PublishSubject<HUDType>! = PublishSubject<HUDType>()
    
    var entrustId: String = ""
    
    var allOrderType: YXAllOrderType = .normal
    
    var market: String = ""
    var symbol: String = ""
    var name: String = ""
    
    var detailResponse: YXResultResponse<YXOrderDetailData>?
    
    let detail: BehaviorRelay<YXOrderDetailData?> = BehaviorRelay<YXOrderDetailData?>(value: nil)
    
    let shareSubject: PublishSubject<Int?> = PublishSubject<Int?>()
    var shareUrl: String = ""
    
    var services: Services! {
        didSet {
            detailResponse = { [weak self] (response) in
                
                self?.hudSubject.onNext(.hide)
                
                switch response {
                case .success(let result, let code):
                    if result.data?.status == 0 || result.data?.status == 3 { // 全成 部成
                        if let type = result.data?.exchangeType, (type == .hk || type == .us) {
                            self?.shareSubject.onNext(type.rawValue)
                        }
                    }
                    if code == .success {
                        if self?.allOrderType == .dayMargin {
                            if let data = result.data {
                                result.data?.detailList = self?.handleDayMarginModel(originData: data)
                            }
                        }
                        
                        self?.detail.accept(result.data)
                        
                    } else {
                        if let msg = result.msg {
                            self?.hudSubject.onNext(.error(msg, false))
                        }
                    }
                case .failed(_):
                    self?.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
        }
    }
    
    @objc convenience init(market: String, symbol: String, entrustId: String, name: String, allOrderType: YXAllOrderType = .normal) {
        self.init()
        self.market = market
        self.entrustId = entrustId
        self.symbol = symbol
        self.name = name
        self.allOrderType = allOrderType
    }
    
    func requestDetail() {
        hudSubject.onNext(.loading(nil, false))
        
        if self.allOrderType == .dayMargin {
            services.tradeService.request(.dayMarginOrderDetail(self.entrustId), response: detailResponse).disposed(by: disposeBag)
        } else if self.allOrderType == .shortSell {
            services.tradeService.request(.shortSellOrderDetail(self.entrustId), response: detailResponse).disposed(by: disposeBag)
        } else {
            services.tradeService.request(.orderDetail(self.entrustId), response: detailResponse).disposed(by: disposeBag)
        }
    }
    
    func handleDayMarginModel(originData: YXOrderDetailData) -> [YXOrderInfoItem] {
        
        if var list = originData.detailList {
            
//            result.data?.detailList?.forEach({ (item) in
//                self?.setUpModel(model: item, fromModel: originData)
//            })
            
            // 在swift中修改数组中的元素以上方法不行
            // 需要这么写
            for i in 0..<list.count {
                self.setUpModel(model: &list[i], fromModel: originData)
            }
            
            var entrustModel = YXOrderInfoItem()
            self.setUpModel(model: &entrustModel, fromModel: originData)
            entrustModel.detailStatusName = originData.entrustName
            entrustModel.detailStatus = originData.status
            entrustModel.createTime = originData.createTime
            
            list.insert(entrustModel, at: 0)
            
            if originData.finalStateFlag == .final && originData.status != -1 && originData.status != 8 {
                var finishModel = YXOrderInfoItem()
                self.setUpModel(model: &finishModel, fromModel: originData)
                finishModel.businessQty = originData.businessAmount
                finishModel.businessBalance = originData.businessBalance
                finishModel.businessAvgPrice = originData.businessAveragePrice
                finishModel.detailStatusName = originData.finalStatusName
                finishModel.detailStatus = originData.status
                finishModel.createTime = originData.transactionTime
                
                list.append(finishModel)
            }
            
            return list
            
        }else {
            return []
        }
    }
    
    func setUpModel(model: inout YXOrderInfoItem, fromModel: YXOrderDetailData) {
        // 将日内融返回的数据结构构造成与普通订单一样的数据结构
        // 不能覆盖businessAmount，businessAveragePrice，businessBalance，createTime，orderStatus，orderStatusName，因为这几个字段在YXOrderInfoModel里面后端已经返回了，而其他字段在外层返回
        model.commissionFee = "\(fromModel.commissionFee ?? 0)"
        model.entrustQty = fromModel.entrustQty
        model.entrustBalance = fromModel.entrustBalance
        if let entrustFee = fromModel.entrustFee {
            model.entrustFee = "\(entrustFee)"
        }else {
            model.entrustFee = nil
        }
        
        model.entrustPrice = fromModel.entrustPrice
        model.entrustProp = fromModel.entrustProp
        model.moneyType = fromModel.moneyType
        model.payFee = "\(fromModel.payFee ?? 0)"
        model.platformUseFee = "\(fromModel.platformUseFee ?? 0)"
        model.stampDutyFee = "\(fromModel.stampDutyFee ?? 0)"
        model.tradingSystemUsage = "\(fromModel.tradingSystemUsage ?? 0)"
        model.transactionFee = "\(fromModel.transactionFee ?? 0)"
        model.transactionLevyFee = "\(fromModel.transactionLevyFee ?? 0)"
        model.transferFee = "\(fromModel.transferFee ?? 0)"
        model.superviseFee = "\(fromModel.superviseFee ?? 0)"
        model.registerTransferFee = "\(fromModel.registerTransferFee ?? 0)"
        model.handleFee = "\(fromModel.handleFee ?? 0)"
        model.depositStockDay = fromModel.depositStockDay
        model.retractMark = fromModel.retractMark
        model.failReason = fromModel.failReason
        model.entrustPropName = fromModel.entrustPropName
    }
}
