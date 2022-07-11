//
//  YXLittleRedDotService.swift
//  uSmartOversea
//
//  Created by Mac on 2019/11/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import PluggableApplicationDelegate

import RxCocoa
import RxSwift

class YXLittleRedDotService: NSObject, ApplicationService {
    func checkLittleRedDot() {
        YXLittleRedDotManager.shared.checkLittleRedDot()
        
        let interval = RxTimeInterval.seconds(120)
        Observable<Int>.timer(interval, period: interval, scheduler: MainScheduler.instance)
            .subscribe({ _ in
                
                YXLittleRedDotManager.shared.checkLittleRedDot()
                
            }).disposed(by: self.rx.disposeBag)
        
        
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        checkLittleRedDot()
        return true
    }
}
