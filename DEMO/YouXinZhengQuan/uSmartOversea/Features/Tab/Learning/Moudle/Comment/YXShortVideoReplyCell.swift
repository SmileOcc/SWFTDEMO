//
//  YXReplyCell.swift
//  uSmartEducation
//
//  Created by usmart on 2022/2/17.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXShortVideoReplyCell: UITableViewCell {
    
    var authorId: String?
    
    var isLive = false {
        didSet {
            authorTag.text = YXLanguageUtility.kLang(key: "beerich_author")
            replyAuthorTag.text = YXLanguageUtility.kLang(key: "beerich_author")
        }
    }
    
    var isLike: Bool = false
    
    var model: YXShortVideoCommentItem? {
        didSet {
            if let item = model {
                var viewArray = [UIView]()
                stackView.removeAllSubviews()
                if let url = item.photoUrl {
                    photoImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "user_default_photo"), options: [], completed: nil)
                }else {
                    photoImageView.image = UIImage(named: "user_default_photo")
                }
                
                nameLabel.text = item.nick ?? "--"
                viewArray.insert(nameLabel, at: 0)
                if item.uid == authorId {
                    viewArray.insert(authorTag, at: 0)
                }
                if item.displayReplyUid == true {
                    if let replyName = item.replyNick {
                        viewArray.insert(replyImage, at: 0)
                        replyNameLabel.text = replyName + ": "
                        viewArray.insert(replyNameLabel, at: 0)
                        if item.replyUid == authorId {
                            viewArray.insert(replyAuthorTag, at: 0)
                        }
                    }
                } else {
                    nameLabel.text = (item.nick ?? "--") + ": "
                }
                
                viewArray.forEach { view in
                    stackView.insertArrangedSubview(view, at: 0)
                }
                
//                if item.likeCount == 0 {
//                    likeButton.setTitle(nil, for: .normal)
//                } else {
//                    likeButton.setTitle("\(item.likeCount)", for: .normal)
//                }
//                likeButton.isSelected = item.like
                
                if let discuss = item.discuss {
                    let paragraph = NSMutableParagraphStyle()
                    paragraph.minimumLineHeight = 20
                    let size = stackView.systemLayoutSizeFitting(CGSize(width: YXConstant.screenWidth, height: CGFloat.greatestFiniteMagnitude))
                    paragraph.firstLineHeadIndent = size.width + 4
                    paragraph.lineBreakMode = .byTruncatingTail
                    let attributeString = NSMutableAttributedString.init(string: discuss, attributes: [NSAttributedString.Key.font : UIFont.normalFont14(), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel2(), NSAttributedString.Key.paragraphStyle : paragraph])
                    contentLabel.attributedText = attributeString
                }else {
                    contentLabel.text = "--"
                }
                
                if let date = item.discussDate {
                    timeLabel.text = YXToolUtility.compareCurrentTime(date)
                }else {
                    timeLabel.text = item.discussDate ?? "--"
                }
                
            }
        }
    }
    
    lazy var authorTag: QMUILabel = {
        let label = QMUILabel()
        label.font = .mediumFont10()
        label.textColor = .white
        label.backgroundColor = UIColor(hexString: "#FF8B00")
        label.layer.cornerRadius = 2
        label.layer.masksToBounds = true
        label.text = YXLanguageUtility.kLang(key: "beerich_author")
        label.contentEdgeInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
        return label
    }()
    
    lazy var replyAuthorTag: QMUILabel = {
        let label = QMUILabel()
        label.font = .mediumFont10()
        label.textColor = .white
        label.backgroundColor = UIColor(hexString: "#FF8B00")
        label.layer.cornerRadius = 2
        label.layer.masksToBounds = true
        label.text = YXLanguageUtility.kLang(key: "beerich_author")
        label.contentEdgeInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
        return label
    }()
    
    lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 13
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = QMUITheme().textColorLevel1()
        return label
    }()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = .normalFont14()
        label.textColor = QMUITheme().textColorLevel1()
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .normalFont12()
        label.textColor = QMUITheme().textColorLevel2()
        
        return label
    }()
    
    lazy var replyLabel: UILabel = {
        let label = UILabel()
        label.font = .mediumFont12()
        label.text = YXLanguageUtility.kLang(key: "reply")
        label.textColor = QMUITheme().textColorLevel2()
        return label
    }()
    
    lazy var replyImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "comment_reply_icon")
        return image
    }()
    
    lazy var replyNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = QMUITheme().textColorLevel1()
        return label
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView.init(arrangedSubviews: [])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 2
        return stackView
    }()
    
    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.themeColor(withNormalHex: "#F8F9FC", andDarkColor: "#212129")
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = QMUITheme().foregroundColor()
        
        contentView.addSubview(bgView)
        
        bgView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(56)
            make.right.equalToSuperview().offset(-16)
        }
        
        
        bgView.addSubview(contentLabel)
//        bgView.addSubview(timeLabel)
//        bgView.addSubview(replyLabel)
        bgView.addSubview(stackView)
        
        nameLabel.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(100)
        }
        
        replyNameLabel.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(100)
        }
        
        stackView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.top.equalToSuperview().offset(12)
            make.right.lessThanOrEqualToSuperview().offset(-40)
            make.height.equalTo(20)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(stackView)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(stackView.snp.top).offset(-2)
            make.bottom.equalToSuperview().offset(-12)
        }
        
//        timeLabel.snp.makeConstraints { make in
//            make.left.equalTo(stackView)
//            make.top.equalTo(contentLabel.snp.bottom).offset(10)
//            make.bottom.equalToSuperview().offset(-12)
//        }
//
//
//        replyLabel.snp.makeConstraints { make in
//            make.left.equalTo(timeLabel.snp.right).offset(12)
//            make.centerY.equalTo(timeLabel.snp.centerY)
//        }

        authorTag.setContentHuggingPriority(.required, for: .horizontal)
        authorTag.setContentCompressionResistancePriority(.required, for: .horizontal)
        replyAuthorTag.setContentHuggingPriority(.required, for: .horizontal)
        replyAuthorTag.setContentCompressionResistancePriority(.required, for: .horizontal)
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
