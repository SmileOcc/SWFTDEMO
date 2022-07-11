//
//  YXStockDetailKlineSettingCell.swift
//  uSmartOversea
//
//  Created by youxin on 2019/12/17.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXStockDetailKlineSettingCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {
        self.selectionStyle = .none
        self.backgroundColor = QMUITheme().foregroundColor()
        contentView.backgroundColor = QMUITheme().foregroundColor()
        contentView.addSubview(titleLabel)

        contentView.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.75)
        }

        contentView.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.left.trailing.bottom.equalToSuperview()
            make.height.equalTo(1)
        }

    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            for view in self.subviews {
                if NSStringFromClass(object_getClass(view) ?? UIView.self).contains("Reorder") {
                    for subview in view.subviews {
                        if subview.isKind(of: UIImageView.self), let imageView = subview as? UIImageView  {
                            imageView.image = UIImage(named: "edit_rank")
                            imageView.contentMode = .center
                            imageView.snp.remakeConstraints { (make) in
                                make.right.equalTo(self).offset(-16)
                                make.centerY.equalTo(self)
                                make.width.height.equalTo(20)
                            }
                        }
                    }
                }
            }
            
        }
    }


    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "--"
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14)
        if YXUserManager.isENMode() {
            label.font = UIFont.systemFont(ofSize: 12)
        }
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()

    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().separatorLineColor()
        return view
    }()

}
