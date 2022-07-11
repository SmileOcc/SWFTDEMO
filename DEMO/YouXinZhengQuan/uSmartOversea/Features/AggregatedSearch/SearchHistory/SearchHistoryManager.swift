//
//  SearchHistoryManager.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/8.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import Foundation

class SearchHistoryManager: NSObject {

    static let sharedManager = SearchHistoryManager()

    private let kAggregatedSearchHistoryKey = "kAggregatedSearchHistoryKey"
    private let kAggregatedSearchHistoryMaxCount = 10

    func getHistories() -> NSArray {
        if let histories = MMKV.default().object(of: NSArray.self, forKey: kAggregatedSearchHistoryKey) as? NSMutableArray {
            return histories
        }
        return []
    }

    func append(_ keyword: String?) {
        guard let keyword = keyword, !keyword.isEmpty else {
            return
        }

        // 判断是否全是空格
        if keyword.removeBlankSpace().isEmpty {
            return
        }

        var newHistories: NSMutableArray

        if let histories = MMKV.default().object(of: NSMutableArray.self, forKey: kAggregatedSearchHistoryKey) as? NSMutableArray {
            if histories.contains(keyword) {
                histories.remove(keyword)
            }

            if histories.count >= kAggregatedSearchHistoryMaxCount {
                histories.removeLastObject()
            }

            histories.insert(keyword, at: 0)

            newHistories = histories
        } else {
            newHistories = NSMutableArray(object: keyword)
        }

        MMKV.default().set(newHistories, forKey: kAggregatedSearchHistoryKey)
    }

    func removeAll() {
        MMKV.default().removeValue(forKey: kAggregatedSearchHistoryKey)
    }

}
