//
//  YXMultiassetView.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/12/6.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

import UIKit

import RxSwift
import RxCocoa
import NSObject_Rx

class YXMultiassetView: UIView {
    
    fileprivate var isEmpty: Bool = false
    fileprivate var cellCount: Int = 0
    fileprivate var assetModel: YXStockMultiasset? //暂存model
    //选中的block
    var selectBlock: ((_ indexPath: IndexPath) -> Void)?
    
    //无数据view的height
    fileprivate var kEmptyHeight: CGFloat {
        134.0
    }
    fileprivate var kCellHeight: CGFloat {
        150.0
    }

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = QMUITheme().textColorLevel1()
        label.textAlignment = .left
        return label
    }()
    
    lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel3()
        label.textAlignment = .left
        return label
    }()
    
    var collectView: UICollectionView!
    
    //无数据视图
    lazy var emptyView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializeViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initializeViews() {
        let margin: CGFloat = 18
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 240.0, height: kCellHeight)
        layout.sectionInset = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin)
        layout.minimumLineSpacing = 10
        
        self.collectView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        self.collectView.delegate = self
        self.collectView.dataSource = self
        self.collectView.backgroundColor = .clear
        self.collectView.register(YXStockSTMutilAssetsDetailCell.self, forCellWithReuseIdentifier: "YXStockSTMutilAssetsDetailCell")
        self.collectView .showsHorizontalScrollIndicator = false
        self.collectView.contentOffset = CGPoint(x: 0, y: 0)
        
        
        self.addSubview(titleLabel)
        self.addSubview(subTitleLabel)
        
        self.addSubview(self.collectView)
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(margin)
            make.right.equalToSuperview().offset(-margin)
            make.top.equalToSuperview().offset(20)
            make.height.equalTo(22)
        }
        
        self.subTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(margin)
            make.right.equalToSuperview().offset(-margin)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(1)
            make.height.equalTo(17)
        }
        
        self.collectView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.subTitleLabel.snp.bottom).offset(10)
            make.height.equalTo(kCellHeight)
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        size.height = 15 * 2 + 13 + 40
        if isEmpty {//空视图的size
            size.height += kEmptyHeight
        } else { //collectView的size
            size.height += kCellHeight
        }
        return size
    }
    
    
    //重载数据
    func reloadData(_ model: YXStockMultiasset?) {
        guard let model = model else { return }
        assetModel = model
        
        self.titleLabel.text = model.columnHeading
        self.subTitleLabel.text = model.columnSubhead
        
        //判断：有没有stocks
        if let count = model.blocks?.count, count > 0 {
            isEmpty = false
            emptyView.isHidden = true
            collectView.isHidden = false
            cellCount = count
        } else {
            isEmpty = true
            emptyView.isHidden = false
            collectView.isHidden = true
            cellCount = 0
        }
        collectView.reloadData()
    }
}

extension YXMultiassetView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "YXStockSTMutilAssetsDetailCell", for: indexPath) as! YXStockSTMutilAssetsDetailCell
        if indexPath.row < assetModel?.blocks?.count ?? 0 {
            cell.reloadData(assetModel?.blocks?[indexPath.row], indexPath: indexPath)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cellCount
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        selectBlock?(indexPath)
    }
}

class YXStockSTMutilAssetsDetailCell: UICollectionViewCell, HasDisposeBag {
    public static let LOGO_IMAGE_VIEW_WIDTH: CGFloat = 50
    public static let LOGO_IMAGE_VIEW_HEIGHT: CGFloat = 50
    
