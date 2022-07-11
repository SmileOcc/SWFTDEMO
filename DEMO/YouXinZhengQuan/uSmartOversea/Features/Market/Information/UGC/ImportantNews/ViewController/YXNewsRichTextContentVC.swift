//
//  YXNewsContentVC.swift
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/5/26.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import IGListKit
import IGListSwiftKit


extension String {
    
    func dt_newsDetailConfig(with maxWidth: CGFloat, andFontSize fontSize: NSInteger =  18) -> NSAttributedString? {
        
        var att: NSAttributedString?
        if self.count > 0, let data = self.data(using: .utf8) {
            let style: [AnyHashable : Any] = [DTDefaultTextColor : UIColor.themeColor(withNormal: QMUITheme().textColorLevel1(), andDarkColor: QMUITheme().textColorLevel2()),
                                              DTDefaultLinkColor: UIColor.themeColor(withNormal: QMUITheme().textColorLevel1(), andDarkColor: QMUITheme().textColorLevel2()),
                                              DTDefaultLinkDecoration: false,
                                              DTDefaultFontSize: fontSize,
                                              DTDefaultLineHeightMultiplier: 1.8,
                                              DTDefaultFontFamily: "PingFang SC",
                                              DTMaxImageSize: NSValue.init(cgSize: CGSize.init(width: maxWidth, height: CGFloat(MAXFLOAT))),
            ]
            
            att = NSAttributedString.init(htmlData: data, options: style, documentAttributes: nil)
        }
        
        return att
    }
    
    func dt_articleDetailConfig(with maxWidth: CGFloat, andFontSize fontSize: NSInteger =  18) -> NSAttributedString? {
        
        var att: NSAttributedString?
        if self.count > 0, let data = self.data(using: .utf8) {
            let path = Bundle.main.path(forResource: "skin-style", ofType: "css") ?? ""
            let url = URL.init(fileURLWithPath: path)
            let str = try! String.init(contentsOf: url, encoding: .utf8)
            let dtCss = DTCSSStylesheet.init(styleBlock: str)!
            
            let style: [AnyHashable : Any] = [DTDefaultTextColor : UIColor.themeColor(withNormal: QMUITheme().textColorLevel1(), andDarkColor: QMUITheme().textColorLevel2()),
                                              DTDefaultLinkColor: UIColor.themeColor(withNormal: QMUITheme().textColorLevel1(), andDarkColor: QMUITheme().textColorLevel2()),
                                              DTDefaultLinkDecoration: false,
                                              DTDefaultFontSize: fontSize,
                                              DTDefaultLineHeightMultiplier: 1.8,
                                              DTDefaultFontFamily: "PingFang SC",
                                              DTDefaultStyleSheet: dtCss,
                                              DTMaxImageSize: NSValue.init(cgSize: CGSize.init(width: maxWidth, height: CGFloat(MAXFLOAT))),
                                              DTDefaultTextAlignment: NSTextAlignment.justified.rawValue]
            
            att = NSAttributedString.init(htmlData: data, options: style, documentAttributes: nil)
        }
        
        return att
    }
    
}

class YXNewsRichTextModel: NSObject {
    @objc var content = ""
    @objc var height: CGFloat = 0
    @objc var attText: NSAttributedString?
    @objc var fontSize: NSInteger = 18
    
    @objc var isArticle = false
    
    @objc init(content: String, fontSize: NSInteger, isArticle: Bool) {
        super.init()
        self.content = content
        self.fontSize = fontSize
        self.isArticle = isArticle
        if isArticle {
            self.attText = content.dt_articleDetailConfig(with: YXConstant.screenWidth - 36, andFontSize: fontSize)
        } else {
            self.attText = content.dt_newsDetailConfig(with: YXConstant.screenWidth - 36, andFontSize: fontSize)
        }
                    
        if let att = self.attText {
            let layouter = DTCoreTextLayouter.init(attributedString: att)
            let maxRect = CGRect.init(x: 0.0, y: 0.0, width: YXConstant.screenWidth - 36, height: CGFloat(CGFLOAT_HEIGHT_UNKNOWN))
            let entireString = NSMakeRange(0, att.length)
            let layoutFrame = layouter?.layoutFrame(with: maxRect, range: entireString)
            self.height = layoutFrame?.frame.size.height ?? 0.0
        }
    }
}

extension YXNewsRichTextModel: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return self
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        
        guard self !== object else { return true }
        guard let object = object as? YXNewsRichTextModel else { return false }
        
        return content == object.content && fontSize == object.fontSize
    }
}

class YXNewsRichTextContentBottomCell: UICollectionViewCell {
    
    let label = UILabel.init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initUI() {
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(20)
        }
    }
}


class YXNewsRichTextContentVC: ListSectionController, ListSupplementaryViewSource {
    
    override init() {
        super.init()
        supplementaryViewSource = self
    }
    
    private var object: YXNewsRichTextModel?
    
    var staticCell: YXNewsRichTextContentCell?
    
    let bottomStr = YXLanguageUtility.kLang(key: "disclaimer_tip")
    
    func supportedElementKinds() -> [String] {
        return [UICollectionView.elementKindSectionFooter]
    }
    
    func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        let height = YXToolUtility.getStringSize(with: bottomStr, andFont: UIFont.systemFont(ofSize: 14, weight: .regular), andlimitWidth: Float(YXConstant.screenWidth) - 32, andLineSpace: 5).height + 30
        return CGSize(width: collectionContext!.containerSize.width, height: height)
    }
    
    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        switch elementKind {
        case UICollectionView.elementKindSectionFooter:
            return userFooterView(atIndex: index)
        default:
            fatalError()
        }
    }
    
    private func userFooterView(atIndex index: Int) -> UICollectionReusableView {
        let view: YXNewsRichTextContentBottomCell = collectionContext.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, forSectionController: self, atIndex: index)

        let att = YXToolUtility.attributedString(withText: bottomStr, font: UIFont.systemFont(ofSize: 14, weight: .regular), textColor: QMUITheme().textColorLevel1().withAlphaComponent(0.3), lineSpacing: 5)
        view.label.attributedText = att
        view.label.numberOfLines = 0
        view.backgroundColor = UIColor.clear
        return view
    }

    override func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext!.containerSize.width

        return CGSize(width: width, height: self.object?.height ?? 300)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        
        if let cell = staticCell {
            
            return cell
        } else {
            let cell: YXNewsRichTextContentCell = collectionContext.dequeueReusableCell(for: self, at: index)
            staticCell = cell
            cell.attText = object?.attText
            cell.richView.refreshHeight = { [weak self] height in
                guard let `self` = self else { return }
                if let sourceHeight = self.object?.height, height != sourceHeight {
                    self.object?.height = height
                    self.collectionContext.invalidateLayout(for: self, completion: nil)
                }
            }
            return cell
        }
    }

    override func didUpdate(to object: Any) {
        self.object = object as? YXNewsRichTextModel
    }
}
