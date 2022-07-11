//
//  YXShareCommonView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/6/24.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

//enum YXShareType {
//    case image
//    case url
//}

@objc class YXShareCommonView: UIView {
    
    var shareMethod:YXShareType = .image
    
    @objc var shareTitle: String? {
        didSet{
            self.bottomView.shareTitle = shareTitle
        }
    }
    @objc var shareText: String? {
        didSet {
            self.bottomView.shareText = shareText
        }
    }
    @objc var shareUrl: String? {
        didSet {
            self.bottomView.shareUrl = shareUrl
        }
    }
    
    @objc var isShowCommunity = false

    // fb分享需要长链接 因为短链fb解析不了就会报error
    @objc var shareLongUrl: String? {
        didSet {
            self.bottomView.shareLongUrl = shareLongUrl
        }
    }
    
    let kImageViewTopMargin: CGFloat = 44 + (YXConstant.deviceScaleEqualToXStyle() ? 20.0 : 0.0)
    
    func bottomContentHeight() -> CGFloat {
        return self.bottomView.currentContentHeight()
    }
    
    var shareImage: UIImage? {
        didSet {
            self.imageView.image = shareImage
            self.bottomView.shareImage = shareImage
            if self.imageView.superview != nil {

                let bottomContentH = bottomContentHeight()
                
                //底部分享视图
                let imageViewBottomMargin: CGFloat = 24 * self.scale
                let maxImageHeight = YXConstant.screenHeight - self.kImageViewTopMargin - imageViewBottomMargin - bottomContentH
                var imageWidth: CGFloat = self.imageViewWidth
                var imageHeight: CGFloat = self.imageViewHeight
                if let tempImageWidth = shareImage?.cgImage?.width, let tempImageHeight = shareImage?.cgImage?.height, let imageScale = shareImage?.scale {
                    //优先根据宽度布局
                    let originWidth = CGFloat(tempImageWidth) / imageScale
                    let originHeight = CGFloat(tempImageHeight) / imageScale
                    let height = imageWidth * originHeight / originWidth
                    if height > maxImageHeight {
                        imageHeight = maxImageHeight
                        //重新计算宽度
                        imageWidth = originWidth * imageHeight / originHeight
                    } else {
                        imageHeight = height
                    }
                }

                self.imageView.snp.updateConstraints { (make) in
                    make.width.equalTo(imageWidth)
                    make.height.equalTo(imageHeight)
                }


            }
        }
    }

    var contentView: UIView?
    var scale = YXConstant.screenWidth / 375.0
    var imageViewWidth: CGFloat = YXConstant.screenWidth * 0.85
    var imageViewHeight: CGFloat = 0

    func convertToImage() {

        self.contentView?.setNeedsDisplay()
        self.contentView?.layoutIfNeeded()
        if let shareView = self.contentView, let image = UIImage.qmui_image(with: shareView) {
            self.shareImage = image
        }
    }

    //MARK: Show Or Hide
    var modalVC: QMUIModalPresentationViewController? = nil
    @objc func showShareView() {

        if shareMethod == .image {
            convertToImage()
            if self.shareImage != nil {
                let modalViewController = QMUIModalPresentationViewController();
                //modalViewController.modal = YES;
                weak var weakView = self
                modalViewController.animationStyle = .slide
                modalViewController.contentViewMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                modalViewController.contentView = weakView;
                modalViewController.showWith(animated: true, completion: nil)
                self.modalVC = modalViewController
            }
        }else{
            showShareBottomView()
        }

    }

    @objc func hideShareView() {
        self.modalVC?.hideWith(animated: true, completion: nil)
    }
    
    @objc func showShareBottomView(){
        let modalViewController = QMUIModalPresentationViewController();
//        self.bgView.isHidden = true
        weak var weakView = self
        modalViewController.animationStyle = .fade
        modalViewController.contentViewMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        modalViewController.contentView = weakView;
        modalViewController.showWith(animated: true, completion: nil)
        self.modalVC = modalViewController
        blurview.isHidden = true
    }

