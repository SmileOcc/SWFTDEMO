//
//  YXDebugTableViewCell.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/1/19.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

struct DebugTableViewCellData {
    
    var image: UIImage?
    var title: String?
    var describeStr: String?
    var showArrow = false
    var showLine = true
    var describeColor: UIColor?
    
    init() {
        
    }
    
    init(image: UIImage?, title: String?, describeStr: String?, showArrow: Bool, showLine: Bool) {
        self.image = image
        self.title = title
        self.describeStr = describeStr
        self.showArrow = showArrow
        self.showLine = showLine
        self.describeColor = QMUITheme().textColorLevel1()
    }
}

class YXDebugTableViewCell: UITableViewCell {
    
    var cellModel = DebugTableViewCellData.init()
    
    var titleLab: UILabel = {
        let lable = UILabel()
        lable.font = UIFont.systemFont(ofSize: 16)
        lable.textColor = QMUITheme().textColorLevel1()
        return lable
    }()
    
    var imageV: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    var arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "user_next")
        return imageView
    }()
    
    var lineView: UIView = {
        let line = UIView()
        line.backgroundColor = QMUITheme().separatorLineColor()
        return line
    }()
    
    var describeLab: UILabel = {
        let lab = UILabel()
        return lab
    }()
    
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
        
        self.initialUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialUI()  {
        
        contentView.addSubview(titleLab)
        contentView.addSubview(imageV)
        contentView.addSubview(arrowImageView)
        contentView.addSubview(lineView)
        contentView.addSubview(describeLab)
        
        imageV.snp.makeConstraints { (make) in
            make.width.height.equalTo(20)
            make.centerY.equalTo(self)
            make.left.equalTo(18)
        }
        
        titleLab.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.left.equalTo(58)
        }
        
        arrowImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.right.equalTo(self).offset(-18)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self)
            make.left.equalTo(self).offset(18)
            make.right.equalTo(self).offset(-18)
            make.height.equalTo(1)
        }
        
        describeLab.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.right.equalTo(self).offset(-34)
        }
        
        self.selectionStyle = .none
        
    }
    
    func refreshUI () {
        
        if let image = cellModel.image {
            imageV.isHidden = false
            imageV.image = image
            titleLab.snp.updateConstraints { (make) in
                make.left.equalTo(58)
            }
        }else {
            imageV.isHidden = true
            titleLab.snp.updateConstraints { (make) in
                make.left.equalTo(18)
            }
        }
        
        if let title = cellModel.title {
            titleLab.text = title
        }
        
        if let describeStr = cellModel.describeStr {
            describeLab.text = describeStr
        }
        
        if cellModel.showArrow {
            arrowImageView.isHidden = false
            describeLab.snp.updateConstraints { (make) in
                make.right.equalTo(-34)
            }
        }else {
            arrowImageView.isHidden = true
            describeLab.snp.updateConstraints { (make) in
                make.left.equalTo(18)
            }
        }
        
        describeLab.textColor = cellModel.describeColor
        lineView.isHidden = !cellModel.showLine
    }
}

