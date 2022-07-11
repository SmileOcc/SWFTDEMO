//
//  YXCommentCell.swift
//  uSmartEducation
//
//  Created by 覃明明 on 2021/8/19.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXCourseCommentCell: UITableViewCell {
    
    var model: YXCourseCommentItem? {
        didSet {
            if let item = model {
                if let url = item.photoUrl {
                    photoImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "user_default_photo"), options: [], completed: nil)
                }else {
                    photoImageView.image = UIImage(named: "user_default_photo")
                }
                
                nameLabel.text = item.nick ?? "--"
                
                if let discuss = item.discuss {
                    let paragraph = NSMutableParagraphStyle()
                    paragraph.minimumLineHeight = 20
                    paragraph.lineBreakMode = .byTruncatingTail
                    let attributeString = NSMutableAttributedString.init(string: discuss, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1(), NSAttributedString.Key.paragraphStyle : paragraph])
                    contentLabel.attributedText = attributeString
                }else {
                    contentLabel.text = "--"
                }
                
                if let date = item.discussDate {
                    timeLabel.text = YXToolUtility.compareCurrentTime(date)
                }else {
                    timeLabel.text = item.discussDate ?? "--"
                }
                
                if let uid = item.uid, uid == String(YXUserManager.userUUID()){
                    optionView.isHidden = false
                }else{
                    optionView.isHidden = true
                }
                
            }
        }
    }
    
    lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel2()
        return label
    }()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel2()
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel3()
        
        return label
    }()
    
    lazy var  optionView : UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage.init(named: "more_option_icon"), for: .normal)
        return btn
    }()
    
    lazy var lineView = UIView.line()
    
    private lazy var popover: YXStockPopover = {    
        let popover = YXStockPopover()
        return popover
    }()
    
    private lazy var deleteButton : QMUIButton = {
        let btn = QMUIButton()
        btn.backgroundColor = QMUITheme().foregroundColor()
        btn.setTitle(YXLanguageUtility.kLang(key: "nbb_delete"), for: .normal)
        btn.qmui_tapBlock = { [weak self] _ in
            self?.popover.dismiss()
            self?.delecClick?()
        }
        btn.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.contentMode = .center
        btn.frame = CGRect.init(x: 0, y: 0, width: 75, height: 48)
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = QMUITheme().foregroundColor()
        selectionStyle = .none
        contentView.addSubview(photoImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(optionView)
        contentView.addSubview(lineView)
        
        photoImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(21)
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(30)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(photoImageView.snp.right).offset(9)
            make.top.equalTo(photoImageView)
            make.right.equalTo(optionView.snp.left).offset(-16)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.right.equalTo(-16)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        
        
        optionView.snp.makeConstraints { make in
            make.centerY.equalTo(nameLabel)
            make.right.equalToSuperview().offset(-18)
            make.size.equalTo(CGSize.init(width: 22, height: 22))
        }
        
        lineView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        optionView.qmui_tapBlock = {[weak self] _ in
            guard let `self` = self else { return }
            self.popover.show(self.deleteButton, from: self.optionView)
        }
    }
    
    var delecClick:(()->())?
    
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
