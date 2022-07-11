//
//  YXAskViewModel.swift
//  uSmartEducation
//
//  Created by usmart on 2021/12/10.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class YXAskViewModel {
    
    func getRedDotAndHotStock() -> Single<YXAskHotStockResModel?> {
        return YXSpecialAPI.askQueryHot.request().map { res in
            return YXAskHotStockResModel.yy_model(withJSON: res?.data ?? [:])}
    }
}
