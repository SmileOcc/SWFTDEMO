//
//  YXGroupListCell.swift
//  uSmartOversea
//
//  Created by ysx on 2021/12/3.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXGroupListCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        selectedGroup = false
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var nameLabel : UILabel = {
        let lable = UILabel()
        lable.font = .systemFont(ofSize: 16)
        lable.textAlignment = .left
        lable.textColor = QMUITheme().textColorLevel1()
        return lable
    }()
    
    var selectedGroup:Bool {
        didSet{
            if selectedGroup == true {
                nameLabel.textColor = QMUITheme().mainThemeColor()
            }else {
                nameLabel.textColor = QMUITheme().textColorLevel1()
            }
        }
    }
    
    
    func initUI() {
        backgroundColor = QMUITheme().popupLayerColor()
        self.selectionStyle = .none
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(16)
            make.right.equalTo(-16)
        }
    }
}
