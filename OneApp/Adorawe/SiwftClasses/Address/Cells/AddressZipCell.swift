//
//  AddressZipCell.swift
//  Adorawe
//
//  Created by fan wang on 2021/11/26.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

class AddressZipCell: UITableViewCell {

    var isFirstCell = false {
        didSet{
            detailTextfield?.snp.updateConstraints({ make in
                make.top.equalTo(isFirstCell ? 14 : 0 )
            })
        }
    }
    
    var keyBoardType:UIKeyboardType?{
        didSet{
            if let type = keyBoardType {
                detailTextfield?.keyBoardType = type
            }
        }
    }
    
    
    
    weak var detailTextfield:ZipCodeInputField?

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
        let detailTextfield = ZipCodeInputField(frame: .zero)
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
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
