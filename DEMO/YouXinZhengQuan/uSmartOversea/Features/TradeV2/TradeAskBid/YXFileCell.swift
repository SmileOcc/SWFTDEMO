//
//  YXFileCell.swift
//  YouXinZhengQuan
//
//  Created by JC_Mac on 2019/1/7.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

@objcMembers class YXFileCell: UITableViewCell {
    
    var fileCount = 1
    var positionModel: PosData?
    var pclose = ""
    var nowBuyPrice:Double = 0
    var maxBuyCount:Double = 0
    var maxSellCount:Double = 0
    var maxWidth = YXConstant.screenWidth/4
    var priceDivisor = 1
    var isShowMark = false
    
    var clickAction: ((Bool, String) -> ())?
    
    lazy var leftMarkView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage.arrow(with: QMUITheme().themeTextColor(), size: CGSize(width: 33, height: 24))
        imageView.image = UIImage.init(image, rotation: .left)
        return imageView
    }()
    
    lazy var rightMarkView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage.arrow(with: QMUITheme().themeTextColor(), size: CGSize(width: 33, height: 24))
        imageView.image = UIImage.init(UIImage.init(image, rotation: .down), rotation: .left) 
        return imageView
    }()
    
    lazy var leftBackBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = QMUITheme().sell().withAlphaComponent(0.05)
        return btn
    }()
    
    lazy var rightBackBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = QMUITheme().buy().withAlphaComponent(0.05)
        return btn
    }()
    
    lazy var buyPriceLab: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().buy()
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    @objc var buyPrice: String = ""
    @objc var sellPrice: String = ""
    
    lazy var sellPriceLab: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().sell()
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    lazy var buyCountLab: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    lazy var sellCountLab: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    lazy var fileLab: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.backgroundColor = UIColor(red: 25.0/255.0, green: 25.0/255.0, blue: 25.0/255.0, alpha: 0.05)
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        label.layer.cornerRadius = 1;
        label.clipsToBounds = true
        return label
    }()
    
    lazy var buyLineView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().themeTextColor()
        return view
    }()
    
    lazy var sellLineView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().sell()
        return view
    }()
    
    lazy var bidAnimationView: UIView = {
        let view = UIView()
//        view.backgroundColor = QMUITheme().sell()
        view.alpha = 0
        return view
    }()
    
    lazy var askAnimationView: UIView = {
        let view = UIView()
        view.alpha = 0
//        view.backgroundColor = QMUITheme().sell()
        return view
    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initialUI()
        self.addAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func initialUI() {
        
        self.selectionStyle = .none
        self.backgroundColor = QMUITheme().foregroundColor()
        
        contentView.addSubview(bidAnimationView)
        contentView.addSubview(askAnimationView)
        contentView.addSubview(leftBackBtn)
        contentView.addSubview(rightBackBtn)
        contentView.addSubview(buyPriceLab)
        contentView.addSubview(sellPriceLab)
        contentView.addSubview(buyCountLab)
        contentView.addSubview(sellCountLab)
        contentView.addSubview(fileLab)
        contentView.addSubview(buyLineView)
        contentView.addSubview(sellLineView)
        contentView.addSubview(leftMarkView)
        contentView.addSubview(rightMarkView)
        
        bidAnimationView.snp.makeConstraints { (make) in
            make.trailing.equalTo(self).offset(-(YXConstant.screenWidth/2 + 13))
            make.width.equalTo(46)
            make.height.equalTo(22)
            make.top.equalTo(4)
        }
        
        askAnimationView.snp.makeConstraints { (make) in
            make.leading.equalTo(self).offset(YXConstant.screenWidth/2 + 13)
            make.width.equalTo(46)
            make.height.equalTo(22)
            make.top.equalTo(4)
        }
        
        leftBackBtn.snp.makeConstraints { (make) in
            make.width.equalTo(YXConstant.screenWidth/2)
            make.right.top.bottom.equalTo(self)
        }
        
        rightBackBtn.snp.makeConstraints { (make) in
            make.width.equalTo(YXConstant.screenWidth/2)
            make.left.top.bottom.equalTo(self)
        }
    
        buyPriceLab.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(12)
            make.top.equalTo(4)
        }
        
        sellPriceLab.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-12)
            make.top.equalTo(4)
        }
        
        fileLab.snp.makeConstraints { (make) in
            make.width.height.equalTo(18)
            make.centerX.equalTo(self)
            make.top.equalTo(6)
        }
        
        buyCountLab.snp.makeConstraints { (make) in
            make.centerY.equalTo(buyPriceLab)
            make.right.equalTo(fileLab.snp.left).offset(-9)
        }
        
        sellCountLab.snp.makeConstraints { (make) in
            make.centerY.equalTo(buyPriceLab)
            make.left.equalTo(fileLab.snp.right).offset(9)
        }
        
        buyLineView.snp.makeConstraints { (make) in
            make.right.equalTo(fileLab).offset(-9)
            make.height.equalTo(6)
            make.width.equalTo(0)
            make.bottom.equalTo(self)
        }
        
        sellLineView.snp.makeConstraints { (make) in
            make.left.equalTo(fileLab).offset(9)
            make.height.equalTo(6)
            make.width.equalTo(0)
            make.bottom.equalTo(self)
        }
        
        leftMarkView.snp.makeConstraints { (make) in
            make.centerY.equalTo(buyPriceLab)
            make.left.equalTo(self)
            make.width.equalTo(8)
            make.height.equalTo(11)
        }
        
        rightMarkView.snp.makeConstraints { (make) in
            make.centerY.equalTo(buyPriceLab)
            make.right.equalTo(self)
            make.width.equalTo(8)
            make.height.equalTo(11)
        }
    }

    func refreshUI() {
        
        self.fileLab.text = "\(fileCount)"
        self.leftMarkView.isHidden = true
        self.rightMarkView.isHidden = true
        self.buyPriceLab.font = .systemFont(ofSize: 16)
        self.sellPriceLab.font = .systemFont(ofSize: 16)
        if let model = positionModel {
            
            let bid = String(format: "%lld", model.bidPrice?.value ?? 0)
            let ask = String(format: "%lld", model.askPrice?.value ?? 0)
            let bidSize = String(format: "%lld", model.bidSize?.value ?? 0)
            let askSize = String(format: "%lld", model.askSize?.value ?? 0)
            let bidChange = model.bidChange?.value ?? 0
            let askChange = model.askChange?.value ?? 0
            
            //设置颜色
            self.buyPriceLab.textColor = YXToolUtility.stockColor(withData: Double(bid) ?? 0, compareData: Double(self.pclose) ?? 0)
            self.sellPriceLab.textColor = YXToolUtility.stockColor(withData: Double(ask) ?? 0, compareData: Double(self.pclose) ?? 0)
            
            //设置数据
            if bid.count > 0 {
                
                if let value = Double(bid), value > 0 {
                    buyPrice = String(format: "%.3f", value/Double(priceDivisor))
                    self.buyPriceLab.text = buyPrice
                    if value == self.nowBuyPrice && self.isShowMark{
                        self.leftMarkView.isHidden = false
                        self.isShowMark = false
                        self.buyPriceLab.font = .systemFont(ofSize: 16, weight: .medium)
                    }
                }else {
                    self.buyPriceLab.text = "--"
                    buyPrice = ""
                }
            }else {
                self.buyPriceLab.text = "--"
                buyPrice = ""
            }
            
            if ask.count > 0 {
                if let value = Double(ask), value > 0 {
                    sellPrice = String(format: "%.3f", value/Double(priceDivisor))
                    self.sellPriceLab.text = sellPrice
                    if value == self.nowBuyPrice && self.isShowMark{
                        self.rightMarkView.isHidden = false
                        self.sellPriceLab.font = .systemFont(ofSize: 16, weight: .medium)
                    }
                }else {
                    self.sellPriceLab.text = "--"
                    sellPrice = ""
                }
            }else {
                self.sellPriceLab.text = "--"
                sellPrice = ""
            }
            
            if bidSize.count > 0 {
                if let value = Double(bidSize) {
                    if value < 1000 {
                        self.buyCountLab.text = String(format: "%.0f", value)
                    }else if value < 1000000 {
                        self.buyCountLab.text = String(format: "%.1fK", value/1000)
                    }else {
                        self.buyCountLab.text = String(format: "%.1fM", value/1000000)
                    }
                    buyLineView.snp.updateConstraints { (make) in
                        if self.maxBuyCount > 0 {
                            let t = value/self.maxBuyCount
                            make.width.equalTo(maxWidth*CGFloat(t))
                        }else {
                            make.width.equalTo(maxWidth)
                        }
                    }
                }else {
                    self.buyCountLab.text = "--"
                    buyLineView.snp.updateConstraints { (make) in
                        make.width.equalTo(0)
                    }
                }
            }else {
                self.buyCountLab.text = "--"
                buyLineView.snp.updateConstraints { (make) in
                    make.width.equalTo(0)
                }
            }
            
            if askSize.count > 0 {
                if let value = Double(askSize) {
                    if value < 1000 {
                        self.sellCountLab.text = String(format: "%.0f", value)
                    }else if value < 1000000 {
                        self.sellCountLab.text = String(format: "%.1fK", value/1000)
                    }else {
                        self.sellCountLab.text = String(format: "%.1fM", value/1000000)
                    }
                    sellLineView.snp.updateConstraints { (make) in
                        if self.maxBuyCount > 0 {
                            let t = value/self.maxSellCount
                            make.width.equalTo(maxWidth*CGFloat(t))
                        }else {
                            make.width.equalTo(maxWidth)
                        }
                    }
                }else {
                    sellLineView.snp.updateConstraints { (make) in
                        make.width.equalTo(0)
                    }
                    self.sellCountLab.text = "--"
                }
                
            }else {
                sellLineView.snp.updateConstraints { (make) in
                    make.width.equalTo(0)
                }
                self.sellCountLab.text = "--"
            }
            
            if bidChange == 1 {
                self.bidAnimationView.backgroundColor = QMUITheme().stockRedColor().withAlphaComponent(0.2)
                refresBidAnimation()
            } else if bidChange == -1 {
                self.bidAnimationView.backgroundColor = QMUITheme().stockGreenColor().withAlphaComponent(0.2)
                refresBidAnimation()
            }
            model.bidChange = NumberInt32(0)
            
            if askChange == 1 {
                self.askAnimationView.backgroundColor = QMUITheme().stockRedColor().withAlphaComponent(0.2)
                refresAskAnimation()
            } else if askChange == -1 {
                self.askAnimationView.backgroundColor = QMUITheme().stockGreenColor().withAlphaComponent(0.2)
                refresAskAnimation()
            }
            model.askChange = NumberInt32(0)
            
        }else {
           
            self.buyPriceLab.text = "--"
            buyPrice = ""
            self.buyCountLab.text = "--"
            self.sellPriceLab.text = "--"
            sellPrice = ""
            self.sellCountLab.text = "--"
            buyLineView.snp.updateConstraints { (make) in
                make.width.equalTo(0)
            }
            sellLineView.snp.updateConstraints { (make) in
                make.width.equalTo(0)
            }
        }
    }
    
    func refresBidAnimation() {
        UIView.animate(withDuration: 0.05, delay: 0, options: .allowUserInteraction, animations: {
            self.bidAnimationView.alpha = 1.0
        }) { (finish) in
            UIView.animate(withDuration: 0.05, delay: 0, options: .allowUserInteraction, animations: {
                self.bidAnimationView.alpha = 0.0
            }, completion: { (finish) in
                
            })
        }
    }
    
    func refresAskAnimation() {
        UIView.animate(withDuration: 0.05, delay: 0, options: .allowUserInteraction, animations: {
            self.askAnimationView.alpha = 1.0
        }) { (finish) in
            UIView.animate(withDuration: 0.05, delay: 0, options: .allowUserInteraction, animations: {
                self.askAnimationView.alpha = 0.0
            }, completion: { (finish) in
                
            })
        }
    }
    
    
    func addAction() {
        //.takeUntil(self.rx.deallocated).observeOn(MainScheduler.instance)
        self.rightBackBtn.rx.tap.asObservable().subscribe(onNext: { [weak self] (isAdd) in
            guard let `self` = self  else { return }
            
            if let action = self.clickAction {
                let bidPrice = String(format: "%lld",self.positionModel?.bidPrice?.value ?? 0)
                action(true, bidPrice)
            }
            
            
            UIView.animate(withDuration: 0.2, animations: {
                //买卖档点击效果
                self.rightBackBtn.backgroundColor = QMUITheme().textColorLevel1().withAlphaComponent(0.05)
            }) { (finished) in
                self.rightBackBtn.backgroundColor = QMUITheme().buy().withAlphaComponent(0.05)
                
                if let action = self.clickAction {
                    action(false, "")
                }
                
            }
            
        }).disposed(by: self.rx.disposeBag)
        
        
        //.takeUntil(self.rx.deallocated).observeOn(MainScheduler.instance)
        self.leftBackBtn.rx.tap.asObservable().subscribe(onNext: { [weak self] (isAdd) in
            guard let `self` = self else { return }
            
            if let action = self.clickAction {
                let askPrice = String(format: "%lld",self.positionModel?.askPrice?.value ?? 0)
                action(true, askPrice)
            }
            
            
            UIView.animate(withDuration: 0.2, animations: {
                //买卖档点击效果
                self.leftBackBtn.backgroundColor = QMUITheme().textColorLevel1().withAlphaComponent(0.05)
            }) { (finished) in
                self.leftBackBtn.backgroundColor = QMUITheme().sell().withAlphaComponent(0.05)
                if let action = self.clickAction {
                    action(false, "")
                }
            }
            
            
        }).disposed(by: self.rx.disposeBag)
    }
}
