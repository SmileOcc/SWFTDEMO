//
//  YXRecommendTableViewCell.swift
//  uSmartEducation
//
//  Created by 覃明明 on 2021/10/12.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxCocoa
import QMUIKit

class YXSpecialContentCell: UITableViewCell {
    
    var tapCollect: (() -> Void)?
    var tapComment: (() -> Void)?
    var tapKOL: (() -> Void)?
    
    var model: YXSpecialArticleItem? {
        didSet {
            if let m = model {
                let url = URL.init(string: m.photoUrl ?? "")
                photoImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "user_default_photo"), options: [], context: nil)
                nameLabel.text = m.nick ?? "--"
                
                if let title = m.postTitle {
                    let paragraph = NSMutableParagraphStyle()
                    paragraph.minimumLineHeight = 20
                    paragraph.lineBreakMode = .byTruncatingTail
                    let attributeString = NSMutableAttributedString.init(string: title, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .semibold),  NSAttributedString.Key.paragraphStyle : paragraph])
                    titleLabel.attributedText = attributeString
                }else {
                    titleLabel.text = "--"
                }

                if let content = m.postContentSummary {
                    let paragraph = NSMutableParagraphStyle()
                    paragraph.minimumLineHeight = 20
                    paragraph.lineBreakMode = .byTruncatingTail
                    let attributeString = NSMutableAttributedString.init(string: content, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),  NSAttributedString.Key.paragraphStyle : paragraph])
                    contentLabel.attributedText = attributeString
                }else {
                    contentLabel.text = "--"
                }
                
                commentCountLabel.text = m.commentCount ?? "--"
                collectCountLabel.text = m.collectionCount ?? "--"
                collectButton.isSelected = m.collectFlag
                
                if let postType = m.postType {
                    vipImageView.isHidden = postType == "1"
                }else {
                    vipImageView.isHidden = true
                }
                
                if let time = m.createTime {
                    timeLabel.text = time
                }
                self.floatView.removeAllSubviews()
                if let tags = m.tags, tags.count != 0 {
                    let tagsImages = tags.compactMap { model in
                        return YXKOLHomeTagType(rawValue: model.id ?? "")?.tagImage()
                    }
                    tagsImages.forEach({ [weak self] tagView in
                        self?.floatView.addSubview(tagView)
                    })
                    nameLabel.snp.updateConstraints { make in
                        make.centerY.equalTo(photoImageView).offset(-10)
                    }
                } else {
                    nameLabel.snp.updateConstraints { make in
                        make.centerY.equalTo(photoImageView).offset(0)
                    }
                }
            }
        }
    }
    
    lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var floatView: QMUIFloatLayoutView = {
        let float = QMUIFloatLayoutView()
        float.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        float.itemMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        float.minimumItemSize = CGSize(width: 52, height: 16)
        float.clipsToBounds = true
        return float
    }()
    
    lazy var tapPhotoButton: UIButton = {
        let button = UIButton()
        _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe { [weak self]_ in
            self?.tapKOL?()
        }

        return button
    }()
    
    lazy var vipImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "vip_icon"))
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = QMUITheme().textColorLevel1()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = QMUITheme().textColorLevel1()
        label.numberOfLines = 2
        return label
    }()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel1()
        label.numberOfLines = 3
        
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel3()
        
        return label
    }()
    
    lazy var bgView: UIView = {
        let bgView = UIView()
        bgView.backgroundColor = QMUITheme().foregroundColor()
        bgView.layer.cornerRadius = 12
        bgView.layer.shadowOpacity = 1
        bgView.layer.shadowColor = UIColor(hexString: "000000")?.withAlphaComponent(0.05).cgColor
        bgView.layer.shadowOffset = CGSize(width: 0, height: 4)
        bgView.layer.shadowRadius = 12
        return bgView
    }()
    
    lazy var commentCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = QMUITheme().textColorLevel2()
        
        return label
    }()
    
    lazy var collectCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = QMUITheme().textColorLevel2()
        
        return label
    }()
    
    lazy var commentView: UIView = {
        let view = UIView()
        let imageView = UIImageView(image: UIImage(named: "comment_count"))
        view.addSubview(imageView)
        view.addSubview(commentCountLabel)
        
        imageView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
        }
        commentCountLabel.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).offset(4)
            make.right.bottom.equalToSuperview()
        }
        
        _ = view.rx.tapGesture().skip(1).takeUntil(self.rx.deallocated).subscribe { [weak self]tap in
            self?.tapComment?()
        }
        
        return view
    }()
    
    lazy var collectButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "collect_count"), for: .normal)
        button.setImage(UIImage(named: "collected_count"), for: .selected)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    lazy var collectView: UIView = {
        let view = UIView()
        view.addSubview(collectButton)
        view.addSubview(collectCountLabel)
        
        collectButton.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.height.width.equalTo(22)
        }
        collectCountLabel.snp.makeConstraints { make in
            make.left.equalTo(collectButton.snp.right).offset(4)
            make.right.bottom.equalToSuperview()
        }
        
        _ = view.rx.tapGesture().skip(1).takeUntil(self.rx.deallocated).subscribe { [weak self]tap in
            self?.tapCollect?()
        }

        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = QMUITheme().foregroundColor()
        
        contentView.addSubview(bgView)
        bgView.addSubview(photoImageView)
        bgView.addSubview(vipImageView)
        bgView.addSubview(nameLabel)
        bgView.addSubview(tapPhotoButton)
        bgView.addSubview(titleLabel)
        bgView.addSubview(contentLabel)
        bgView.addSubview(timeLabel)
        bgView.addSubview(commentView)
        bgView.addSubview(collectView)
        bgView.addSubview(floatView)
        
        floatView.snp.makeConstraints { make in
            make.left.equalTo(photoImageView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
            make.height.equalTo(16)
        }
        
        bgView.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(16)
            make.right.bottom.equalToSuperview().offset(-16)
        }
        
        photoImageView.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(16)
            make.width.height.equalTo(50)
        }
        
        vipImageView.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(photoImageView.snp.right).offset(8)
            make.right.lessThanOrEqualToSuperview().offset(-16)
            make.centerY.equalTo(photoImageView).offset(0)
        }
        
        tapPhotoButton.snp.makeConstraints { make in
            make.left.top.bottom.equalTo(photoImageView)
            make.right.equalTo(nameLabel)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(photoImageView.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
        
//        commentView.snp.makeConstraints { make in
//            make.centerY.equalTo(timeLabel)
//            make.right.equalTo(collectView.snp.left).offset(-16)
//        }
        
        commentView.snp.makeConstraints { make in
            make.centerY.equalTo(timeLabel)
            make.right.equalToSuperview().offset(-16)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

let VIEWS_CELL_IMAGE_VIEW_WIDTH: CGFloat = 107
let VIEWS_CELL_IMAGE_VIEW_HEIGHT: CGFloat = 69

class YXViewsContentCell: UITableViewCell {

    var clickStockCallBack: ((YXInfomationStockModel) -> ())?
    
    var refreshCallBack: (() -> ())?
    
    var model: YXSpecialArticleItem? {
        
        didSet {
            refreshUI()
        }
        
    }
    
    func refreshUI() -> Void {
        
        guard let articleData = model else {
            return
        }
        
        //image
        if let pictureUrl = articleData.postCover, pictureUrl.count > 0 {
            infoImageView.isHidden = false
            let rPadding: CGFloat = 16 + VIEWS_CELL_IMAGE_VIEW_WIDTH + 16
            titleLabel.snp.updateConstraints { (make) in
                make.right.equalToSuperview().offset(-rPadding)
            }

            let imageUrl = pictureUrl
            let transformer = SDImageResizingTransformer(size: CGSize(width: VIEWS_CELL_IMAGE_VIEW_WIDTH * UIScreen.main.scale, height: VIEWS_CELL_IMAGE_VIEW_HEIGHT * UIScreen.main.scale), scaleMode: .aspectFill)
            infoImageView.sd_setImage(with: NSURL.init(string: imageUrl)! as URL, placeholderImage: nil, options: [], context: [SDWebImageContextOption.imageTransformer: transformer])
        } else {
            infoImageView.isHidden = true
            titleLabel.snp.updateConstraints { (make) in
                make.right.equalToSuperview().offset(-16)
            }
        }
        
        //title
        if let title = articleData.postTitle {
            titleLabel.text = title;
        } else {
            titleLabel.text = ""
        }

        // time
//        if let time = articleData.releaseTime, time > 0 {
////            timeLabel.text = YXToolUtility.dateString(withTimeIntervalSince1970: time)
//            if let dateStr = NSDate(timeIntervalSince1970: TimeInterval(time)).string(withFormat: "yyyy-MM-dd HH-mm-ss") {
////                timeLabel.text = YXDateHelper.commonDateString(dateStr)
//                timeLabel.text =  YXToolUtility.compareCurrentTime(dateStr)
//
//            } else {
//                timeLabel.text = ""
//            }
//        } else {
//            timeLabel.text = ""
//        }

        if let time = articleData.baseCreateTime {
            timeLabel.text = YXToolUtility.compareCurrentTime(time)
        } else {
            if let time = articleData.createTime {
                timeLabel.text = time
            } else {
                timeLabel.text = ""
            }
        }

    }
    

    
//    override func sizeThatFits(_ size: CGSize) -> CGSize {
//        var size = super.sizeThatFits(size)
//        guard let articleData = stockArticleData else {
//            return size
//        }
//        if let pictureUrl = articleData.pictureURL, pictureUrl.count > 0 {
//            size.height = (VIEWS_CELL_IMAGE_VIEW_HEIGHT + 18 + 18)
//
//            size.height += sourceLabel.sizeThatFits(size).height + 12
//
//        } else {
//            size.height = (18 + 18)
//            var height = YXToolUtility.getStringSize(with: titleLabel.text ?? "", andFont: UIFont.systemFont(ofSize: 14), andlimitWidth: Float(YXConstant.screenWidth - 30), andLineSpace: 5).height
//            if height <= 21 {
//                height = 21
//            } else if (height > 21 && height < 42){
//                height = 42
//            } else {
//                height = 42
//            }
//            size.height += height
//
//            let count = articleData.stocks?.count ?? 0
//            if count > 0 {
//                size.height += (22 + 8)
//            }
//
//            size.height += sourceLabel.sizeThatFits(size).height + 12
//
//        }
//        if articleData.refreshFlag {
//            size.height += 32
//        }
//
//        return size
//    }
    
    lazy var titleLabel: QMUILabel = {
        let lab = QMUILabel()
        lab.text = ""
        lab.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        lab.textColor = QMUITheme().textColorLevel1()
        lab.textAlignment = .left
        lab.numberOfLines = 2
        lab.lineBreakMode = .byTruncatingTail
        return lab
    }()
    
    lazy var infoImageView: UIImageView = {
        let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: VIEWS_CELL_IMAGE_VIEW_WIDTH, height: VIEWS_CELL_IMAGE_VIEW_HEIGHT))
        imageView.layer.cornerRadius = 2.0
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "launch_icon")
        imageView.contentMode = .scaleAspectFill
        return imageView;
    }()
    
    lazy var timeLabel: QMUILabel = {
        let lab = QMUILabel()
        lab.text = ""
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.textColor = QMUITheme().textColorLevel3()
        return lab
    }()
    
    lazy var topline: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().separatorLineColor()
        return view
    }()
    
    lazy var bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().separatorLineColor()
        return view
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    func initUI() -> Void {
        
        backgroundColor = QMUITheme().foregroundColor()
        self.selectionStyle = .none
        contentView.addSubview(titleLabel)
        contentView.addSubview(infoImageView)
        contentView.addSubview(timeLabel)
        contentView.addSubview(topline)
        contentView.addSubview(bottomLine)
        
        infoImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(25)
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(VIEWS_CELL_IMAGE_VIEW_WIDTH)
            make.height.equalTo(VIEWS_CELL_IMAGE_VIEW_HEIGHT)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(25)
            make.right.equalToSuperview().offset(-16)
            make.height.lessThanOrEqualTo(42)
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-25)
        }
        
        topline.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(0)
            make.right.equalToSuperview().offset(0)
            make.top.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        bottomLine.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
