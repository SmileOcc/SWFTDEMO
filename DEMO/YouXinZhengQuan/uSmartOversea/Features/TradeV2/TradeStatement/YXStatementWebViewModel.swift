//
//  YXStatementWebViewModel.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/7/20.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXStatementWebViewModel: YXViewModel {
    
    var pdfUrl:String = ""
    
    override func initialize() {
        super.initialize()
        
        if let pdfUrl = self.params?["pdfUrl"]  {
            self.pdfUrl = pdfUrl as? String ?? ""
        }
    }

}
