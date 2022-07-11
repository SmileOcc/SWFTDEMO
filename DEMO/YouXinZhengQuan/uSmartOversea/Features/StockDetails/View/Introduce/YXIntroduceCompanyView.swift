//
//  YXIntroduceCompanyView.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/7/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit
import RxSwift
import RxCocoa

class YXIntroduceCompanyView: UIView {
    
    var moreCallBack: ((_ height: CGFloat) -> ())?
    //是否滑动到顶部
    var scrollToTopClosure: ((_ should: Bool) -> ())?
    
    var industryClickBlock:((_ title: String, _ market: String, _ code: String) -> Void)?

    var ipoInfoClickBlock:(() -> Void)?

    var pushToDetailBlock:(() -> Void)?
    
    var padding_x = 132
    
    var isHkMarket = true {
        didSet {
            detailButton.isHidden = !isHkMarket
        }
    }
    
    var isShow = false
    
    var offsetHeight: CGFloat = 0

    var conceptionIsExpand: Bool = false
    var floatLayoutViewHeight: CGFloat = 0
    
    var model: YXIntroduceProfile? {
        didSet {
            if let model = self.model {

//                self.industryLabel.yx_setDefaultText(with: model.industryDesc)
//                let industryPctchng: Double? = model.pctchng
//                if let industryPctchng = industryPctchng {
//                    var roc = String(format: "%.2lf%%", industryPctchng / 100)
//
//                    if industryPctchng > 0 {
//                        roc = "+\(roc)"
//                        self.industryPctchngLabel.textColor = QMUITheme().stockRedColor()
//                    } else if industryPctchng == 0 {
//                        self.industryPctchngLabel.textColor = QMUITheme().stockGrayColor()
//                    } else {
//                        roc = "\(roc)"
//                        self.industryPctchngLabel.textColor = QMUITheme().stockGreenColor()
//                    }
//                    self.industryPctchngLabel.yx_setDefaultText(with: roc)
//                } else {
//                    self.industryPctchngLabel.text = ""
//                }
                
                if self.isHkMarket {
                    self.nameLabel.yx_setDefaultText(with: model.companyName)
                } else {
                    self.nameLabel.yx_setDefaultText(with: model.companyEngName)
                }
                if let timeStr = model.listDate, timeStr.count >= 10 {                    
                    self.listTimeLabel.text = YXDateHelper.commonDateString(timeStr)
                } else {
                    self.listTimeLabel.text = "--"
                }
                self.chairManLabel.yx_setDefaultText(with: model.chairman)
                self.setBriefLabel(self.isShow)
                
                self.emptyView.isHidden = true
            } else {
                self.emptyView.isHidden = false
                self.showMoreBtn.isHidden = true
            }
        }
    }
    
