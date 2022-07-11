//
//  YXShortVideoIndexViewController.swift
//  YouXinZhengQuan
//
//  Created by usmart on 2022/3/12.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import QMUIKit
import Lottie
import MMKV
import RxCocoa
import YXKit

class YXShortVideoIndexViewController: YXHKViewController {
    
    lazy var vc: YXShortVideoMainViewController = {
        let vc = YXShortVideoMainViewController()
        vc.isFullScreen = false
        vc.businessType = .mutile
        vc.didClickedBackBlock = { [weak self] in
            guard let `self` = self else { return }
            self.vc.isFullScreen = false
            self.vc.view.removeFromSuperview()
            self.addChild(vc)
            self.view.addSubview(self.vc.view)
            self.vc.view.snp.makeConstraints { make in
                make.left.right.top.equalToSuperview()
                make.bottom.equalTo(-YXConstant.tabBarHeight())
            }
        }
        vc.didClickPlayBlock = { [weak self] in
            guard let `self` = self else { return }
            self.vc.isFullScreen = true
            vc.removeFromParent()
            self.vc.view.removeFromSuperview()
            UIApplication.shared.keyWindow?.addSubview(self.vc.view)
            self.vc.view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        return vc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addChild(vc)
        self.view.addSubview(self.vc.view)
        self.vc.view.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(-YXConstant.tabBarHeight())
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
