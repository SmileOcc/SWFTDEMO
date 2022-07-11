//
//  YXNewStockTagsView.swift
//  uSmartOversea
//
//  Created by 裴艳东 on 2019/5/6.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import SnapKit

class YXNewStockTagsView: UIView {

    public private(set) var totalHeight: CGFloat = 0
    public private(set) var linesCount: Int = 0   //总行数
    var tagBackgroundColor: UIColor?
    var textFont: UIFont = UIFont.systemFont(ofSize: 12)
    var textColor: UIColor = QMUITheme().textColorLevel2()
    var contentInset: UIEdgeInsets? //标签内容的内间距
    var lineSpacing: CGFloat = 8.0
    var columSpacing: CGFloat = 30.0
    var cornerRadius: CGFloat?
    var maxShowLines: Int = Int.max   //最多展示的行数


    fileprivate var textArray: [[String]] = []

    //标签(left, top)距离视图的距离是(0, lineSpacing)
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTags(_ tags: [String], maxWidth: CGFloat) {
        
        self.totalHeight = 0
        self.linesCount = 0
        for view in self.subviews {
            view.removeFromSuperview()
        }
        textArray.removeAll()
        guard tags.count > 0 else { return }
        var lines = 1
        let totalWidth = maxWidth
        let leftInset: CGFloat = self.contentInset?.left ?? 0
        let rightInset: CGFloat = self.contentInset?.right ?? 0
        let topInset: CGFloat = self.contentInset?.top ?? 0
        let bottomInset: CGFloat = self.contentInset?.bottom ?? 0

        var tempTotalHeight: CGFloat = 0
        var remainingWidth: CGFloat = totalWidth //每行布置一个文案后剩余的宽度
        var tempTextArray: [String] = []
        for text in tags {

            if text.count <= 0 {
                continue
            }
            //默认最多展示self.maxShowLines 行
            if lines > self.maxShowLines {
                tempTextArray.removeAll()
                break
            }
            let size = text.boundingRect(with: CGSize.init(width: totalWidth, height: 500), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font : self.textFont], context: nil).size
            let width = size.width + leftInset + rightInset
            let height = size.height + topInset + bottomInset
            if width > remainingWidth {
                
                if totalWidth - remainingWidth < 1 {
                    tempTextArray.append(text)
                    textArray.append(tempTextArray)
                    remainingWidth = totalWidth
                    tempTextArray = []
                } else {
                    remainingWidth = totalWidth - (width + columSpacing)
                    textArray.append(tempTextArray)
                    tempTextArray = []
                    tempTextArray.append(text)
                }
                lines += 1
                if lines <= self.maxShowLines {
                    tempTotalHeight += (height + lineSpacing)
                }
            } else {
                if lines == 1 && totalWidth - remainingWidth < 1 && lines <= self.maxShowLines {
                    tempTotalHeight += (height + lineSpacing)
                }
                remainingWidth -= (width  + columSpacing)
                tempTextArray.append(text)
            }
        }
        
        if tempTextArray.count > 0 {
            textArray.append(tempTextArray)
        }
        self.totalHeight = tempTotalHeight
        self.linesCount = lines
        addSubviews()
    }

    func addSubviews() {

        var rightConstraint: SnapKit.ConstraintItem? = nil
        var bottomConstraint: SnapKit.ConstraintItem? = nil
        for (texts) in textArray {
            
            for (index, text) in texts.enumerated() {
                let label = self.tagLabel()
                label.text = text
                addSubview(label)
                label.snp.makeConstraints { (make) in
                    make.left.equalTo(rightConstraint == nil ? self.snp.left : rightConstraint!).offset(rightConstraint == nil ? 0 : columSpacing)
                    make.top.equalTo(bottomConstraint == nil ? self.snp.top : bottomConstraint!).offset(lineSpacing)
                }
                rightConstraint = label.snp.right
                if index == texts.count - 1 {
                    bottomConstraint = label.snp.bottom
                }
            }
            rightConstraint = nil
        }
    }

    func tagLabel() -> QMUILabel {

        let label = QMUILabel()
        label.font = self.textFont
        label.textColor = self.textColor
        label.textAlignment = .center
        if let inset = self.contentInset {
            label.contentEdgeInsets = inset
        }
        if let radius = self.cornerRadius {
            label.layer.cornerRadius = radius
            label.layer.masksToBounds = true
        }
        if let backgroundColor = self.tagBackgroundColor {
            label.backgroundColor = backgroundColor
        }

        return label
    }

}


