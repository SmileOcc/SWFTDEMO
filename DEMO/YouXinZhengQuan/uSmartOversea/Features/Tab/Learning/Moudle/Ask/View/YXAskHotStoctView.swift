//
//  YXAskHotStockCell.swift
//  uSmartEducation
//
//  Created by usmart on 2021/12/9.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation
import UIKit
import QMUIKit
import SnapKit
import RxSwift
import RxCocoa
import YXKit

class YXAskHotStoctView: UIView {
    
    var didSelectStocksCallback: (([YXAskStockResModel]) -> Void)?
    
    lazy var hotImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ask_hot_stock_icon")
        return imageView
    }()
    
    lazy var floatLayouView: QMUIFloatLayoutView = {
        let floatView = QMUIFloatLayoutView()
        floatView.padding = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 12)
        floatView.itemMargins = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 12)
        floatView.minimumItemSize = CGSize(width: 52, height: 28)
        floatView.clipsToBounds = true
        return floatView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var currentSelected = [YXAskStockResModel]()
    
    func addHotStock(stocks: [YXAskStockResModel]) {
        for stock in stocks {
            let btn = QMUIButton()
            btn.setBackgroundImage(UIImage(color: UIColor(hexString: "F5F5F5")!), for: .normal)
            btn.setBackgroundImage(UIImage(color: UIColor(hexString: "FEF0E5")!), for: .selected)
            btn.layer.masksToBounds = true
            btn.layer.cornerRadius = 12
            btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
            btn.setTitle(stock.stockName, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 12)
            btn.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
            btn.setTitleColor(UIColor(hexString: "EF7100")!, for: .selected)
            let _ = btn.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext:{ [weak self]_ in
                guard let `self` = self else { return }
                if btn.isSelected {
                    if let index = self.currentSelected.firstIndex(of: stock) {
                        self.currentSelected.remove(at: index)
                    }
                } else {
                    self.currentSelected.append(stock)
                }
                btn.isSelected = !btn.isSelected
                self.didSelectStocksCallback?(self.currentSelected)
            })
            floatLayouView.addSubview(btn)
        }
        let size = floatLayouView.sizeThatFits(CGSize(width: YXConstant.screenWidth, height: YXConstant.screenHeight))
        self.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    }
    
    func setupUI() {
        self.addSubview(hotImage)
        self.addSubview(floatLayouView)
        
        backgroundColor = QMUITheme().foregroundColor()
        
        hotImage.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.top.equalToSuperview().offset(6)
        }
        
        floatLayouView.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.left.equalTo(hotImage.snp.right).offset(6)
        }
    }
    
}
