//
//  YXKlineVSLandViewModel.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2021/2/4.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class YXKlineVSLandViewModel: YXViewModel {


    var dataSourceObservable: Observable<[Bool]> { 
        var signalArray: [Observable<Bool>] = []
        for item in YXKlineVSTool.shared.selectList {
            let signal = self.requestKlineDataSignal(item.secu)
            signalArray.append(signal.asObservable())
        }
        return Observable.zip(signalArray)
    }

    func requestKlineDataSignal(_ secu: YXSecu) -> Single<Bool> {
        return Single<Bool>.create { [weak self] (single) -> Disposable in
            guard let `self` = self else { return Disposables.create() }
            YXKlineVSTool.shared.requestKlineData(item: secu, completion: {
                 success in
                single(.success(success))
            })

            return Disposables.create()
        }
    }

    

}

