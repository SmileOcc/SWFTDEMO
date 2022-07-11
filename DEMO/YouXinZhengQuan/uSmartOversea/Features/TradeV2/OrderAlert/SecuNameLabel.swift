//
//  YXSecuNameLabel.swift
//  YouXinZhengQuan
//
//  Created by Mac on 2019/12/23.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class SecuNameLabel: UIView {

    @objc var text: String? {
        willSet {
            var text = newValue
            if newValue == nil {
                text = "--"
            }
            self.label.font = self.defaultFont
            self.label.text = text

            self.setNeedsLayout()
        }
    }
    var attributedText: NSAttributedString? {
        willSet {
            self.label.attributedText = newValue
        }
    }
    var textColor: UIColor? {
        willSet {
            self.label.textColor = newValue;
        }
    }
    var textAlignment: NSTextAlignment? {
        willSet {
            self.label.textAlignment = newValue ?? .left
        }
    }

    var defaultFont: UIFont = .systemFont(ofSize: 16)
    var smallFont: UIFont = .systemFont(ofSize: 12)
    var font: UIFont {
        self.label.font
    }
    var preferredMaxLayoutWidth: CGFloat = 0

    fileprivate var label: UILabel = UILabel()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.text = ""
        self.attributedText = NSAttributedString(string: "")
        self.textColor = .black
        self.textAlignment = .left

        self.backgroundColor = UIColor.clear
        
        addSubview(self.label)
        self.label.snp.makeConstraints { (make) in
            make.left.top.right.bottom.equalToSuperview()
        }
    }
    
    
    
    convenience init() {
        self.init(frame: CGRect.zero)
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.sizeThatFits()
    }

    func sizeThatFits() {
        var font = self.defaultFont

        if let textSize = self.text?.size(withAttributes: [NSAttributedString.Key.font:font]),
            (textSize.width > self.bounds.size.width),
            (textSize.width > self.preferredMaxLayoutWidth) {

                font = self.smallFont
            }
            self.label.font = font;
    }


}
