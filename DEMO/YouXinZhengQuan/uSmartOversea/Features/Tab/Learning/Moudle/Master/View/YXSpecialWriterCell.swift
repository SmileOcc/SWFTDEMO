//
//  YXSubscribeTableViewCell.swift
//  uSmartEducation
//
//  Created by 覃明明 on 2021/10/12.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXSpecialWriterCell: UITableViewCell {
    
    var model: YXSpecialKOLItem? {
        didSet {
            if let m = model {
                let url = m.photoUrl ?? ""
                photoImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "user_default_photo"), options: [], context: nil)
                nameLabel.text = m.nick
                if let content = m.personalProfile {
                    let paragraph = NSMutableParagraphStyle()
                    paragraph.minimumLineHeight = 20
                    paragraph.lineBreakMode = .byTruncatingTail
                    let attributeString = NSMutableAttributedString.init(string: content, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),  NSAttributedString.Key.paragraphStyle : paragraph])
                    descLabel.attributedText = attributeString
                }
                self.floatView.removeAllSubviews()
                if let tags = m.tags, tags.count != 0 {
                    let tagsImages = tags.compactMap { model in
                        return YXKOLHomeTagType(rawValue: model.id ?? "")?.tagImage()
                    }
                    tagsImages.forEach({ [weak self] tagView in
                        self?.floatView.addSubview(tagView)
                    })
                    nameLabel.snp.updateConstraints { make in
                        make.top.equalTo(photoImageView)
                    }
                    descLabel.snp.updateConstraints { make in
                        make.top.equalTo(nameLabel.snp.bottom).offset(20)
                    }
                } else {
                    nameLabel.snp.updateConstraints { make in
                        make.top.equalTo(photoImageView).offset(10)
                    }
                    descLabel.snp.updateConstraints { make in
                        make.top.equalTo(nameLabel.snp.bottom).offset(4)
                    }
                }
                
            }
        }
    }
    
    lazy var floatView: QMUIFloatLayoutView = {
        let float = QMUIFloatLayoutView()
        float.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        float.itemMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        float.minimumItemSize = CGSize(width: 52, height: 16)
        float.clipsToBounds = true
        return float
    }()
    
    lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = QMUITheme().textColorLevel1()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    lazy var descLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel1()
        label.numberOfLines = 3
        return label
    }()
    
    lazy var bgView: UIView = {
        let bgView = UIView()
        bgView.backgroundColor = QMUITheme().foregroundColor()
        bgView.layer.cornerRadius = 12
        bgView.layer.shadowOpacity = 1
        bgView.layer.shadowColor = UIColor(hexString: "000000")?.withAlphaComponent(0.05).cgColor
        bgView.layer.shadowOffset = CGSize(width: 0, height: 2)
        bgView.layer.shadowRadius = 8
        return bgView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = QMUITheme().foregroundColor()
        
        contentView.addSubview(bgView)
        bgView.addSubview(photoImageView)
        bgView.addSubview(nameLabel)
        bgView.addSubview(descLabel)
        bgView.addSubview(floatView)
        
        floatView.snp.makeConstraints { make in
            make.left.equalTo(photoImageView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
            make.height.equalTo(16)
        }
        
        bgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        photoImageView.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(16)
            make.width.height.equalTo(50)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(photoImageView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(photoImageView)
        }
        
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.left.equalTo(nameLabel)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
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