    var HSModel: YXHSStockIntroduceModel? {
        didSet {
            if let model = self.HSModel?.profile {
                
//                self.industryLabel.yx_setDefaultText(with: model.industryName)
//                let industryPctchng: Double? = model.industryPctchng
//                if let industryPctchng = industryPctchng {
//                    var roc = String(format: "%.2lf%%", industryPctchng / 100)
//
//                    if industryPctchng > 0 {
//                        roc = "+\(roc)"
//                        self.industryPctchngLabel.textColor = QMUITheme().stockRedColor()
//                    } else if industryPctchng == 0 {
//                        self.industryPctchngLabel.textColor = QMUITheme().stockGrayColor()
//                    } else {
//                        roc = "\(roc)"
//                        self.industryPctchngLabel.textColor = QMUITheme().stockGreenColor()
//                    }
//                    self.industryPctchngLabel.yx_setDefaultText(with: roc)
//                } else {
//                    self.industryPctchngLabel.text = ""
//                }
                
                self.nameLabel.yx_setDefaultText(with: model.compName)
                
                if let timeStr = model.listedDate, timeStr.count >= 8 {
                    if timeStr.count == 8 {
                        var subStringTo8 = String(timeStr.prefix(8))
                        subStringTo8.insert("-", at: subStringTo8.index(subStringTo8.startIndex, offsetBy: 4))
                        subStringTo8.insert("-", at: subStringTo8.index(subStringTo8.startIndex, offsetBy: 7))
                        self.listTimeLabel.text = subStringTo8
                    } else {
                        self.listTimeLabel.text = timeStr
                    }
                } else {
                    self.listTimeLabel.text = "--"
                }
                self.chairManLabel.yx_setDefaultText(with: model.chairman)
                self.setBriefLabel(self.isShow)
                
                self.emptyView.isHidden = true
            } else {
                self.emptyView.isHidden = false
                self.showMoreBtn.isHidden = true
            }
            
//            if let conceptions = self.HSModel?.conception, conceptions.count > 0 {
//                for conception in conceptions {
//                    if let conceptionName = conception.conceptionName {
//                        let button = QMUIGhostButton()
//                        button.ghostColor = UIColor.qmui_color(withHexString: "#1E93F3")?.withAlphaComponent(0.4)
//                        button.layer.borderWidth = QMUIHelper.pixelOne()
//                        let conceptionNameFont = UIFont.systemFont(ofSize: 14)
//                        let conceptionPctchngFont: UIFont = UIFont.systemFont(ofSize: 16)
//                        let conceptionNameTextColor = UIColor.black
//                        var conceptionPctchngTextColor:UIColor?
//
//                        let conceptionPctchng: Double = conception.conceptionPctchng ?? 0
//                        var roc = String(format: "%.2lf%%", conceptionPctchng / 100)
//                        if conceptionPctchng > 0 {
//                            roc = "+\(roc)"
//                            conceptionPctchngTextColor = QMUITheme().stockRedColor()
//                        } else if conceptionPctchng == 0 {
//                            conceptionPctchngTextColor = QMUITheme().stockGrayColor()
//                        } else {
//                            roc = "\(roc)"
//                            conceptionPctchngTextColor = QMUITheme().stockGreenColor()
//                        }
//
//                        let conceptionNameAttributes = [
//                            NSAttributedString.Key.font : conceptionNameFont,
//                            NSAttributedString.Key.foregroundColor : conceptionNameTextColor
//                        ]
//
//                        let conceptionPctchngAttributes = [
//                            NSAttributedString.Key.font : conceptionPctchngFont,
//                            NSAttributedString.Key.foregroundColor : conceptionPctchngTextColor ?? UIColor.gray
//                        ]
//                        let nameAndSpace = "\(conceptionName)  "
//                        let title = "\(nameAndSpace)\(roc)"
//                        let attributeString = NSMutableAttributedString(string: title)
//                        attributeString.addAttributes(conceptionNameAttributes, range: NSRange(location: 0, length: nameAndSpace.count))
//                        attributeString.addAttributes(conceptionPctchngAttributes, range: NSRange(location: nameAndSpace.count, length: title.count - nameAndSpace.count))
//                        button.setAttributedTitle(attributeString, for: .normal)
//                        button.contentEdgeInsets = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8)
//
//                        button.rx.tap
//                            .takeUntil(button.rx.deallocated)
//                            .subscribe(onNext: {
//                            [weak self] _ in
//                            guard let `self` = self else { return }
//                            //服务器那边没有sz， APP这边统一写死sh
//                            if let code = conception.conceptionCodeYx, code.count > 0 {
//                                self.industryClickBlock?((conception.conceptionName ?? ""), YXMarketType.ChinaSH.rawValue, code)
//                            }
//                        }).disposed(by: self.rx.disposeBag)
//
//                        self.floatLayoutView.addSubview(button)
//                    }
//                }
//                self.setNeedsLayout()
//            } else {
//                if hasConcept {
//                    removeConceptualSection()
//                }
//            }
        }
    }

    var hasIPOInfo: Bool = false {
        didSet {
            ipoInfoExpanBtn.isHidden = !hasIPOInfo
        }
    }
    
//    var industryLabel = QMUILabel.init(with: QMUITheme().textColorLevel1(), font: UIFont.systemFont(ofSize: 14), text: "--")
//    var industryPctchngLabel = QMUILabel.init(with: QMUITheme().stockGrayColor(), font: UIFont.systemFont(ofSize: 14), text: "--")
    var nameLabel = QMUILabel.init(with: QMUITheme().textColorLevel1(), font: UIFont.systemFont(ofSize: 14), text: "--")
    var listTimeLabel = QMUILabel.init(with: QMUITheme().textColorLevel1(), font: UIFont.systemFont(ofSize: 14), text: "--")
    var chairManLabel = QMUILabel.init(with: QMUITheme().textColorLevel1(), font: UIFont.systemFont(ofSize: 14), text: "--")
    var mainBusinessLabel = YYLabel.init()
    //var conceptView = UIView()
    
