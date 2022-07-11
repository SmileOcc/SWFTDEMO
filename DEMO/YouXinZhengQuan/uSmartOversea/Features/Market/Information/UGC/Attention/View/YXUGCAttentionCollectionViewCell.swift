//
//  YXUGCAttentionCollectionViewCell.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/31.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXUGCAttentionCollectionViewCell: UICollectionViewCell {
    typealias ClickActionBlock = ( _ paramDic:[String:String]?, _ type:CommentButtonType) -> Void
    var toolBarButtonBlock:ClickActionBlock?
    
    var tapImageBlock:((_ index: Int) -> Void)?
  
    var jumpToBlock:((_ dict:[String:String]) -> Void)?

    var model:YXUGCFeedAttentionModel?
    
    var postId:String = ""
    var postType:String = ""
        
    lazy var gotoUserCenterBtn:QMUIButton = {
        let btn = QMUIButton()
        btn.addTarget(self, action: #selector(gotoUserCenterAction(_ :)), for: .touchUpInside)
        
        return btn
    }()
    
    lazy var popover: YXStockPopover = {
        let pop = YXStockPopover.init()

        return pop
    }()
    
  
    lazy var phoneImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 17
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var levelImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage.init(named: "da_V")
        imageView.isHidden = true
        return imageView
    }()
    
    lazy var nickNameLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    lazy var proImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
