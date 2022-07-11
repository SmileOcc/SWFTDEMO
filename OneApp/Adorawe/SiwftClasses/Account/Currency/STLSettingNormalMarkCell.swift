//
//  STLSettingNormalMarkCell.swift
// XStarlinkProject
//
//  Created by odd on 2021/8/31.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

class STLSettingNormalMarkCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.backgroundColor = OSSVThemesColors.stlClearColor()
        
        self.contentView.addSubview(self.bgView)
        self.bgView.addSubview(self.contentLabel)
        self.bgView.addSubview(self.accesoryImageView)
        self.bgView.addSubview(self.lineView)
        
        self.bgView.snp.makeConstraints { make in
            make.leading.equalTo(self.contentView.snp.leading).offset(12)
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-12)
            make.top.bottom.equalTo(self.contentView)
        }
        self.contentLabel.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets.init(top: 0, left: 14, bottom: 0, right: 14))
            make.centerY.equalTo(self.bgView.snp.centerY)
        }
        
        self.accesoryImageView.snp.makeConstraints { make in
            make.trailing.equalTo(self.bgView.snp.trailing).offset(-14)
            make.centerY.equalTo(self.bgView.snp.centerY)
            make.size.equalTo(CGSize.init(width: 24, height: 24))
        }
        
        self.lineView.snp.makeConstraints { make in
            make.leading.equalTo(self.bgView.snp.leading).offset(14)
            make.trailing.equalTo(self.bgView.snp.trailing).offset(-14)
            make.bottom.equalTo(self.bgView.snp.bottom)
            make.height.equalTo(0.5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func showLine(show: Bool) {
        self.lineView.isHidden = !show
    }
    
    var isMarked: Bool = false {
        didSet {
            self.contentLabel.font = isMarked ?  UIFont.boldSystemFont(ofSize: 14) : UIFont.systemFont(ofSize: 14)
            self.accesoryImageView.isHidden = !isMarked
        }
    }
    
    //MARK: - setter
    
    var bgView: UIView = {
        let view = UIView.init()
        view.backgroundColor = OSSVThemesColors.stlWhiteColor()
        return view
    }()
    var contentLabel: UILabel = {
        let label = UILabel.init()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = OSSVThemesColors.col_0D0D0D()
        label.textAlignment = OSSVSystemsConfigsUtils.isRightToLeftShow() ? NSTextAlignment.right : NSTextAlignment.left
        return label
    }()
    
    var accesoryImageView: UIImageView = {
        let imageView = UIImageView.init(image: UIImage.init(named: "selected_mark_24"))
        return imageView
    }()
    
    var lineView: UIView = {
        let view = UIView.init()
        view.backgroundColor = OSSVThemesColors.col_EEEEEE()
        return view
    }()

}
