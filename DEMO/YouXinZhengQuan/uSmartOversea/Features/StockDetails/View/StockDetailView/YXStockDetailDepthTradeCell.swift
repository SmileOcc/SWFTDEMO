//
//  YXStockDetailDepthTradeCell.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2021/6/22.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import AudioToolbox.AudioServices
import YXKit

class YXStockDetailDepthTradeCell: UITableViewCell {
    
    @objc var tapBlock: ((_ priceString: String?, _ number: NSNumber?) -> Void)?
    
    fileprivate var model: YXDepthOrder?
    let maxWidth: CGFloat = 66
    var isBuy = false
    var isTrade = false
 
    @objc func refreshUI(_ model: YXDepthOrder?, latestPrice: Int64, priceBase: Int, maxSize: Int64) {
        
        self.model = model
        
        if let currentPrice = model?.price?.value{
            priceLabel.text = YXToolUtility.stockPriceData(Double(currentPrice), deciPoint: priceBase, priceBase: priceBase)
        }else {
            priceLabel.text = "--"
        }

        var sizeNum :Int64 = 0
        if let size = model?.size?.value{
            numberLabel.text = YXToolUtility.stockVolumeUnit(Int(size))
            sizeNum = size
        }else {
            numberLabel.text = "--"
            sizeNum = 0
        }
      
        
        if maxSize == 0 {
            numberColorView.isHidden = true
        } else {
            numberColorView.isHidden = false
            let width = maxWidth * (CGFloat(sizeNum) / CGFloat(maxSize))
            numberColorView.snp.updateConstraints { make in
                make.width.equalTo(width)
            }
            numberColorlayer.frame = CGRect.init(x: 0, y: 0, width: width, height: 18)
            let path = UIBezierPath.init(roundedRect: CGRect.init(x: 0, y: 0, width: width, height: 18), byRoundingCorners: [.topLeft,.bottomLeft], cornerRadii: CGSize.init(width: 2, height: 2))
            numberColorlayer.path = path.cgPath
        }
    }

    
    func showAnimation(_ type: YXStockDetailDepthTradeView.YXDepthTradeTapType) {
        var colorView: UIView?
        if type == .price {
            colorView = self.tapPriceColorView
        } else if type == .number {
            colorView = self.tapNumberColorView
        } else if type == .all {
            colorView = self.tapContentColorView
        }
        
        AudioServicesPlaySystemSound(1520)
//        let impactLight = UIImpactFeedbackGenerator(style: .heavy)
//        impactLight.impactOccurred()
        
        UIView.animate(withDuration: 0.05, delay: 0, options: .allowUserInteraction) {
            colorView?.alpha = 1.0
        } completion: { finish in
            UIView.animate(withDuration: 0.05, delay: 0, options: .allowUserInteraction) {
                colorView?.alpha = 0.0
            } completion: { finish in
                 
            }
        }

    }
    
