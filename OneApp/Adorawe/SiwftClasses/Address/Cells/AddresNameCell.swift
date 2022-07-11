//
//  AddresNameCell.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/5.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

class AddresNameCell: UITableViewCell {
    
    weak var firstNameTextfield:NormalInputFiled?
    weak var lastNameTextfield:NormalInputFiled?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(self)
//            make.height.equalTo(90)
        }
        let firstNameTextfield = NormalInputFiled(frame: .zero)
        contentView.addSubview(firstNameTextfield)
        firstNameTextfield.snp.makeConstraints { make in
            make.leading.equalTo(11)
            make.trailing.equalTo(contentView.snp.centerX).offset(-2.5)
            make.bottom.lessThanOrEqualTo(0)
            make.top.equalTo(14)
        }
        
        firstNameTextfield.deviderColor = OSSVThemesColors.col_CCCCCC()
        firstNameTextfield.floatPlaceholderColor = OSSVThemesColors.col_999999()
        firstNameTextfield.placeholder = STLLocalizedString_("FirstName")!
        
        let lastNameTextfield = NormalInputFiled(frame: .zero)
        contentView.addSubview(lastNameTextfield)
        lastNameTextfield.snp.makeConstraints { make in
            make.leading.equalTo(contentView.snp.centerX).offset(2.5)
            make.trailing.equalTo(-11)
            make.bottom.lessThanOrEqualTo(0)
            make.top.equalTo(14)
        }
        
        lastNameTextfield.deviderColor = OSSVThemesColors.col_CCCCCC()
        lastNameTextfield.floatPlaceholderColor = OSSVThemesColors.col_999999()
        lastNameTextfield.placeholder = STLLocalizedString_("LastName")!
        
        self.firstNameTextfield = firstNameTextfield
        self.lastNameTextfield = lastNameTextfield
        
//        firstNameTextfield.errorMessage = "Error"
//        lastNameTextfield.errorMessage = "Error"
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
