//
//  YXCommentImagesView.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/9.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXCommentImagesView: UIView {
    typealias TapImageBlock = (_ index: Int) -> Void
    var tapImageBlock: TapImageBlock?
    var imageViewArray: [YXCommentImageItemView] = []
    var imageUrls: [String] = []
    
    var isCommentPic: Bool = false

    lazy var imageBGView: UIView = {
        let gridview = UIView()
        gridview.layer.masksToBounds = true
        return gridview
    }()
    
    
    lazy var countLabel: QMUILabel = {
       let label = QMUILabel()
        label.textColor = QMUITheme().foregroundColor()
        label.font = UIFont.systemFont(ofSize: 28)
        label.textAlignment = .center
        label.backgroundColor = QMUITheme().shadeLayerColor()
        label.layer.cornerRadius = 3
        label.layer.masksToBounds = true
        label.isHidden = true
        return label
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        addSubview(imageBGView)
        
        imageBGView.snp.makeConstraints { make  in
            make.edges.equalToSuperview()
        }
        
        let unitWith: CGFloat = (YXConstant.screenWidth - 24 - 10) / 3
        
        for i in 0..<9 {
            let imageView = YXCommentImageItemView()
            imageView.tag = 3000 + i
            imageView.isHidden = true
            imageView.layer.cornerRadius = 4
            imageView.layer.masksToBounds = true
            imageView.isUserInteractionEnabled = true
         
            imageBGView.addSubview(imageView)
            imageViewArray.append(imageView)
            let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tapAction(_:)))
            imageView.addGestureRecognizer(tapGesture)
            
            imageView.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.left.equalToSuperview().offset(i * (Int(unitWith) + 5))
                make.height.equalTo(0)
                make.width.equalTo(0)
            }
        }

        imageBGView.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().offset(-8)
            make.width.equalTo(36)
            make.height.equalTo(22)
        }
        self.bringSubviewToFront(countLabel)
    }

    //新方法 dic 里有显示视频icon 时长等
    func updatePictureFromeSinglePicSize(pictures: [String], picSize: CGSize, dict:[String:String]) {
        if picSize.height <= 0 || pictures.count == 0 {
            self.countLabel.isHidden = true
            return
        }
        for (index, item) in imageViewArray.enumerated() {
            item.imageView.image = nil
            if index < 3 {
                item.isHidden = false
                
//                //内容类型 1=要闻资讯 2=图文 3=直播 4=回放 5=个股讨论
//                let content_type:String = dict["content_type"] ?? "0"
                
                if pictures.count == 1 {
                    self.countLabel.isHidden = true
                    let singPicWidth:CGFloat = picSize.width > 0 ? picSize.width : ( picSize.height * 1.33 )
                    item.snp.remakeConstraints{ make in
                        make.top.left.equalToSuperview()
                        make.width.equalTo(singPicWidth)
                        make.bottom.equalToSuperview()
                    }
                    
                    let picString:String = YXUGCCommentManager.changeThumbUrl(picUrl: pictures.first ?? "", size: CGSize.init(width: singPicWidth, height: picSize.height))
                    var placeholderName = "banner_placeholder"
                    if picSize.width > 0 {
                        if picSize.height > picSize.width {
                            placeholderName = "banner_placeholder_v"
                        }
                    }
                    item.imageView.sd_setImage(with: URL.init(string: picString), placeholderImage: UIImage(named: placeholderName), options: .retryFailed) {  image, err, cacheType, url in
                        if let image = image {
                            let imageWidth:CGFloat = self.getImageWidthFromImage(image: image, height: picSize.height)
                            if picSize.width <= 0 {
                                item.snp.updateConstraints{ make in
                                    make.width.equalTo(imageWidth)
                                }
                            }
                        }
                    }
                }else{
                    if pictures.count > 3 {
                        self.countLabel.isHidden = false
                        let numCount:Int = pictures.count - 3
                        self.countLabel.text = String(format: "+%d", numCount)
                    }else{
                        self.countLabel.isHidden = true
                    }
                    if index < pictures.count {
                        let picStr:String = pictures[index]

                        let boundsWith: CGFloat = (YXConstant.screenWidth - 64 - 16)
                        let unitWidth:CGFloat = (boundsWith - 10) / 3
                        let picString:String = YXUGCCommentManager.changeThumbUrl(picUrl: picStr, size: CGSize.init(width: unitWidth, height: picSize.height))
                        item.imageView.sd_setImage(with: URL.init(string:picString), placeholderImage:  UIImage.init(named: "banner_placeholder_s"), options: .retryFailed, completed: nil)
                        
                        item.snp.remakeConstraints{ make in
                            make.top.equalToSuperview()
                            make.left.equalToSuperview().offset((Int(unitWidth) + 5) * index)
                            make.width.equalTo(unitWidth)
                            make.bottom.equalToSuperview()
                        }
                        if index == 2 {
                            self.countLabel.snp.remakeConstraints { make in
                                make.edges.equalTo(item)
                            }
                        }
                    }
               
                }
                item.modelDic = dict
            }else{
                item.isHidden = true
            }
        }
    }
    
    //先创建 布局不超过3个时,多于的显示剩余label
    func updatePicture(pictures: [String], height: CGFloat, singlePicSize:CGSize) {
     
        if height <= 0 || pictures.count == 0 {
            self.countLabel.isHidden = true
            return
        }
        for (index, item) in imageViewArray.enumerated() {
            item.imageView.image = nil
            if index < 3 {
                item.isHidden = false
                if pictures.count == 1 {
                    self.countLabel.isHidden = true
                    let singPicWidth:CGFloat = singlePicSize.width > 0 ? singlePicSize.width : singlePicSize.height * 1.33
                    item.snp.remakeConstraints{ make in
                        make.top.left.equalToSuperview()
                        make.width.equalTo(singPicWidth)
                        make.bottom.equalToSuperview()
                    }
                    let picString:String = YXUGCCommentManager.changeThumbUrl(picUrl: pictures.first ?? "", size: CGSize.init(width: singPicWidth, height: height))
                    item.imageView.sd_setImage(with: URL.init(string: picString), placeholderImage: UIImage(named: "pop_placeholder"), options: .retryFailed) {  image, err, cacheType, url in
                        if let image = image {
                            let imageWidth:CGFloat = self.getImageWidthFromImage(image: image, height: singlePicSize.height)
                            if singlePicSize.width <= 0 {
                                item.snp.updateConstraints{ make in
                                    make.width.equalTo(imageWidth)
                                }
                            }
                           
                        }
                    }
                   
                }else{
                    if pictures.count > 3 {
                        self.countLabel.isHidden = false
                        let numCount:Int = pictures.count - 3
                        self.countLabel.text = String(format: "+%d", numCount)
                    }else{
                        self.countLabel.isHidden = true
                    }
                    if index < pictures.count {
                        let picStr:String = pictures[index]

                        let boundsWith: CGFloat = YXConstant.screenWidth - 24
                        let unitWidth:CGFloat = (boundsWith - 10) / 3
                        
                        let picString:String = YXUGCCommentManager.changeThumbUrl(picUrl: picStr, size: CGSize.init(width: unitWidth, height: height))
                        item.imageView.sd_setImage(with: URL.init(string:picString), placeholderImage:  UIImage.init(named: "banner_placeholder"), options: .retryFailed, completed: nil)
                        item.snp.remakeConstraints{ make in
                            make.top.equalToSuperview()
                            make.left.equalToSuperview().offset((Int(unitWidth) + 5) * index)
                            make.width.equalTo(unitWidth)
                            make.bottom.equalToSuperview()
                        }
                    }
               
                }
            }else{
                item.isHidden = true
            }
        }
    }
    
    //9宫格
    func updatePictureNineShow(pictures: [String], height: CGFloat, singlePicSize:CGSize) {
        self.countLabel.isHidden = true
        if height <= 0 || pictures.count == 0 {
            return
        }
        for (index, item) in imageViewArray.enumerated() {
            item.imageView.image = nil
            if index <= pictures.count - 1 {
                item.isHidden = false
                if pictures.count == 1 {
                    let singPicWidth:CGFloat = singlePicSize.width > 0 ? singlePicSize.width : singlePicSize.height * 1.33
                    item.snp.remakeConstraints{ make in
                        make.top.left.equalToSuperview()
                        make.width.equalTo(singPicWidth)
                        make.bottom.equalToSuperview()
                    }
                    let picString:String = YXUGCCommentManager.changeThumbUrl(picUrl: pictures.first ?? "", size: CGSize.init(width: singPicWidth, height: singlePicSize.height))
                    item.imageView.sd_setImage(with: URL.init(string: picString), placeholderImage: UIImage(named: "banner_placeholder"), options: .retryFailed) {  image, err, cacheType, url in
                        if let image = image {
                            let imageWidth:CGFloat = self.getImageWidthFromImage(image: image, height: singlePicSize.height)
                            if singlePicSize.width <= 0 {
                                item.snp.updateConstraints{ make in
                                    make.width.equalTo(imageWidth)
                                }
                            }
                        }
                    }
                }else{
                    let unitWidth:CGFloat = (YXConstant.screenWidth - 24 - 10) / 3.0
                    let currentRow = index / 3
                    let currentColumn = index % 3
                    
                    if currentRow == 0   {
                        item.snp.remakeConstraints { make in
                            make.top.equalToSuperview()
                            make.left.equalTo((Int(unitWidth) + 5) *  currentColumn )
                            make.width.equalTo(unitWidth)
                            make.height.equalTo(115)
                        }
                    }else if currentRow == 1 {
                        item.snp.remakeConstraints { make in
                            make.top.equalToSuperview().offset(120)
                            make.left.equalTo(( Int(unitWidth) + 5) * currentColumn)
                            make.width.equalTo(unitWidth)
                            make.height.equalTo(115)
                        }
                    }else{
                        item.snp.remakeConstraints { make in
                            make.top.equalToSuperview().offset(240)
                            make.left.equalTo(( Int(unitWidth) + 5) * currentColumn)
                            make.width.equalTo(unitWidth)
                            make.height.equalTo(115)
                        }
                    }
                    let picurlString:String = pictures[index]
                    let picString:String = YXUGCCommentManager.changeThumbUrl(picUrl:picurlString , size: CGSize.init(width: unitWidth, height: 115))
                    item.imageView.sd_setImage(with: URL.init(string:picString), placeholderImage:  UIImage.init(named: "banner_placeholder"), options: .retryFailed, completed: nil)
                }
            }else{
                item.isHidden = true
            }
        }
    }
    
    // (关注界面)
    func updatePictureFromSeedType(pictures: [String], height: CGFloat, picSize:CGSize, dict:[String:String]) {
     
        if height <= 0 || pictures.count == 0 {
            self.countLabel.isHidden = true
            return
        }
        for (index, item) in imageViewArray.enumerated() {
            item.imageView.image = nil
            if index < 3 {
                item.isHidden = false
                //内容类型 1=要闻资讯 2=图文 3=直播 4=回放 5=个股讨论
                let content_type:String = dict["content_type"] ?? "0"
                if pictures.count == 1 {
                    self.countLabel.isHidden = true
                    
                    if Int(content_type) == 3 || Int(content_type) == 4 || Int(content_type) == 7 {
                        
                        item.snp.remakeConstraints { make in
                            make.edges.equalToSuperview()
                        }
                        let picString:String = YXUGCCommentManager.changeThumbUrl(picUrl: pictures.first ?? "", size: picSize)
                        item.imageView.sd_setImage(with: URL.init(string:picString), placeholderImage:  UIImage.init(named: "banner_placeholder"), options: .retryFailed, completed: nil)
                    }else{
                        
                        let singPicWidth:CGFloat = picSize.width > 0 ? picSize.width : picSize.height * 1.33
                        item.snp.remakeConstraints{ make in
                            make.top.left.equalToSuperview()
                            make.width.equalTo(singPicWidth)
                            make.bottom.equalToSuperview()
                        }
                        let picString:String = YXUGCCommentManager.changeThumbUrl(picUrl: pictures.first ?? "", size: picSize)
                        item.imageView.sd_setImage(with: URL.init(string: picString), placeholderImage: UIImage(named: "banner_placeholder"), options: .retryFailed) {  image, err, cacheType, url in
                            if let image = image{
                               
                                let imageWidth:CGFloat = self.getImageWidthFromImage(image: image, height: picSize.height)
                                
                                if picSize.width <= 0 {
                                    item.snp.updateConstraints{ make in
                                        make.width.equalTo(imageWidth)
                                    }
                                }
                               
                            }
                        }
                    }
                    
                    item.modelDic = dict
                }else{
                    if Int(content_type) == 5 {
                        if pictures.count > 3 {
                            self.countLabel.isHidden = false
                            let numCount:Int = pictures.count - 3
                            self.countLabel.text = String(format: "+%d", numCount)
                        }else{
                            self.countLabel.isHidden = true
                        }
                        if index < pictures.count {
                            let picStr:String = pictures[index]
                            
                            let boundsWith: CGFloat = YXConstant.screenWidth - 24
                            let unitWidth:CGFloat = (boundsWith - 10) / 3
                            
                            let picString:String = YXUGCCommentManager.changeThumbUrl(picUrl: picStr, size: CGSize.init(width: unitWidth, height: picSize.height))
                            item.imageView.sd_setImage(with: URL.init(string:picString), placeholderImage:  UIImage.init(named: "banner_placeholder"), options: .retryFailed, completed: nil)

                            item.snp.remakeConstraints{ make in
                                make.top.equalToSuperview()
                                make.left.equalToSuperview().offset((Int(unitWidth) + 5) * index)
                                make.width.equalTo(unitWidth)
                                make.bottom.equalToSuperview()
                            }
                        }
                    }
                    item.modelDic = dict
                }
            }else{
                item.isHidden = true
            }
        }
    }
    
    private func getImageWidthFromImage(image:UIImage?, height:CGFloat) -> CGFloat {
        var imageWidth:CGFloat = 0
        guard let image = image else {
            return imageWidth
        }
       
        let imageRatio:CGFloat = image.size.width  / image.size.height
        
        if imageRatio >= 1 {
            imageWidth = height * 1.33
        }else{
            imageWidth = height * 0.75
        }
        
        return imageWidth
    }
    
    @objc func tapAction(_ sender: UITapGestureRecognizer) {
       
        if let tag = sender.view?.tag {
            let index:Int = tag - 3000
            tapImageBlock?(index)
        }
       
    }
}
