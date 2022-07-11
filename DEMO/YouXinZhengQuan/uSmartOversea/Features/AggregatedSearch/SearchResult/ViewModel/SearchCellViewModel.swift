//
//  SearchCellViewModel.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/2.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class SearchCellViewModel: NSObject {

    let searchWord: String

    private(set) var cellHeight: CGFloat = 0

    init(searchWord: String) {
        self.searchWord = searchWord
        super.init()
        cellHeight = calculateCellHeight()
    }

    func calculateCellHeight() -> CGFloat {
        return 0
    }

}
