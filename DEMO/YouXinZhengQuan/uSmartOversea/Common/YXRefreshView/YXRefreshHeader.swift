//
//  YXRefreshHeader.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/2/1.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import FLAnimatedImage

class YXRefreshHeader: MJRefreshHeader {
    
    @objc var xNoNavStyle = false
    
    private var refreshingStartTime  : TimeInterval = 0

    
    lazy var pullingView : LOTAnimationView = {
        let pullingView = LOTAnimationView.init(name: refreshAnimation())
        return pullingView
      }()
    
    
    lazy var refreshingView: LOTAnimationView = {
        let refreshingView = LOTAnimationView.init(name: refreshAnimation())
        refreshingView.loopAnimation = true
        return refreshingView
    }()
    
    
    lazy var tiplab: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.qmui_color(withHexString: "#888996")
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }()
    
    func pullingAnimation() -> String {
        "refresh_pulling"
    }
    
    func refreshAnimation() -> String {
        "refresh_refreshing"
    }
    
    func tipLabelColor() -> UIColor {
        QMUITheme().textColorLevel2()
    }

    override var state: MJRefreshState {
        didSet {
            switch state {
            case .idle:
                self.pullingView.stop()
                self.refreshingView.isHidden = true
                self.pullingView.isHidden = false
                self.tiplab.text = YXLanguageUtility.kLang(key: "common_drop_refresh")
                self.refreshingView.stop()
            case .pulling:
                self.refreshingView.isHidden = true
                self.pullingView.isHidden = false
                self.tiplab.text = YXLanguageUtility.kLang(key: "common_release_refresh")
            case .refreshing:
                self.refreshingView.play()
                self.refreshingView.isHidden = false
                self.pullingView.isHidden = true
                self.pullingView.play(toProgress: 1, withCompletion: nil)
                self.tiplab.text = YXLanguageUtility.kLang(key: "common_refreshing")
                self.refreshingStartTime = Date.timeIntervalSinceReferenceDate
            case .noMoreData:
                log(.debug, tag: kOther, content: "no more data")
            case .willRefresh:
                log(.debug, tag: kOther, content: "will refresh")
            }
        }
    }
    
    override var pullingPercent: CGFloat {
        didSet {
            if state != .idle {
                return
            }
        }
    }
    
    override func prepare() {
        super.prepare()
        
        self.mj_h = 85
        self.addSubview(self.pullingView)
        self.addSubview(self.refreshingView)
        self.addSubview(self.tiplab)
    }
    
    override func placeSubviews() {
        super.placeSubviews()
        
        var y = self.mj_h-55
        if xNoNavStyle {
            y = self.mj_h-75
        }
        self.pullingView.bounds = CGRect.init(x: 0, y: 0, width: uniHorLength(68), height: uniVerLength(14))
        self.pullingView.center = CGPoint.init(x: self.mj_w/2, y: y)
        self.refreshingView.bounds = CGRect.init(x: 0, y: 0, width: uniHorLength(68), height: uniVerLength(14))
        self.refreshingView.center = CGPoint.init(x: self.mj_w/2, y: y)
        self.tiplab.bounds = CGRect.init(x: 0, y: 0, width: YXConstant.screenWidth, height: 25)
        self.tiplab.center = CGPoint(x: self.mj_w/2, y: self.pullingView.frame.minY+self.pullingView.frame.height+20)
    }
    
    override func endRefreshing() {
        
        let diff = Date.timeIntervalSinceReferenceDate - self.refreshingStartTime
        
        if  diff >= 1 {
            self.delayEndRefreshing()
        }else {//完成一次动画播放耗时1秒
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + (1 - diff)) {
                self.delayEndRefreshing()
            }
        }
        
    }
    //为了展示刷新完成状态延迟 刷新
    private func delayEndRefreshing() {
        self.refreshingView.isHidden = true
        self.pullingView.isHidden = false
      //  pullingView.image = refreshDoneImage
        self.tiplab.text = YXLanguageUtility.kLang(key: "common_refresh_done")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            super.endRefreshing()
        }
    }
}