    //MARK: initialization Method
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, isBuy: Bool, isTrade: Bool) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.translatesAutoresizingMaskIntoConstraints = true
        
        self.isBuy = isBuy
        self.isTrade = isTrade
        initUI()
        
        if isTrade {
            priceLabel.rx.tapGesture().subscribe(onNext: { [weak self] ges in
                guard let `self` = self else { return }

                if ges.state == .ended  {
                    self.tapBlock?(self.priceLabel.text, nil)
                    self.showAnimation(.price)
                }
                
            }).disposed(by: self.rx.disposeBag)
            
            tapNumberView.rx.tapGesture().subscribe(onNext: { [weak self] ges in
                guard let `self` = self else { return }

                if ges.state == .ended {
                    self.tapBlock?(nil, NSNumber.init(value: self.model?.size?.value ?? 1))
                    self.showAnimation(.number)
                }
                
            }).disposed(by: self.rx.disposeBag)
            
            nameLabel.rx.tapGesture().subscribe(onNext: { [weak self] ges in
                guard let `self` = self else { return }

                if ges.state == .ended {
                    self.tapBlock?(self.priceLabel.text, NSNumber.init(value: self.model?.size?.value ?? 1))
                    self.showAnimation(.all)
                }
                
            }).disposed(by: self.rx.disposeBag)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    func initUI() {
        self.backgroundColor = QMUITheme().foregroundColor()
        self.contentView.addSubview(numberColorView)
        
        self.contentView.addSubview(tapPriceColorView)
        self.contentView.addSubview(tapNumberColorView)
        self.contentView.addSubview(tapContentColorView)
        self.contentView.addSubview(tapNumberView)
        
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(priceLabel)
        self.contentView.addSubview(numberLabel)
        
        numberColorView.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.width.equalTo(0)
            make.top.equalTo(5)
            make.bottom.equalToSuperview().offset(-5)
           // make.centerY.equalToSuperview()
        }
        
        self.tapContentColorView.snp.makeConstraints { make in
            make.edges.equalTo(self.contentView)
        }
        
        let nameWidth: CGFloat = 56
        let rightMargin: CGFloat = self.isTrade ? 9 : 6
        
        let margin: CGFloat = self.isTrade ? 0 : 18
    
        let width: CGFloat = ((YXConstant.screenWidth / 2.0) - margin - rightMargin - nameWidth)
        let halfWidth: CGFloat = width / 2.0
        var priceWidth: CGFloat = 55
        var numberWidth: CGFloat = 35
        if halfWidth >= priceWidth {
            priceWidth = halfWidth
            numberWidth = halfWidth
        } else if width - priceWidth > numberWidth {
            numberWidth = width  - priceWidth
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.width.equalTo(nameWidth)
            make.top.bottom.equalToSuperview()
        }
        
        priceLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.right)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(priceWidth)
        }
        
        self.tapPriceColorView.snp.makeConstraints { make in
            make.edges.equalTo(self.priceLabel)
        }
        
        numberLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-rightMargin)
            make.width.equalTo(numberWidth)
            make.top.bottom.equalToSuperview()
        }
        
        self.tapNumberColorView.snp.makeConstraints { make in
            make.edges.equalTo(self.numberLabel)
        }
        
        self.tapNumberView.snp.makeConstraints { make in
            make.left.top.bottom.equalTo(self.numberLabel)
            make.right.equalToSuperview()
        }
        
    }
    
    lazy var nameLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 12)
        label.text = "ARCA"
        label.textAlignment = .left
        label.isUserInteractionEnabled = true
        label.contentEdgeInsets = UIEdgeInsets(top: 0, left: self.isTrade ? 12 : 8, bottom: 0, right: 0)
        return label
    }()
    
    
    lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = true
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 12)
        label.text = ""
        label.textAlignment = .left
        return label
    }()
    

    lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 12)
        label.text = ""
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()
    
    lazy var numberColorView: UIView = {
        let view = UIView()
//        if self.isBuy {
//           view.backgroundColor = UIColor.qmui_color(withHexString: "#00C767")?.withAlphaComponent(0.3)
//        } else {
//            view.backgroundColor = UIColor.qmui_color(withHexString: "#FF6933")?.withAlphaComponent(0.3)
//        }
        view.layer.addSublayer(self.numberColorlayer)
        view.clipsToBounds = true
        return view
    }()
    
    lazy var numberColorlayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer.init()
       
        if self.isBuy {
            shapeLayer.fillColor  = UIColor.qmui_color(withHexString: "#00C767")?.withAlphaComponent(0.3).cgColor
        } else {
            shapeLayer.fillColor  = UIColor.qmui_color(withHexString: "#FF6933")?.withAlphaComponent(0.3).cgColor
        }
        shapeLayer.lineWidth = 0.1
        return shapeLayer
    }()
    
    lazy var tapNumberView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    lazy var tapPriceColorView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().themeTintColor().withAlphaComponent(0.2)
        view.alpha = 0
        return view
    }()
    
    lazy var tapNumberColorView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().themeTintColor().withAlphaComponent(0.2)
        view.alpha = 0
        return view
    }()
    
    lazy var tapContentColorView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().themeTintColor().withAlphaComponent(0.2)
        view.alpha = 0
        return view
    }()
    
}
