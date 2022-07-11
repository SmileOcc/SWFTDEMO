//
//  YXShareBottomAlertView.swift
//  uSmartOversea
//
//  Created by ysx on 2022/4/2.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import sqlcipher


@objc class YXShareItemModel : NSObject {
    
    // 分享按钮标题
    var shareName: String?
    // 分享按钮类型
    var sharePlatform: YXSharePlatform = .unKnown
    // 分享按钮图片
    var shareImageName: String?
    
    // 字符串类型，用于web
    var shareType: String?
    var shareTag: NSInteger = 0
}

typealias ShareResultCallBlock = (_ platform: YXSharePlatform, _ result: Bool) -> Void

class YXShareBottomAlertView: UIView {

    @objc var shareTitle: String?
    @objc var shareText: String?
    // 短链
    @objc var shareUrl: String?
    // 长链
    @objc var shareLongUrl: String?
    @objc var shareImage: UIImage?
    // 分享类型
    @objc var shareType:YXShareType = .image
    
    //分享按钮点击,如果没有设置,内部自动处理
    var shareClickBlock: ((YXShareItemModel) -> Void)?
    //分享三方平台结果回调
    var shareResultBlock: ShareResultCallBlock?
    //取消事件回调
    var cancelCallBlock: (() -> Void)?
    //分享社区，如果没有设置,内部自动处理
    var shareToUsmartCommunityCallback: (() -> Void)?
    
    //分享按钮集合
    var shareThirdItems:[YXShareItemModel] = []
    //工具分享集合
    var toolsItems:[YXShareItemModel] = []
    
    // 是否显示盲盒活动的角标
    var showMysteryBoxBadge = false {
        didSet {
            self.thirdBottomView.showMysteryBoxBadge = showMysteryBoxBadge
            self.toolBottomView.showMysteryBoxBadge = showMysteryBoxBadge
        }
    }

    //内部默认统一弹出提示
    @objc var isDefaultShowMessage = false
    
    // 一行分享滑动高度
    let kShareLienHeight: CGFloat = 85
    let kShareCancelHeight: CGFloat = 50

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 初始化方法
    func configure(shareType:YXShareType,toolTypes:[YXSharePlatform],thirdTypes:[YXSharePlatform], clickCallBlock:((YXShareItemModel) -> Void)?,resultCallBlock:ShareResultCallBlock?, cancelBlock:(() -> Void)?) {
        
        if toolTypes.count == 0 && thirdTypes.count == 0{
            self.shareThirdItems = YXShareManager.getThirdShareItems(nil,shareType)
            self.toolsItems = YXShareManager.getToolShareItems(nil)
            
        } else {
            self.shareThirdItems = YXShareManager.getThirdShareItems(thirdTypes,shareType)
            self.toolsItems = YXShareManager.getToolShareItems(toolTypes)
        }

        configure(shareType: shareType,
                  toolItems: self.toolsItems,
                  thirdItems: self.shareThirdItems,
                  clickCallBlock: clickCallBlock,
                  resultCallBlock: resultCallBlock,
                  cancelBlock: cancelBlock)
    }
    
    func configure(shareType:YXShareType,toolItems:[YXShareItemModel],thirdItems:[YXShareItemModel], clickCallBlock:((YXShareItemModel) -> Void)?, resultCallBlock:ShareResultCallBlock?, cancelBlock:(() -> Void)?) {
        
        self.shareType = shareType
        self.shareClickBlock = clickCallBlock
        self.cancelCallBlock = cancelBlock
        self.shareResultBlock = resultCallBlock
        
        self.toolsItems = toolItems
        self.shareThirdItems = thirdItems
        
        //优先判断外部传入的
        if thirdItems.count == 0 && toolItems.count == 0{
            self.shareThirdItems = YXShareManager.getThirdShareItems(nil,shareType)
            self.toolsItems = YXShareManager.getToolShareItems(nil)
        }
        
        self.initUI()
    }
    
    // 容器高度
    func currentContentHeight() -> CGFloat {
        var contentH = 11 + 6 + kShareLienHeight + kShareCancelHeight + YXConstant.safeAreaInsetsBottomHeight()
        if self.shareThirdItems.count >= 3 {
            contentH = 11 + 6 + kShareLienHeight * 2 + kShareCancelHeight + YXConstant.safeAreaInsetsBottomHeight()
        }
        return contentH
    }
    
    func refreshUI() {
        self.thirdBottomView.refreshBottomView()
        self.toolBottomView.refreshBottomView()
    }
    
