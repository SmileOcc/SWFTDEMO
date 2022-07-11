//
//  YXSmartTradeGuideTypeView.swift
//  YouXinZhengQuan
//
//  Created by Mac on 2020/4/22.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
class YXSmartTradeGuideTypeView: UIView {
    
    @objc var clickSmartOrderType: ((SmartOrderType) -> Void)?
    
    @objc var contentHeight: CGFloat = 0
    
    @objc var configs: [[String: Any]] = [] {
        didSet {
            var top: CGFloat = 0
            for config in configs {
                let titleLabel = UILabel()
                titleLabel.numberOfLines = 0
                addSubview(titleLabel)
                
                titleLabel.snp.makeConstraints { make in
                    make.left.equalTo(16)
                    make.right.equalToSuperview().offset(-18)
                    make.top.equalTo(top)
                    make.height.equalTo(34)
                }
                
                let title = config["title"] as? String ?? ""
                let titleAttr = NSAttributedString(string: title, attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium), .foregroundColor: QMUITheme().textColorLevel3()])
                titleLabel.attributedText = titleAttr
                
                top += 34
                
                guard let items = config["items"] as? [[String: Any]] else {
                    break
                }
                
                for index in 0..<items.count {
                    let item = items[index]
                    let itemTitle = item["title"] as? String ?? ""
                    let itemDesc = item["desc"] as? String ?? ""
                    let itemImage = item["image"] as? UIImage ?? UIImage()
                    
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.lineSpacing = 5
                    paragraphStyle.lineBreakMode = .byWordWrapping
                    
                    let itemAttr = NSMutableAttributedString(string: itemTitle + "\n", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: QMUITheme().textColorLevel1(), .paragraphStyle: paragraphStyle])
                    
                    let paragraphStyle1 = NSMutableParagraphStyle()
                    paragraphStyle1.lineSpacing = 1
                    paragraphStyle1.lineBreakMode = .byWordWrapping
                    itemAttr.append(NSAttributedString(string: itemDesc, attributes: [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: QMUITheme().textColorLevel3(), .paragraphStyle: paragraphStyle1]))
                    
                    let button = QMUIButton()
                    button.addTarget(self, action: #selector(self.itemClick(_:)), for: .touchUpInside)
                    button.setImage(itemImage, for: .normal)
                    button.contentHorizontalAlignment = .left
                    button.contentVerticalAlignment = .top
                    button.imagePosition = .left
                    button.spacingBetweenImageAndTitle = 12
                    button.imageEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 0)
                    button.titleLabel?.numberOfLines = 0
                    button.titleEdgeInsets = UIEdgeInsets(top: 14, left: 0, bottom: 0, right: 52)
                    button.setAttributedTitle(itemAttr, for: .normal)
                    button.highlightedBackgroundColor = QMUITheme().backgroundColor()
                    
                    let arrow = UIImageView(image: UIImage(named: "market_more_arrow"))
                    button.addSubview(arrow)
                    
                    arrow.snp.makeConstraints { make in
                        make.right.equalToSuperview().offset(-20)
                        make.centerY.equalToSuperview()
                    }
                    
                    let buttonHeight: CGFloat = itemAttr.height(limitWidth: YXConstant.screenWidth - 110) + 26
                    button.frame = CGRect(x: 0, y: top, width: YXConstant.screenWidth, height: buttonHeight)
                    button.tag = item["smartOrderType"] as? Int ?? 0
                    addSubview(button)
                    
                    top += buttonHeight
                }
                top += 14
                contentHeight = top
            }
        }
    }
    
    @objc func itemClick(_ sender: UIButton) {
        if let smartOrderType = SmartOrderType(rawValue: sender.tag) {
            clickSmartOrderType?(smartOrderType)
        }
    }
    
}

