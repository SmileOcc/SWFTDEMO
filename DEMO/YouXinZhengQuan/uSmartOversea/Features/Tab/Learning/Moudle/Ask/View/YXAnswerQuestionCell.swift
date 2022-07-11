//
//  YXAnswerQuestionCell.swift
//  uSmartEducation
//
//  Created by usmart on 2021/12/8.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation
import UIKit
import QMUIKit
import SnapKit
import RxCocoa
import RxSwift

class YXAnswerQuestionCell: UITableViewCell {
    
    var canDelete: Bool = false
    
    lazy var tagImageView1: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "user_default_photo")

        return imageView
    }()
    
    lazy var tagImageView2: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "master_ask_icon")

        return imageView
    }()
    
    lazy var bg: UIView = {
        let bg = UIView()
        bg.backgroundColor = QMUITheme().blockColor()
        bg.layer.cornerRadius = 12
        bg.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMaxXMaxYCorner,.layerMinXMaxYCorner]
        return bg
    }()
    
    lazy var kolBtn: UIControl = {
        let btn = UIControl()
        btn.backgroundColor = .clear
        let _ = btn.rx.controlEvent(.touchUpInside).takeUntil(self.rx.deallocated).subscribe(onNext:{ [weak self] in
            self?.didTapKolCallBack?()
        })
        return btn
    }()
    
    lazy var kolHearderView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    
    lazy var nameLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = QMUITheme().textColorLevel1()
        label.numberOfLines = 1
        return label
    }()
    
    lazy var dateLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = QMUITheme().textColorLevel3()
        label.numberOfLines = 1
        return label
    }()
    
    lazy var contentLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = QMUITheme().textColorLevel1()
        label.numberOfLines = 3
        return label
    }()
    
    lazy var likeBtn: QMUIButton = {
        let btn = QMUIButton()
        btn.setImage(UIImage(named: "kol_like_icon_unselected"), for: .normal)
        btn.setImage(UIImage(named: "kol_like_icon"), for: .selected)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        let _ = btn.rx.tap.takeUntil(self.rx.deallocated).subscribe { [weak self] tap in
            self?.likeTapCallback?()
        }
        return btn
    }()
    
    lazy var longPress: UILongPressGestureRecognizer = {
        let ges = UILongPressGestureRecognizer(target: self, action: #selector(longPressEvent(sender:)))
        ges.minimumPressDuration = 1
        return ges
    }()
    
    var tagsView = [UIView]()
    
    var likeTapCallback: (()->Void)?
    
    var deleteCallback: (()->Void)?
    
    var didTapKolCallBack: (()->Void)?
    
    @objc func longPressEvent(sender: UIGestureRecognizer) {
        if canDelete {
            if sender.state == .began {
                if let touchView = sender.view {
                    self.becomeFirstResponder()
                    let deleteItem = UIMenuItem(title: "delete", action: #selector(deleteContent))
                    let menu = UIMenuController.shared
                    menu.menuItems = [deleteItem]
                    menu.update()
                    let point = sender.location(in: touchView)
                    if #available(iOS 13.0, *) {
                        menu.showMenu(from: touchView, rect: CGRect(x: point.x, y: point.y , width:30, height: 20))
                    } else {
                        menu.setTargetRect(CGRect(x: point.x, y: point.y , width:30, height: 20), in: touchView)
                    }
                }
            }
        }
    }
    
    @objc func deleteContent() {
        self.deleteCallback?()
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(deleteContent)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupUI() {
        selectionStyle = .none
        contentView.backgroundColor = QMUITheme().foregroundColor()
        contentView.addSubview(bg)
        
        bg.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(64)
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-24)
        }
        
        bg.addSubview(kolHearderView)
        bg.addSubview(nameLabel)
        bg.addSubview(dateLabel)
        bg.addSubview(contentLabel)
        bg.addSubview(likeBtn)
        bg.addSubview(kolBtn)
        
        bg.addSubview(tagImageView1)
        bg.addSubview(tagImageView2)
        
        kolBtn.snp.makeConstraints { make in
            make.left.equalTo(kolHearderView.snp.left)
            make.top.equalTo(kolHearderView.snp.top)
            make.bottom.equalTo(kolHearderView.snp.bottom)
            make.right.equalTo(likeBtn.snp.left)
        }
        
        kolHearderView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
            make.size.equalTo(40)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(kolHearderView.snp.top)
            make.left.equalTo(kolHearderView.snp.right).offset(8)
            make.right.equalTo(likeBtn.snp.left).offset(-8)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(kolHearderView.snp.bottom).offset(8)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.left.equalTo(kolHearderView.snp.right).offset(8)
            make.right.equalTo(likeBtn.snp.left).offset(-8)
            make.bottom.equalTo(kolHearderView.snp.bottom)
        }
        
        likeBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-5)
            make.centerY.equalTo(kolHearderView.snp.centerY)
            make.width.equalTo(60)
        }
        
        tagImageView2.snp.makeConstraints { (make) in
            make.bottom.equalTo(kolHearderView.snp.bottom)
            make.right.equalTo(kolHearderView.snp.right)
            make.size.equalTo(16)
        }
        
        tagImageView1.snp.makeConstraints { (make) in
            make.bottom.equalTo(kolHearderView.snp.bottom)
            make.size.equalTo(16)
            make.centerX.equalTo(tagImageView2.snp.centerX).offset(4)
        }
        
        addGestureRecognizer(longPress)
    }
    
    func configure(model: YXAskReplyResModel?, businessType: YXAskListType) {
        if let model = model {
            if let urlStr = model.replyImg, let url = URL(string: urlStr) {
                kolHearderView.sd_setImage(with: url, placeholderImage: UIImage(named: "user_default_photo"))
            } else {
                kolHearderView.image = UIImage(named: "user_default_photo")
            }
            addKolTags(tags: model.kolTag?.compactMap{YXKOLHomeTagType(rawValue: $0)} ?? [])
            nameLabel.text = model.replyName
            dateLabel.text = model.replyTime
            contentLabel.text = model.replyDetail
            if model.likeNum == 0 {
                likeBtn.setTitle(YXLanguageUtility.kLang(key: "nbb_Like"), for: .normal)
            } else {
                likeBtn.setTitle("\(model.likeNum)", for: .normal)
            }
            likeBtn.isSelected = model.likeFlag
            if businessType == .kol {
                canDelete = false
            } else {
                canDelete = model.deleteFlag
            }
            
        }
    }
    
