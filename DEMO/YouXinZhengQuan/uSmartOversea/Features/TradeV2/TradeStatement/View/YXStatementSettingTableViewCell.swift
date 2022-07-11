//
//  YXTableViewCell.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/7/17.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXStatementSettingTableViewCell: UITableViewCell {
    typealias ClickAction = () -> Void
    var tipClickBlock:ClickAction?
    var languageBlock:ClickAction?
    
    lazy var titleLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .normalFont14()
        label.text = YXLanguageUtility.kLang(key: "language_setting")
        return label
    }()
    
    lazy var tipsBtn:YXExpandAreaButton = {
        let btn = YXExpandAreaButton()
        btn.expandX = 15
        btn.expandY = 15
        btn.setImage(UIImage.init(named: "smart_type_info"), for: .normal)
        btn.addTarget(self, action: #selector(tipsAction(_ :)), for: .touchUpInside)
        
        return btn
    }()

    lazy var moreBtn:QMUIButton = {
        let btn = QMUIButton()
        btn.titleLabel?.font = .normalFont14()
        btn.setTitle(YXLanguageUtility.kLang(key: "mine_simplified"), for: .normal)
        btn.setImage(UIImage(named: "mine_arrow"), for: .normal)
        btn.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        btn.spacingBetweenImageAndTitle = 1
        btn.contentHorizontalAlignment = .right
        btn.imagePosition = .right
        btn.addTarget(self, action: #selector(languageAction(_ :)), for: .touchUpInside)
        
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
        contentView.backgroundColor = QMUITheme().foregroundColor()
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(tipsBtn)
        contentView.addSubview(moreBtn)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
        tipsBtn.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right).offset(4)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(15)
            
        }
        moreBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
    }
    
    var type:TradeStatementLanguageType = .chinese {
        didSet {
            self.moreBtn.setTitle(type.text, for: .normal)
            self.moreBtn.spacingBetweenImageAndTitle = 1
        }
    }
    
    @objc func languageAction(_ sender:QMUIButton) {
        self.languageBlock?()
    }
    @objc func tipsAction(_ sender:QMUIButton) {
        self.tipClickBlock?()
    }
}