    // MARK: - 约束
    func initUI() {
    
        self.addSubview(self.bgContentView)
        self.addSubview(self.thirdBottomView)
        self.addSubview(self.toolBottomView)
        self.addSubview(self.bottomCancelButton)
        self.addSubview(self.lineView)
        
        self.bottomCancelButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(kShareCancelHeight)
            make.bottom.equalToSuperview().offset(-YXConstant.safeAreaInsetsBottomHeight())
        }
        
        self.thirdBottomView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(0)
        }
        self.toolBottomView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(kShareLienHeight)
            make.top.equalTo(self.thirdBottomView.snp.bottom)
            make.bottom.equalTo(self.bottomCancelButton.snp.top).offset(-11)
        }
        
        self.bgContentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.thirdBottomView.snp.top).offset(-6)
            make.bottom.equalToSuperview()
        }
        
        self.lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.bottomCancelButton.snp.top)
            make.height.equalTo(0.5)
        }
        
        //三方分享数据处理
        if self.shareThirdItems.count >= 3 {
            self.thirdBottomView.snp.updateConstraints { make in
                make.height.equalTo(kShareLienHeight)
            }
            self.toolBottomView.shareItems = self.toolsItems
            self.thirdBottomView.shareItems = self.shareThirdItems
        } else {
            self.thirdBottomView.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
            //隐藏第一行，默认的第三方组，统一显示到第一组去
            let allItemsDatas:[YXShareItemModel] = self.shareThirdItems + self.toolsItems
            self.toolBottomView.shareItems = allItemsDatas
            self.thirdBottomView.shareItems = []
        }
        
    }

    // MARK: - 控件
    lazy var bgContentView: UIView = {
        let view = UIView()
        //view.backgroundColor = QMUITheme().backgroundColor()
        view.backgroundColor = QMUITheme().popupLayerColor()
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 16
        return view
    }()
    
    //三方按钮模块
    lazy var thirdBottomView: YXShareBottomContentView = {
        let view = YXShareBottomContentView.init(items: []) {[weak self] itemModel in
            guard let `self` = self else { return }
            if let callBlock = self.shareClickBlock {
                callBlock(itemModel)
            } else {
                self.autoHandleClick(itemModel)
            }
        }
        return view
    }()
    
    //本地工具按钮模块
    lazy var toolBottomView: YXShareBottomContentView = {
        let view = YXShareBottomContentView.init(items: []) {[weak self] itemModel in
            guard let `self` = self else { return }
            if let callBlock = self.shareClickBlock {
                callBlock(itemModel)
            } else {
                self.autoHandleClick(itemModel)
            }
        }
        return view
    }()

    lazy var cancelButton: UIControl = {
        let view = UIControl()
        view.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        return view
    }()
    
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().popSeparatorLineColor()
        return view
    }()
    
    lazy var bottomCancelButton: UIButton = {
        let btn = UIButton()
        btn.setTitle(YXLanguageUtility.kLang(key: "cancel_btn"), for: .normal)
        if YXThemeTool.isDarkMode() {
            btn.setTitleColor(UIColor(hexString:"#D3D4E6"), for: .normal)
        } else {
            btn.setTitleColor(UIColor(hexString:"#191919"), for: .normal)
        }
        btn.titleLabel?.font = .systemFont(ofSize: 16)
        btn.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        btn.backgroundColor = QMUITheme().popupLayerColor()
        return btn
    }()

    // MARK: - 事件
    // 取消
    @objc func cancelButtonAction() {
        if let cancelBlock = self.cancelCallBlock {
            cancelBlock()
        }
    }
    
    // 事件处理，
    @objc func autoHandleClick(_ itemModel: YXShareItemModel) {
        
        if YXShareManager.isNeedHiddeModalPresent(itemModel.sharePlatform) {
            if let modalVC =  UIViewController.current() as? QMUIModalPresentationViewController {
                modalVC.hideWith(animated: false, completion: { finished in
                    self.shareEvent(itemModel)
                })
                return
            } else {
                //防止试图弹窗 在windows上
                if let cancelBlock = self.cancelCallBlock {
                    cancelBlock()
                    self.shareEvent(itemModel)
                    return
                }
            }
        }
        
        self.shareEvent(itemModel)
    }
    
    // MARK: - 分享事件处理
    func shareEvent(_ itemModel: YXShareItemModel) {
        
        // 分享结果提示
        let shareResultInfoBlock: (YXSharePlatform,Bool) -> Void = {[weak self](platform, success) in
            guard let `self` = self else { return }
            if self.isDefaultShowMessage == true {
                YXShareManager.showShareResultMessage(sharePlatform: platform, success: success)
            }
       }
        
        if itemModel.shareTag > 0 {
            let type:YXSharePlatform  = itemModel.sharePlatform
            
            // more 分享功能： telegram 图片分享时暂时用more功能
            if type == .more || (type == .telegram && shareType == .image) {
                
                if shareType == .link {
                    guard let url = shareUrl else { return }
                    let urll = "\(shareText ?? "") " + "\(shareTitle ?? "" ) " + url
                    
                    YXShareManager.shared.shareToMore(activityItems: [urll]) { platform, result in
                        if result == true {
                            shareResultInfoBlock(.more, result)
                        }
                    }
                    
                }else {
                    
                    guard let img = shareImage else { return }
                    YXShareManager.shared.shareToMore(activityItems: [img]) { platform, result in
                        if result == true {
                            shareResultInfoBlock(.more, result)
                        }
                    }
                }
                return
            }
            
            
            // 图片 保存，社区
            if let image = self.shareImage {
                
                if type == .save {
                    
                    trackViewClickEvent(customPageName: "P&L Amount", name: "Save Picture")
                    YXToolUtility.saveImage(toAlbum: image) { (success) in
                        shareResultInfoBlock(type, success)
                    }
                    return
                    
                } else if type == .uSmartSocial {
                    
                    trackViewClickEvent(customPageName: "P&L Amount", name: "uSMART Community")
                    if let communityCallback = self.shareToUsmartCommunityCallback {
                        communityCallback()
                    } else {
                        YXShareManager.shareToUsmartCommunity(self.shareImage)
                    }
                    return
                }
            }

            
            // 链接分享
            if self.shareType == .link {
                
                if type == .copy {// 复制链接
                    
                    if let url = shareUrl {
                        let pab = UIPasteboard.general
                        pab.string = "\(shareText ?? "") " + "\(shareTitle ?? "" ) " + url
                    }
                    shareResultInfoBlock(type,true)

                } else if type == .wxMiniProgram {
                    
                    
                } else if type == .sms { // 短信
                    
                    let desc: String? = (self.shareTitle ?? "") + "\n" + (self.shareUrl ?? "")
                    YXShareManager.shared.shareToMessage(content: desc, sharingImage: nil, imageUrlString: "", shareResultBlock:{ [weak self] (success) in
                        guard let `self` = self else { return }
        
                        shareResultInfoBlock(type, success)
                        if let callBack = self.shareResultBlock  {
                            callBack(type, success)
                        }
                    })
                    
                } else {
                    
                    if type == .twitter {// twitter分享 是直接接口请求，添加一个加载提示
                        YXProgressHUD.showLoading("", in: self.superview)
                    }
                    
                    // 分享到facebook的链接用长链接
                    var curretShareUrl = shareUrl
                    if let longUrl = shareLongUrl, (type == .facebook || type == .telegram) {
                        curretShareUrl = longUrl
                    }

                    YXShareManager.shared.shareTextImage(to: type, text: shareText ?? (YXConstant.appName ?? ""), images: nil, url: URL(string: curretShareUrl ?? ""), title: shareTitle ?? (YXConstant.appName ?? ""), contentType: .auto) { [weak self] (platform, success) in
                        guard let `self` = self else { return }
                        if type == .twitter {
                            YXProgressHUD.hide(for: self.superview!, animated: false)
                        }
                        shareResultInfoBlock(type, success)
                        if let callBack = self.shareResultBlock  {
                            callBack(type, success)
                        }
                    }
                }
                

            } else {
                if let image = shareImage {
                    if type == .twitter {
                        YXProgressHUD.showLoading("", in: self.superview)
                    }
                    
                    YXShareManager.shared.shareImage(to: type, shareImage: image, shareResultBlock: { [weak self] (platform, result) in
                        guard let `self` = self else { return }
                        if type == .twitter {
                            YXProgressHUD.hide(for: self.superview!, animated: false)
                        }
                        shareResultInfoBlock(type, result)
                        
                        if let callBack = self.shareResultBlock  {
                            callBack(type, result)
                        }
                    })
                }
                
            }
        }
    }
}


