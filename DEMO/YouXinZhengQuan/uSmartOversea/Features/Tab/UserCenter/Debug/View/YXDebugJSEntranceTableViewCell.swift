//
//  YXDebugJSEntranceTableViewCell.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/1/21.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXDebugJSEntranceTableViewCell: UITableViewCell {
    lazy var dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.textColor = QMUITheme().textColorLevel1()
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        return dateLabel
    }()
    
    lazy var closeBtnTipsLabel: UILabel = {
        let closeBtnTipsLabel = UILabel()
        closeBtnTipsLabel.textColor = QMUITheme().textColorLevel1()
        closeBtnTipsLabel.font = UIFont.systemFont(ofSize: 12)
        closeBtnTipsLabel.textAlignment = .right
        return closeBtnTipsLabel
    }()
    
    lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.textColor = QMUITheme().textColorLevel1()
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        return nameLabel
    }()
    
    lazy var urlLabel: UILabel = {
        let urlLabel = UILabel()
        urlLabel.textColor = QMUITheme().textColorLevel1()
        urlLabel.font = UIFont.systemFont(ofSize: 14)
        return urlLabel
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
        
        self.initialUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // cell 高度 = 12 + 21 + 8 + 21 + 8 + 21 + 12 = 103
    func initialUI() {
        contentView.addSubview(self.dateLabel)
        
        self.dateLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(14)
            make.top.equalToSuperview().offset(12)
            make.height.equalTo(21)
            make.width.lessThanOrEqualTo(208)
        }
        
        self.dateLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 250.0), for: .horizontal)
        self.dateLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 751.0), for: .horizontal)
        
        contentView.addSubview(self.closeBtnTipsLabel)
        self.closeBtnTipsLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self.dateLabel.snp.trailing).offset(8)
            make.centerY.equalTo(self.dateLabel.snp.centerY)
            make.trailing.equalToSuperview().offset(-32)
        }
        
        contentView.addSubview(self.nameLabel)
        self.nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.dateLabel.snp.bottom).offset(8)
            make.height.equalTo(21);
            make.leading.equalTo(self.dateLabel.snp.leading)
            make.trailing.equalToSuperview().offset(-32)
        }
        
        contentView.addSubview(self.urlLabel)
        self.urlLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.nameLabel.snp.bottom).offset(8)
            make.height.equalTo(21);
            make.leading.equalTo(self.dateLabel.snp.leading)
            make.bottom.equalToSuperview().offset(-12)
            make.trailing.equalToSuperview().offset(-32)
        }
    }
}
