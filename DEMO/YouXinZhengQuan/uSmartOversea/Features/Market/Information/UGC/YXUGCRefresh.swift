//
//  YXUGCRefresh.swift
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/5/27.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

@objcMembers class YXUGCRefreshHeader: MJRefreshHeader {

    @objc lazy var tipsLabel: QMUILabel = {
        let label = QMUILabel()
        label.textAlignment = .center
        return label
    }()
    
    override var state: MJRefreshState {
        didSet {
            tipsLabel.attributedText = state.headerAttributedString
        }
    }
    
    override func prepare() {
        super.prepare()
        
        mj_h = 52
        addSubview(tipsLabel)
    }
    
    override func placeSubviews() {
        super.placeSubviews()
        
        tipsLabel.frame = CGRect(x: 0, y: 16, width: YXConstant.screenWidth, height: 20)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

@objcMembers class YXUGCRefreshFooter: MJRefreshBackFooter {

    @objc lazy var tipsLabel: QMUILabel = {
        let label = QMUILabel()
        label.textAlignment = .center
        return label
    }()
    
    override var state: MJRefreshState {
        didSet {
            tipsLabel.attributedText = state.footerAttributedString
        }
    }
    
    override func prepare() {
        super.prepare()
        
        mj_h = 52
        addSubview(tipsLabel)
    }
    
    override func placeSubviews() {
        super.placeSubviews()
        
        tipsLabel.frame = CGRect(x: 0, y: 16, width: YXConstant.screenWidth, height: 20)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

private extension MJRefreshState {
    var headerAttributedString: NSAttributedString? {
        let arrowAttr = NSAttributedString.qmui_attributedString(with: UIImage(named: "ugc_arrow_up") ?? UIImage(), baselineOffset: -3, leftMargin: 4, rightMargin: 0)
        let attributed: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: QMUITheme().themeTextColor()]
        switch self {
        case .idle:
            let attr = NSMutableAttributedString(string: YXLanguageUtility.kLang(key: "ugc_pull_prev"), attributes: attributed)
            attr.append(arrowAttr)
            return attr
        case .willRefresh,
             .refreshing,
             .pulling:
            let attr = NSMutableAttributedString(string: YXLanguageUtility.kLang(key: "ugc_release_prev"), attributes: attributed)
            attr.append(arrowAttr)
            return attr
        default:
            break
        }
        return nil
    }
    
    var footerAttributedString: NSAttributedString? {
        let arrowAttr = NSAttributedString.qmui_attributedString(with: UIImage(named: "ugc_arrow_down") ?? UIImage(), baselineOffset: -3, leftMargin: 4, rightMargin: 0)
        let attributed: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: QMUITheme().themeTextColor()]
        switch self {
        case .idle:
            let attr = NSMutableAttributedString(string: YXLanguageUtility.kLang(key: "ugc_pull_next"), attributes: attributed)
            attr.append(arrowAttr)
            return attr
        case .willRefresh,
             .refreshing,
             .pulling:
            let attr = NSMutableAttributedString(string: YXLanguageUtility.kLang(key: "ugc_release_next"), attributes: attributed)
            attr.append(arrowAttr)
            return attr
        default:
            break
        }
        return nil
    }
}
