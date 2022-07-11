//
//  YXImportStockCell.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2019/7/4.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXImportStockCell: QMUITableViewCell {
    
    var importStock: ImportSecu?

    lazy var rightBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "import_select"), for: .normal)
        button.setImage(UIImage(named: "import_selected"), for: .selected)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        textLabel?.font = .systemFont(ofSize: 16)
        textLabel?.textColor = QMUITheme().textColorLevel1()
        
        detailTextLabel?.font = .systemFont(ofSize: 12)
        detailTextLabel?.textColor = QMUITheme().textColorLevel2()
        
        contentView.addSubview(rightBtn)
        
        rightBtn.snp.makeConstraints { (make) in
            make.right.height.equalTo(self)
            make.width.equalTo(self.snp.height)
            make.centerY.equalTo(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
