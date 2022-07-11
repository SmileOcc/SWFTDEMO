//
//  AddressLocateCell.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/5.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

class AddressLocateCell: UITableViewCell {
    
    
    weak var detailTextfield:CustomTalingTextField?
    
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
        }
        let detailTextfield = CustomTalingTextField(frame: .zero)
        detailTextfield.placeholder = STLLocalizedString_("user_address_street")!
        contentView.addSubview(detailTextfield)
        detailTextfield.snp.makeConstraints { make in
            make.leading.equalTo(11)
            make.trailing.equalTo(-11)
            make.bottom.equalTo(0)
            make.top.equalTo(0)
        }
        
        detailTextfield.deviderColor = OSSVThemesColors.col_CCCCCC()
        detailTextfield.floatPlaceholderColor = OSSVThemesColors.col_999999()
        self.detailTextfield = detailTextfield
        
//        detailTextfield.errorMessage = "Error"
        
        let locateBtn = TopIconButton(frame: .zero)
        locateBtn.label?.text = STLLocalizedString_("Locate")
        locateBtn.imgView?.image = UIImage(named: "address_locate")
        detailTextfield.traillingView?.addSubview(locateBtn)
        locateBtn.snp.makeConstraints { make in
            make.edges.equalTo(detailTextfield.traillingView!)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
