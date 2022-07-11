//
//  YXCourseCell.swift
//  uSmartEducation
//
//  Created by 覃明明 on 2021/8/20.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import QMUIKit

enum YXCourseUI {
    case type1(index: Int)
    case type2(index: Int)
    case type3(index: Int)
    
    var info: (imageName: String, color: UIColor) {
        switch self {
        case .type1(let index):
            return ("coursebg1_\(index)", UIColor.qmui_color(withHexString: "#005354")!)
        case .type2(let index):
            return ("coursebg2_\(index)", UIColor.qmui_color(withHexString: "#00467C")!)
        case .type3(let index):
            return ("coursebg3_\(index)", UIColor.qmui_color(withHexString: "#03029E")!)
        }
    }
}

class YXCourseCell: UITableViewCell {
    var clickBlock:((_ model:YXCourseListItem?)->())?

    var model: YXCourseListItem? {
        didSet {
            if let m = model {
                nameLabel.text = "--"
                priceLabel.textColor = QMUITheme().mainThemeColor()
                if let name = m.courseName,name.isEmpty == false {
                    nameLabel.text = name
                }
                learnNowBtn.setProgress(value: CGFloat(m.studyProgress))
                learnNowBtn.isSelected = true
                learnNowBtn.clickBlock = {[weak self] in
                    self?.clickBlock?(self?.model)
                }
              //  learnNowBtn.isSelected =  m.coursePaidType == 0 || m.coursePaidFlag == true
                let url = URL.init(string: m.courseCover ?? "")
                courseImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "banner_placeholder1"), options: [], context: nil)
                if m.coursePaidType == 0 {
                    priceLabel.text = YXLanguageUtility.kLang(key: "nbb_free_limit")
                }else {
                    if m.coursePaidFlag {
                        priceLabel.text = YXLanguageUtility.kLang(key: "nbb_bought")
                        priceLabel.textColor = QMUITheme().textColorLevel4()
                    }else {
                        priceLabel.text = "\(m.currencySymbol ?? "")\(m.coursePrice ?? "--")"
                    }
                }
                ///处理标签
                if let tag = m.courseLabel, !tag.isEmpty {
                    tagLabel.isHidden = false
                    if tag.contains(",") {
                        if let t = tag.split(separator: ",").first {
                            tagLabel.text = String(t)
                        }
                    } else {
                        tagLabel.text = tag
                    }
                } else {
                    tagLabel.isHidden = true
                }
            }
        }
    }
    
    
    
    lazy var courseImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = QMUITheme().blockColor()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = QMUITheme().textColorLevel2()
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()
    
    lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = QMUITheme().mainThemeColor()
        label.textAlignment = .left
        label.text = "--"
        return label
    }()
    
    lazy var learnNowBtn: YXCourseLearnButton = {
        let btn = YXCourseLearnButton()
        return btn
    }()
    
    lazy var bgView: UIView = {
        let bgView = UIView()
        bgView.backgroundColor = .clear
//        bgView.layer.cornerRadius = 12
//        bgView.layer.shadowOpacity = 1
//        bgView.layer.shadowColor = UIColor(hexString: "000000")?.withAlphaComponent(0.05).cgColor
//        bgView.layer.shadowOffset = CGSize(width: 0, height: 4)
//        bgView.layer.shadowRadius = 12
        return bgView
    }()
    
    let lineView : UIView = UIView.line()
    
    lazy var tagLabel: QMUILabel = {
        let label = QMUILabel()
        label.layer.backgroundColor = QMUITheme().mainThemeColor().withAlphaComponent(0.1).cgColor
        label.textColor = QMUITheme().mainThemeColor()
        label.font = .systemFont(ofSize: 10)
        label.layer.cornerRadius = 2
        label.contentEdgeInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(bgView)
        contentView.backgroundColor = QMUITheme().foregroundColor()

        bgView.addSubview(courseImageView)
        bgView.addSubview(nameLabel)
        bgView.addSubview(priceLabel)
        bgView.addSubview(learnNowBtn)
        bgView.addSubview(tagLabel)
        contentView.addSubview(lineView)
        
        bgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        courseImageView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(128)
            make.height.equalTo(92)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(courseImageView)
            make.left.equalTo(courseImageView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-16)
        }
            
        tagLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.left.equalTo(courseImageView.snp.right).offset(8)
            make.right.lessThanOrEqualTo(learnNowBtn.snp.left).offset(-5)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.bottom.equalTo(courseImageView).offset(-1)
            make.right.equalTo(learnNowBtn.snp.left).offset(-5)
        }
        
        learnNowBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(courseImageView).offset(-1)
            make.size.equalTo(30)
        }
        
        lineView.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.bottom.equalToSuperview()
            make.left.equalTo(courseImageView)
            make.right.equalTo(learnNowBtn)
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
