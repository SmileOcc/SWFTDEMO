//
//  SearchBaseCell.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/2/28.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class SearchBaseCell: YXTableViewCell {

    var searchWord: String = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func initialUI() {
        super.initialUI()
        backgroundColor = QMUITheme().foregroundColor()

        let selectedBgView = UIView()
        selectedBgView.backgroundColor = QMUITheme().backgroundColor()
        selectedBackgroundView = selectedBgView
    }
    
}
