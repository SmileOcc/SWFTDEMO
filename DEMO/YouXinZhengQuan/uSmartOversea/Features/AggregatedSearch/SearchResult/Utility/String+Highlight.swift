//
//  String+Highlight.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/2.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import Foundation

extension String {

    func attributedString(
        font: UIFont,
        textColor: UIColor,
        lineSpacing: CGFloat = 2
    ) -> NSAttributedString {
        // TODO: 1.5 倍行高设置
        let style = NSMutableParagraphStyle()
        style.lineSpacing = font.lineHeight * 0.25

        let attributes: [NSAttributedString.Key : Any] = [
            .font : font,
            .foregroundColor : textColor,
            .paragraphStyle : style
        ]
        let attributedStr = NSMutableAttributedString(string: self, attributes: attributes)

        return attributedStr
    }

     @discardableResult
     func searchRange(for keyword: String) -> [NSRange] {
        let str: NSString = self as NSString
        var ranges: [NSRange] = []
        var startRange = str.range(of: keyword, options: .caseInsensitive)

        while startRange.location != NSNotFound {
            ranges.append(startRange)

            let remainIndex = startRange.location + startRange.length
            let remainRange = NSMakeRange(remainIndex, str.length - remainIndex)
            startRange = str.range(of: keyword, options: .caseInsensitive, range: remainRange)
        }

        return ranges
     }

}

extension NSAttributedString {

    func addHighlight(
        for keyword: String,
        highlightedColor: UIColor = QMUITheme().themeTextColor()
    ) -> NSMutableAttributedString {
        let attributedStr = NSMutableAttributedString(attributedString: self)

        let ranges: [NSRange] = self.string.searchRange(for: keyword)
        for range in ranges {
            attributedStr.addAttribute(.foregroundColor, value: highlightedColor, range: range)
        }

        return attributedStr
    }

    func height(with maxWidth:CGFloat, maxLines: NSInteger? = nil) -> CGFloat {
        if self.string.isEmpty {
            return 0.0
        }

        let height = self.boundingRect(
            with: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesFontLeading, .usesLineFragmentOrigin],
            context: nil
        ).height

        guard let maxLines = maxLines else {
            return height
        }

        let attributes = self.attributes(at: 0, effectiveRange: nil)
        // 用一个字符计算单行文本高度
        let text = NSAttributedString(string: "U", attributes: attributes)

        let singleLineHeight = text.boundingRect(
            with: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesFontLeading, .usesLineFragmentOrigin],
            context: nil
        ).height

        var lineSpacing: CGFloat = 0
        if let paragraphStyle = attributes[.paragraphStyle] as? NSParagraphStyle {
            lineSpacing = paragraphStyle.lineSpacing
        }

        let maxHeight = singleLineHeight * CGFloat(maxLines) + lineSpacing * CGFloat(maxLines - 1)

        return min(height, maxHeight)
    }

}
