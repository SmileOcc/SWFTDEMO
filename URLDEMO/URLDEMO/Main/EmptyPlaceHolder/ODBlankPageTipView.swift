//
//  ODBlankPageTipView.swift
//  URLDEMO
//
//  Created by odd on 7/16/22.
//

import UIKit

let kBlankTipViewTag = 2022
class ODBlankPageTipView: UIView {

    private var actionBtn: UIButton?
    private var actionBlock: (() ->Void)?
    
    class func tipViewByFrame(frame: CGRect, topDistance: CGFloat, moveOffsetY: CGFloat, topImage: UIImage?, title: Any?, subTitle: Any?, buttonTitle: Any?, actionBlock: (() ->Void)?) -> ODBlankPageTipView{
        
        let tipView = ODBlankPageTipView(frame: frame, topDistance: topDistance, moveOffsetY: moveOffsetY, topImage: topImage, title: title, subTitle: subTitle, buttonTitle: buttonTitle, actionBlock: actionBlock)
        tipView.tag = kBlankTipViewTag
        tipView.backgroundColor = UIColor.clear
        return tipView
    }
    
    convenience init(frame: CGRect, topDistance: CGFloat, moveOffsetY: CGFloat, topImage: UIImage?, title: Any?, subTitle: Any?, buttonTitle: Any?, actionBlock: ( () ->Void)?) {
        self.init(frame: frame)
        self.actionBlock = actionBlock
        
        let tipViewWidth = frame.size.width < 50 ? UIScreen.main.bounds.size.width : frame.size.width
        let viewLeftMargin = 40.0
        let maxWidth = tipViewWidth - viewLeftMargin * 2
        
        let contentView = UIView()
        contentView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        contentView.backgroundColor = UIColor.clear
        addSubview(contentView)
        
        var contentViewMaxHeight = 0.0
        
        //底部图片
        let imageSpace = 8.0
        //var tipImageView: UIImageView?
        
        if let image = topImage {
            let tipImageView = UIImageView()
            tipImageView.image = image
            tipImageView.backgroundColor = UIColor.clear
            tipImageView.contentMode = .scaleAspectFill
            tipImageView.clipsToBounds = true
            tipImageView.frame = CGRect(x: (frame.size.width - image.size.width) / 2.0, y: 0, width: image.size.width, height: image.size.height)
            contentView.addSubview(tipImageView)
            
            contentViewMaxHeight = tipImageView.frame.maxY + imageSpace
        }
        
        // 标题
        let titleSpace = 16.0
        
        if ODBlankPageTipView.isContainContent(content: title) {
            let tipLable = UILabel()
            tipLable.frame = CGRect(x: 0, y: 0, width: maxWidth, height: 20.0)
            tipLable.backgroundColor = UIColor.clear
            tipLable.font = .systemFont(ofSize: 14)
            tipLable.textColor = UIColor.lightGray
            tipLable.textAlignment = .center
            tipLable.numberOfLines = 0
            tipLable.adjustsFontSizeToFitWidth = true
            tipLable.preferredMaxLayoutWidth = maxWidth
            contentView.addSubview(tipLable)
            
            if let title = title as? String {
                tipLable.text = title
            } else if let title = title as? NSAttributedString {
                tipLable.attributedText = title
            }
            
            tipLable.sizeToFit()
            
            let tipLabelWidth = [maxWidth, tipLable.bounds.size.width].min() ?? 0.0
            tipLable.frame = CGRect(x: (frame.size.width - tipLabelWidth) / 2.0, y: contentViewMaxHeight, width: tipLabelWidth, height: tipLable.bounds.size.height)
            contentViewMaxHeight = tipLable.frame.maxY + titleSpace
        }
        
        //副标题
        let subTitleSpace = 36.0
        if ODBlankPageTipView.isContainContent(content: subTitle) {
            let subTitleLabel = UILabel()
            subTitleLabel.frame = CGRect(x: 0, y: 0, width: maxWidth, height: 20.0)
            subTitleLabel.backgroundColor = UIColor.clear
            subTitleLabel.font = .systemFont(ofSize: 13)
            subTitleLabel.textColor = UIColor.lightGray
            subTitleLabel.textAlignment = .center
            subTitleLabel.numberOfLines = 0
            subTitleLabel.adjustsFontSizeToFitWidth = true
            subTitleLabel.preferredMaxLayoutWidth = maxWidth
            contentView.addSubview(subTitleLabel)
            
            if let subTitle = subTitle as? String {
                subTitleLabel.text = subTitle
            } else if let subTitle = subTitle as? NSAttributedString {
                subTitleLabel.attributedText = subTitle
            }
            subTitleLabel.sizeToFit()
            
            let subTitleWidth = [maxWidth, subTitleLabel.bounds.size.width].min() ?? 0.0
            subTitleLabel.frame = CGRect(x: (frame.size.width - subTitleWidth) / 2.0, y: contentViewMaxHeight, width: subTitleWidth, height: subTitleLabel.bounds.size.height)
            contentViewMaxHeight = subTitleLabel.frame.maxY + subTitleSpace
        } else {
            //contentViewMaxHeight = contentViewMaxHeight + subTitleSpace
        }
        
        // 底部按钮
        if ODBlankPageTipView.isContainContent(content: buttonTitle) {
            let actionBtn = UIButton()
            actionBtn.titleLabel?.font = .systemFont(ofSize: 12)
            actionBtn.setTitleColor(UIColor.black, for: .normal)
            actionBtn.layer.backgroundColor = UIColor.black.cgColor
            actionBtn.layer.borderWidth = 2.0
            
            actionBtn.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            contentView.addSubview(actionBtn)
            self.actionBtn = actionBtn
            
            if let buttonTitle = buttonTitle as? String {
                actionBtn.setTitle(buttonTitle, for: .normal)
            } else if let buttonTitle = buttonTitle as? NSAttributedString {
                actionBtn.setAttributedTitle(buttonTitle, for: .normal)
            }
            actionBtn.sizeToFit()
            
            var btnW = tipViewWidth - viewLeftMargin * 2.0
            //强制 为屏幕的一半
            btnW = UIScreen.main.bounds.size.width / 2.0
            
            let btnH = 40.0
            actionBtn.frame = CGRect(x: (contentView.bounds.size.width - btnW) / 2.0, y: contentViewMaxHeight, width: btnW, height: btnH)
            contentViewMaxHeight = actionBtn.frame.maxY
        }
        
        //设置contenView位置（只能上移距离）
        var topX = (frame.size.height - contentViewMaxHeight) / 2.0
        if topDistance > 0 {
            topX = topDistance
        } else {
            if topX > moveOffsetY && moveOffsetY > 0 {
                topX -= moveOffsetY
            }
        }
        
        contentView.frame = CGRect(x: 0, y: topX, width: frame.size.width, height: contentViewMaxHeight)
    }
    
    @objc func buttonAction() {
        if let actBlock = self.actionBlock {
            actBlock()
        }
    }

    class func isContainContent(content: Any?) -> Bool {
        if let tit = content as? String, !tit.isEmpty{
            return true
        }

        if let tit = content as? NSAttributedString, !tit.string.isEmpty {
            return true
        }
        return false
    }
}