    var blurview : UIVisualEffectView!
    //MARK: Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc convenience init(frame: CGRect,sharetype:YXShareType, isShowCommunity:Bool) {
        self.init(frame: frame)
        self.shareMethod = sharetype
        self.isShowCommunity = isShowCommunity
        self.creatShareItme()
    }

    
    func creatShareItme() {
        
        var thirdPlatforms:[YXSharePlatform] = [.facebook,.facebookMessenger,.whatsApp,.twitter]
        if self.shareMethod == .image {
            thirdPlatforms.append(.instagram)
        }
        if self.isShowCommunity {
            thirdPlatforms.append(.uSmartSocial)
        }
        thirdPlatforms.append(.telegram)
        thirdPlatforms.append(.line)
        var toolsPlatforms:[YXSharePlatform] = [.copy,.more]
        if self.shareMethod == .image {
            toolsPlatforms = [.save,.more]
        }
        
        self.bottomView.configure(shareType: self.shareMethod, toolTypes: toolsPlatforms, thirdTypes: thirdPlatforms, clickCallBlock: { [weak self] itemModel in
            
            guard let `self` = self else { return }
            self.shareClick(itemModel: itemModel)
        }, resultCallBlock: nil) {[weak self] in
            
            guard let `self` = self else { return }
            self.hideShareView()
        }

        self.bottomView.snp.updateConstraints { make in
            make.height.equalTo(self.bottomContentHeight())
        }
    }

    func initUI() {
        addSubview(bgView)
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        bgView.backgroundColor = QMUITheme().textColorLevel1().withAlphaComponent(0.1)

        let blurEffect = UIBlurEffect(style: .light)
        blurview = UIVisualEffectView(effect: blurEffect)
        blurview.alpha = 0.95
        self.addSubview(blurview!)
        blurview.snp.makeConstraints { (make) in
            make.left.top.bottom.right.equalToSuperview()
        }

        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.alpha = 0.95
        blurview.contentView.addSubview(vibrancyView)
        vibrancyView.snp.makeConstraints { (make) in
            make.left.top.bottom.right.equalToSuperview()
        }

        addSubview(cancelButton)
        cancelButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(self.kImageViewTopMargin)
            make.width.equalTo(0)
            make.height.equalTo(0)
        }

        addSubview(self.bottomView)
        
        self.bottomView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(self.bottomContentHeight())
            make.bottom.equalToSuperview()
        }
        
    }

    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = false
        return view
    }()

    lazy var bgView: UIView = {
        let view = UIView()
        return view
    }()

    lazy var cancelButton: UIControl = {
        let view = UIControl()
        view.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        return view
    }()
    
    lazy var bottomView: YXShareBottomAlertView = {
        let view = YXShareBottomAlertView()
        view.isDefaultShowMessage = true
        return view
    }()

    @objc func cancelButtonAction() {
        self.hideShareView()
    }
    
    @objc func shareClick(itemModel: YXShareItemModel) {
        
        if YXShareManager.isNeedHiddeModalPresent(itemModel.sharePlatform) {
            if let modalVC =  UIViewController.current() as? QMUIModalPresentationViewController {
                modalVC.hideWith(animated: false, completion: { finished in
                    self.shareEvent(itemModel)
                })
                return
            }
        }
        
        self.shareEvent(itemModel)
    }
    
    func shareEvent(_ itemModel: YXShareItemModel) {
        
        let shareResultBlock: (YXSharePlatform,Bool) -> Void = {(platform, success) in
            YXShareManager.showShareResultMessage(sharePlatform: platform, success: success)
        }
        
        if itemModel.shareTag > 0 {
            let type:YXSharePlatform  = itemModel.sharePlatform
            
            if type == .more || (type == .telegram && self.shareMethod == .image) { //telegram 图片分享暂时用more功能
                
                if shareMethod == .link {
                    guard let url = shareUrl else { return }
                    let urll = "\(shareText ?? "") " + "\(shareTitle ?? "" ) " + url
                    YXShareManager.shared.shareToMore(activityItems: [urll]) { platform, result in
                        if result == true {
                            shareResultBlock(.more,true)

                        }
                    }
                    
                }else {
                    
                    guard let img = shareImage else { return }
                    YXShareManager.shared.shareToMore(activityItems: [img]) { platform, result in
                        if result == true {
                            shareResultBlock(.more,true)
                        }
                    }
                    
                }
                
                return
            }
            
            
            // 图片 保存，社区
            if let image = self.shareImage {
                
                if type == .save {
                    trackViewClickEvent(customPageName: "P&L Amount", name: "Save Picture")

                    YXToolUtility.saveImage(toAlbum: image) { (res) in
                        shareResultBlock(type,res)
                        self.hideShareView()
                    }
                    return
                    
                } else if type == .uSmartSocial {
                    trackViewClickEvent(customPageName: "P&L Amount", name: "uSMART Community")

                    YXShareManager.shareToUsmartCommunity(self.shareImage)

                    return
                }
            }

            
            
            if self.shareMethod == .link {
                if type == .copy {
            
                    if let url = shareUrl {
                        let pab = UIPasteboard.general
                        pab.string = "\(shareText ?? "") " + "\(shareTitle ?? "" ) " + url
                    }
                    shareResultBlock(type,true)
                    self.hideShareView()

                } else if type == .wxMiniProgram {
                    
//                    if let pageURL = URL(string: self.shortUrl), YXShareSDKHelper.isClientIntalled(.typeWechat) {
//                        YXShareSDKHelper.shareInstance()?.shareMiniProgram(by: .typeWechat, title: self.title, description: self.desc, webpageUrl: pageURL, path: config.wxPath, thumbImage: images, hdThumbImage: images, userName: config.wxUserName, withShareTicket: config.withShareTicket, miniProgramType: config.miniProgramType, forPlatformSubType: .subTypeWechatSession, callback: { (success, userInfo, _) in
//                            shareResultBlock?(platform, success)
//                        })
//                    }
                    
                } else if type == .sms {
                    let desc: String? = (self.shareTitle ?? "") + "\n" + (self.shareUrl ?? "")
                    
                    YXShareManager.shared.shareToMessage(content: desc, sharingImage: nil, imageUrlString: "", shareResultBlock:{ [weak self] (success) in
                        guard let `self` = self else { return }
                        shareResultBlock(type,success)

                        self.hideShareView()
                    })
                } else {
                    
                    // 分享到facebook的链接用长链接
                    var currentShareUrl = shareUrl
                    if let longUrl = self.shareLongUrl, (type == .facebook || type == .telegram) {
                        currentShareUrl = longUrl
                    }
                    
                    if type == .twitter {
                        YXProgressHUD.showLoading("", in: self.superview)
                    }
                    
                    YXShareManager.shared.shareTextImage(to: type, text: (shareText ?? (YXConstant.appName ?? "") + "\n"), images: nil, url: URL(string: currentShareUrl ?? ""), title: shareTitle ?? (YXConstant.appName ?? ""), contentType: .auto) { [weak self] (platform, result) in
                        guard let `self` = self else { return }
                        if type == .twitter {
                            YXProgressHUD.hide(for: self.superview!, animated: false)
                        }
                        shareResultBlock(type, result)
                        self.hideShareView()
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
                        shareResultBlock(type, result)
                        self.hideShareView()
                    })
                }
                
            }

        }
    }

}
