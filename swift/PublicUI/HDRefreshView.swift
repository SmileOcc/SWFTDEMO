//
//  HDRefreshView.swift
//  HDPublicUIProject
//
//  Created by MountainZhu on 2020/6/16.
//  Copyright © 2020 航电. All rights reserved.
//

import UIKit
import MJRefresh

public class HDRefreshView: MJRefreshNormalHeader {

//    // 转圈icon
//    var loadingView: UIActivityIndicatorView?
//    // 下拉的icon
//    var arrowImage: UIImageView?
//    
//    // 处理不同刷新状态下的组件状态
//    override public var state: MJRefreshState {
//        didSet {
//            switch state {
//            case .idle:
//                self.loadingView?.isHidden = true
//                self.arrowImage?.isHidden = false
//                self.loadingView?.stopAnimating()
//            case .pulling:
//                self.loadingView?.isHidden = false
//                self.arrowImage?.isHidden = true
//                self.loadingView?.startAnimating()
//            case .refreshing:
//                self.loadingView?.isHidden = false
//                self.arrowImage?.isHidden = true
//                self.loadingView?.startAnimating()
//            default:
//                print("")
//            }
//        }
//    }
//    
//    // 初始化组件
//    override public func prepare() {
//        super.prepare()
//        self.mj_h = 50
//        
//        self.loadingView = UIActivityIndicatorView(style: .gray)
//        self.arrowImage = UIImageView(image: UIImage(named: "arrow_downward"))
////        self.addSubview(loadingView!)
////        self.addSubview(arrowImage!)
//        
//    }
//    
//    // 组件定位
//    override public func placeSubviews() {
//        super.placeSubviews()
//        self.loadingView?.center = CGPoint(x: self.mj_w / 2, y: self.mj_h / 2)
//        self.arrowImage?.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
//        self.arrowImage?.center = self.loadingView!.center
//    }

}
