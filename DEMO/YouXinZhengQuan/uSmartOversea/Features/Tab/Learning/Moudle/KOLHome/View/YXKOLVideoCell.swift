//
//  YXKOLVideoCell.swift
//  uSmartEducation
//
//  Created by usmart on 2022/2/18.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import QMUIKit
import SnapKit

class YXKOLVideoCell: UICollectionViewCell {
    
    var model: YXKOLVideoResModel? {
        didSet {
            if let model = model {
                nameLabel.text = model.videoTitle
                //dateLabel.text = model.updateTime
                let duration = Double(model.videoDuration ?? "0") ?? 0
                durationLabel.text = String(format: "%02d:%02d", Int(ceil(duration)/60),Int(ceil(duration))%60)
                dateLabel.text = YXDateHelper.commonDateString(model.updateTime ?? "", format: .DF_MDY)
        
                if let urlStr = model.videoCover,let url = URL(string: urlStr) {
//                    imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "banner_placeholder_v"))
                    imageView.setImageUrl(url, completed: nil)
                } else {
                    imageView.setImageUrl(nil, completed: nil)
                }
            }
        }
    }

    //    lazy var imageView: UIImageView = {
//        let imageView = UIImageView(image: UIImage(named: "banner_placeholder_v"))
//        imageView.layer.cornerRadius = 4
//        imageView.clipsToBounds = true
//        return imageView
//    }()
    
    lazy var imageView: YXPlaceholderImageView = {
        let imageView = YXPlaceholderImageView()
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var nameLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = QMUITheme().textColorLevel1()
        label.numberOfLines = 2
        return label
    }()
    
    lazy var dateLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = QMUITheme().textColorLevel4()
        label.numberOfLines = 1
        return label
    }()
    
    lazy var durationLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {

        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(durationLabel)
        contentView.addSubview(dateLabel)
        ;
        imageView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-(44+20))
        }
        
        durationLabel.snp.makeConstraints { make in
            make.bottom.equalTo(imageView.snp.bottom).offset(-4)
            make.left.equalTo(imageView.snp.left).offset(4)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(8)
            //make.bottom.lessThanOrEqualToSuperview().offset(0)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-4)
            make.left.equalTo(imageView.snp.left).offset(4)
        } 
    }
    
}
