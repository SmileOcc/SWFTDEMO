//
//  YXCoursewareCell.swift
//  uSmartEducation
//
//  Created by usmart on 2021/11/14.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import SnapKit

class YXCoursewareCell: UITableViewCell {
    
    lazy var lessonImage : UIImageView = {
       let img = UIImageView()
        img.layer.borderWidth = 1
        img.layer.borderColor = UIColor.qmui_color(withHexString: "#EAEAEA")?.cgColor
        return img
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(lessonImage)
        self.contentView.backgroundColor = QMUITheme().foregroundColor()
        lessonImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().inset(0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
