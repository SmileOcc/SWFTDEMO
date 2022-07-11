//
//  YXNewWarrantsFundFlowRankCell.swift
//  uSmartOversea
//
//  Created by youxin on 2020/10/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import Masonry

class YXNewWarrantsFundFlowRankCell: YXStockListCell {
    
    lazy var marketIconView:UIImageView = {
        return UIImageView.init()
    }()
    
    override var labels: [YXMobileBrief1Label] {
        get {
            
            return self.mobileBrief1Labels
        }
        set {
            
        }
    }
    
    lazy var mobileBrief1Labels: [YXMobileBrief1Label] = {
        return self.sortTypes.map { (number) -> YXMobileBrief1Label in
            if let num = number as? NSNumber {
                let type = YXMobileBrief1Type.init(rawValue: UInt(num.intValue)) ?? .now
                let label = YXMobileBrief1Label.init(mobileBrief1Type: type)
                var tap: UITapGestureRecognizer
                if type == .yxSelection {
                    tap = UITapGestureRecognizer.init(target: self, action: #selector(tapYXSelection))
                }else {
                    tap = UITapGestureRecognizer.init(target: self, action: #selector(tapStock))
                }
                label.addGestureRecognizer(tap)
                label.isUserInteractionEnabled = true
                return label
            }else {
                return YXMobileBrief1Label.init(mobileBrief1Type: .now)
            }
        }
    }()
    
    override func initialUI() {
        super.initialUI()
        
        contentView.addSubview(marketIconView)
        
        nameLabel.mas_remakeConstraints { maker in
            
        }
        
        delayLabel.mas_remakeConstraints { make in
            
        }
        
        self.symbolLabel.snp.makeConstraints { make in
            make.left.equalTo(self.contentView).offset(16)
            make.top.equalTo(self.contentView).offset(30)
            make.height.equalTo(22)
        }
        self.nameLabel.snp.makeConstraints { make in
            make.left.equalTo(self.contentView).offset(16)
            make.top.equalTo(self.contentView).offset(10)
            make.width.equalTo(135)
            make.height.equalTo(15)
        }
        
        self.delayLabel.snp.makeConstraints { make in
            make.left.equalTo(self.symbolLabel.snp.right).offset(4)
            make.height.equalTo(12);
            make.centerY.equalTo(self.symbolLabel);
        }
        
        self.marketIconView.snp.makeConstraints { make in
            make.left.equalTo(self.contentView).offset(16)
            make.centerY.equalTo(self.symbolLabel)
            make.height.equalTo(11);
        }
        
//        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self.contentView).offset(18);
//            make.width.mas_equalTo(135);
//            make.top.equalTo(self.symbolLabel.mas_bottom).offset(4);
//            make.height.mas_equalTo(22);
//        }];
//
//        [self.symbolLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self.nameLabel).offset(0);
//            make.top.equalTo(self.contentView).offset(10);
//            make.height.mas_equalTo(15);
//            //make.width.equalTo(self.nameLabel);
//        }];
        
        
        nameLabel.font = .systemFont(ofSize: 16)
        nameLabel.textColor = QMUITheme().textColorLevel1()
        
        symbolLabel.textColor = QMUITheme().textColorLevel3()
        symbolLabel.font = .systemFont(ofSize: 14)
    }
    
    override func refreshUI() {
//        self.marketIconView.isHidden = true
        self.scrollView.isUserInteractionEnabled = true
//        self.stockInfoView.delayLabel.isHidden = self.model.level == 0 ? false : true
//        if let warrantsModel = self.model as? YXWarrantsFundFlowRankItem {
//
//            self.stockInfoView.name = warrantsModel.asset?.name
//            self.stockInfoView.symbol = warrantsModel.asset?.secuCode
//            self.stockInfoView.market = warrantsModel.asset?.market
//
//            self.labels.forEach { (label) in
//                label.warrantsModel = warrantsModel
//            }
//        }
        self.scrollView.isUserInteractionEnabled = true
        self.lineView.isHidden = true
        self.delayLabel.isHidden = self.model.level == 0 ? false : true
        if let warrantsModel = self.model as? YXWarrantsFundFlowRankItem {
            self.marketIconView.image = UIImage.init(named: warrantsModel.asset?.market ?? "")
            self.symbolLabel.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(36);
            }
            self.nameLabel.text = warrantsModel.asset?.name ?? "--"
            self.symbolLabel.text = warrantsModel.asset?.secuCode ?? "--"
            
            self.labels.forEach { (label) in
                label.warrantsModel = warrantsModel
                
            }
        }
        
    }
    
    @objc func tapYXSelection() {

        if let model = self.model as? YXWarrantsFundFlowRankItem {
            goToStockDetail(market: model.derivative?.market, symbol: model.derivative?.symbol)
        }
    }
    
    @objc func tapStock() {
        if let model = self.model as? YXWarrantsFundFlowRankItem {
            goToStockDetail(market: model.asset?.market, symbol: model.asset?.secuCode)
        }
    }
    
    func goToStockDetail(market: String?, symbol: String?) {
        if let mkt = market, let code = symbol {
            let input = YXStockInputModel()
            input.market = mkt
            input.symbol = code
            input.name = ""

            if let root = UIApplication.shared.delegate as? YXAppDelegate {
                let navigator = root.navigator
                navigator.pushPath(.stockDetail, context: ["dataSource": [input], "selectIndex": 0], animated: true)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    
}