//MARK: - 一行按钮组件

class YXShareBottomContentView: UIScrollView {

    let kShareButtonWidth: CGFloat = 68
    let kShareButtonHeight: CGFloat = 78

    // 是否显示盲盒活动的角标
    var showMysteryBoxBadge = false
    // 点击事件回调
    var shareSelectCallback: ((YXShareItemModel) -> Void)?

    var shareButtons: [UIButton] = [UIButton]()
    var shareItems:[YXShareItemModel]? {
        didSet{
            creatShareItme()
            layoutShareView()
        }
    }

    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    convenience init(items:[YXShareItemModel],clickCallBlack:((YXShareItemModel) -> Void)?) {
        self.init(frame:.zero)
        self.shareItems = items
        self.shareSelectCallback = clickCallBlack
        creatShareItme()
        layoutShareView()
    }

    func initUI() {
        backgroundColor = UIColor.clear
        showsHorizontalScrollIndicator = false

        addSubview(contentView)
        creatShareItme()
        layoutShareView()
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
    }
    
    func creatShareItme() {
        shareButtons.forEach { btn in
            btn.removeFromSuperview()
        }
        shareButtons.removeAll()

        if let itmesArray = self.shareItems {
            for subItem in itmesArray {
                shareButtons.append(shareButton(with: (subItem.shareImageName ?? "") as String, title:(subItem.shareName ?? "") as String, tag: subItem.shareTag))
            }
        }
    }

