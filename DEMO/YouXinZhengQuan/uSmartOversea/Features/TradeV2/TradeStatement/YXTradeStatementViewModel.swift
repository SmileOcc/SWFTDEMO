//
//  YXTradeStatementViewModel.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/7/15.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXTradeStatementViewModel: YXViewModel {
    
    var request: YXRequest?
    
    var page:Int = 1
    var accountType:TradeStatementAccountType = .stock
    var endDate: Date?   // 结单时间止
    var beginDate: Date? // 结单时间
    var statementType:TradeStatementType = .all // 结单类型
    var timeScope:TradeStatementTimeType = .threeMonth
    
   
    var statementModel:YXTradeStatementModel?
    
    var itemList:[YXStatementListItemModel] = []
    var resultList:[YXStatementListSectionModel] = []
    
    override func initialize() {
        super.initialize()
        
    }
    
    func reqStatementSingle() -> Single<YXTradeStatementModel?> {
        
        let single = Single<YXTradeStatementModel?>.create { [weak self] single in
            guard let `self` = self else { return Disposables.create() }

            if let request = self.request {
                request.stop()
                self.request = nil
            }
            
            let requestModel = YXTradeStatementListReqModel()
            
            if self.statementType == .month, let begin = self.beginDate, let end = self.endDate  {
                self.beginDate = YXDateToolUtility.getMonthBeginDay(with: begin)
                self.endDate = YXDateToolUtility.getMonthEndDay(with: end)
            }
            
            requestModel.accountType = self.accountType
            
            requestModel.startTime = Int64((self.beginDate?.timeIntervalSince1970 ?? 0) * 1000)
            requestModel.endTime = Int64((self.endDate?.timeIntervalSince1970 ?? 0) * 1000)
            requestModel.timeScope = self.timeScope
            requestModel.statementType = self.statementType
            requestModel.pageNum = self.page
            requestModel.pageSize = 20
           
            let request = YXRequest.init(request:requestModel)
            let loadingHud = YXProgressHUD.showLoading("")
            
            request.startWithBlock(success: { [weak self](model) in
                guard let `self` = self else { return }
                loadingHud.hide(animated: true)
                guard let modelData = model as? YXTradeStatementModel else {
                    return
                }
                self.statementModel = modelData
                if self.page == 1 {
                    self.itemList = modelData.list
                }else{
                    if modelData.list.count > 0 {
                        self.itemList.append(contentsOf: modelData.list )
                    }
                }
                self.resultList  = self.changeModel(arr: self.itemList)

                single(.success(self.statementModel))
            }, failure: { [weak self] (request) in
                guard let `self` = self else { return }

                self.resultList.removeAll()
                single(.success(nil))
                loadingHud.hide(animated: true)
            })
            
            return Disposables.create()
        }
        
        return single
    }
    

    
    private func changeModel(arr:[YXStatementListItemModel]) -> [YXStatementListSectionModel] {
        
        var resultArr:[YXStatementListSectionModel] = []
        
        var sectionArray:[String] = []
        
        var itemList:[[YXStatementListItemModel]] = [[YXStatementListItemModel]]()   //二维数组

        var tempArr:[YXStatementListItemModel] = []
        var preTime:String = ""
        
        for (index, item) in arr.enumerated() {
            let time:String = YXDateHelper.commonDateString( item.statementDate, format: .DF_MY)
            if time != preTime {
                preTime = time
                if index != 0 {
                    itemList.append(tempArr)
                    tempArr.removeAll()
                }
                sectionArray.append(time)
                tempArr.append(item)
            }else{
                tempArr.append(item)
            }
            if index == arr.count - 1 {
                itemList.append(tempArr)
            }
        }
        
        if sectionArray.count > 0 && sectionArray.count == itemList.count {
            for (index, time) in sectionArray.enumerated() {
                let sectionModel:YXStatementListSectionModel = YXStatementListSectionModel()
                sectionModel.time = time
                sectionModel.list = itemList[index]
                resultArr.append(sectionModel)
            }
        }
        
        
        return resultArr
    }
}
