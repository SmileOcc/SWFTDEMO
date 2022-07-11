//
//  YXCompanySetViewModel.swift
//  uSmartOversea
//
//  Created by ysx on 2021/7/16.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class YXBrokerSetViewModel: YXViewModel {
    var navigator: NavigatorServicesType!
    
    var logoutSubject:Single<String>  {
         Single<String>.create { single -> Disposable in
            let requestModel = YXBrokerLogOutRequest()
            let  request = YXRequest.init(request: requestModel)
            request.startWithBlock { response in
                if response.code == .success{
                    single(.success(""))
                   
                }else {
                    YXProgressHUD.showError(response.msg)
                }
            } failure: { request in
                single(.error(YXError.internalError(code: -1, message: YXLanguageUtility.kLang(key: "common_net_error"))))
            }
            return Disposables.create()
        }
    }
    
    var dataSource: [CommonCellData] = {
        var cellArr = [CommonCellData]()
        let title = YXUserManager.shared().tradePassword() == true ? YXLanguageUtility.kLang(key: "mine_change_trade_pwd") :  YXLanguageUtility.kLang(key: "mine_set_trade_pwd")
       // let title = "Change the trade password"
        
        let tradeCell = CommonCellData(image: nil, title: title, describeStr: "", showArrow: true, showLine: false)
        cellArr.append(tradeCell)
       
        if YXUserManager.shared().curBroker == .nz{
            let accountCell = CommonCellData(image: nil, title: "IB account / initial password", describeStr: "", showArrow: true, showLine: false)
            let commissionCell = CommonCellData(image: nil, title: "My commission", describeStr: "", showArrow: true, showLine: false)
            cellArr.append(accountCell)
            cellArr.append(commissionCell)
        }
      //  self.viewModel
        return cellArr
    }()
    
    
}
