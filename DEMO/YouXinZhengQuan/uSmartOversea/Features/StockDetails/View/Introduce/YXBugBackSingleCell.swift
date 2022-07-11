//
//  YXBugBackSingleCell.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/7/22.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit


class YXBugBackSingleCell: UITableViewCell {

    let firstLabel = QMUILabel.init(with: QMUITheme().textColorLevel1(), font: UIFont.systemFont(ofSize: 14) , text: "--")
    let secondLabel = QMUILabel.init(with: QMUITheme().textColorLevel1(), font: UIFont.systemFont(ofSize: 14), text: "--")
    let thirdLabel = QMUILabel.init(with: QMUITheme().textColorLevel1(), font: UIFont.systemFont(ofSize: 14), text: "--")
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var isHiddenFirst: Bool = false {
        didSet {
            if isHiddenFirst {
                if firstLabel.isHidden == false {
                    firstLabel.isHidden = true
                    secondLabel.textAlignment = .left
                    secondLabel.snp.remakeConstraints { (make) in
                        make.leading.equalToSuperview().offset(16)
                        make.top.bottom.equalToSuperview()
                    }
                }
            } else {
                if firstLabel.isHidden {
                    firstLabel.isHidden = false
                    secondLabel.textAlignment = .right
                    secondLabel.snp.remakeConstraints { (make) in
                        make.top.bottom.equalToSuperview()
                        make.trailing.equalToSuperview().offset(uniHorLength(-145))
                    }
                }
            }
        }
    }
    
    func initUI() {
    
        backgroundColor = QMUITheme().foregroundColor()
        self.selectionStyle = .none
        thirdLabel.numberOfLines = 4
        thirdLabel.textAlignment = .right
        contentView.addSubview(firstLabel)
        contentView.addSubview(secondLabel)
        contentView.addSubview(thirdLabel)
        firstLabel.textAlignment = .left
        secondLabel.textAlignment = .right
        firstLabel.minimumScaleFactor = 0.5
        secondLabel.minimumScaleFactor = 0.5
        firstLabel.adjustsFontSizeToFitWidth = true
        secondLabel.adjustsFontSizeToFitWidth = true
        
        firstLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(86)
        }
        secondLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview().offset(uniHorLength(-145))
            make.width.equalTo(86)
        }
        
        thirdLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
            make.leading.equalTo(secondLabel.snp.trailing).offset(20)
        }
    }
}
