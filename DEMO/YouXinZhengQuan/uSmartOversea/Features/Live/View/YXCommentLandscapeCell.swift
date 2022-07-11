//
//  YXCommentLandscapeCell.swift
//  uSmartOversea
//
//  Created by suntao on 2021/2/3.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXCommentLandscapeCell: UITableViewCell {

    var item: YXCommentItem? {
        didSet {
            commentLabel.attributedText = item?.attributeString
            commentLabel.layer.cornerRadius = 4
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
            make.left.equalToSuperview().offset(5)
            make.top.equalToSuperview().offset(2)
            make.bottom.equalToSuperview().offset(-2)
            make.right.lessThanOrEqualToSuperview().offset(-5)
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