    let emptyView = YXStockEmptyDataView.init()
    
    var hasConcept = false
    
    var showMoreBtn = QMUIButton.init(frame: CGRect.init(x: 0, y: 0, width: 30, height: 16))
    let truncationTokenView:UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 70, height: 16))
    lazy var floatLayoutView: QMUIFloatLayoutView = {
        let view = QMUIFloatLayoutView()
        view.itemMargins = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 8)
        view.minimumItemSize = CGSize(width: 69, height: 29)
        view.qmui_frameWillChangeBlock = { [weak self] (view, rect) in
            guard let `self` = self else { return rect }
            
            if self.floatLayoutView.superview != nil {
                self.floatLayoutView.snp.updateConstraints { (make) in
                    make.height.equalTo(rect.size.height)
                }
            }
            self.floatLayoutViewHeight = rect.size.height

            self.layoutConceptionView()

            return rect
        }
        return view
    }()

    lazy var conceptionExpanBtn: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setTitle(YXLanguageUtility.kLang(key: "show_more"), for: .normal)
        button.setTitle(YXLanguageUtility.kLang(key: "stock_detail_pack_up"), for: .selected)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(QMUITheme().mainThemeColor(), for: .normal)
        button.addTarget(self, action: #selector(conceptionExpandAction(sender:)), for: .touchUpInside)
        button.backgroundColor = UIColor.white
        button.isHidden = true
        return button
    }()

    @objc func conceptionExpandAction(sender: UIButton) {
        self.conceptionIsExpand = !self.conceptionIsExpand
        sender.isSelected = self.conceptionIsExpand
        layoutConceptionView()
    }

    lazy var ipoInfoExpanBtn: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setTitle(YXLanguageUtility.kLang(key: "stock_ipo_info"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(QMUITheme().mainThemeColor(), for: .normal)
        button.addTarget(self, action: #selector(ipoInfoExpandAction(sender:)), for: .touchUpInside)
        button.backgroundColor = UIColor.white
        button.isHidden = true
        return button
    }()

    @objc func ipoInfoExpandAction(sender: UIButton) {
        self.ipoInfoClickBlock?()
    }

    func layoutConceptionView() {

        var floatHeight: CGFloat = self.floatLayoutViewHeight
        if self.floatLayoutViewHeight > 60 {
            conceptionExpanBtn.isHidden = false
            if self.conceptionIsExpand {
                floatHeight = self.floatLayoutViewHeight + 40
                
            } else {
                floatHeight = 70 + 40
            }
            conceptionView.snp.updateConstraints { (make) in
                make.height.equalTo(floatHeight)
            }

        } else {
            conceptionExpanBtn.isHidden = true
            conceptionView.snp.updateConstraints { (make) in
                make.height.equalTo(self.floatLayoutViewHeight)
            }
        }

        self.moreCallBack?(floatHeight + self.offsetHeight)
    }

    lazy var conceptionView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.addSubview(floatLayoutView)
        floatLayoutView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(70)
        }

        view.addSubview(conceptionExpanBtn)
        conceptionExpanBtn.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(40)
        }

        view.bringSubviewToFront(conceptionExpanBtn)

        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, market: String) {
        self.init(frame: frame)
        if market == YXMarketType.ChinaSZ.rawValue || market == YXMarketType.ChinaSH.rawValue {
            self.hasConcept = true
        }
        initUI()
   
//        industryButton.rx.tap.subscribe(onNext: {
//            [weak self] (ges) in
//            guard let `self` = self else { return }
//
//            if market == YXMarketType.ChinaSZ.rawValue || market == YXMarketType.ChinaSH.rawValue {
//                //服务器那边没有sz， APP这边统一写死sh
//                if let profile = self.HSModel?.profile, let industryCode = profile.industryCodeYx, industryCode.count > 0 {
//                    self.industryClickBlock?((profile.industryName ?? ""), YXMarketType.ChinaSH.rawValue, industryCode)
//                }
//            } else {
//                if let profile = self.model, let industryCode = profile.industryCodeYx, industryCode.count > 0 {
//                    self.industryClickBlock?((profile.industryDesc ?? ""), market, industryCode)
//                }
//            }
//
//        }).disposed(by: rx.disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var industryButton: QMUIButton = {
        let button = QMUIButton()
   
        button.backgroundColor = UIColor.clear
        return button
    }()
    
    //let conceptTitle = QMUILabel.init(with: QMUITheme().textColorLevel2(), font: UIFont.systemFont(ofSize: 14), text:  YXLanguageUtility.kLang(key: "conceptual_section"))
    let nameTitle = QMUILabel.init(with: QMUITheme().textColorLevel3(), font: UIFont.systemFont(ofSize: 14), text: YXLanguageUtility.kLang(key: "company_name"))
    
    func initUI() {

        mainBusinessLabel.textColor = QMUITheme().textColorLevel1()
        mainBusinessLabel.font = UIFont.systemFont(ofSize: 14)
        mainBusinessLabel.textVerticalAlignment = .top
        //更多
        showMoreBtn.setTitle(YXLanguageUtility.kLang(key: "share_info_more"), for: .normal)
        showMoreBtn.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        showMoreBtn.titleLabel?.font = .systemFont(ofSize: 14)
        showMoreBtn.backgroundColor = QMUITheme().foregroundColor()
        showMoreBtn.addTarget(self, action: #selector(self.moreClick(_:)), for: .touchUpInside)
        
        showMoreBtn.titleLabel?.sizeToFit()
        
        var width = showMoreBtn.titleLabel?.mj_w ?? 0
        truncationTokenView.addSubview(showMoreBtn)
        let dotLalabel = QMUILabel.init(with: QMUITheme().textColorLevel1(), font: .systemFont(ofSize: 14), text: " ...  ")
        dotLalabel.sizeToFit()
        width += dotLalabel.mj_w
        
        
        truncationTokenView.mj_w = width + 5
        
        truncationTokenView.addSubview(dotLalabel)
        dotLalabel.snp.makeConstraints { make in
            make.top.bottom.left.equalToSuperview()
        }
        showMoreBtn.snp.makeConstraints { make in
            make.left.equalTo(dotLalabel.snp.right)
            make.top.bottom.right.equalToSuperview()
        }
        
        let titleLabel = QMUILabel.init(with: QMUITheme().textColorLevel1(), font: UIFont.systemFont(ofSize: 20, weight: .medium), text: YXLanguageUtility.kLang(key: "stock_detail_company_profile"))
        //let industryTitle = QMUILabel.init(with: QMUITheme().textColorLevel2(), font: UIFont.systemFont(ofSize: 14), text:  YXLanguageUtility.kLang(key: "belong_industry"))

        let listTimeTitle = QMUILabel.init(with: QMUITheme().textColorLevel3(), font: UIFont.systemFont(ofSize: 14), text: YXLanguageUtility.kLang(key: "launch_date"))
        let chairmanTitle = QMUILabel.init(with: QMUITheme().textColorLevel3(), font: UIFont.systemFont(ofSize: 14), text: YXLanguageUtility.kLang(key: "company_chairman"))
        listTimeTitle.adjustsFontSizeToFitWidth = true
        listTimeTitle.minimumScaleFactor = 0.3
        chairmanTitle.adjustsFontSizeToFitWidth = true
        chairmanTitle.minimumScaleFactor = 0.3
       // let mainBusinessTitle = QMUILabel.init(with: QMUITheme().textColorLevel3(), font: UIFont.systemFont(ofSize: 14), text: YXLanguageUtility.kLang(key: "major_business"))
        
        //industryPctchngLabel.textAlignment = .right
        
        addSubview(titleLabel)
//        addSubview(industryTitle)
//        if hasConcept {
//            addSubview(conceptTitle)
//            addSubview(conceptionView)
//        }
        addSubview(nameTitle)
        addSubview(listTimeTitle)
        addSubview(chairmanTitle)
        //addSubview(mainBusinessTitle)
        
//        addSubview(industryLabel)
//        addSubview(industryButton)
//        addSubview(industryPctchngLabel)
        addSubview(nameLabel)
        addSubview(listTimeLabel)
        addSubview(chairManLabel)
        addSubview(mainBusinessLabel)
        addSubview(self.emptyView)

      //  addSubview(self.ipoInfoExpanBtn)
        addSubview(self.detailButton)
        
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(28)
            make.height.equalTo(24)
        }

        detailButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(16)
            make.centerY.equalTo(titleLabel)
        }
        
