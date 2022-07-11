//
//  AddressCountrySelectCell.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/6.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

class AddressCountrySelectCell: UITableViewCell {
    
    weak var countrynameLbl:UILabel?
    weak var checkmark:UIImageView?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)        
        let countryName = UILabel()
        countryName.numberOfLines = 0
        contentView.addSubview(countryName)
        countrynameLbl = countryName
        countryName.font = UIFont.systemFont(ofSize: 14)
        countryName.convertTextAlignmentWithARLanguage()
        countryName.snp.makeConstraints { make in
            make.leading.equalTo(contentView.snp.leading).offset(14)
            make.trailing.equalTo(contentView.snp.trailing).offset(-14)
            make.top.equalTo(contentView.snp.top).offset(15)
            make.bottom.equalTo(contentView.snp.bottom).offset(-15)
        }
        selectionStyle = .none
        
        let separatorV = UIView()
        contentView.addSubview(separatorV)
        separatorV.backgroundColor = OSSVThemesColors.col_EEEEEE()
        separatorV.snp.makeConstraints { make in
            make.leading.trailing.equalTo(0)
            make.bottom.equalTo(contentView.snp.bottom)
            make.height.equalTo(0.5)
        }
        
        let checkMark = UIImageView(image: UIImage(named: "address_check_mark"))
        contentView.addSubview(checkMark)
        checkMark.snp.makeConstraints { make in
            make.width.equalTo(24)
            make.height.equalTo(26)
            make.trailing.equalTo(contentView.snp.trailing).offset(-14)
            make.centerY.equalTo(contentView.snp.centerY)
        }
        self.checkmark = checkMark
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        countrynameLbl?.text = nil
        checkmark?.isHidden = true
        isSelected = false
    }
    
    override var isSelected: Bool{
        didSet{
            checkmark?.isHidden = !isSelected
        }
    }
    
}