    lazy var belowView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var backView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var logoImgView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "multi_asset_default"))
        return iv
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = QMUITheme().textColorLevel1()
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel2()
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    lazy var stockNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = QMUITheme().textColorLevel1()
        label.numberOfLines = 2
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 12.0 / 16.0
        return label
    }()
    
    lazy var stockIdLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = QMUITheme().textColorLevel3()
        label.textAlignment = .left
        return label
    }()
    lazy var stockRateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = YXStockColor.currentColor(.up)
        label.textAlignment = .right
        return label
    }()
    lazy var rateDescLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = QMUITheme().textColorLevel3()
        label.textAlignment = .right
        label.numberOfLines = 2
        label.text = YXLanguageUtility.kLang(key: "stockST_today_gains")
        return label
    }()
    lazy var delayLabel: QMUILabel = {
        let label = QMUILabel()
        label.text = YXLanguageUtility.kLang(key: "common_delay")
        label.font = .systemFont(ofSize: 10)
        label.textColor = QMUITheme().textColorLevel3()
        label.backgroundColor = QMUITheme().separatorLineColor()
        label.isHidden = true
        label.contentEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializeViews()
        asyncRender()
        
    }
    func initializeViews() {
        
        self.backgroundColor = .clear
        
        self.contentView.addSubview(belowView)
        belowView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        //backView在level-1
        belowView.addSubview(backView)
        backView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        let rightMargin: CGFloat = 15
        backView.addSubview(logoImgView)
        logoImgView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(15)
            make.size.equalTo(CGSize(width: YXStockSTMutilAssetsDetailCell.LOGO_IMAGE_VIEW_WIDTH, height: YXStockSTMutilAssetsDetailCell.LOGO_IMAGE_VIEW_HEIGHT))
        }
        
        backView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.logoImgView.snp.right).offset(rightMargin)
            make.right.equalToSuperview().offset(-rightMargin)
            make.top.equalToSuperview().offset(rightMargin)
            make.height.equalTo(25)
        }
        
        backView.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.titleLabel)
            make.right.equalToSuperview().offset(-rightMargin)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(3)
        }
        
        backView.addSubview(stockNameLabel)
        stockNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.logoImgView)
            make.top.equalTo(self.logoImgView.snp.bottom).offset(15)
        }
    
        backView.addSubview(stockIdLabel)
        stockIdLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.logoImgView)
            make.top.equalTo(self.stockNameLabel.snp.bottom).offset(3)
        }
        // [延]
        backView.addSubview(delayLabel)
        delayLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.stockIdLabel.snp.right).offset(6)
            make.centerY.equalTo(self.stockIdLabel)
        }
        delayLabel.rx.observeWeakly(String.self, "text").subscribe(onNext: {  [weak self] (_) in
            self?.delayLabel.layer.cornerRadius = 2
            self?.delayLabel.layer.masksToBounds = true
        }).disposed(by: disposeBag)
        
        backView.addSubview(stockRateLabel)
        stockRateLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-20)
            make.left.greaterThanOrEqualTo(self.stockNameLabel.snp.right).offset(5)//-10)
            make.top.equalTo(self.stockNameLabel)
        }
        stockRateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
      
        backView.addSubview(rateDescLabel)
        rateDescLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-20)
            make.left.greaterThanOrEqualTo(self.stockNameLabel.snp.right).offset(-5)
            make.top.equalTo(self.stockRateLabel.snp.bottom).offset(3)
            //make.bottom.equalTo(self.stockIdLabel)
        }
    }
    override func draw(_ rect: CGRect) {
        self.belowView.layer.shadowPath = UIBezierPath.init(rect: self.belowView.bounds.offsetBy(dx: 0, dy: 4)).cgPath
    }
    //异步渲染
    func asyncRender() {
        DispatchQueue.main.async {
            self.belowView.layer.backgroundColor = QMUITheme().foregroundColor().cgColor
            self.belowView.layer.cornerRadius = 10
            self.belowView.layer.borderColor = QMUITheme().separatorLineColor().cgColor
            self.belowView.layer.borderWidth = 1
            self.belowView.layer.shadowColor = QMUITheme().separatorLineColor().cgColor
            self.belowView.layer.shadowOpacity = 1.0
            
            self.backView.layer.backgroundColor = QMUITheme().foregroundColor().cgColor
            self.backView.layer.cornerRadius = 10
            self.backView.layer.masksToBounds = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //重载数据
    func reloadData(_ model: YXStockMultiassetBlocks?, indexPath: IndexPath) {
        guard let model = model else { return }
        
        if let iconText = model.icon, iconText.count > 0 {
            let transformer = SDImageResizingTransformer(size: CGSize(width: YXStockSTMutilAssetsDetailCell.LOGO_IMAGE_VIEW_WIDTH * UIScreen.main.scale, height: YXStockSTMutilAssetsDetailCell.LOGO_IMAGE_VIEW_HEIGHT * UIScreen.main.scale), scaleMode: .aspectFill)
            logoImgView.sd_setImage(with: URL(string: iconText), placeholderImage: UIImage(named: "multi_asset_default"), options: [], context: [SDWebImageContextOption.imageTransformer: transformer])
        }
        
        if let market = model.topStockMarket {
            switch YXUserManager.userLevel(market) {
            case .usDelay, .hkDelay:
                self.delayLabel.isHidden = false
            default:
                self.delayLabel.isHidden = true
            }
        } else {
            self.delayLabel.isHidden = true
        }
        
        
        
        titleLabel.text = model.blockHeading
        subTitleLabel.text = model.blockSubhead
        self.stockNameLabel.text = model.topStockName
        self.stockIdLabel.text = model.topStockID
        if let stockRate = model.topStockRate, let rate = Double(stockRate) {
            if rate > 0 {
                stockRateLabel.text = String(format: "+%.02f%%", rate * 100.0)
                stockRateLabel.textColor = YXStockColor.currentColor(.up)
            } else if rate < 0 {
                stockRateLabel.text = String(format: "%.02f%%", rate * 100.0)
                stockRateLabel.textColor = YXStockColor.currentColor(.down)
            } else {
                stockRateLabel.text = String(format: "%.02f%%", rate * 100.0)
                stockRateLabel.textColor = YXStockColor.currentColor(.flat)
            }
        } else {
            stockRateLabel.text = "0.00%"
            stockRateLabel.textColor = QMUITheme().textColorLevel1()
        }
    }
}