//        industryTitle.snp.makeConstraints { (make) in
//            make.leading.equalTo(titleLabel)
//            make.top.equalTo(titleLabel.snp.bottom).offset(12)
//            make.height.equalTo(20)
//        }
//        if hasConcept {
//            conceptTitle.snp.makeConstraints { (make) in
//                make.leading.equalTo(titleLabel)
//                make.top.equalTo(industryTitle.snp.bottom).offset(20)
//                make.height.equalTo(20)
//            }
//            conceptionView.snp.makeConstraints { (make) in
//                make.leading.equalToSuperview().offset(padding_x)
//                make.trailing.equalToSuperview().offset(-18)
//                make.top.equalTo(conceptTitle.snp.top)
//                make.height.equalTo(0)
//            }
//            nameTitle.snp.makeConstraints { (make) in
//                make.leading.equalTo(titleLabel)
//                make.top.equalTo(conceptionView.snp.bottom).offset(20)
//                make.height.equalTo(20)
//            }
//        } else {
//            nameTitle.snp.makeConstraints { (make) in
//                make.leading.equalTo(titleLabel)
//                make.top.equalTo(industryTitle.snp.bottom).offset(20)
//                make.height.equalTo(20)
//            }
//        }

        nameTitle.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.height.equalTo(40)
        }

        listTimeTitle.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(nameTitle.snp.bottom)
            make.height.equalTo(40)
            make.width.lessThanOrEqualTo(padding_x - 16 - 5)
        }
        chairmanTitle.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(listTimeTitle.snp.bottom)
            make.height.equalTo(40)
            make.width.lessThanOrEqualTo(padding_x - 16 - 5)
        }
