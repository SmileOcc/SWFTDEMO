//
//  YXWeakBox.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/5/28.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation

final class WeakBox<T: AnyObject> {
    weak var unbox: T?
    init(_ value: T) {
        unbox = value
    }
}

struct WeakArray<Element: AnyObject> {
    private var items: [WeakBox<Element>] = []
    
    init(_ elements: [Element]) {
        items = elements.map { WeakBox($0) }
    }
}

extension WeakArray: Collection {
    var startIndex: Int {
        items.startIndex
    }
    var endIndex: Int {
        items.endIndex
    }
    
    subscript(_ index: Int) -> Element? {
        items[index].unbox
    }
    
    func index(after idx: Int) -> Int {
        items.index(after: idx)
    }
}
