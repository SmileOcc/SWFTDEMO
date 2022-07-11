//
//  YXCommentCell.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/9/8.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXCommentCell: UITableViewCell {
    
    var item: YXCommentItem? {
        didSet {
            commentLabel.attributedText = item?.attributeString
            commentLabel.layer.cornerRadius = 15
            commentLabel.layer.masksToBounds = true
        }
    }
    
    lazy var commentLabel: QMUILabel = {
        let label = QMUILabel()
        label.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        label.lineBreakMode = .byWordWrapping
        label.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(commentLabel)
        
        commentLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(2)
            make.height.greaterThanOrEqualTo(28)
            make.right.lessThanOrEqualToSuperview().offset(-68)
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
