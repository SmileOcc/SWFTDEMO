//
//  YXNewsBannerCell.swift
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/5/31.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXNewsBannerCell: UICollectionViewCell {
    
    @objc var tapAction: ((_ index: Int) -> Void)?
    
    @objc var model: YXBannerActivityModel? {
        didSet {
            if let data = model {
                imageBannerView.imageURLStringsGroup = data.bannerList.map({ (model) -> String in
                    return model.pictureUrl
                })
            }
        }
    }
    
    lazy var imageBannerView: YXImageBannerView = {
        let banner = YXImageBannerView.init(frame: .zero, delegate: self, placeholderImage: UIImage(named: "black_4_1"))!
        banner.autoScrollTimeInterval = 3
        return banner
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initUI() {
        contentView.addSubview(imageBannerView)
        imageBannerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
}


extension YXNewsBannerCell: YXCycleScrollViewDelegate {
    
    func cycleScrollView(_ cycleScrollView: YXCycleScrollView!, didSelectItemAt index: Int) {
        self.tapAction?(index)
    }
}
