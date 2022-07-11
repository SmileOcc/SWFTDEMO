//
//  YXStockDetailArticleCell.swift
//  uSmartOversea
//
//  Created by Kelvin on 2019/4/11.
//  Copyright © 2019年 RenRenDai. All rights reserved.
//

import UIKit

class YXStockDetailArticleCell: UITableViewCell {
    let INFO_IMAGE_VIEW_WIDTH: CGFloat = 109
    let INFO_IMAGE_VIEW_HEIGHT: CGFloat = 69
    
    var stockArticleData: YXStockArticleDetailModel? {
    
        didSet {
            refreshUI()
        }
    
    }
    
    func refreshUI() -> Void {
        
        guard let articleData = stockArticleData else {
            return
        }
        //image
        if let pictureUrl = articleData.pictureUrl, pictureUrl.count > 0 {
            infoImageView.isHidden = false
            titleLabel.snp.updateConstraints { (make) in
                make.right.equalToSuperview().offset(-18 - INFO_IMAGE_VIEW_WIDTH - 13)
            }
            
            if let imageUrl = pictureUrl.first, let url = URL(string: imageUrl) {
                let transformer = SDImageResizingTransformer(size: CGSize(width: INFO_IMAGE_VIEW_WIDTH * UIScreen.main.scale, height: INFO_IMAGE_VIEW_HEIGHT * UIScreen.main.scale), scaleMode: .aspectFill)
                infoImageView.sd_setImage(with: url, placeholderImage: nil, options: [], context: [SDWebImageContextOption.imageTransformer: transformer])
            }
        } else {
            infoImageView.isHidden = true
            titleLabel.snp.updateConstraints { (make) in
                make.right.equalToSuperview().offset(-18)
            }
        }
        //title
        if let title = articleData.title {
            titleLabel.attributedText = YXToolUtility.attributedString(withText: title, font: UIFont.systemFont(ofSize: 14), textColor: QMUITheme().textColorLevel1(), lineSpacing: 5.0)
            titleLabel.lineBreakMode = .byTruncatingTail
        }
        
        //source
        sourceLabel.text = articleData.source
        
        //tag
        if let tag = articleData.tag, tag.count > 0 {
            
            let str = tag as NSString
            let size = str.boundingRect(with: CGSize.init(width: 200, height: 15), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: 10)], context: nil)
            tipsLabel.snp.updateConstraints { (make) in
                make.width.equalTo(size.width + 5)
            }
            sourceLabel.snp.updateConstraints { (make) in
                make.left.equalTo(tipsLabel.snp.right).offset(8)
            }
            tipsLabel.text = tag
        } else {
            tipsLabel.snp.updateConstraints { (make) in
                make.width.equalTo(0)
            }
            sourceLabel.snp.updateConstraints { (make) in
                make.left.equalTo(tipsLabel.snp.right).offset(0)
            }
            tipsLabel.text = ""
        }
        
        //time
        if let time = articleData.releaseTime, time > 0 {
//            timeLabel.text = YXToolUtility.dateString(withTimeIntervalSince1970: time)
            if let dateStr = NSDate(timeIntervalSince1970: TimeInterval(time)).string(withFormat: "yyyy-MM-dd HH-mm-ss") {
//                timeLabel.text = YXDateHelper.commonDateString(dateStr)
                timeLabel.text =  YXToolUtility.compareCurrentTime(dateStr)

            } else {
                timeLabel.text = ""
            }
        } else {
            timeLabel.text = ""
        }
    }
     
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        if let articleData = stockArticleData, let pictureUrl = articleData.pictureUrl, pictureUrl.count > 0 {
            size.height = 130
         } else {
            size.height = 44
            var height = YXToolUtility.getStringSize(with: titleLabel.text ?? "", andFont: UIFont.systemFont(ofSize: 14), andlimitWidth: Float(size.width - 36), andLineSpace: 5).height
            if height > 72 {
                height = 72
            }
            size.height += height
            size.height += sourceLabel.sizeThatFits(size).height
        }
        return size
    }
    
    lazy var titleLabel: YXAlignmentLabel = {
        let lab = YXAlignmentLabel()
        lab.text = ""
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.textColor = QMUITheme().textColorLevel1()
        lab.verticalAlignment = .top
        lab.textAlignment = .left
        lab.numberOfLines = 3;
        lab.lineBreakMode = .byTruncatingTail
        return lab
    }()
    
    lazy var infoImageView: UIImageView = {
        let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: INFO_IMAGE_VIEW_WIDTH, height: INFO_IMAGE_VIEW_HEIGHT))
        imageView.layer.cornerRadius = 2.0
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "launch_icon")
        imageView.contentMode = .scaleAspectFill
        return imageView;
    }()
    
    lazy var tipsLabel: QMUILabel = {
        let lab = QMUILabel()
        lab.text = ""
        lab.font = UIFont.systemFont(ofSize: 10)
        lab.textColor = UIColor.qmui_color(withHexString: "#EF577E")
        lab.layer.cornerRadius = 1.0
        lab.layer.borderWidth = 1.0
        lab.layer.borderColor = UIColor.qmui_color(withHexString: "#EF577E")?.cgColor
        lab.textAlignment = .center
        return lab
    }()
    
    lazy var sourceLabel: QMUILabel = {
        let lab = QMUILabel()
        lab.text = ""
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.textColor = QMUITheme().textColorLevel2()
        return lab
    }()
    
    lazy var timeLabel: QMUILabel = {
        let lab = QMUILabel()
        lab.text = ""
        lab.font = UIFont.systemFont(ofSize: 12, weight: .light)
        lab.textColor = QMUITheme().textColorLevel3()
        return lab
    }()
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().separatorLineColor()
        return view
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    func initUI() -> Void {
        
        self.selectionStyle = .none
        
        backgroundColor = QMUITheme().foregroundColor()
        contentView.addSubview(titleLabel)
        contentView.addSubview(infoImageView)
        contentView.addSubview(tipsLabel)
        contentView.addSubview(sourceLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(lineView)
        
        infoImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-18)
            make.width.equalTo(INFO_IMAGE_VIEW_WIDTH)
            make.height.equalTo(INFO_IMAGE_VIEW_HEIGHT)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.top.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-18)
            make.height.lessThanOrEqualTo(72)
        }
        
        tipsLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.left)
            make.bottom.equalToSuperview().offset(-10)
            make.width.equalTo(0)
            //make.height.equalTo(15)
        }
        
        sourceLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-10)
            make.left.equalTo(tipsLabel.snp.right).offset(8)
            //make.height.equalTo(15)
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(sourceLabel.snp.centerY)
            make.left.equalTo(sourceLabel.snp.right).offset(8)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
