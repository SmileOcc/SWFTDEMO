//
//  HDActionSheetTableViewCell.swift
//  HDPublicUIProject
//
//  Created by MountainZhu on 2020/6/18.
//  Copyright © 2020 航电. All rights reserved.
//

import UIKit

class HDActionSheetTableViewCell: UITableViewCell {
    //MARK: - public property
    internal var signlabel: UILabel!
    
    //MARK: - system cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        signlabel = UILabel()
        self.contentView.addSubview(signlabel)
        signlabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let centerX = NSLayoutConstraint(item: signlabel!, attribute: .centerX, relatedBy: .equal, toItem: self.contentView, attribute: .centerX, multiplier: 1.0, constant: 0)
        let centerY = NSLayoutConstraint(item: signlabel!, attribute: .centerY, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1.0, constant: 0)
        self.contentView.addConstraints([centerX, centerY])
    }

}
