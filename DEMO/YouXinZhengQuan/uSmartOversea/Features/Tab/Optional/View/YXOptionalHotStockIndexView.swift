//
//  YXOptionalHotStockIndexView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/6/30.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import SDCycleScrollView
import YXKit

class YXOptionalHotStockIndexView: UIView {

    var onClickIndexPath: ((_ inputs: [YXStockInputModel], _ selectIndex: Int) -> Void)?

    private var resetPage: Int = 0
    private var isFirstResetCurrentPage = true
    fileprivate let scale = YXConstant.screenWidth / 375.0
    fileprivate let collectionViewWidth: CGFloat = (YXConstant.screenWidth - 30)


    @objc var dataSource: [YXV2Quote] = [] {
        didSet {
            if dataSource.count < 4 {
                self.collectionView.isScrollEnabled = false
            } else {
                self.collectionView.isScrollEnabled = true
            }
            let pages = dataSource.count / 3
            pageControl.numberOfPages = pages > 0 ? pages : 1
            self.collectionView.reloadData()
            DispatchQueue.main.async {
                self.resetCurrentPage(self.resetPage)
            }
        }
    }

    func resetCurrentPage(_ currentPage: Int) {

        self.resetPage = currentPage
        if isFirstResetCurrentPage, self.dataSource.count > 0, currentPage < pageControl.numberOfPages {
            isFirstResetCurrentPage = false
            pageControl.currentPage = currentPage
            collectionView.setContentOffset(CGPoint(x: collectionViewWidth * CGFloat(currentPage), y: 0), animated: false)

        }

    }


    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func initializeViews() {

        addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.bottom.equalToSuperview()
        }

        addSubview(pageControl)
        pageControl.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-6)
        }

        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().textColorLevel1()
        addSubview(lineView)

        lineView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self)
            make.height.equalTo(1)
        }
    }

    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(YXOptionalHotStockIndexCell.self, forCellWithReuseIdentifier: NSStringFromClass(YXOptionalHotStockIndexCell.self))
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = UIColor.qmui_color(withHexString: "#F1F1F1")

        return collectionView
    }()

    fileprivate lazy var pageControl: TAPageControl = {
        let pageControl = TAPageControl()
        pageControl.numberOfPages = 3
        pageControl.dotImage = UIImage.qmui_image(with: QMUITheme().itemBorderColor(), size: CGSize(width: 8, height: 2), cornerRadius: 1)
        pageControl.currentDotImage = UIImage.qmui_image(with: QMUITheme().themeTextColor(), size: CGSize(width: 8, height: 2), cornerRadius: 1)
        pageControl.isUserInteractionEnabled = false
        pageControl.currentPage = 0
        pageControl.spacingBetweenDots = 6
        pageControl.hidesForSinglePage = true

        return pageControl
    }()

}


//MARK: - UICollectionViewDelegate
extension YXOptionalHotStockIndexView: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let indexCell = cell as? YXOptionalHotStockIndexCell {
            if indexPath.item < dataSource.count {
                let obj = dataSource[indexPath.item]
                indexCell.secu = obj
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        var inputs: [YXStockInputModel] = []
        for info in dataSource {
            if let market = info.market, let symbol = info.symbol {

                let input = YXStockInputModel()
                input.market = market
                input.symbol = symbol
                input.name = info.name ?? ""
                inputs.append(input)
            }
        }
        if inputs.count > 0 {
            self.onClickIndexPath?(inputs, indexPath.item)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / collectionViewWidth + 0.5)
        if page != pageControl.currentPage {
            pageControl.currentPage = page
        }
    }
}

//MARK: - UICollectionViewDataSource
extension YXOptionalHotStockIndexView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXOptionalHotStockIndexCell.self), for: indexPath)
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension YXOptionalHotStockIndexView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: self.collectionViewWidth / 3, height: 35)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0;
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }


}




class YXOptionalHotStockIndexCell: UICollectionViewCell {
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.qmui_color(withHexString: "#666666")
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.text = "--"
        return label
    }()

    lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().stockGrayColor()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.text = "--"
        return label
    }()

    lazy var changeRocLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.textColor = QMUITheme().stockGrayColor()
        label.text = "0.00%"
        return label
    }()

    var secu: YXV2Quote? {
        didSet {
            update()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.qmui_color(withHexString: "#F1F1F1")
        initializeViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func initializeViews() {
        let scale = YXConstant.screenWidth / 375.0

        addSubview(priceLabel)
        addSubview(nameLabel)
        addSubview(changeRocLabel)

        priceLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(10 * scale)
            make.right.equalToSuperview().offset(-10 * scale)
            make.height.equalTo(18)
        }

        changeRocLabel.snp.makeConstraints { (make) in
            make.top.equalTo(priceLabel.snp.bottom)
            make.right.equalToSuperview().offset(-10 * scale)
            make.height.equalTo(17)
        }
        changeRocLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(priceLabel.snp.bottom)
            make.left.equalToSuperview().offset(10 * scale)
            make.height.equalTo(17)
            make.right.lessThanOrEqualTo(changeRocLabel.snp.left).offset(-5)
        }

    }

    func update() {
        if let secuObject = secu {
            nameLabel.text = secuObject.name

            var op = ""
            if let value = secuObject.netchng?.value, value > 0 {
                op = "+"
                priceLabel.textColor = QMUITheme().stockRedColor()
                changeRocLabel.textColor = QMUITheme().stockRedColor()

            } else if let value = secuObject.netchng?.value, value < 0 {
                priceLabel.textColor = QMUITheme().stockGreenColor()
                changeRocLabel.textColor = QMUITheme().stockGreenColor()

            } else {
                priceLabel.textColor = QMUITheme().stockGrayColor()
                changeRocLabel.textColor = QMUITheme().stockGrayColor()

            }
            if let value = secuObject.latestPrice?.value, value > 0,
                let priceBase = secuObject.priceBase?.value {
                priceLabel.text = String(format: "%.\(priceBase)f", Double(value)/pow(10.0, Double(priceBase)))
            } else {
                priceLabel.text = "--";
            }

            if let roc = secuObject.pctchng?.value {
                 changeRocLabel.text = op + String(format: "%.2f%%", Double(roc)/100.0)
            } else {
                changeRocLabel.text = "0.00%"
            }

        }
    }
}


