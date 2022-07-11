//
//  YXKOLChatRoomCell.swift
//  uSmartEducation
//
//  Created by usmart on 2021/12/2.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import QMUIKit
import SnapKit

class YXKOLChatRoomCell: UITableViewCell {
    
    var model: YXKOLChatGroupResModel? {
        didSet {
            if let model = model {
                self.nameLabel.text = model.chatGroupTitle
                self.descLabel.text = model.chatGroupProfile
                self.badgeView.isHidden = !model.isSpot
                if model.totalPeople > 0 {
                    self.chatMember.isHidden = false
                    self.chatMember.setTitle("\(model.totalPeople)", for: .normal)
                } else {
                    self.chatMember.isHidden = true
                    self.chatMember.setTitle("", for: .normal)
                }
                if let urlStr = model.chatGroupCover, let url = URL(string: urlStr) {
                    chatImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "user_default_photo"))
                } else {
                    chatImageView.image = UIImage(named: "user_default_photo")
                }
                addTags(tags: model.tagList ?? [])
            }
        }
    }
    
    lazy var badgeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "F95151")!
        view.layer.cornerRadius = 6
        view.isHidden = true
        return view
    }()
    
    lazy var bg: UIView = {
        let bg = UIView()
//        bg.backgroundColor = .white
//        bg.layer.cornerRadius = 12
//        bg.layer.shadowColor = UIColor.qmui_color(withHexString: "#000000")?.withAlphaComponent(0.05).cgColor
//        bg.layer.shadowOffset = CGSize(width: 0, height: 4)
//        bg.layer.shadowOpacity = 1.0
//        bg.layer.shadowRadius = 12.0
        return bg
    }()
    
    lazy var chatImageView: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 25
        image.layer.masksToBounds = true
        return image
    }()
    
    lazy var nameLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = QMUITheme().textColorLevel1()
        label.numberOfLines = 1
        return label
    }()
    
    lazy var chatMember: QMUIButton = {
        let btn = QMUIButton()
        btn.backgroundColor = QMUITheme().blockColor()
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        btn.setTitleColor(UIColor(hexString: "888996"), for: .normal)
        btn.setImage(UIImage(named: "chat_num_icon"), for: .normal)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        btn.cornerRadius = QMUIButtonCornerRadiusAdjustsBounds
        return btn
    }()
    
    lazy var descLabel: QMUILabel = {
        let label = QMUILabel()
        label.numberOfLines = 2
        label.qmui_lineHeight = 20
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel3()
        return label
    }()
    
    ///添加标签
    func addTags(tags: [YXKOLChatRoomTagResModel]) {
        
        descLabel.snp.updateConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(tags.count > 0 ? 28 : 8)
        }
        var paddingView: UIView?
        for tag in tags {
            let view = QMUIButton()
            view.backgroundColor = .clear
            view.layer.masksToBounds = true
            view.layer.borderWidth = 0.5
            view.layer.borderColor = QMUITheme().mainThemeColor().cgColor
            view.titleLabel?.font = .systemFont(ofSize: 10, weight: .regular)
            view.contentEdgeInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
            view.setTitleColor(QMUITheme().mainThemeColor(), for: .normal)
//            view.setBackgroundImage(UIImage(gradientColors: [UIColor(hexString: tag.gradientLeft?.replacingOccurrences(of: "#", with: "") ?? "") ?? .white,
//                                                             UIColor(hexString: tag.gradientRight?.replacingOccurrences(of: "#", with: "") ?? "") ?? .white]), for: .normal)
            var title = ""
            switch YXUserManager.curLanguage() {
            case .HK: //目前写死en英文
                title = tag.itemNameEn ?? "test"
            case .CN:
                title = tag.itemNameEn ?? "test"
            default:
                title = tag.itemNameEn ?? "test"
            }
            view.setTitle(title, for: .normal)
            bg.addSubview(view)
            
            view.snp.makeConstraints { make in
                make.top.equalTo(nameLabel.snp.bottom).offset(8)
                if paddingView == nil {
                    make.left.equalTo(chatImageView.snp.right).offset(23)
                } else {
                    make.left.equalTo(paddingView!.snp.right).offset(8)
                }
            }
            paddingView = view
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
        selectionStyle = .none
        
        contentView.addSubview(bg)
        backgroundColor = QMUITheme().foregroundColor()
        bg.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        bg.addSubview(chatImageView)
        bg.addSubview(nameLabel)
        bg.addSubview(chatMember)
        bg.addSubview(nameLabel)
        bg.addSubview(descLabel)
        bg.addSubview(badgeView)
        
        badgeView.snp.makeConstraints { make in
            make.top.equalTo(chatImageView.snp.top)
            make.right.equalTo(chatImageView.snp.right)
            make.size.equalTo(12)
        }
        
        chatImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(33)
            make.left.equalToSuperview().offset(16)
            make.size.equalTo(50)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(chatImageView.snp.top)
            make.left.equalTo(chatImageView.snp.right).offset(23)
            make.right.equalToSuperview().offset(-16)
        }
        
        chatMember.snp.makeConstraints { make in
            make.top.equalTo(chatImageView.snp.bottom).offset(8)
            make.centerX.equalTo(chatImageView.snp.centerX)
            make.bottom.equalToSuperview().offset(-24)
        }
        
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.right.equalToSuperview().offset(-16)
            make.left.equalTo(nameLabel.snp.left)
//            make.bottom.equalToSuperview().offset(8)
        }
    }
    
}
