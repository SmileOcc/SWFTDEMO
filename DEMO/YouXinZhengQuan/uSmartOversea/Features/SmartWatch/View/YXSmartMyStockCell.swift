//
//  YXSmartMyStockCell.swift
//  uSmartOversea
//
//  Created by youxin on 2019/3/29.
//  Copyright © 2019年 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXSmartMyStockCell: UITableViewCell {
    
    enum CellPosition {
        case top, middle, bottom, both
    }
    
    var detailText: String = ""
    func reloadData(position: CellPosition, model: YXSmartMyStockSmartStare, roc: Int?) {
        
        endPointerView.isHidden = true
        switch position {
        case .top, .both:
            lineView.snp.remakeConstraints { (make) in
                make.top.equalTo(pointerView.snp.bottom).offset(-3)
                make.bottom.equalToSuperview()
                make.centerX.equalTo(pointerView.snp.centerX)
                make.width.equalTo(1)
            }
            
            if position == .both {
                endPointerView.snp.updateConstraints { (make) in
                    make.top.equalTo(lineView.snp.bottom).offset(-7)
                }
                endPointerView.isHidden = false
            }
            
        case .middle:
            lineView.snp.remakeConstraints { (make) in
                make.top.bottom.equalToSuperview()
                make.centerX.equalTo(pointerView.snp.centerX)
                make.width.equalTo(1)
            }
        case .bottom:
            lineView.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.centerX.equalTo(pointerView.snp.centerX)
                make.width.equalTo(1)
                make.bottom.equalTo(pointerView.snp.top).offset(3)
            }
        }
        
        if let text = model.describe {
            var color = QMUITheme().textColorLevel2()
            if let colorNum = model.color {
                if colorNum > 0 {
                    color = YXStockColor.currentColor(.up)
                } else if colorNum < 0 {
                    color = YXStockColor.currentColor(.down)
                }
            }
            if let signalName = model.signalName {
                contentLabel.attributedText = text.addAttributesToSubString(signalName, attributes: [NSAttributedString.Key.foregroundColor : color])
            } else {
                contentLabel.attributedText = text.addAttributesToSubString("", attributes: [NSAttributedString.Key.foregroundColor : color])
            }
        } else {
            contentLabel.text = ""
        }
       
        detailBgView.isHidden = true
        var detailText = ""
        if let stockName = model.stockName {
            detailText = stockName + stockMarket(model.stockCode)
        }
        
        var rocColor = YXStockColor.currentColor(.flat)
        var rocString = ""
        if let stockRoc = roc {
            detailBgView.isHidden = false
            rocColor = QMUITheme().textColorLevel2()
            if stockRoc > 0 {
                rocColor = YXStockColor.currentColor(.up)
            } else if stockRoc < 0 {
                rocColor = YXStockColor.currentColor(.down)
            }
            detailBgView.backgroundColor = rocColor.withAlphaComponent(0.05)
            let prefix = stockRoc > 0 ? "+" : ""
            rocString = prefix + String(format: "%.2lf%%", Double(stockRoc)/100.0)
            detailText = detailText + " " + rocString
        } else {
            detailText = detailText + " " + "--"
        }
        self.detailText = detailText
        detailLabel.attributedText = detailText.addAttributesToSubString(rocString, attributes: [NSAttributedString.Key.foregroundColor : rocColor])
        timeLabel.text = YXDateHelper.dateSting(from: TimeInterval(model.unixTime), formatterStyle: .short)
    }
    
    func stockMarket(_ stockCode: String?) -> String {
        
        if let symbol = stockCode {
            let lowerSymbol = symbol.lowercased()
            if lowerSymbol.hasPrefix(YXMarketType.HK.rawValue) {
                return "." + YXMarketType.HK.rawValue.uppercased()
            } else if lowerSymbol.hasPrefix(YXMarketType.US.rawValue) {
                return "." + YXMarketType.US.rawValue.uppercased()
            } else if lowerSymbol.hasPrefix(YXMarketType.ChinaSH.rawValue) {
                return "." + YXMarketType.ChinaSH.rawValue.uppercased()
            } else if lowerSymbol.hasPrefix(YXMarketType.ChinaSZ.rawValue) {
                return "." + YXMarketType.ChinaSZ.rawValue.uppercased()
            } else if lowerSymbol.hasPrefix(YXMarketType.ChinaHS.rawValue) {
                return "." + YXMarketType.ChinaHS.rawValue.uppercased()
            }
        }
        return ""
    }
    
    //MARK: initialization Method
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        initializeViews()
    }
    
    func initializeViews() {
        contentView.addSubview(timeLabel)
        contentView.addSubview(pointerView)
        contentView.addSubview(lineView)
        contentView.addSubview(endPointerView)
        contentView.addSubview(contentLabel)
        contentView.addSubview(detailBgView)
        contentView.addSubview(detailLabel)
        
        let margin: CGFloat = 18
        timeLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(margin)
            make.top.equalToSuperview().offset(2.5)
        }
        
        pointerView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(56)
            make.top.equalToSuperview().offset(5)
            make.width.equalTo(7)
            make.height.equalTo(7)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.centerX.equalTo(pointerView.snp.centerX)
            make.width.equalTo(1)
        }
        
        endPointerView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(56)
            make.top.equalTo(lineView.snp.bottom).offset(-7)
            make.width.equalTo(7)
            make.height.equalTo(7)
        }
        
        
        contentLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(3.5)
            make.left.equalToSuperview().offset(75)
            make.right.lessThanOrEqualToSuperview().offset(-margin)
        }
        
        detailLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentLabel.snp.left).offset(4)
            make.top.equalTo(contentLabel.snp.bottom).offset(14)
            make.right.lessThanOrEqualToSuperview().offset(-(margin + 4))
        }
        
        detailBgView.snp.makeConstraints { (make) in
            make.left.equalTo(detailLabel.snp.left).offset(-4)
            make.top.equalTo(detailLabel.snp.top).offset(-4)
            make.right.equalTo(detailLabel.snp.right).offset(4)
            make.bottom.equalTo(detailLabel.snp.bottom).offset(4)
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        size.height = 0
        size.height += contentLabel.sizeThatFits(size).height
        if detailText.count > 0 {
            size.height += (detailText as NSString).boundingRect(with: CGSize(width: YXConstant.screenWidth - 97.0, height: 10000.0), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font : detailLabel.font], context: nil).height
        }
        size.height += detailLabel.sizeThatFits(size).height
        size.height += 37.5
        return size
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Lazy setter and getter
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel3()
        label.textAlignment = .left
        return label
    }()
    
    lazy var pointerView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().pointColor()
        view.layer.cornerRadius = 7/2.0
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var endPointerView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().pointColor()
        view.layer.cornerRadius = 7/2.0
        view.layer.masksToBounds = true
        view.isHidden = true
        return view
    }()
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().pointColor()
        return view
    }()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel1()
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel1()
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    
    lazy var detailBgView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().stockRedColor()
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
}


