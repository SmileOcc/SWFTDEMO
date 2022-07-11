//
//  YXPushSwitchCell.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2020/1/20.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit


class YXPushSwitchCell: UITableViewCell {
    
    @objc var stChangeCallBack: ((_ model: YXStareSignalSettingModel?) -> ())?
    
    @objc var label: UILabel
    
    @objc var st: UISwitch
    
    @objc var model: YXStareSignalSettingModel? {
        didSet {
            self.label.text = self.model?.signalName
            if let on = self.model?.defult {
                self.st.setOn(on == 1, animated: false)
            } else {
                self.st.setOn(false, animated: false)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.label = UILabel.init(text: "--", textColor: QMUITheme().textColorLevel1(), textFont: UIFont.systemFont(ofSize: 14))
        self.st = UISwitch.init()
        st.onTintColor = QMUITheme().themeTintColor()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension YXPushSwitchCell {
    func initUI() {
        self.selectionStyle = .none
        st.transform = CGAffineTransform.init(scaleX: 0.75, y: 0.75)
        st.addTarget(self, action: #selector(self.stValueChange(_:)), for: .valueChanged)
        
        contentView.addSubview(label)
        contentView.addSubview(st)
        
        label.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
        
        st.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
    }
    
    @objc func stValueChange(_ sender: UISwitch) {
        self.model?.defult = sender.isOn ? 1 : 0
        stChangeCallBack?(self.model)
    }
}

