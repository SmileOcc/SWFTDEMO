//
//  YXMineCommonViewCell.swift
//  uSmartOversea
//
//  Created by mac on 2019/4/8.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

struct CommonCellData {
    var image: UIImage?
    /// 左侧图片。没有url时，placeholder就是图片名字
    var imageUrl:(url:String,placeholder:String)?
    var title: String?
    var describeStr: String?
    var showArrow = false
    var showLine = true
    var describeColor: UIColor?
    var describeImage: UIImage?
    //描述图片的链接。没有url时，placeholder就是图片名字
    var describeImgUrl: (url:String,placeholder:UIImage?)?
    
    init() {
        
    }
    ///图像，标题，描述，箭头，描述图片
    init(imageUrl: (url:String,placeholder:String)?, title: String?, describeStr: String?, showArrow: Bool, showLine: Bool, describeImgUrl: (url:String,placeholder:UIImage?)) {
        self.imageUrl = imageUrl
        self.title = title
        self.describeStr = describeStr
        self.showArrow = showArrow
        self.showLine = showLine
        self.describeColor = QMUITheme().textColorLevel1()
        self.describeImgUrl = describeImgUrl
    }
    ///图像，标题，描述，箭头，描述图片
    init(image: UIImage?, title: String?, describeStr: String?, showArrow: Bool, showLine: Bool, describeImage: UIImage) {
        self.image = image
        self.title = title
        self.describeStr = describeStr
        self.showArrow = showArrow
        self.showLine = showLine
        self.describeColor = QMUITheme().textColorLevel1()
        self.describeImage = describeImage
    }
    ///图像，标题，描述，箭头，描述颜色
    init(image: UIImage?, title: String?, describeStr: String?, showArrow: Bool, showLine: Bool, describeColor: UIColor?) {
        self.image = image
        self.title = title
        self.describeStr = describeStr
        self.showArrow = showArrow
        self.showLine = showLine
        self.describeColor = describeColor
    }
    ///图像，标题，描述，箭头
    init(image: UIImage?, title: String?, describeStr: String?, showArrow: Bool, showLine: Bool) {
        self.image = image
        self.title = title
        self.describeStr = describeStr
        self.showArrow = showArrow
        self.showLine = showLine
        self.describeColor = QMUITheme().textColorLevel1()
        self.describeImage = nil
    }
}
//uer_chanage_pwd
class YXMineCommonViewCell: QMUITableViewCell {
    let IMAGE_V_WIDTH: CGFloat = 26
    let IMAGE_V_HEIGHT: CGFloat = 26
    
    var cellModel = CommonCellData.init()
    //标题
    var titleLab: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: uniSize(14))
        label.textColor = QMUITheme().textColorLevel1()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    //
    var imageV: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    //箭头
    var arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "user_next")
        return imageView
    }()
    //底部的横线
    var lineView: UIView = {
        let line = UIView()
        line.backgroundColor = QMUITheme().separatorLineColor()
        return line
    }()
    //描述
    var describeLab: UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 14)
        return lab
    }()
    
    var describeImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
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
        backgroundColor = QMUITheme().foregroundColor()
        contentView.addSubview(titleLab)
        contentView.addSubview(imageV)
        contentView.addSubview(arrowImageView)
        contentView.addSubview(lineView)
        contentView.addSubview(describeLab)
        contentView.addSubview(describeImageView)
        
        qmui_selectedBackgroundColor = QMUITheme().backgroundColor()
        //左侧的图片
        imageV.snp.makeConstraints { (make) in
            make.width.equalTo(IMAGE_V_WIDTH)
            make.height.equalTo(IMAGE_V_HEIGHT)
            make.centerY.equalTo(self)
            make.left.equalTo(16)
        }
        //标题
        titleLab.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.left.equalTo(self).offset(53)
        }
        
        //右侧的箭头
        arrowImageView.snp.makeConstraints { (make) in
            //make.left.equalTo(titleLab.snp.right).offset(5)
            make.centerY.equalTo(self)
            make.right.equalTo(self).offset(-18)
        }
        /// 底部横线
        lineView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self)
            make.left.equalTo(self).offset(18)
            make.right.equalTo(self).offset(-18)
            make.height.equalTo(0.5)
        }
        /// 右侧的描述
        describeLab.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.right.equalTo(self).offset(-34)
        }
        //描述左侧的描述图片
        describeImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.right.equalTo(describeLab.snp.left).offset(-10)
        }
        
      //  self.selectionStyle = .none
        
    }

    func refreshUI() {
        
        if let image = cellModel.image {
            imageV.isHidden = false
            imageV.image = image
            titleLab.snp.updateConstraints { (make) in
                make.left.equalTo(self).offset(58)
            }
        }
        else if let imageUrl = cellModel.imageUrl {
            if imageUrl.url.count > 0 {
                let transformer = SDImageResizingTransformer(size: CGSize(width: IMAGE_V_WIDTH * UIScreen.main.scale, height: IMAGE_V_HEIGHT * UIScreen.main.scale), scaleMode: .aspectFill)
                imageV.sd_setImage(with: URL(string: imageUrl.url), placeholderImage: UIImage.init(named: imageUrl.placeholder), options: [], context: [SDWebImageContextOption.imageTransformer: transformer])
            } else if imageUrl.placeholder.count > 0 {
                imageV.isHidden = false
                imageV.image = UIImage.init(named: imageUrl.placeholder)
                titleLab.snp.updateConstraints { (make) in
                    make.left.equalTo(self).offset(58)
                }
            } else {
                imageV.isHidden = true
                titleLab.snp.updateConstraints { (make) in
                    make.left.equalTo(self).offset(18)
                }
            }
        }
        else {
            imageV.isHidden = true
            titleLab.snp.updateConstraints { (make) in
                make.left.equalTo(self).offset(18)
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
                make.right.equalTo(self).offset(-40)
            }
        }else {
            arrowImageView.isHidden = true
            describeLab.snp.updateConstraints { (make) in
                make.right.equalTo(self).offset(-17)
            }
        }
        
        if cellModel.describeImage != nil {
            describeImageView.image  = cellModel.describeImage
        }
        else if let describeImgUrl = cellModel.describeImgUrl {
            describeImageView.sd_setImage(with: URL(string: describeImgUrl.url), placeholderImage: describeImgUrl.placeholder) {[weak self] (image, error, cacheType, url) in
                if error == nil {
                    self?.cellModel.describeImage = image
                }
            }
        }
        else {
            //describeImageView.image  = nil
        }
        
        describeLab.textColor = cellModel.describeColor
        lineView.isHidden = !cellModel.showLine
    }
}
