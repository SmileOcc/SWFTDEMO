//
//  YXTabView+Rx.swift
//  uSmartOversea
//
//  Created by ellison on 2019/5/1.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import YXKit

extension Reactive where Base: YXTabView {
    
    public var titles: Binder<[String]> {
        Binder(self.base) { tabView, titles in
            if tabView.titles.elementsEqual(titles) == false {
                tabView.titles = titles
                tabView.reloadData()
            }
        }
    }    
}
