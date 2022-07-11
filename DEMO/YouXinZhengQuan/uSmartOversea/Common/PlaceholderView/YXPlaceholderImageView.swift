//
//  YXPlaceholderImageView.swift
//  uSmartOversea
//
//  Created by 欧冬冬 on 2022/4/14.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit


//infoImageView.setImageUrl(NSURL.init(string: imageUrl!)! as URL, options: [], context: [SDWebImageContextOption.imageTransformer: transformer])  {  [weak self](image, err, cacheType, url) in
//}

class YXPlaceholderImageView: UIView {

    @objc var isShowPlaceholder: Bool = true {
        didSet {
            self.placeholderView.isHidden = !isShowPlaceholder
        }
    }

    // 默认背景色
    var themeColor: UIColor = UIColor.themeColor(withNormalHex: "#F8F9FC", andDarkColor: "#19191F") {
        didSet {
            self.placeholderView.backgroundColor = themeColor
        }
    }
    
    //背景默认试图
    lazy var placeholderView: UIView = {
        let view = UIView()
        view.backgroundColor = self.themeColor
        return view
    }()
    //默认logo
    lazy var placeIcon: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "placehole_logo")
        return view
    }()
    
    //内容图片
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        addSubview(placeholderView)
        addSubview(imageView)
        
        placeholderView.addSubview(placeIcon)
        
        placeholderView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        placeIcon.snp.makeConstraints { make in
            make.center.equalTo(placeholderView)
            //make.size.equalTo(CGSize(width: 64, height: 12))
        }
    }
    
    func setImageUrl(_ imageUrl: URL?, options:SDWebImageOptions?, context:[SDWebImageContextOption:Any]?, completed:SDExternalCompletionBlock?) {
        
        self.imageView.backgroundColor = UIColor.clear
        if let _ = imageUrl {
            
            imageView.sd_setImage(with: imageUrl, placeholderImage: nil, options: options ?? [], context: context ?? [:], progress: nil) {  [weak self](image, err, cacheType, url) in
                guard let `self` = self else { return }
                if let _ = image{
                    self.imageView.backgroundColor = self.themeColor
                }
                
                if let completeBlock = completed {
                    completeBlock(image,err,cacheType,url)
                }
            }
        }
    }
    
    func setImageUrl(_ imageUrl: URL?, completed:SDExternalCompletionBlock?) {
        self.setImageUrl(imageUrl, options: [], context: [:], completed: completed)
    }

}
