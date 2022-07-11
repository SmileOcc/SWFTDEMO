//
//  STLSettingCell.swift
// XStarlinkProject
//
//  Created by odd on 2021/8/30.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

class STLSettingCell: UITableViewCell {


    
    
    var model: STLSettingModel? {
        didSet {
            self.titleLabel.text = model?.title ?? ""
            self.detailLabel.text = model?.detailTitle ?? ""
            self.arrowView.isHidden = !(model?.isArrow ?? true)
            
            self.detailLabel.snp.updateConstraints { make in
                make.trailing.equalTo(self.contentView.snp.trailing).offset(self.arrowView.isHidden ? -14 : -30)
            }
            
        }
    }
    
    func showLine(show: Bool) {
        self.divider.isHidden = !show
    }
    
    @objc func switchStateAction() {
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = OSSVThemesColors.stlWhiteColor()
        self.selectionStyle = .none
        
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.detailLabel)
        self.contentView.addSubview(self.arrowView)
        self.contentView.addSubview(self.divider)
        
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.contentView.snp.leading).offset(14)
            make.centerY.equalTo(self.contentView.snp.centerY)
        }
        
        self.detailLabel.snp.makeConstraints { make in
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-30)
            make.centerY.equalTo(self.contentView.snp.centerY)
        }
        
        self.arrowView.snp.makeConstraints { make in
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-14)
            make.size.equalTo(CGSize.init(width: 12, height: 12))
            make.centerY.equalTo(self.contentView)
        }
        
        self.divider.snp.makeConstraints { make in
            make.leading.equalTo(self.contentView.snp.leading).offset(14)
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-14)
            make.height.equalTo(0.5)
            make.bottom.equalTo(self.contentView.snp.bottom)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    //MARK: - setter
    
    var arrowView: UIImageView = {
        let imgView = UIImageView.init(image: UIImage.init(named: "arrow_12"))
        imgView.convertUIWithARLanguage()
        return imgView
    }()
    
    var switchView: UISwitch = {
        let switchView = UISwitch.init()
        switchView.addTarget(self, action: #selector(switchStateAction), for: .valueChanged)
        return switchView
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.zero)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = OSSVThemesColors.col_0D0D0D()
        label.textAlignment = .left
        if OSSVSystemsConfigsUtils.isRightToLeftShow() {
            label.textAlignment = .right
        }
        return label
    }()
    
    var detailLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = OSSVThemesColors.col_0D0D0D()
        label.textAlignment = .left
        if OSSVSystemsConfigsUtils.isRightToLeftShow() {
            label.textAlignment = .right
        }
        return label
    }()
    
    
    var badgeView: UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 16, height: 16))
        view.backgroundColor = OSSVThemesColors.col_FF4E6A()
        view.layer.cornerRadius = 8;
        view.clipsToBounds = true
        return view
    }()
    
    var divider: UIView = {
        let view = UIView.init(frame: CGRect.zero)
        view.backgroundColor = OSSVThemesColors.col_EEEEEE()
        return view
    }()
}
