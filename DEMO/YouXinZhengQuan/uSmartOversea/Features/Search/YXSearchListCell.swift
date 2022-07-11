//
//  YXSearchListCell.swift
//  uSmartOversea
//
//  Created by ZhiYun Huang on 2019/4/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXSearchListCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var rightBtn: UIButton!
    
    var rightBtnAction :((UIButton)->())?
    
    lazy var stockInfoView: YXStockBaseinfoView = {
        return YXStockBaseinfoView()
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.isHidden = true
        subTitleLabel.isHidden = true
        backgroundColor = QMUITheme().foregroundColor()
        qmui_selectedBackgroundColor = QMUITheme().backgroundColor()
        
        addSubview(stockInfoView)
        stockInfoView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.bottom.equalToSuperview()
            make.right.lessThanOrEqualTo(rightBtn.snp.left).offset(-5)
        }
        subTitleLabel.font = .systemFont(ofSize: 12)
    }

    @IBAction func buttonAction(_ sender: UIButton) {
        rightBtnAction?(sender)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
