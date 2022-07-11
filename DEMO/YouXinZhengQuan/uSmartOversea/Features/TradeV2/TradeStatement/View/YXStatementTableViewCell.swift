//
//  YXStatementTableViewCell.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/7/16.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXStatementTableViewCell: UITableViewCell {
    
    var lookPdfBlock:(() -> Void)?
    
    lazy var bgView:UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().foregroundColor()
        
        return view
    }()
    
    lazy var iconImageView:UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    lazy var titleLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .mediumFont14()
    
        return label
    }()

    lazy var tagLabel: QMUILabel = {
        let label = QMUILabel()
        label.font = .normalFont12()
        label.textColor = QMUITheme().textColorLevel3()
        return label
    }()
    
    lazy var timeValueLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = .normalFont12()
        label.textAlignment = .left
        return label
    }()
    
    lazy var lookBtn:QMUIButton = {
        let btn = QMUIButton()
        btn.setImage(UIImage.init(named: "statement_arrow"), for: .normal)

        btn.addTarget(self, action: #selector(lookAction(_ :)), for: .touchUpInside)
        
        return btn
    }()
    
 
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        self.selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = QMUITheme().foregroundColor()
        contentView.backgroundColor = UIColor.clear
        contentView.addSubview(bgView)
        bgView.addSubview(iconImageView)
        bgView.addSubview(titleLabel)
        bgView.addSubview(tagLabel)
        bgView.addSubview(timeValueLabel)
        
        bgView.addSubview(lookBtn)
   
        bgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
            make.height.width.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(8)
            make.top.equalTo(16)
            make.height.equalTo(16)
        }
        
        tagLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.left)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.height.equalTo(14)
        }
        
        timeValueLabel.snp.makeConstraints { make in
            make.centerY.equalTo(tagLabel)
            make.left.equalTo(tagLabel.snp.right).offset(12)
            make.height.equalTo(14)
            make.right.lessThanOrEqualToSuperview().offset(-12)
        }
        
        lookBtn.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(15)
        }
    }
    
    func updateUI(model:YXStatementListItemModel?, statementType:TradeStatementType) {
        if let model = model {
            iconImageView.image = UIImage.init(named: model.accountType.icon)
            titleLabel.text = model.accountType.text
            tagLabel.text = model.market + " " + model.statementType.text
          
            if model.statementType == .month {
                timeValueLabel.text = YXDateHelper.commonDateString(model.statementDate, format: .DF_MY)
            }else{
                timeValueLabel.text = YXDateHelper.commonDateString(model.statementDate, format: .DF_MDY)
            }
        }
    }
    @objc func lookAction(_ sender:QMUIButton) {
        self.lookPdfBlock?()
    }
}
