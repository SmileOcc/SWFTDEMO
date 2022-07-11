//
//  SwiftStockDetailDiscussViewController.swift
//  uSmartOversea
//
//  Created by 陈明茂 on 2022/6/6.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import JXPagingView

class SwiftStockDetailDiscussViewController: YXStockDetailDiscussViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.didCallScroll = { [weak self] scrollView in
            self?.listViewDidScrollCallback?(scrollView)
        }
    }
    
}

extension SwiftStockDetailDiscussViewController: JXPagingViewListViewDelegate {
    
    func listScrollView() -> UIScrollView { self.collectionView }
    
}

