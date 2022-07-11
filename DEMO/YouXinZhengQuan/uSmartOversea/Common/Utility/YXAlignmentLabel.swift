//
//  YXAlignmentLabel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/3/15.
//  Copyright © 2019年 RenRenDai. All rights reserved.
//

import UIKit

@objc enum YXVerticalAlignment : Int, RawRepresentable {
    case top
    case center
    case bottom
}


@objcMembers class YXAlignmentLabel: UILabel {
    var _verticalAlignment : YXVerticalAlignment = .center;
    var verticalAlignment : YXVerticalAlignment {
        set {
            _verticalAlignment = newValue
            self.setNeedsDisplay()
        }
        
        get {
            _verticalAlignment;
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.verticalAlignment = .center
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawText(in rect: CGRect) {
        let actualRect = self.textRect(forBounds: rect, limitedToNumberOfLines: self.numberOfLines)
        super.drawText(in: actualRect)
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var textRect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        switch self.verticalAlignment {
        case .top:
            textRect.origin.y = bounds.origin.y
        case .center:
            textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height)/2.0
        case .bottom:
            textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height
        }
        
        return textRect
    }
    
    
    
}

extension UILabel {
    func actualFontSize() -> CGFloat {
        var text: NSMutableAttributedString = NSMutableAttributedString()
        if let attrStr = self.attributedText {
            text = NSMutableAttributedString(attributedString: attrStr)
        } else if let str = self.text {
            text = NSMutableAttributedString(string: str)
        }
        text.setAttributes([NSAttributedString.Key.font: self.font as Any], range: NSMakeRange(0, text.length))
        let context: NSStringDrawingContext = NSStringDrawingContext()
        context.minimumScaleFactor = self.minimumScaleFactor
        text.boundingRect(with: self.frame.size, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: context)
        let adjustedFontSize: CGFloat = self.font.pointSize * context.actualScaleFactor
        return adjustedFontSize
    }
}


extension String {

    func height(_ font: UIFont, limitWidth: CGFloat) -> CGFloat {
        let height = (self as NSString).boundingRect(with: CGSize(width: limitWidth, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font : font], context: nil).height
        return ceil(height)
    }

    func width(_ font: UIFont, limitHeight: CGFloat) -> CGFloat {
        let width = (self as NSString).boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: limitHeight), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font : font], context: nil).width
        return ceil(width)
    }
}

extension NSAttributedString {
    func height(limitWidth: CGFloat) -> CGFloat {
        let height = boundingRect(with: CGSize(width: limitWidth, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).height
        return ceil(height)
    }

    func width(limitHeight: CGFloat) -> CGFloat {
        let width = boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: limitHeight), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).width
        return ceil(width)
    }
}
