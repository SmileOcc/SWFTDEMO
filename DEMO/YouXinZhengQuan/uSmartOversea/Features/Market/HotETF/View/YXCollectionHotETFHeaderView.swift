//
//  YXCollectionHotETFHeaderView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/5/21.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXCollectionHotETFHeaderView: UICollectionReusableView {
    
    var action: (() -> Void)?
    
    lazy var commonHeader: YXMarketCommonHeaderCell = {
        let header = YXMarketCommonHeaderCell()
        header.titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        header.titleLabel.snp.remakeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.equalTo(YXConstant.screenWidth-70)
        }
        return header
    }()
    
    var blueView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().mainThemeColor()
        return view
    }()
    
    var title: String = "" {
        didSet {
            commonHeader.title = title
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(commonHeader)
        
        addSubview(blueView)
        
        commonHeader.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        blueView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(14)
            make.width.equalTo(4)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
