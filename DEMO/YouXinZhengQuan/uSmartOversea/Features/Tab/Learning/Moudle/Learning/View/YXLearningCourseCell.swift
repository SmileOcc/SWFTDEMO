//
//  YXLearningCourseCell.swift
//  uSmartOversea
//
//  Created by usmart on 2021/12/16.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class YXLearningCourseCell1: UICollectionViewCell {
    
    lazy var cycleScrollView: YXCycleScrollView = {
        let banner = YXCycleScrollView(frame: CGRect.zero, delegate: self, placeholderImage: UIImage.init(named: "course_banner_placeholder"))
        banner?.showPageControl = false
        banner?.layer.cornerRadius = 12
        banner?.layer.masksToBounds = true
        return banner ?? YXCycleScrollView()
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = QMUITheme().foregroundColor()
        addSubview(cycleScrollView)
        cycleScrollView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
    
    var datas: [YXActivityBannerModel]? {
        didSet {
            self.cycleScrollView.imageURLStringsGroup = datas?.compactMap{$0.img}
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension YXLearningCourseCell1: YXCycleScrollViewDelegate {
    
    func cycleScrollView(_ cycleScrollView: YXCycleScrollView!, didScrollTo index: Int) {
//        pageControl.currentPage = index
    }
    
    func cycleScrollView(_ cycleScrollView: YXCycleScrollView!, didSelectItemAt index: Int) {
        if let bannerModel = datas?[index], let url = bannerModel.redirectPosition {
            if bannerModel.redirectMethod == 2 {
                let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: url]
                NavigatorServices.shareInstance.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            } else {
                YXGoToNativeManager.shared.gotoNativeViewController(withUrlString: url)
            }
        }
    }
}

class YXLearningCourseCell: UICollectionViewCell {
    
    var didTapAction: ((_ market: YXActivityBannerModel) -> Void)?
    var disposeBag: DisposeBag? = DisposeBag()

    var datas: [YXActivityBannerModel] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = QMUITheme().foregroundColor()
//        if #available(iOS 11.0, *) {
//            collectionView.contentInsetAdjustmentBehavior = .never
//        }
        collectionView.dataSource = self
        collectionView.delegate = self
//        collectionView.alwaysBounceHorizontal = true
//        collectionView.alwaysBounceVertical = false
        collectionView.register(YXLearningCourseSubCell.self, forCellWithReuseIdentifier: NSStringFromClass(YXLearningCourseSubCell.self))
//        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = QMUITheme().foregroundColor()
        addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = nil
    }
}

extension YXLearningCourseCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : YXLearningCourseSubCell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXLearningCourseSubCell.self), for: indexPath) as! YXLearningCourseSubCell
        let obj = datas[indexPath.item]
        cell.info = obj
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = datas[indexPath.item]
//        self.didTapAction?(item)
        
//        let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl:item.redirectPosition ?? ""]
//        NavigatorServices.shareInstance.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        
        if item.redirectMethod == 2 {
            let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: item.redirectPosition]
            NavigatorServices.shareInstance.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        } else {
            YXGoToNativeManager.shared.gotoNativeViewController(withUrlString: item.redirectPosition ?? "")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 138*2.017, height: (138 + 8 + 8))
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
//    }
    //
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//
//    }
    //
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    //
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    //
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize
    
}

class YXLearningCourseSubCell: UICollectionViewCell, HasDisposeBag {
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 4
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16, weight: .medium)
//        label.adjustsFontSizeToFitWidth = true
//        label.minimumScaleFactor = 0.3
        label.numberOfLines = 2
        return label
    }()
    
    fileprivate lazy var rocLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    fileprivate lazy var stockNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = .systemFont(ofSize: 14)
//        label.adjustsFontSizeToFitWidth = true
//        label.minimumScaleFactor = 0.8
        return label
    }()
    
    lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center;
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.isHidden = true
        return label
    }()
    
    fileprivate lazy var stockRocLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    var info: YXActivityBannerModel? {
        didSet {
            updateInfo()
        }
    }
    
    var leadStockInfo: YXMarketRankCodeListInfo? {
        didSet {
            if let stock = leadStockInfo {
                if let stockName = stock.chsNameAbbr {
                    stockNameLabel.text = stockName
                }
                
                var color = QMUITheme().stockGrayColor()
                if let stockRoc = stock.pctChng {
                    var op = ""
                    if stockRoc > 0 {
                        op = "+"
                        color = QMUITheme().stockRedColor()
                    }else if stockRoc < 0 {
                        color = QMUITheme().stockGreenColor()
                    }
                    
                    stockRocLabel.textColor = color
                    stockRocLabel.text = op + String(format: "%.2f%%", Double(Double(stockRoc))/100.0)
                    priceLabel.textColor = stockRocLabel.textColor
                }
                
                if let stockPrice = stock.latestPrice, let priceBase = stock.priceBase {
                    priceLabel.text = String(format: "%.\(priceBase)f", Double(stockPrice)/pow(10.0, Double(priceBase)))
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = QMUITheme().foregroundColor()
        layer.cornerRadius = 4
        layer.masksToBounds = true
        initializeViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func updateInfo() {
        self.imageView.sd_setImage(with: URL(string: info?.img ?? ""), placeholderImage: UIImage.init(named: "banner_placeholder1"))
            
    }
    
    fileprivate func initializeViews() {
        
        contentView.addSubview(imageView)
        
        
        imageView.snp.makeConstraints { (make) in
//            make.bottom.equalToSuperview().offset(-8)
//            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(138)
        }
    }
    
    
}