//    lazy var detailButton: YXExpandAreaButton = {
//        let btn = YXExpandAreaButton()
//        btn.expandX = 20
//        btn.expandY = 20
//        btn.setBackgroundImage(UIImage(named:"ygc_more"), for: .normal)
//        btn.contentHorizontalAlignment = .right
//        btn.addTarget(self, action: #selector(detailAction(_:)), for: .touchUpInside)
//
//        return btn
//    }()
    
    lazy var timeLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()

    /// 付费订阅标识
    private lazy var subscribedTagView: YXGradientButton = {
        let view = YXGradientButton(type: .custom)
        view.spacingBetweenImageAndTitle = 3
        view.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        view.setTitleColor(UIColor.qmui_color(withHexString: "#A7701E"), for: .normal)
        view.setTitle(YXLanguageUtility.kLang(key: "for_vip"), for: .normal)
        view.setImage(UIImage(named: "icon_diamond"), for: .normal)
        view.isUserInteractionEnabled = false
        view.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)

        if let layer = view.layer as? CAGradientLayer {
            layer.cornerRadius = 1
            layer.masksToBounds = true
            layer.colors = [UIColor(red: 0.98, green: 0.85, blue: 0.59, alpha: 1).cgColor,
                             UIColor(red: 0.99, green: 0.92, blue: 0.77, alpha: 1).cgColor]
            layer.locations = [0, 1]
            layer.startPoint = CGPoint(x: 0.97, y: 1)
            layer.endPoint = CGPoint(x: 0.09, y: 0.09)
        }

        return view
    }()
    
    lazy var commentLabel: YYLabel = {
        let label = YYLabel()
        
        label.highlightTapAction = { (containerView, text, range ,rect) in
            let string = (text.string as NSString).substring(with: range)
            YXStockDetailViewModel.pushSafty(paramDic: ["dataSource": [string.reportStock], "selectIndex": 0])
        }
        
        return label
    }()
    
    lazy var subCommentLabel: YYLabel = {
        let label = YYLabel()
        
        label.highlightTapAction = { (containerView, text, range ,rect) in
            let string = (text.string as NSString).substring(with: range)
            YXStockDetailViewModel.pushSafty(paramDic: ["dataSource": [string.reportStock], "selectIndex": 0])
        }
        
        return label
    }()
    
    
    lazy var imageBGView:YXCommentImagesView = {
        let view = YXCommentImagesView()
        view.tapImageBlock = { [weak self] index in
            guard let `self` = self else { return }
            var picture:[String] = []
            if let arr = self.model?.cover_images {
                for (index, item) in arr.enumerated() {
                    picture.append(item.cover_images )
                }
            }
           
            var canShowImage:Bool = true
            if let contenType = self.model?.content_type {
                if contenType == .live || contenType == .chatRoom {
                   canShowImage = false
                }else if contenType == .replay{
                    canShowImage = false
                }else{
                    if let videoUrl = self.model?.video?.url, videoUrl.count > 0 {
                        canShowImage = false
                    }
                }
            }
            if picture.count > 0  && canShowImage {
                XLPhotoBrowser.show(withImages: picture, currentImageIndex: index)
            }else{
                if let model = self.model {
                    let paraDict:[String:String] = ["show_time":model.show_time, "cid":model.cid]
                    self.jumpToBlock?(paraDict)
                }
            }
        }
        return view
    }()

    lazy var stockButton: QMUIButton = {
        let btn = QMUIButton()
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.isHidden = true
        btn.addTarget(self, action: #selector(stockAction(_ :)), for: .touchUpInside)
       
        return btn
    }()
    
    lazy var tagButton: YXExpandAreaButton = {
        let btn = YXExpandAreaButton()
        btn.expandX = 10
        btn.expandY = 10
        btn.layer.cornerRadius = 1
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.qmui_color(withHexString: "#ff7127")?.cgColor
        btn.setTitleColor(UIColor.qmui_color(withHexString: "#ff7127"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.addTarget(self, action: #selector(tagAction(_:)), for: .touchUpInside)
        btn.isHidden = true
        
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupUI() {
        contentView.backgroundColor = QMUITheme().foregroundColor()
        backgroundColor = QMUITheme().foregroundColor()
        contentView.addSubview(phoneImageView)
        contentView.addSubview(levelImageView)
        contentView.addSubview(nickNameLabel)
        contentView.addSubview(proImageView)
        contentView.addSubview(timeLabel)

        contentView.addSubview(subscribedTagView)

        contentView.addSubview(commentLabel)
        contentView.addSubview(subCommentLabel)
        contentView.addSubview(gotoUserCenterBtn)
        
//        contentView.addSubview(detailButton)
        contentView.addSubview(imageBGView)
        contentView.addSubview(stockButton)
        contentView.addSubview(tagButton)
      
//        contentView.addSubview(detailButton)
        
        phoneImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(22)
            make.left.equalToSuperview().offset(12)
            make.width.height.equalTo(34)
        }
        levelImageView.snp.makeConstraints { (make) in
            make.bottom.equalTo(phoneImageView.snp.bottom)
            make.right.equalTo(phoneImageView.snp.right)
            make.width.height.equalTo(12)
        }
        nickNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(phoneImageView.snp.top)
            make.left.equalTo(phoneImageView.snp.right).offset(8)
            make.right.equalTo(proImageView.snp.left).offset(-8)
        }
        proImageView.snp.makeConstraints { (make) in
            make.right.lessThanOrEqualToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(13)
            make.centerY.equalTo(nickNameLabel)
        }
        timeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nickNameLabel.snp.left)
            make.top.equalTo(nickNameLabel.snp.bottom).offset(2)
        }
//        detailButton.snp.makeConstraints { (make) in
//            make.right.equalToSuperview().offset(-10)
//            make.centerY.equalTo(phoneImageView.snp.centerY)
//            make.width.height.equalTo(15)
//        }

        subscribedTagView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.top.equalTo(phoneImageView.snp.bottom).offset(12)
            make.height.equalTo(16)
        }

        commentLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.top.equalTo(phoneImageView.snp.bottom).offset(12)
            make.height.equalTo(0)
        }
        
        subCommentLabel.snp.makeConstraints { make in
            make.top.equalTo(commentLabel.snp.bottom).offset(5)
            make.height.equalTo(0)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
        }
        
        imageBGView.snp.makeConstraints { (make) in
            make.top.equalTo(subCommentLabel.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(0)
        }
        
        stockButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.height.equalTo(20)
            make.bottom.equalToSuperview().offset(-10)
        }
        tagButton.snp.makeConstraints { make in
            make.left.equalTo(stockButton.snp.right).offset(5)
            make.height.equalTo(20)
            make.right.lessThanOrEqualToSuperview().offset(-12)
            make.centerY.equalTo(stockButton)
        }
        
        gotoUserCenterBtn.snp.makeConstraints { make in
            make.left.top.equalTo(phoneImageView)
            make.height.equalTo(phoneImageView)
            make.right.equalTo(nickNameLabel)
      
        }
        
    }
    
    @objc func detailAction(_ sender: YXExpandAreaButton) {
        
        YXToolUtility.handleBusinessWithLogin {
            [weak self] in
            guard let `self` = self else { return }
            
            if let model = self.model, let uid = model.creator_info?.uid {
                let userIdDouble: Double = Double(uid) ?? 99
                var popList: [Int] = []
                if model.content_type == .stockdiscuss { //个股讨论
                    if  YXUserManager.userUUID() == UInt64(userIdDouble) { //是本人
                        popList = [CommentButtonType.delete.rawValue, CommentButtonType.share.rawValue]
                    }else{
                        popList = [CommentButtonType.report.rawValue, CommentButtonType.share.rawValue]
                    }
                }else{
                    popList = [ CommentButtonType.share.rawValue]
                }
               
                let view:YXCommentDetailPopView = YXCommentDetailPopView.init(list: popList, isWhiteStyle: true) {
                    [weak self] type in
                    guard let `self` = self else { return }
                    
                    if let model = self.model {
                        let content:String = YXToolUtility.reverseTransformHtmlString(model.content) ?? ""
                        let paramDic:[String:String] = ["post_id":model.cid, "post_type":self.postType, "share_content":content]
                        
                        self.toolBarButtonBlock?(paramDic , CommentButtonType(rawValue: type) ?? CommentButtonType.report)

                    }
                    self.popover.dismiss()
                }
                self.popover.show(view, from: sender)
            }
        }
        
    }
    
    
    func updateUI(model: YXUGCFeedAttentionModel?, commentCount:UInt64) {
        if let model = model {
            self.model = model
            
            self.phoneImageView.sd_setImage(with: URL.init(string: model.creator_info?.avatar ?? ""), placeholderImage: UIImage.init(named: "nav_user_WhiteSkin"), options: [], context: [:])
            self.nickNameLabel.text = model.creator_info?.nickName ?? ""
//            if let user = model.creator_info {
//                self.proImageView.isHidden = false
//                if user.pro == 1 { //Pro账户取值：1：普通账户  2：Pro2账户   4：Pro1账户    5：Pro3账户
//                    self.proImageView.isHidden = true
//                }else if user.pro == 2 {
//                    self.proImageView.image = UIImage.init(named: String(format: "VIP2"))
//                }else if user.pro == 4 {
//                    self.proImageView.image = UIImage.init(named: String(format: "VIP1"))
//                }else if user.pro == 5 {
//                    self.proImageView.image = UIImage.init(named: String(format: "VIP3"))
//                }else{
//                    self.proImageView.isHidden = true
//                }
//                self.levelImageView.isHidden = !user.auth_user
//            }else{
//                self.levelImageView.isHidden = true
//                self.proImageView.isHidden = true
//            }
            if let user = model.creator_info {
                self.levelImageView.isHidden = !user.auth_user
            }else{
                self.levelImageView.isHidden = true
            }
            self.timeLabel.text = YXToolUtility.compareCurrentTime(model.show_time)

            subscribedTagView.isHidden = !model.pay_type
            
            if let layout = model.layout {
                
                self.commentLabel.textLayout = layout.contentlayout
                commentLabel.snp.updateConstraints { make in
                    var offset = 12
                    if !subscribedTagView.isHidden {
                        offset += 26
                    }
                    make.top.equalTo(phoneImageView.snp.bottom).offset(offset)
                    make.height.equalTo(8 + (layout.contentlayout?.textBoundingRect.maxY ?? 0))
                }
                
                self.subCommentLabel.textLayout = layout.subContentLayout
                let noHtmlTitle:String =  YXToolUtility.reverseTransformHtmlString(model.title) ?? ""
                var subCommentTopMas:CGFloat = noHtmlTitle.count == 0 ? 0 : 5
                let noHtmlContent:String =  YXToolUtility.reverseTransformHtmlString(model.content) ?? ""
                let subCommentHeightMas:CGFloat = noHtmlContent.count == 0 ? 0 : 8
                subCommentLabel.snp.updateConstraints { make in
                    make.top.equalTo(commentLabel.snp.bottom).offset(subCommentTopMas)
                    make.height.equalTo(subCommentHeightMas + (layout.subContentLayout?.textBoundingRect.maxY ?? 0))
                }
                subCommentTopMas = model.content.count == 0 ? 0 : 5
                imageBGView.snp.updateConstraints { make in
                    make.top.equalTo(subCommentLabel.snp.bottom).offset(subCommentTopMas)
                    make.height.equalTo(layout.imageHeight)
                }
                var picture:[String] = []
                if model.content_type == .stockdiscuss  { //个股讨论 有多张图
                    for (_, item) in model.cover_images.enumerated() {
                        picture.append(item.cover_images)
                    }
                }else{
                    picture.append(model.cover_images.first?.cover_images ?? "")
                }
                let dict = [
                    "content_type":String(model.content_type.rawValue),
                    "duration":model.video?.duration ?? "",
                    "videoUrl":model.video?.url ?? "",
                    "chatRoomStatus": String(model.text_live_info?.status.rawValue ?? 0),
                    "hot_degree": String(model.text_live_info?.hot_degree ?? 0)
                ]
                imageBGView.updatePictureFromSeedType(pictures: picture, height: layout.imageHeight, picSize: layout.singleImageSize, dict: dict)
            }
            if let stockInfo = model.stock_info, stockInfo.symbol.count > 0 {
                self.stockButton.isHidden = false
                
                var textcolor:UIColor = .clear
                
                var exchangeOp = ""
                if stockInfo.pctchng > 0 {
                    exchangeOp = "+"
                    textcolor = QMUITheme().stockRedColor()
                }else if stockInfo.pctchng < 0 {
                    textcolor = QMUITheme().stockGreenColor()
                }else{
                    textcolor = QMUITheme().stockGrayColor()
                }
        
                let titleString:String = String(format: " %@  %@%.2f%% ", stockInfo.name , exchangeOp,  Double(stockInfo.pctchng)/100.0)
                
                stockButton.setTitleColor(textcolor, for: .normal)
                stockButton.backgroundColor = textcolor.withAlphaComponent(0.04)
                stockButton.setTitle(titleString, for: .normal)
                
                if model.feed_tag.count > 0 {
                    self.tagButton.isHidden = false
                    let tagString:String = String(format: " %@ ", model.feed_tag)
                    self.tagButton.setTitle(tagString, for: .normal)
                }else{
                    self.tagButton.isHidden = true
                }
                
            }else{
                self.stockButton.isHidden = true
                self.tagButton.isHidden = true
            }
            
            
        } else {
            subscribedTagView.isHidden = true
        }
    }
    
    
    @objc func shareAction(_ sender: QMUIButton) {
        if let model = model {
            let postTypeString:String = String(model.content_type.rawValue )
            let content:String = YXToolUtility.reverseTransformHtmlString(model.content) ?? ""
            let dic:[String:String] = [
                "post_id":model.cid,
                "post_type":postTypeString,
                "share_content":content
            ]
            toolBarButtonBlock?(dic , .share)
        }
    }
    
    @objc func commentAction(_ sender: QMUIButton) {
        if let model = model {
            let postTypeString:String = String(model.content_type.rawValue )
            let dic:[String:String] = ["post_id":model.cid, "post_type":postTypeString]
            toolBarButtonBlock?(dic, .comment)
        }
    }
    
    @objc func tagAction(_ sender:YXExpandAreaButton) {
        
    }
    
    @objc func headClick() {
        if let model = model {
            let paraDict:[String:String] = ["show_time":model.show_time, "cid":model.cid]
            self.jumpToBlock?(paraDict)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        headClick()
    }
    
    @objc func gotoUserCenterAction(_ sender: QMUIButton) {
        if model != nil {
            YXToolUtility.handleBusinessWithLogin { [weak self] in
                guard let `self` = self else { return }
                
                if let model = self.model {
                    YXUGCCommentManager.gotoUserCenter(uid: model.creator_info?.uid ?? "")
                }
            }
        }
  
    }
    
    @objc func stockAction(_ sender: Any) {
        let input:YXStockInputModel = YXStockInputModel()
        if let stockInfo = model?.stock_info {
            input.market = stockInfo.market
            input.symbol = stockInfo.symbol
            input.name = stockInfo.name
            YXStockDetailViewModel.pushSafty(paramDic: ["dataSource": [ input ], "selectIndex": 0])
        }
       
    }
    
}

private class YXGradientButton: QMUIButton {
    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
