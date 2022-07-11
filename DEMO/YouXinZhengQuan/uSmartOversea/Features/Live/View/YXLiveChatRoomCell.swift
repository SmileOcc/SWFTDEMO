//
//  YXLiveChatRoomCell.swift
//  uSmartOversea
//
//  Created by Apple on 2020/10/13.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
class YXLiveChatRoomCell: UITableViewCell {
    
    var item: YXCommentItem? {
        didSet {
            commentLabel.attributedText = item?.attributeString
            commentLabel.layer.cornerRadius = 4
            commentLabel.layer.masksToBounds = true
            
            nameLabel.attributedText = item?.nickAttributeString
            iconView.sd_setImage(with: URL(string: item?.iconUrl ?? ""), placeholderImage: UIImage(named: "nav_user"))
            
            if let isAnchor = item?.isAnchor, isAnchor == true {
                tagLabel.isHidden = false
                
                nameLabel.snp.remakeConstraints { (make) in
                    make.left.equalTo(tagLabel.snp.right).offset(6)
                    make.top.equalTo(iconView)
                    make.height.equalTo(20)
                }
            } else {
                tagLabel.isHidden = true
                
                nameLabel.snp.remakeConstraints { (make) in
                    make.left.equalTo(iconView.snp.right).offset(10)
                    make.top.equalTo(iconView)
                    make.height.equalTo(20)
                }
            }
        }
    }
    
    lazy var commentLabel: QMUILabel = {
        let label = QMUILabel()
        label.backgroundColor = UIColor(hexString: "#F3F3F3")
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        label.lineBreakMode = .byWordWrapping
        label.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return label
    }()
    
    lazy var tagLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 12)
        label.text = YXLanguageUtility.kLang(key: "live_instructor")
        label.textColor = .white
        label.backgroundColor = UIColor(hexString: "#2F79FF")
        label.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.isHidden = true
        return label
    }()
    
    lazy var iconView: UIImageView = {
        let iconView = UIImageView ()
        iconView.layer.cornerRadius = 16
        iconView.layer.masksToBounds = true
        return iconView
    }()

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor(hexString: "#191919")?.withAlphaComponent(0.45)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(iconView)
        contentView.addSubview(tagLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(commentLabel)
        
        iconView.snp.makeConstraints { (make) in
            make.left.top.equalTo(12)
            make.width.height.equalTo(32)
        }
        
        tagLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconView.snp.right).offset(10)
            make.top.equalTo(iconView)
            make.height.equalTo(20)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(tagLabel.snp.right).offset(6)
            make.top.equalTo(iconView)
            make.height.equalTo(20)
        }
        
        commentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconView.snp.right).offset(10)
            make.top.equalTo(nameLabel.snp.bottom).offset(6)
            make.height.greaterThanOrEqualTo(28)
            make.right.lessThanOrEqualToSuperview().offset(-68)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

