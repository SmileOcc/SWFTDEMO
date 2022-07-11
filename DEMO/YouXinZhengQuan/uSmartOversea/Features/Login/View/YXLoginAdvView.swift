//
//  YXLoginAdvView.swift
//  uSmartOversea
//
//  Created by 欧冬冬 on 2022/5/7.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXLoginAdvView: UIView {

    
    typealias closeBlock = ()->()
    typealias bannerBlock = (Int)->()
    
    @objc var didCloseBlock : closeBlock?
    @objc var tapBannerBlock: bannerBlock?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        addSubview(cycleScrollView)
        addSubview(pageControl)
        addSubview(closeBannerButton)
        
        cycleScrollView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        pageControl.snp.makeConstraints { make in
            make.bottom.equalTo(self.snp.bottom).offset(-5)
            make.centerX.equalToSuperview()
        }
        
        closeBannerButton.snp.makeConstraints { make in
            make.right.equalTo(self.self.snp.right).offset(-8)
            make.top.equalTo(self.self.snp.top).offset(3)
        }
        
        self.layer.cornerRadius = 2
        self.layer.masksToBounds = true
        
     }
    
    @objc var imageURLStringsGroup = [String]() {
        didSet {
            self.cycleScrollView.imageURLStringsGroup = imageURLStringsGroup
            self.numberOfPages = imageURLStringsGroup.count
        }
    }
    
    @objc var numberOfPages = 0 {
        didSet {
            self.pageControl.numberOfPages = numberOfPages
            if numberOfPages <= 1 {
                self.pageControl.isHidden = true
            } else {
                self.pageControl.isHidden = false
            }
        }
    }
    
    
    lazy var cycleScrollView: YXCycleScrollView = {
        let banner = YXCycleScrollView(frame: CGRect.zero, delegate: self, placeholderImage: UIImage.init(named: "login_banner_placeholder"))
        banner?.showPageControl = false
        banner?.autoScrollTimeInterval = 5
        return banner ?? YXCycleScrollView()
    }()
    
    lazy var pageControl: TAPageControl = {
        let pageControl = TAPageControl()
        pageControl.spacingBetweenDots = 4
        pageControl.isUserInteractionEnabled = false
        pageControl.hidesForSinglePage = true
        pageControl.currentPage = 0
        let dotSize = CGSize(width: 8, height: 2)
        pageControl.dotSize = dotSize
        pageControl.isHidden = true

        var normalColor = UIColor.qmui_color(withHexString: "#FFFFFF")?.withAlphaComponent(0.4)
        var selectedColor = UIColor.qmui_color(withHexString: "#FFFFFF")
        pageControl.currentDotImage = UIImage.qmui_image(with: selectedColor, size: CGSize(width: 8, height: 2), cornerRadius: 1.5)
        pageControl.dotImage = UIImage.qmui_image(with: normalColor, size: CGSize(width: 8, height: 2), cornerRadius: 1.5)
        return pageControl
    }()
    
    lazy var closeBannerButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.addTarget(self, action: #selector(closeBannerAction), for: .touchUpInside)
        button.setImage(UIImage.init(named: "closed_white"), for: .normal)
        return button
    }()

    @objc func closeBannerAction() {
        if let close = self.didCloseBlock {
            close()
        }
    }
}


extension YXLoginAdvView: YXCycleScrollViewDelegate {
    
    func cycleScrollView(_ cycleScrollView: YXCycleScrollView!, didScrollTo index: Int) {
        pageControl.currentPage = index
    }
    
    func cycleScrollView(_ cycleScrollView: YXCycleScrollView!, didSelectItemAt index: Int) {
        if let tapBlock = self.tapBannerBlock {
            tapBlock(index)
        }
    }
    
}
