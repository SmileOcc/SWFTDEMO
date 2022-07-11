//
//  YXGifAndPictureBannerView.swift
//  uSmartOversea
//
//  Created by suntao on 2021/1/22.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import SDCycleScrollView
import FLAnimatedImage


class YXGifAndPictureBannerView: UIView, YXCycleScrollViewDelegate {
    
    typealias TapActionBlock = () -> Void
    typealias DidSelectBlock = (_ index: Int) -> Void
    @objc var tapClickBlock: TapActionBlock?
    @objc var didSeletBlock: DidSelectBlock?
    
    var imageUrls: [String] = []
    var pageControl: TAPageControl = {
        let pageDot = TAPageControl()
        pageDot.isUserInteractionEnabled = true
        pageDot.currentPage = 0
        pageDot.spacingBetweenDots = 6
        pageDot.currentDotImage = UIImage.qmui_image(with: UIColor.qmui_color(withHexString: "#191919"), size: CGSize.init(width: 8, height: 2), cornerRadius: 0)
        pageDot.dotImage = UIImage.qmui_image(with: UIColor.white.withAlphaComponent(0.3), size: CGSize.init(width: 8, height: 2), cornerRadius: 0)
        
        return pageDot
    }()
    
    lazy var cycleScrollView: YXCycleScrollView = {
        let scrollView = YXCycleScrollView(frame: CGRect(x: 0, y: 0, width: YXConstant.screenWidth - 12 - 12 , height: 70))
        scrollView.backgroundColor = .clear
        scrollView.delegate = self;
        scrollView.scrollDirection = .horizontal
        scrollView.showPageControl = false
        scrollView.autoScrollTimeInterval = 3
        scrollView.isUserInteractionEnabled = true
        scrollView.pageControlStyle = YXCycleScrollViewPageContolStyleNone
        scrollView.showBackView = false
        
        return scrollView
    }()
    
    lazy var shadowLayerView: UIView = {
        let view = UIView()
        view.layer.shadowColor = UIColor.qmui_color(withHexString: "#000000")?.withAlphaComponent(0.1).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize.init(width: 2, height: 2)
        view.layer.shadowRadius = 4
        
        return view
    }()
    
    lazy var shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.qmui_color(withHexString: "#FBFBFB")
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        
        return view
    }()
    
    lazy var closeButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setImage(UIImage.init(named: "ad_close"), for: .normal)
        button.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        
        return button
    }()
    
    var dataSource: [Banner]? {
        didSet {
            self.imageUrls.removeAll()
            dataSource?.forEach({ (banner) in
                if let url = banner.pictureUrl {
                    self.imageUrls.append(url)
                }
                
            })
            self.cycleScrollView.imageURLStringsGroup = self.imageUrls
            if self.imageUrls.count > 1 {
                self.pageControl.isHidden = false
                self.pageControl.numberOfPages = self.imageUrls.count
            }else{
                self.pageControl.isHidden = true
            }
           
        }
    }
                

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(shadowLayerView)
        shadowLayerView.addSubview(shadowView)
        shadowView.addSubview(cycleScrollView)
        shadowView.addSubview(closeButton)
        
        shadowView.addSubview(pageControl)
        
        shadowLayerView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(12)
            make.right.equalTo(-12)
        }
        
        shadowView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.shadowLayerView)
        }
        
        closeButton.snp.makeConstraints { (make) in
            make.top.equalTo(7)
            make.width.equalTo(15)
            make.height.equalTo(15)
            make.right.equalTo(-7)
        }
        
        cycleScrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        pageControl.snp.makeConstraints { (make) in
            make.bottom.equalTo(-6)
            make.centerX.equalToSuperview()
        }
        
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    @objc func tapAction() {
//         tapClickBlock?()
//     }
    
    @objc func closeButtonAction() {
        tapClickBlock?()
    }
    
    func cycleScrollView(_ cycleScrollView: YXCycleScrollView!, didSelectItemAt index: Int) {
        didSeletBlock?(index)
    }

    func customCollectionViewCellClass(for view: YXCycleScrollView!) -> AnyClass! {
        YXGifAndPictureBannerCell.self
    }
    
    func setupCustomCell(_ cell: UICollectionViewCell!, for index: Int, cycleScrollView view: YXCycleScrollView!) {
        if let cell = cell as? YXGifAndPictureBannerCell {
            if index < self.imageUrls.count {
                cell.imageUrl = self.imageUrls[index]
            }
        }
    }
    
    func cycleScrollView(_ cycleScrollView: YXCycleScrollView!, didScrollTo index: Int) {
        self.pageControl.currentPage = index
    }
}


class YXGifAndPictureBannerCell: YXCycleViewCell {
    
    var imageUrl: String? {
        didSet {
            if let url = imageUrl {
                picImageView.sd_setImage(with: URL(string: url), placeholderImage: nil, options: [], context: [:])
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        addSubview(gifImageView)
        addSubview(picImageView)
        picImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        gifImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    lazy var picImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()

    lazy var gifImageView : FLAnimatedImageView = {
        let imageView = FLAnimatedImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        
        return imageView
        
    }()
}


