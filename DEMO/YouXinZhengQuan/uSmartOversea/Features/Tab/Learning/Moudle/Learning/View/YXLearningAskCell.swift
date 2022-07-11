//
//  YXLearningAskCell.swift
//  uSmartOversea
//
//  Created by usmart on 2021/12/16.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class YXLearningAskCell: UICollectionViewCell, HasDisposeBag {
    override func prepareForReuse() {
        super.prepareForReuse()

        disposeBag = DisposeBag()
    }
    
    var data: YXRecommendAskResModel? {
        didSet {
            if let model = data {
                question.text =  model.questionDetail
                if let reply = model.replyDTOList?.first {
                    if let urlStr = reply.replyImg, let url = URL(string: urlStr) {
                        answerImageView.sd_setImage(with: url, placeholderImage: UIImage(named: ""))
                    }
                    answer.text =  reply.replyDetail
                    answerName.text = reply.replyName  ?? "EMPTY NAME"
                    
                    addKolTags(tags: reply.tags?.compactMap{YXKOLHomeTagType(rawValue: $0.stringValue)} ?? [])
                    

                }
                
                if let name = model.askStockInfoDTO?.stockName {
                    stockLabel.text = "$\(name)$"
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
        image.image = UIImage(named: "master_ask_icon")
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    lazy var answerImageView: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 11
        image.image = UIImage(named: "user_default_photo")
        image.contentMode = .scaleAspectFit
        return image
    }()

    lazy var tagImageView1: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "user_default_photo")
        return imageView
    }()
    
    lazy var tagImageView2: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "user_default_photo")
        return imageView
    }()

    lazy var question: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = QMUITheme().textColorLevel1()
        label.numberOfLines = 3
        return label
    }()
    
    lazy var answerName: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = QMUITheme().textColorLevel2()
        label.numberOfLines = 1
        return label
    }()
    
    let btn = UIButton()
    
    //股票
    lazy var stockLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = QMUITheme().themeTextColor()
        return label
    }()
    
    lazy var answer: QMUILabel = {
        let label = QMUILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = QMUITheme().textColorLevel2()
        label.numberOfLines = 2
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = QMUITheme().foregroundColor()
        
//        contentView.addSubview(bg)
        
//        bg.snp.makeConstraints { make in
//            make.left.equalToSuperview().offset(16)
//            make.top.equalToSuperview().offset(4)
//            make.right.equalToSuperview().offset(-16)
//            make.bottom.equalToSuperview().offset(-8)
//        }
        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().separatorLineColor()
        
        contentView.addSubview(lineView)
        
        contentView.addSubview(question)
        contentView.addSubview(questionImageView)
        contentView.addSubview(answerName)
        contentView.addSubview(stockLabel)
        contentView.addSubview(btn)
        contentView.addSubview(answer)
        contentView.addSubview(answerImageView)
        contentView.addSubview(tagImageView1)
        contentView.addSubview(tagImageView2)
        
        lineView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(1)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(0.5)
        }
        
        questionImageView.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(16)
            make.size.equalTo(32)
        }
        
        stockLabel.snp.makeConstraints { make in
            make.left.equalTo(questionImageView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(questionImageView.snp.top)
        }
        
        btn.snp.makeConstraints { make in
            make.top.equalTo(questionImageView.snp.top)
            make.left.equalTo(stockLabel.snp.left)
            make.right.equalTo(stockLabel.snp.right)
            make.height.equalTo(questionImageView.snp.height)
        }
        
        question.snp.makeConstraints { make in
            make.left.equalTo(questionImageView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(stockLabel.snp.bottom)
            make.height.greaterThanOrEqualTo(questionImageView.snp.height);
        }
        
        answerImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(question.snp.bottom).offset(12)
            make.size.equalTo(32)
        }
        
        answerName.snp.makeConstraints { make in
            make.left.equalTo(answerImageView.snp.right).offset(8)
            make.top.equalTo(answerImageView.snp.top)
            make.right.equalToSuperview().offset(-16)
        }
        
        answer.snp.makeConstraints { make in
            make.left.equalTo(answerImageView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-8)
            make.top.equalTo(answerName.snp.bottom).offset(4)
        }
        
        tagImageView2.snp.makeConstraints { (make) in
            make.bottom.equalTo(answerImageView.snp.bottom)
            make.right.equalTo(answerImageView.snp.right)
            make.size.equalTo(16)
        }
        
        tagImageView1.snp.makeConstraints { (make) in
            make.bottom.equalTo(answerImageView.snp.bottom)
            make.size.equalTo(16)
            make.centerX.equalTo(tagImageView2.snp.centerX).offset(4)
        }
        
        self.layoutIfNeeded()
        answerImageView.layer.cornerRadius = answerImageView.frame.size.width / 2;
        answerImageView.layer.masksToBounds = true
        tagImageView1.layer.cornerRadius = tagImageView1.frame.size.width / 2;
        tagImageView1.layer.masksToBounds = true
        tagImageView2.layer.cornerRadius = tagImageView2.frame.size.width / 2;
        tagImageView2.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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