//        mainBusinessTitle.snp.makeConstraints { (make) in
//            make.leading.equalTo(titleLabel)
//            make.top.equalTo(chairmanTitle.snp.bottom)
//            make.height.equalTo(40)
//        }
//        industryPctchngLabel.snp.makeConstraints { (make) in
//            make.trailing.lessThanOrEqualToSuperview().offset(-18)
//            make.top.equalTo(industryTitle)
//            make.height.equalTo(20)
//            make.width.greaterThanOrEqualTo(0)
//        }
//        industryPctchngLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
//
//        industryLabel.snp.makeConstraints { (make) in
//            make.leading.equalToSuperview().offset(padding_x)
//            make.top.equalTo(industryTitle)
//            make.height.equalTo(20)
//            make.trailing.equalTo(industryPctchngLabel.snp.leading).offset(-8)
//        }
        
//        industryButton.snp.makeConstraints { (make) in
//            make.right.equalToSuperview()
//            make.top.equalTo(industryLabel)
//            make.left.equalTo(industryLabel)
//            make.bottom.equalTo(industryLabel)
//        }
        nameLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(padding_x)
            make.top.equalTo(nameTitle)
            make.height.equalTo(40)
            make.trailing.equalToSuperview().offset(-16)
        }
        listTimeLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(padding_x)
            make.top.equalTo(listTimeTitle)
            make.height.equalTo(40)
           // make.trailing.equalToSuperview().offset(-18)
        }

