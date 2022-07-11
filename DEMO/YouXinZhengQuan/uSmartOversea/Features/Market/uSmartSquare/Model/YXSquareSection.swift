//
//  YXSquareSection.swift
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/5/6.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import IGListKit

@objc enum SquareSectionType: Int {
    case newStock, hotStock, guess, topic, comment
}

class YXSquareSection: NSObject {
    
    @objc let name: String
    @objc var subName: String?
    @objc let color: UIColor?
    @objc let type: SquareSectionType

    @objc init(name: String, subName: String?, color: UIColor, type: SquareSectionType) {
        self.name = name
        self.subName = subName
        self.type = type
        self.color = color
    }

}

extension YXSquareSection: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self !== object else { return true }
        guard let object = object as? YXSquareSection else { return false }
        return name == object.name && subName == object.subName
    }
}

