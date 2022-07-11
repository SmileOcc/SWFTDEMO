//
//  CountryRegionCell.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/5.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

class CountryRegionCell: UITableViewCell {
    
    weak var detailTextfield:CountryDisplayField?

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
        let detailTextfield = CountryDisplayField(frame: .zero)
        detailTextfield.placeholder = STLLocalizedString_("text_address_select_city")!
        contentView.addSubview(detailTextfield)
        detailTextfield.snp.makeConstraints { make in
            make.leading.equalTo(11)
            make.trailing.equalTo(-11)
            make.bottom.equalTo(0)
            make.top.equalTo(14)
        }
        
        detailTextfield.deviderColor = OSSVThemesColors.col_CCCCCC()
        detailTextfield.floatPlaceholderColor = OSSVThemesColors.col_999999()
        self.detailTextfield = detailTextfield
        
//        detailTextfield.errorMessage = "Error"
        
        let accerryView = YYAnimatedImageView()
        accerryView.image = UIImage(named: "address_arr")
        accerryView.convertUIWithARLanguage()
        detailTextfield.traillingView?.addSubview(accerryView)
        accerryView.snp.makeConstraints { make in
            make.width.height.equalTo(12)
            make.trailing.equalTo(detailTextfield.traillingView!.snp.trailing)
            make.centerY.equalTo(detailTextfield.traillingView!.snp.centerY)
        }
        
//        detailTextfield.contentText = "ajsfhkjasfjgasfhjsa\nashjgdahsjgd\nashdghasgd\n"
//        detailTextfield.contentText = nil
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }


}
