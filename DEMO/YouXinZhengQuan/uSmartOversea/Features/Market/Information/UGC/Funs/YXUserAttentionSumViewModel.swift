//
//  YXUserAttentionSumViewModel.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/8/17.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXUserAttentionSumViewModel: YXViewModel {
    
    @objc var selectedIndex: Int = 0
    @objc var target_uid: String = ""

    override func initialize() {
        super.initialize()
        
        if let uid = self.params?["target_uid"] as? String {
            self.target_uid = uid
        }
        if let selectedIndex = self.params?["selectedIndex"] as? Int {
            self.selectedIndex = selectedIndex
        }
    }

}