fileprivate extension NSAttributedString {
    //给字符串添加属性，没找到则返回自身
    func addAttributesToSubString(_ range: NSRange, attributes: [NSAttributedString.Key : Any]) -> NSAttributedString? {
        if range.location != NSNotFound {
            let attributeString = NSMutableAttributedString(attributedString: self)
            attributeString.addAttributes(attributes, range: range)
            return attributeString
        }
        return self
    }
    //给字符串添加属性，没找到则返回自身
    func addAttributesToSubString(_ subString: String, attributes: [NSAttributedString.Key : Any]) -> NSAttributedString? {
        if let range = self.string.range(of: subString) {
            let nsRange = self.string.nsRange(from: range)
            if nsRange.location != NSNotFound {
                let attributeString = NSMutableAttributedString(attributedString: self)
                attributeString.addAttributes(attributes, range: nsRange)
                return attributeString
            }
        }
        
        return self
    }
}

fileprivate extension String {
    //给字符串添加属性，没找到则返回自身的属性字符串
    func addAttributesToSubString(_ subString: String, attributes: [NSAttributedString.Key : Any]) -> NSAttributedString? {
        if let range = self.range(of: subString) {
            let nsRange = self.nsRange(from: range)
            if nsRange.location != NSNotFound {
                let attributeString = NSMutableAttributedString(string: self)
                attributeString.addAttributes(attributes, range: nsRange)
                return attributeString
            }
        }
        
        return NSAttributedString(string: self)
    }
    
    //Range转换为NSRange
    func nsRange(from range: Range<String.Index>) -> NSRange {
        guard
            let from = range.lowerBound.samePosition(in: utf16),
            let to = range.upperBound.samePosition(in: utf16)
            else { return NSRange(location:NSNotFound, length: 0) }
        return NSRange(location: utf16.distance(from: utf16.startIndex, to: from),
                       length: utf16.distance(from: from, to: to))
    }
    
    //Range转换为NSRange
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location,
                                     limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length,
                                   limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        return from ..< to
    }
}
