//
//  YXImportViewModel.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/6/28.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import URLNavigator
import RxCocoa
import NSObject_Rx

class YXImportPicViewModel: ServicesViewModel, HasDisposeBag {
    typealias Services = YXPreferencesService
    
    var services: Services!
    
    var navigator: NavigatorServicesType!
    
    let importResult = BehaviorRelay<YXResult<YXImportPicResponseModel>?>(value: nil)
    
    func upload(imageData: Data) {
        _ = importProvider.rx.request(.upload(imageData)).map(YXResult<YXImportPicResponseModel>.self).subscribe(onSuccess: { [weak self] (result) in
            self?.importResult.accept(result)
        }) { [weak self] (_) in
            self?.importResult.accept(nil)
        }
    }
}
