//
//  YXPageView+Rx.swift
//  uSmartOversea
//
//  Created by ellison on 2019/5/1.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import YXKit

extension Reactive where Base: YXPageView {
    
    public var viewControllers: Binder<[UIViewController]> {
        Binder(self.base) { pageView, viewControllers in
            if pageView.viewControllers.elementsEqual(viewControllers) == false {
                pageView.viewControllers = viewControllers
                pageView.reloadData()
            }
        }
    }    
}