    func layoutShareView() {
        let buttonWidth: CGFloat = kShareButtonWidth
        let count: CGFloat = 4.5 // 一页显示4个半
        let spacing = (YXConstant.screenWidth - buttonWidth * count) / count
        let left = spacing / 2
        let right = spacing / 2
        var lastButton: UIButton?
        
        //标题一行显示
        for (i, button) in shareButtons.enumerated() {
            contentView.addSubview(button)
            button.snp.makeConstraints { (make) in
                make.top.equalTo(10)
                make.height.equalTo(kShareButtonHeight)
                make.width.equalTo(buttonWidth)

                if let lastBtn = lastButton {
                    make.left.equalTo(lastBtn.snp.right).offset(spacing)
                } else {
                    make.left.equalToSuperview().offset(left)
                }

                if i == shareButtons.count - 1 {
                    make.right.equalToSuperview().offset(-right)
                }
            }
            lastButton = button
            
            if isShowMysteryBoxBadge(tag: button.tag) {
                let badgeView = QMUIButton()
                badgeView.isHidden = true
                badgeView.tag = 7777 + button.tag
                badgeView.isUserInteractionEnabled = false

                let image = UIImage(named: "img_mystery_box_flag")!
                badgeView.setBackgroundImage(
                    image.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: image.size.width * 0.3, bottom: 0, right: image.size.width * 0.3)),
                    for: .normal
                )

                badgeView.setTitle(YXLanguageUtility.kLang(key: "mystery_box_flag"), for: .normal)
                badgeView.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
                badgeView.setTitleColor(.white, for: .normal)
                badgeView.titleLabel?.font = .systemFont(ofSize: 10, weight: .medium)
                contentView.addSubview(badgeView)

                badgeView.snp.makeConstraints { make in
                    make.top.equalTo(button.snp.top).offset(-3)
                    make.right.equalTo(button.snp.right)
                    make.height.equalTo(14)
                }
            }
        }
    }
    
    // 刷新盲盒
    func refreshBottomView() {
        for (_, button) in shareButtons.enumerated() {
            if let view = contentView.viewWithTag(7777 + button.tag) {
                if showMysteryBoxBadge {
                    view.isHidden = false
                } else {
                    view.isHidden = true
                }
            }
        }
    }
    
    func isShowMysteryBoxBadge(tag: Int) -> Bool{
        if let itmesArray = self.shareItems {
            for item in itmesArray {
                if item.shareTag ==  tag{
                    if item.sharePlatform == .twitter || item.sharePlatform == .facebook || item.sharePlatform == .instagram {
                        return true
                    }
                }
            }
        }
        return false
    }

    // 分享按钮
    func shareButton(with imageName: String,title :String, tag: Int) -> QMUIButton {
        let shareButton = QMUIButton()
        shareButton.setImage(UIImage(named: imageName), for: .normal)
        shareButton.tag = tag
        shareButton.addTarget(self, action: #selector(shareButtonAction(_:)), for: .touchUpInside)
        shareButton.setTitle(title, for: .normal)
        shareButton.imagePosition = .top
        shareButton.spacingBetweenImageAndTitle = 8
        shareButton.contentVerticalAlignment = .top
        shareButton.titleLabel?.numberOfLines = 2
        shareButton.titleLabel?.textAlignment = .center
        if YXThemeTool.isDarkMode() {
            shareButton.setTitleColor(UIColor.qmui_color(withHexString: "#D3D4E6"), for: .normal)
        } else {
            shareButton.setTitleColor(UIColor.qmui_color(withHexString: "#191919")?.withAlphaComponent(0.65), for: .normal)
        }
        shareButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        
        return shareButton
    }

    // MARK: 点击事件
    @objc func shareButtonAction(_ sender: UIButton) {
        if sender.tag > 0, let selectCallBack = self.shareSelectCallback {
            if let itemsArray = self.shareItems {
                
                for subItem in itemsArray {
                    if sender.tag == subItem.shareTag {
                        selectCallBack(subItem)
                        return
                    }
                }
            }
        }
    }
}
