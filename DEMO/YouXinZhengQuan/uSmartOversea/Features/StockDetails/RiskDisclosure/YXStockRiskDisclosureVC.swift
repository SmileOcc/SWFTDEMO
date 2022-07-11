//
//  YXStockRiskDisclosureVC.swift
//  uSmartOversea
//
//  Created by Mac on 2019/9/2.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXStockRiskDisclosureVC: YXPopViewController {
    
    var alertView: YXStockRiskDisclosureView!
    
    var viewModel: YXStockRiskDisclosureViewModel = YXStockRiskDisclosureViewModel()
    
    override func visibleArea() -> UIView? {
        alertView
    }
    var completed :(()->Void)?
    var cancel :(()->Void)?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.2)
        
        let verMargin: CGFloat = uniVerLength(150)
        alertView = YXStockRiskDisclosureView(frame: CGRect(x: 25, y: verMargin, width: YXConstant.screenWidth - 50, height: YXConstant.screenHeight - verMargin * 2))
        view.addSubview(alertView)
        
        alertView.completed = { [weak self] in
            
            self?.dismiss(animated: true, completion: nil)
            self?.completed?()
        }
        alertView.cancel = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
            self?.cancel?()
        }
    }
    deinit {
        print(">>> YXStockRiskDisclosureVC deint")
    }
}