//        ipoInfoExpanBtn.snp.makeConstraints { (make) in
//            make.centerY.equalTo(listTimeLabel)
//            make.left.equalTo(listTimeLabel.snp.right).offset(25)
//        }


        chairManLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(padding_x)
            make.top.equalTo(chairmanTitle)
            make.height.equalTo(40)
            make.trailing.equalToSuperview().offset(-16)
        }
        mainBusinessLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(chairManLabel.snp.bottom).offset(12)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(70)
        }
        
        emptyView.snp.makeConstraints { (make) in
            make.leading.top.equalTo(nameTitle)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(mainBusinessLabel)
        }
    }
    
    //移除概念板块
    func removeConceptualSection() {
        
//        hasConcept = false
//        nameTitle.snp.remakeConstraints { (make) in
//            make.leading.equalTo(conceptTitle)
//            make.top.equalTo(conceptTitle.snp.top)
//            make.height.equalTo(20)
//        }
//        conceptTitle.isHidden = true
//        conceptionView.isHidden = true
    }
    //【更多】的响应
    @objc func moreClick(_ sender: UIButton) {
        self.isShow = !self.isShow
        self.setBriefLabel(self.isShow)
        if hasConcept {
            self.layoutConceptionView()
        } else {
            self.moreCallBack?(self.offsetHeight)
        }
    }
    
    func setBriefLabel(_ isShow: Bool) {
        
        var companyBrief: String?
        if self.model != nil {
            companyBrief = self.model?.companyBriefText
        } else {
            companyBrief = self.HSModel?.profile?.compBrief
        }
        
        var height: CGFloat = 0
        if let str = companyBrief, str.count > 0 {
            let att = YXToolUtility.attributedString(withText: str, font: UIFont.systemFont(ofSize: 14), textColor: QMUITheme().textColorLevel1(), lineSpacing: 5)
            
            
            if isShow {
                self.mainBusinessLabel.numberOfLines = 0
                self.mainBusinessLabel.truncationToken = nil
                //收起
                let showAtt = NSMutableAttributedString.init(string: "\n" + YXLanguageUtility.kLang(key: "stock_detail_pack_up"))
                showAtt.yy_font = .systemFont(ofSize: 14)
                showAtt.yy_color = QMUITheme().themeTextColor()
                showAtt.yy_setTextHighlight(NSRange.init(location: 0, length: showAtt.length), color: QMUITheme().themeTextColor(), backgroundColor: .clear) { [weak self] (view, att, range, rect) in
                    //点击【收起】的响应
                    guard let `self` = self else { return }
                    self.moreClick(self.showMoreBtn)
                }
                att?.append(showAtt)
            } else {
                self.mainBusinessLabel.numberOfLines = 3
                self.mainBusinessLabel.sizeToFit()
//                self.mainBusinessLabel.mj_w
                                
                let attachment = NSMutableAttributedString.yy_attachmentString(withContent: self.truncationTokenView, contentMode: .center, attachmentSize: CGSize.init(width: self.truncationTokenView.mj_w ?? 70, height: self.truncationTokenView.mj_h ?? 16), alignTo: UIFont.systemFont(ofSize: 14), alignment: .center)
                self.mainBusinessLabel.truncationToken = attachment
            }
            
            if let att = att {
                let layout = YYTextLayout.init(containerSize: CGSize.init(width: Int(YXConstant.screenWidth) - 32, height: Int.max), text: att)
                height = layout?.textBoundingSize.height ?? 20
            } else {
                height = 20
            }
            if !isShow {
                //如果是收起状态，height > 63,则固定为63
                if height > 63 {
                    height = 63
                    self.scrollToTopClosure?(true)
                }
            }
            self.mainBusinessLabel.attributedText = att
        } else {
            self.mainBusinessLabel.text = "--"
        }
        self.mainBusinessLabel.snp.updateConstraints { (make) in
            make.height.equalTo(height)
        }
        
        if height > 63 {
            self.offsetHeight = height - 63
        } else {
            self.offsetHeight = 0
        }
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        if hasConcept {
//            if YXUserManager.isENMode() {
//                padding_x = 138
//            }
//
//            self.floatLayoutView.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth - CGFloat(padding_x) - 18, height: QMUIViewSelfSizingHeight)
//        }
//    }

    lazy var detailButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.contentHorizontalAlignment = .right
        button.setImage(UIImage(named: "market_more_arrow"), for: .normal)
        button.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }

            self.pushToDetailBlock?()

        }).disposed(by: rx.disposeBag)
        return button
    }()
}


extension UILabel {
    convenience init(with color: UIColor?, font: UIFont, text: String?) {
        self.init()
        self.text = text
        self.font = font
        self.textColor = color
    }
    
    // 设置默认值
    func yx_setDefaultText(with text: String?) {
        
        if let str = text, str.count > 0 {
            self.text = str
        } else {
            self.text = "--"
        }
    }
}


