//
//  YXRecommendAskCell.swift
//  uSmartEducation
//
//  Created by usmart on 2021/12/7.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation
import UIKit
import QMUIKit
import SnapKit

class YXRecommendAskCell: UITableViewCell {
    
    var model: YXRecommendAskResModel? {
        didSet {
            if let model = model {
                question.text = model.questionDetail
                if let reply = model.replyDTOList?.first {
                    if let urlStr = reply.replyImg, let url = URL(string: urlStr) {
                        answerImageView.sd_setImage(with: url, placeholderImage: UIImage(named: ""))
                    }
                    answer.text = reply.replyDetail
                }
            }
        }
    }
    
    lazy var bg: UIView = {
        let bg = UIView()
        bg.backgroundColor = QMUITheme().foregroundColor()
        bg.layer.cornerRadius = 12
        bg.layer.shadowColor = UIColor.qmui_color(withHexString: "#000000")?.withAlphaComponent(0.05).cgColor
        bg.layer.shadowOffset = CGSize(width: 0, height: 4)
        bg.layer.shadowOpacity = 1.0
        bg.layer.shadowRadius = 12.0
        return bg
    }()
    
    lazy var questionImageView: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 11
        image.layer.masksToBounds = true
        image.image = UIImage(named: "master_ask_icon")
        return image
    }()
    
    lazy var answerImageView: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 11
        image.layer.masksToBounds = true
        image.image = UIImage(named: "user_default_photo")
        return image
    }()
    
    lazy var question: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = QMUITheme().textColorLevel1()
        label.numberOfLines = 1
        return label
    }()
    
    lazy var answer: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = QMUITheme().textColorLevel2()
        label.numberOfLines = 1
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = QMUITheme().foregroundColor()
        selectionStyle = .none
        
        contentView.addSubview(bg)
        
        bg.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(4)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        bg.addSubview(question)
        bg.addSubview(questionImageView)
        bg.addSubview(answer)
        bg.addSubview(answerImageView)
        
        questionImageView.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(8)
            make.size.equalTo(22)
        }
        
        question.snp.makeConstraints { make in
            make.left.equalTo(questionImageView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-8)
            make.centerY.equalTo(questionImageView.snp.centerY)
        }
        
        answerImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.top.equalTo(questionImageView.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.size.equalTo(22)
        }
        
        answer.snp.makeConstraints { make in
            make.left.equalTo(answerImageView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-8)
            make.centerY.equalTo(answerImageView.snp.centerY)
        }
    }
    
}
