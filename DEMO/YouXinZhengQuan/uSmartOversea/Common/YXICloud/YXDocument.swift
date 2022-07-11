//
//  YXDocument.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/12/16.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXDocument: UIDocument {
    public var data = Data.init()
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let data = contents as? Data else { return }
        
        self.data = data
    }
}
