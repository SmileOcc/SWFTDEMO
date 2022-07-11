//
//  YXPersonalDataTableViewCell.swift
//  uSmartOversea
//
//  Created by rrd on 2019/5/17.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit


class YXPersonalDataTableViewCell: QMUITableViewCell {
    let IMAGE_V_WIDTH: CGFloat = 20
    let IMAGE_V_HEIGHT: CGFloat = 20
    
    let DESCRIBE_IMAGE_V_WIDTH: CGFloat = 60
    let DESCRIBE_IMAGE_V_HEIGHT: CGFloat = 60

    var cellModel = CommonCellData.init()
    //标题
    var titleLab: UILabel = {
        let lable = UILabel()
        lable.font = UIFont.systemFont(ofSize: 14)
        lable.textColor = QMUITheme().textColorLevel1()
        return lable
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
        lab.adjustsFontSizeToFitWidth = true
        lab.font = .systemFont(ofSize: 14)
        lab.minimumScaleFactor = 0.3
        lab.textColor = QMUITheme().textColorLevel2()
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
            make.left.equalTo(18)
        }
        //标题
        titleLab.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.left.equalTo(self).offset(58)
        }
        
        //右侧的箭头
        arrowImageView.snp.makeConstraints { (make) in
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
            make.left.equalTo(titleLab.snp.right).offset(5)
            make.right.equalTo(self).offset(-34)
        }
        //描述左侧的描述图片
        describeImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.right.equalTo(describeLab.snp.left)
            make.width.equalTo(DESCRIBE_IMAGE_V_WIDTH)
            make.height.equalTo(DESCRIBE_IMAGE_V_HEIGHT)
        }
        
      //  self.selectionStyle = .none
        
    }
    
    func refreshUI () {
        
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
                make.right.equalTo(self).offset(-18)
            }
        }
        
        if let describeImage = cellModel.describeImage {
            describeImageView.image  = describeImage
        }
        else if let describeImgUrl = cellModel.describeImgUrl {
            let transformer = SDImageResizingTransformer(size: CGSize(width: DESCRIBE_IMAGE_V_WIDTH * UIScreen.main.scale, height: DESCRIBE_IMAGE_V_HEIGHT * UIScreen.main.scale), scaleMode: .aspectFill)
            describeImageView.sd_setImage(with: URL(string: describeImgUrl.url), placeholderImage: describeImgUrl.placeholder, options: [], context: [SDWebImageContextOption.imageTransformer: transformer], progress: nil, completed: { [weak self] (image, error, cacheType, url) in
                guard let `self` = self else { return }
                
                if error == nil {
                    let tempImage = image?.drawCorner(in: CGRect(x: 0, y: 0, width: self.DESCRIBE_IMAGE_V_WIDTH, height: self.DESCRIBE_IMAGE_V_HEIGHT), cornerRadius: self.DESCRIBE_IMAGE_V_HEIGHT * 0.5)
                    self.describeImageView.image = tempImage
                    self.cellModel.describeImage = tempImage
                }
            })
        }
        else {
            describeImageView.image  = nil
        }
        
        describeLab.textColor = cellModel.describeColor
        lineView.isHidden = !cellModel.showLine
    }
}
