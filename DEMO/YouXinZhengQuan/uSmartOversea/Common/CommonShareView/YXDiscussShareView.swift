//
//  YXDiscussShareView.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2021/9/3.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXDiscussShareView: UIView {
    
    @objc class func showShareView(model: YXSquareStockPostListModel) {

        loadPicture(model.pictures.first) { picture in
            let shareView = YXDiscussShareView()
            shareView.updateUI(model: model, shareImage: picture)
            shareView.layoutIfNeeded()
            let image = UIImage.qmui_image(with: CGSize(width: shareView.frame.width, height: shareView.frame.height), opaque: false, scale: 0) { (contextRef) in
                shareView.layer.render(in: contextRef)
            }
            let config = YXShareImageType.discuss.config
            config.isDefaultShowMessage = true
            YXShareManager.shared.showImage(config, shareImage: image)
        }
    }
    
    class func loadPicture(_ url: String?, resultBlock:((_ shareImage: UIImage?) -> Void)?) {
        if let picurl = url, !picurl.isEmpty {
            let hud = YXProgressHUD.showLoading("")
            SDWebImageManager.shared.loadImage(with: URL(string: picurl), options: .retryFailed, progress: nil) { image, data, error, cacheType, finished, imageURL in
                hud.hide(animated: true)
                resultBlock?(image)
            }
        } else {
            resultBlock?(nil)
        }
    }
    
    lazy var userView:YXCommentUserView = {
        let view = YXCommentUserView(frame: .zero, hadRightBtn: false)
        return view
    }()
    

    lazy var commentLabel: YYLabel = {
        let label = YYLabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.numberOfLines = 0
    
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()

        return view
    }()

    lazy var moreLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 12)
//        label.text = YXLanguageUtility.kLang(key: "see_more_discuss")
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.textAlignment = .center
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
        self.backgroundColor = QMUITheme().foregroundColor()
        
        addSubview(userView)
        addSubview(commentLabel)
  
        addSubview(imageView)
        addSubview(moreLabel)
       
        userView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalToSuperview().offset(14)
            make.height.equalTo(35)
            make.right.equalToSuperview().offset(-35)
            
        }
        commentLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.top.equalTo(userView.snp.bottom).offset(10)
            make.height.equalTo(0)
        }
        
        moreLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(26)
            make.bottom.equalToSuperview()
        }
        moreLabel.isHidden = true
    
        imageView.snp.makeConstraints { (make) in
            make.bottom.equalTo(moreLabel.snp.top)
            make.centerX.equalToSuperview()
            make.width.equalTo(0)
            make.height.equalTo(0)
        }
    }
    
    
    func updateUI(model: YXSquareStockPostListModel?, shareImage: UIImage?) {
        
        userView.updateUI(model: model?.creator_user ?? nil, createTime: model?.create_time ?? "", followStates: 1) //model?.follow_status ?? 0
        
        var totalHeight: CGFloat = 14 + 35 + 10 + 26
        
        if let model = model {
           
            let layout = YXSquareCommentManager.transformStockContentLayout(text: model.content, font: UIFont.systemFont(ofSize: 14), textColor: QMUITheme().textColorLevel1(), maxRows: 0, width: YXConstant.screenWidth - 24)
            self.commentLabel.textLayout = layout
            let commmentHeight: CGFloat = 4 + (layout?.textBoundingRect.maxY ?? 0)
            commentLabel.snp.updateConstraints { make in
                make.height.equalTo(commmentHeight)
            }
            
            totalHeight += commmentHeight

            //内容类型 1=要闻资讯 2=图文 3=直播 4=回放 5=个股讨论
            if let tempImageWidth = shareImage?.cgImage?.width, let tempImageHeight = shareImage?.cgImage?.height, let imageScale = shareImage?.scale {
                
                //优先根据宽度布局
                let originWidth = CGFloat(tempImageWidth) / imageScale
                let originHeight = CGFloat(tempImageHeight) / imageScale
                
                let maxWidth: CGFloat = YXConstant.screenWidth - 24.0
                
                
                let imageViewWidth: CGFloat = (originWidth > maxWidth) ? maxWidth : originWidth
         
                let imageViewHeight: CGFloat = imageViewWidth * originHeight / originWidth
                imageView.snp.updateConstraints { (make) in
                    make.height.equalTo(imageViewHeight)
                    make.width.equalTo(imageViewWidth)
                }
                
                imageView.image = shareImage
                
                totalHeight += imageViewHeight
                totalHeight += 10
            } else {
                imageView.snp.updateConstraints { (make) in
                    make.height.equalTo(0)
                    make.width.equalTo(0)
                }
                imageView.isHidden = true
            }
            
            if model.pictures.count > 1 {
                moreLabel.isHidden = false
            }
        
        }

        self.frame = CGRect(x: 0, y: 0, width: YXConstant.screenWidth, height: totalHeight)
    }
}