//    func addKolTags(tags: [YXKOLHomeTagType]) {
//        var paddingView: UIView?
//        tagsView.forEach { v in
//            v.removeFromSuperview()
//        }
//
//        nameLabel.snp.updateConstraints { make in
//            make.top.equalTo(kolHearderView.snp.top).offset(tags.count == 0 ? 10 : 0)
//        }
//
//        for tag in tags {
//            let view = tag.tagImage()
//            tagsView.append(view)
//            bg.addSubview(view)
//            view.snp.makeConstraints { make in
//                make.top.equalTo(nameLabel.snp.bottom).offset(2)
//                if paddingView == nil {
//                    make.left.equalTo(kolHearderView.snp.right).offset(8)
//                } else {
//                    make.left.equalTo(paddingView!.snp.right).offset(8)
//                }
//            }
//            paddingView = view
//        }
//    }
    func addKolTags(tags: [YXKOLHomeTagType]) {
        tagImageView1.isHidden = true
        tagImageView2.isHidden = true
        
        let tag1 = tags[safe: 0]
        let tag2 = tags[safe: 1]
        
        if let tag = tag1 {
            let t = tag as YXKOLHomeTagType
            let image = t.headIcon()
            tagImageView1.image = image
            tagImageView1.isHidden = false
        }

        if let tag = tag2 {
            let t = tag as YXKOLHomeTagType
            let image = t.headIcon()
            tagImageView2.image = image
            tagImageView2.isHidden = false
        }
    }
}
