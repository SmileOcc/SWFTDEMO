//
//  AddressPhoneCell.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/5.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

class AddressPhoneCell: UITableViewCell {
    
    var isFirstCell = false {
        didSet{
            detailTextfield?.snp.updateConstraints({ make in
                make.top.equalTo(isFirstCell ? 14 : 0 )
            })
        }
    }
    
    weak var detailTextfield:PhoneNumTextField?

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
        let detailTextfield = PhoneNumTextField(frame: .zero)
        detailTextfield.placeholder = STLLocalizedString_("CountryRegion")!
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
        
//        self.detailTextfield?.regionCode = "007"
//        self.detailTextfield?.errorMessage = "Error"
        
//        let locateBtn = TopIconButton(frame: .zero)
//        locateBtn.label?.text = STLLocalizedString_("Locate")
//        locateBtn.imgView?.image = UIImage(named: "locationMe")
////        detailTextfield.inputContainer?.addArrangedSubview(locateBtn)
//        locateBtn.snp.makeConstraints { make in
//            make.height.equalTo(35)
//        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
