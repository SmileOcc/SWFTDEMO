//
//  YXCommentDetailHeaderCollectionViewCell.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/24.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXCommentDetailHeaderCollectionViewCell: UICollectionViewCell {
    
    
    lazy var userView:YXUGCPublisherView = {
        let view = YXUGCPublisherView.init(style: .normal)

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
    
    lazy var imageBGView:YXCommentImagesView = {
        let view = YXCommentImagesView()
        view.tapImageBlock = { [weak self] index in
            guard let `self` = self else { return }
            if let pictures = self.model?.pictures {
                XLPhotoBrowser.show(withImages: pictures, currentImageIndex: index)
            }

        }

        return view
    }()
    
    
    lazy var riskLabel: YYLabel = {
        let label = YYLabel()
//        label.preferredMaxLayoutWidth = YXConstant.screenWidth - 16*2
//        label.numberOfLines = 0
        return label
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI()  {
      
        contentView.addSubview(userView)
        contentView.addSubview(commentLabel)
        contentView.addSubview(imageBGView)
        
        contentView.addSubview(riskLabel)
        
        userView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(14)
            make.right.equalToSuperview().offset(-14)
            make.height.equalTo(70)
        }
      
        commentLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(userView.snp.bottom)
            make.height.equalTo(0)
        }
        
        riskLabel.snp.makeConstraints { make in
            make.left.right.equalTo(commentLabel)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(0)
        }
        
        imageBGView.snp.makeConstraints { make in
            make.bottom.equalTo(riskLabel.snp.top).offset(-10)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(0)
        }
        
    }
    
    var model:YXCommentDetailHeaderModel? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        if let model = model {
           
            userView.userModel = model.creator_user
            userView.descLabel.text = YXToolUtility.compareCurrentTime(model.create_time)
          
            if let layout = model.postHeaderLayout {
                self.commentLabel.textLayout = layout.contentlayout
                imageBGView.snp.updateConstraints { make in
                    make.height.equalTo(layout.imageHeight)
                }
                commentLabel.snp.updateConstraints { make in
                    make.height.equalTo(4 + (layout.contentlayout?.textBoundingRect.maxY ?? 0))
                }
                riskLabel.textLayout = layout.replayLayout
                riskLabel.snp.updateConstraints { make in
                    make.height.equalTo(8 + (layout.replayLayout?.textBoundingRect.maxY ?? 0))
                }
                imageBGView.updatePictureNineShow(pictures: model.pictures, height: layout.imageHeight, singlePicSize: layout.singleImageSize)
            }
        }
    }
    
    
    
}
