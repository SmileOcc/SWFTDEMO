//
//  SetAsDefaultCell.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/5.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import SnapKit

class SetAsDefaultCell: UITableViewCell {
    
    weak var defaultSwitch:UISwitch?
    
    var isDefault:Bool?{
        set{
            defaultSwitch?.isOn = newValue ?? false
        }
        get{
            defaultSwitch?.isOn
        }
    }

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
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(self)
            make.height.equalTo(50)
        }
        
        let devider = UIView(frame: .zero)
        devider.backgroundColor = OSSVThemesColors.col_EEEEEE()
        contentView.addSubview(devider)
        devider.snp.makeConstraints { make in
            make.leading.equalTo(11+14)
            make.trailing.equalTo(-25)
            make.top.equalTo(0)
            make.height.equalTo(1)
        }
        
        let titleLbl = UILabel(frame: .zero)
        contentView.addSubview(titleLbl)
        titleLbl.snp.makeConstraints { make in
            make.top.equalTo(18)
            make.leading.equalTo(14+11)
        }
        titleLbl.text = STLLocalizedString_("SetDefaultAddress")
        titleLbl.font = UIFont.systemFont(ofSize: 14)
        titleLbl.textColor = OSSVThemesColors.col_0D0D0D()
        
        let defaultSwitch = UISwitch(frame: .zero)
        contentView.addSubview(defaultSwitch)
        defaultSwitch.snp.makeConstraints { make in
            make.trailing.equalTo(devider.snp.trailing)
            make.top.equalTo(11.5)
        }
        defaultSwitch.onTintColor = OSSVThemesColors.col_0D0D0D()
        self.defaultSwitch = defaultSwitch
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
