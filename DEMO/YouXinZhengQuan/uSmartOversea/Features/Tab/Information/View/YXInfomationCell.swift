//
//  YXInfomationCell.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/9/6.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

let INFOMATION_CELL_IMAGE_VIEW_WIDTH: CGFloat = 109
let INFOMATION_CELL_IMAGE_VIEW_HEIGHT: CGFloat = 69

//class YXInfomationCell: UITableViewCell {
//
//    var clickStockCallBack: ((YXInfomationStockModel) -> ())?
//
//    var refreshCallBack: (() -> ())?
//
//    var stockArticleData: YXInfomationModel? {
//
//        didSet {
//            refreshUI()
//        }
//
//    }
//
//    func refreshUI() -> Void {
//
//        guard let articleData = stockArticleData else {
//            return
//        }
//
//        // 刷新的隐藏
//
//        var btnH: CGFloat = 0
//        if articleData.refreshFlag {
//            btnH = 32
//        }
//        self.refreshBtn.snp.updateConstraints { (make) in
//            make.height.equalTo(btnH)
//        }
//
//        //image
//        if let pictureUrl = articleData.pictureURL, pictureUrl.count > 0 {
//            infoImageView.isHidden = false
//            let rPadding: CGFloat = 15 + 109 + 13
//            titleLabel.snp.updateConstraints { (make) in
//                make.right.equalToSuperview().offset(-rPadding)
//            }
//            stockRocLabel.snp.updateConstraints { (make) in
//                make.right.lessThanOrEqualToSuperview().offset(-rPadding)
//            }
//            let imageUrl = pictureUrl.first
//            let transformer = SDImageResizingTransformer(size: CGSize(width: INFOMATION_CELL_IMAGE_VIEW_WIDTH * UIScreen.main.scale, height: INFOMATION_CELL_IMAGE_VIEW_HEIGHT * UIScreen.main.scale), scaleMode: .aspectFill)
//            infoImageView.sd_setImage(with: NSURL.init(string: imageUrl!)! as URL, placeholderImage: nil, options: [], context: [SDWebImageContextOption.imageTransformer: transformer])
//        } else {
//            infoImageView.isHidden = true
//            titleLabel.snp.updateConstraints { (make) in
//                make.right.equalToSuperview().offset(-15)
//            }
//            let rPadding: CGFloat = 15 + 109 + 13
//            stockRocLabel.snp.updateConstraints { (make) in
//                make.right.lessThanOrEqualToSuperview().offset(-rPadding)
//            }
//        }
//
//        //title
//        if let title = articleData.title {
//
//            var color: UIColor?
//            if articleData.isRead {
//                color = QMUITheme().grayTitleColor()
//            } else {
//                color = QMUITheme().articleTitleColor()
//            }
//            titleLabel.attributedText = YXToolUtility.attributedString(withText: title, font: UIFont.systemFont(ofSize: 14), textColor: color, lineSpacing: 5.0)
//            titleLabel.lineBreakMode = .byTruncatingTail
//        } else {
//            titleLabel.text = ""
//        }
//        //source
//        if var sourceStr = articleData.source {
//            if sourceStr.count > 20 {
//                let sub = sourceStr.prefix(19)
//                sourceStr = sub + "..."
//            }
//            sourceLabel.text = sourceStr
//        } else {
//            sourceLabel.text = ""
//        }
//
//        var tag = ""
//        // 推荐
//        if articleData.isRecommend {
//            if let alg = articleData.alg, alg == "topped" {
//                tag = YXLanguageUtility.kLang(key: "news_label_top")
//            }
//        } else {
//            if let alg = articleData.tag {
//                tag = alg
//            }
//        }
//
//        if tag.count > 0 {
//            let str = tag as NSString
//            let size = str.boundingRect(with: CGSize.init(width: 200, height: 15), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: 10)], context: nil)
//            tipsLabel.snp.updateConstraints { (make) in
//                make.width.equalTo(size.width + 5)
//            }
//            sourceLabel.snp.updateConstraints { (make) in
//                make.left.equalTo(tipsLabel.snp.right).offset(8)
//            }
//            tipsLabel.text = str as String
//        } else {
//            tipsLabel.snp.updateConstraints { (make) in
//                make.width.equalTo(0)
//            }
//            sourceLabel.snp.updateConstraints { (make) in
//                make.left.equalTo(tipsLabel.snp.right).offset(0)
//            }
//            tipsLabel.text = ""
//        }
//
//        // time
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
//
//        self.updateRoc(with: articleData.stocks?.first)
//    }
//
//    func updateRoc(with model: YXInfomationStockModel?) {
//        // 涨跌额
//        if let stock = model {
//            stockBtn.setTitle(" " + (stock.symbol ?? "--") + "(" + (stock.name ?? "--") + ")", for: .normal)
//            //roc
//            if let roc = stock.roc {
//                let number = YXToolUtility.stockPercentData(Double(roc), priceBasic: 2, deciPoint: 2)
//                self.stockRocLabel.text =  " " + (number ?? "--") + " "
//                self.stockRocLabel.textColor = YXToolUtility.changeColor(Double(roc))
//                stockBtn.setTitleColor(YXToolUtility.changeColor(Double(roc)), for: .normal)
//            } else {
//                self.stockRocLabel.text = " -- "
//            }
//            self.stockBtn.isHidden = false
//            self.stockRocLabel.isHidden = false
//        } else {
//            self.stockBtn.isHidden = true
//            self.stockRocLabel.isHidden = true
//        }
//    }
//
//    override func sizeThatFits(_ size: CGSize) -> CGSize {
//        var size = super.sizeThatFits(size)
//        guard let articleData = stockArticleData else {
//            return size
//        }
//        if let pictureUrl = articleData.pictureURL, pictureUrl.count > 0 {
//            size.height = (INFOMATION_CELL_IMAGE_VIEW_HEIGHT + 18 + 18)
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
//
//    lazy var titleLabel: YXAlignmentLabel = {
//        let lab = YXAlignmentLabel()
//        lab.text = ""
//        lab.font = UIFont.systemFont(ofSize: 14)
//        lab.textColor = QMUITheme().articleTitleColor()
//        lab.verticalAlignment = .top
//        lab.textAlignment = .left
//        lab.numberOfLines = 2
//        lab.lineBreakMode = .byTruncatingTail
//        return lab
//    }()
//
//    lazy var infoImageView: UIImageView = {
//        let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: INFOMATION_CELL_IMAGE_VIEW_WIDTH, height: INFOMATION_CELL_IMAGE_VIEW_HEIGHT))
//        imageView.layer.cornerRadius = 2.0
//        imageView.layer.masksToBounds = true
//        imageView.image = UIImage(named: "launch_icon")
//        imageView.contentMode = .scaleAspectFill
//        return imageView;
//    }()
//
//    lazy var tipsLabel: QMUILabel = {
//        let lab = QMUILabel()
//        lab.text = ""
//        lab.font = UIFont.systemFont(ofSize: 10)
//        lab.textColor = QMUITheme().tipTitleColor()
//        lab.layer.cornerRadius = 1.0
//        lab.layer.borderWidth = 1.0
//        lab.layer.borderColor = QMUITheme().tipTitleColor().cgColor
//        lab.textAlignment = .center
//        return lab
//    }()
//
//    lazy var sourceLabel: QMUILabel = {
//        let lab = QMUILabel()
//        lab.text = ""
//        lab.font = UIFont.systemFont(ofSize: 12)
//        lab.textColor = QMUITheme().grayTitleColor()
//        return lab
//    }()
//
//    lazy var timeLabel: QMUILabel = {
//        let lab = QMUILabel()
//        lab.text = ""
//        lab.font = UIFont.systemFont(ofSize: 12)
//        lab.textColor = QMUITheme().grayTitleColor()
//        return lab
//    }()
//
//    lazy var lineView: UIView = {
//        let view = UIView()
//        view.backgroundColor = QMUITheme().separatorLineColor()
//        return view
//    }()
//
//    let refreshBtn = QMUIButton.init()
//
//    let jumView = UIView.init()
//    let stockRocLabel = UILabel.init(with: QMUITheme().stockGrayColor(), font: UIFont.systemFont(ofSize: 12), text: "0.00%")
//
//    let stockBtn = QMUIButton.init()
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        initUI()
//    }
//
//    func initUI() -> Void {
//        self.selectionStyle = .none
//
//        refreshBtn.clipsToBounds = true
//        refreshBtn.setTitleColor(.white, for: .normal)
//        refreshBtn.titleLabel?.font = .systemFont(ofSize: 14)
//        refreshBtn.setTitle(YXLanguageUtility.kLang(key: "news_last_view_point"), for: .normal)
//        refreshBtn.backgroundColor = UIColor.qmui_color(withHexString: "#0091FF")
//        refreshBtn.addTarget(self, action: #selector(self.refreshClick(_:)), for: .touchUpInside)
//
//        stockBtn.setTitleColor(QMUITheme().stockGrayColor(), for: .normal)
//        stockBtn.titleLabel?.font = .systemFont(ofSize: 12)
//        stockBtn.titleLabel?.lineBreakMode = .byTruncatingTail
//        stockBtn.contentHorizontalAlignment = .center
//        stockBtn.setBackgroundImage(UIImage(color: QMUITheme().blockColor()!), for: .normal)
//
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.clickStock(_:)))
//        jumView.addGestureRecognizer(tap)
//
//        stockRocLabel.backgroundColor = QMUITheme().blockColor()
//
//        contentView.addSubview(refreshBtn)
//        contentView.addSubview(titleLabel)
//        contentView.addSubview(infoImageView)
//        contentView.addSubview(tipsLabel)
//        contentView.addSubview(sourceLabel)
//        contentView.addSubview(timeLabel)
//        contentView.addSubview(lineView)
//        contentView.addSubview(stockRocLabel)
//        contentView.addSubview(stockBtn)
//        contentView.addSubview(jumView)
//
//        refreshBtn.snp.makeConstraints { (make) in
//            make.leading.trailing.top.equalToSuperview()
//            make.height.equalTo(32)
//        }
//
//        infoImageView.snp.makeConstraints { (make) in
//            make.top.equalTo(refreshBtn.snp.bottom).offset(18)
//            make.right.equalToSuperview().offset(-15)
//            make.width.equalTo(INFOMATION_CELL_IMAGE_VIEW_WIDTH)
//            make.height.equalTo(INFOMATION_CELL_IMAGE_VIEW_HEIGHT)
//        }
//
//        titleLabel.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(15)
//            make.top.equalTo(refreshBtn.snp.bottom).offset(18)
//            make.right.equalToSuperview().offset(-15)
//            make.height.lessThanOrEqualTo(42)
//        }
//
//        tipsLabel.snp.makeConstraints { (make) in
//            make.left.equalTo(titleLabel.snp.left)
//            make.bottom.equalToSuperview().offset(-18)
//            make.width.equalTo(0)
//            make.height.equalTo(15)
//        }
//
//        sourceLabel.snp.makeConstraints { (make) in
//            make.bottom.equalToSuperview().offset(-18)
//            make.left.equalTo(tipsLabel.snp.right).offset(8)
//        }
//
//        timeLabel.snp.makeConstraints { (make) in
//            make.centerY.equalTo(sourceLabel.snp.centerY)
//            make.left.equalTo(sourceLabel.snp.right).offset(8)
//        }
//
//        lineView.snp.makeConstraints { (make) in
//            make.left.equalTo(titleLabel)
//            make.right.equalToSuperview().offset(-15)
//            make.bottom.equalToSuperview()
//            make.height.equalTo(0.5)
//        }
//        let rPadding: CGFloat = 15 + 109 + 13
//
//        stockRocLabel.snp.makeConstraints { (make) in
//            make.right.lessThanOrEqualToSuperview().offset(-rPadding)
//            make.centerY.equalTo(stockBtn)
//            make.left.equalTo(stockBtn.snp.right)
//            make.height.equalTo(22)
//        }
//
//        stockBtn.snp.makeConstraints { (make) in
//            make.left.equalTo(titleLabel)
//            make.height.equalTo(22)
////            make.bottom.equalToSuperview().offset(-44)
//            make.top.equalTo(titleLabel.snp.bottom).offset(8)
//
//        }
//
//        jumView.snp.makeConstraints { (make) in
//            make.height.bottom.right.equalTo(stockRocLabel)
//            make.left.equalTo(stockBtn)
//        }
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    @objc func clickStock(_ sender: UITapGestureRecognizer) {
//
//        if let model = self.stockArticleData?.stocks?.first {
//            self.clickStockCallBack?(model)
//        }
//    }
//
//    @objc func refreshClick(_ sender: UIButton) {
//        self.refreshCallBack?()
//    }
//}


 class YXInfomationCell: UITableViewCell {

     var clickStockCallBack: ((YXInfomationStockModel) -> ())?
     
     var refreshCallBack: (() -> ())?
     
     var stockArticleData: YXInfomationModel? {
         
         didSet {
             refreshUI()
         }
         
     }
     
     func refreshUI() -> Void {
         
         guard let articleData = stockArticleData else {
             return
         }
         
         // 刷新的隐藏

         var btnH: CGFloat = 0
         if articleData.refreshFlag {
             btnH = 32
         }
         self.refreshBtn.snp.updateConstraints { (make) in
             make.height.equalTo(btnH)
         }
         
         //image
         if let pictureUrl = articleData.pictureURL, pictureUrl.count > 0 {
             infoImageView.isHidden = false
             let rPadding: CGFloat = 15 + 109 + 13
             titleLabel.snp.updateConstraints { (make) in
                 make.right.equalToSuperview().offset(-rPadding)
             }
             stockRocLabel.snp.updateConstraints { (make) in
                 make.right.lessThanOrEqualToSuperview().offset(-rPadding)
             }
             let imageUrl = pictureUrl.first
             let transformer = SDImageResizingTransformer(size: CGSize(width: INFOMATION_CELL_IMAGE_VIEW_WIDTH * UIScreen.main.scale, height: INFOMATION_CELL_IMAGE_VIEW_HEIGHT * UIScreen.main.scale), scaleMode: .aspectFill)
             infoImageView.sd_setImage(with: NSURL.init(string: imageUrl!)! as URL, placeholderImage: nil, options: [], context: [SDWebImageContextOption.imageTransformer: transformer])
         } else {
             infoImageView.isHidden = true
             titleLabel.snp.updateConstraints { (make) in
                 make.right.equalToSuperview().offset(-15)
             }
             let rPadding: CGFloat = 15 + 109 + 13
             stockRocLabel.snp.updateConstraints { (make) in
                 make.right.lessThanOrEqualToSuperview().offset(-rPadding)
             }
         }
         
         //title
         if let title = articleData.title {
             
             var color: UIColor?
             if articleData.isRead {
                color = QMUITheme().textColorLevel2()
             } else {
                 color = QMUITheme().textColorLevel1()
             }
             titleLabel.attributedText = YXToolUtility.attributedString(withText: title, font: UIFont.systemFont(ofSize: 14), textColor: color, lineSpacing: 5.0)
             titleLabel.lineBreakMode = .byTruncatingTail
         } else {
             titleLabel.text = ""
         }
         //source
         if var sourceStr = articleData.source {
             if sourceStr.count > 20 {
                 let sub = sourceStr.prefix(19)
                 sourceStr = sub + "..."
             }
             sourceLabel.text = sourceStr
         } else {
             sourceLabel.text = ""
         }
         
         var tag = ""
         // 推荐
         if articleData.isRecommend {
             if let alg = articleData.alg, alg == "topped" {
                 tag = YXLanguageUtility.kLang(key: "news_label_top")
             }
         } else {
             if let alg = articleData.tag {
                 tag = alg
             }
         }
         
//         if tag.count > 0 {
//             let str = tag as NSString
//             let size = str.boundingRect(with: CGSize.init(width: 200, height: 15), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: 10)], context: nil)
//             tipsLabel.snp.updateConstraints { (make) in
//                 make.width.equalTo(size.width + 5)
//             }
//             sourceLabel.snp.updateConstraints { (make) in
//                 make.left.equalTo(tipsLabel.snp.right).offset(8)
//             }
//             tipsLabel.text = str as String
//         } else {
//             tipsLabel.snp.updateConstraints { (make) in
//                 make.width.equalTo(0)
//             }
//             sourceLabel.snp.updateConstraints { (make) in
//                 make.left.equalTo(tipsLabel.snp.right).offset(0)
//             }
//             tipsLabel.text = ""
//         }

         // time
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
         
         self.updateRoc(with: articleData.stocks?.first)
        
        if articleData.alg == "kol"  {//kol文章
            sourceLabel.textColor = QMUITheme().textColorLevel1()

             kolUserHeadView.snp.updateConstraints { (make) in
                make.size.equalTo(CGSize.init(width: 20, height: 20))
             }
            tagImageView1.snp.updateConstraints { (make) in
               make.size.equalTo(CGSize.init(width: 0, height: 0))
            }
            tagImageView2.snp.updateConstraints { (make) in
               make.size.equalTo(CGSize.init(width: 0, height: 0))
            }
            sourceLabel.snp.updateConstraints { (make) in
                make.width.lessThanOrEqualTo(85)
            }

            kolUserHeadView.isHidden = false
            tagImageView1.isHidden = true
            tagImageView2.isHidden = true
            
            if let data = articleData.news_tag?.data(using: .utf8),
               let json = ((try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]) as [String : Any]??)  {
                let model = YXKolModel.yy_model(withJSON: json)
                if let m = model {
                    self.addKolTags(tags: m.tags?.compactMap{YXKOLHomeTagType(rawValue: $0.id ?? "1")} ?? [])
                    let url = URL.init(string: m.user_icon_url ?? "")
                    kolUserHeadView.sd_setImage(with: url, placeholderImage: UIImage(named: "user_default_photo"), options: .retryFailed, context: nil)
                }
            }
            

//            self.addKolTags(tags: articleData.news_tag?.tags?.compactMap{YXKOLHomeTagType(rawValue: $0.id ?? "1")} ?? [])
            
//            let url = URL.init(string: articleData.news_tag?.userUrl ?? "")
//            kolUserHeadView.sd_setImage(with: url, placeholderImage: UIImage(named: "user_default_photo"), options: .retryFailed, context: nil)
            
         } else {
             sourceLabel.textColor = QMUITheme().textColorLevel2()

            kolUserHeadView.snp.updateConstraints { (make) in
               make.size.equalTo(CGSize.init(width: 0, height: 0))
            }
            tagImageView1.snp.updateConstraints { (make) in
               make.size.equalTo(CGSize.init(width: 0, height: 0))
            }
            tagImageView2.snp.updateConstraints { (make) in
               make.size.equalTo(CGSize.init(width: 0, height: 0))
            }
            sourceLabel.snp.updateConstraints { (make) in
                make.width.lessThanOrEqualTo(100)
            }
            kolUserHeadView.isHidden = true
            tagImageView1.isHidden = true
            tagImageView2.isHidden = true
            
         }
     }
     
     func updateRoc(with model: YXInfomationStockModel?) {
         // 涨跌额
         if let stock = model {
             stockBtn.setTitle(" " + (stock.name ?? "--") + "(" + (stock.symbol ?? "--") + ")", for: .normal)
             //roc
             if let roc = stock.roc {
                 let number = YXToolUtility.stockPercentData(Double(roc), priceBasic: 2, deciPoint: 2)
                 self.stockRocLabel.text =  " " + (number ?? "--") + " "
                 self.stockRocLabel.textColor = YXToolUtility.changeColor(Double(roc))
                 stockBtn.setTitleColor(YXToolUtility.changeColor(Double(roc)), for: .normal)
             } else {
                 self.stockRocLabel.text = " -- "
             }
             self.stockBtn.isHidden = false
             self.stockRocLabel.isHidden = false
         } else {
             self.stockBtn.isHidden = true
             self.stockRocLabel.isHidden = true
         }
     }
     
     override func sizeThatFits(_ size: CGSize) -> CGSize {
         var size = super.sizeThatFits(size)
         guard let articleData = stockArticleData else {
             return size
         }
         if let pictureUrl = articleData.pictureURL, pictureUrl.count > 0 {
             size.height = (INFOMATION_CELL_IMAGE_VIEW_HEIGHT + 18 + 18)
             
             size.height += sourceLabel.sizeThatFits(size).height + 12
             
         } else {
             size.height = (18 + 18)
             var height = YXToolUtility.getStringSize(with: titleLabel.text ?? "", andFont: UIFont.systemFont(ofSize: 14), andlimitWidth: Float(YXConstant.screenWidth - 30), andLineSpace: 5).height
             if height <= 21 {
                 height = 21
             } else if (height > 21 && height < 42){
                 height = 42
             } else {
                 height = 42
             }
             size.height += height
             
             let count = articleData.stocks?.count ?? 0
             if count > 0 {
                 size.height += (22 + 8)
             }
             
             size.height += sourceLabel.sizeThatFits(size).height + 12

         }
         if articleData.refreshFlag {
             size.height += 32
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
         lab.numberOfLines = 2
         lab.lineBreakMode = .byTruncatingTail
         return lab
     }()
     
     lazy var infoImageView: UIImageView = {
         let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: INFOMATION_CELL_IMAGE_VIEW_WIDTH, height: INFOMATION_CELL_IMAGE_VIEW_HEIGHT))
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
     
     let refreshBtn = QMUIButton.init()
     
     let jumView = UIView.init()
     let stockRocLabel = UILabel.init(with: QMUITheme().stockGrayColor(), font: UIFont.systemFont(ofSize: 12), text: "0.00%")
     
     let stockBtn = QMUIButton.init()
     
    lazy var kolUserHeadView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "user_default_photo")
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
     lazy var tagImageView1: UIImageView = {
         let imageView = UIImageView()
         imageView.image = UIImage(named: "")
         imageView.contentMode = .scaleToFill
         return imageView
     }()
     
     lazy var tagImageView2: UIImageView = {
         let imageView = UIImageView()
         imageView.image = UIImage(named: "")
         imageView.contentMode = .scaleToFill
         return imageView
     }()
     
     override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
         super.init(style: style, reuseIdentifier: reuseIdentifier)
         initUI()
     }
     
     func initUI() -> Void {
         self.selectionStyle = .none

        backgroundColor = QMUITheme().foregroundColor()
         refreshBtn.clipsToBounds = true
         refreshBtn.setTitleColor(.white, for: .normal)
         refreshBtn.titleLabel?.font = .systemFont(ofSize: 14)
         refreshBtn.setTitle(YXLanguageUtility.kLang(key: "news_last_view_point"), for: .normal)
         refreshBtn.backgroundColor = QMUITheme().themeTextColor()
         refreshBtn.addTarget(self, action: #selector(self.refreshClick(_:)), for: .touchUpInside)
         
         stockBtn.setTitleColor(QMUITheme().stockGrayColor(), for: .normal)
         stockBtn.titleLabel?.font = .systemFont(ofSize: 12)
         stockBtn.titleLabel?.lineBreakMode = .byTruncatingTail
         stockBtn.contentHorizontalAlignment = .center
        stockBtn.backgroundColor = QMUITheme().blockColor()

         let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.clickStock(_:)))
         jumView.addGestureRecognizer(tap)
         
         stockRocLabel.backgroundColor = QMUITheme().blockColor()
         
         contentView.addSubview(refreshBtn)
         contentView.addSubview(titleLabel)
         contentView.addSubview(infoImageView)
         contentView.addSubview(tipsLabel)
         contentView.addSubview(sourceLabel)
         contentView.addSubview(timeLabel)
         contentView.addSubview(lineView)
         contentView.addSubview(stockRocLabel)
         contentView.addSubview(stockBtn)
         contentView.addSubview(jumView)
        contentView.addSubview(kolUserHeadView)
         contentView.addSubview(tagImageView1)
         contentView.addSubview(tagImageView2)
         
         refreshBtn.snp.makeConstraints { (make) in
             make.leading.trailing.top.equalToSuperview()
             make.height.equalTo(32)
         }
         
         infoImageView.snp.makeConstraints { (make) in
             make.top.equalTo(refreshBtn.snp.bottom).offset(18)
             make.right.equalToSuperview().offset(-15)
             make.width.equalTo(INFOMATION_CELL_IMAGE_VIEW_WIDTH)
             make.height.equalTo(INFOMATION_CELL_IMAGE_VIEW_HEIGHT)
         }
         
         titleLabel.snp.makeConstraints { (make) in
             make.left.equalToSuperview().offset(15)
             make.top.equalTo(refreshBtn.snp.bottom).offset(18)
             make.right.equalToSuperview().offset(-15)
             make.height.lessThanOrEqualTo(42)
         }
         
//         tipsLabel.snp.makeConstraints { (make) in
//             make.left.equalTo(titleLabel.snp.left)
//             make.bottom.equalToSuperview().offset(-18)
//             make.width.equalTo(0)
//             make.height.equalTo(15)
//         }
         
         sourceLabel.snp.makeConstraints { (make) in
             make.bottom.equalToSuperview().offset(-18)
             make.left.equalTo(kolUserHeadView.snp.right).offset(2)
            make.width.lessThanOrEqualTo(75)
         }
         
         timeLabel.snp.makeConstraints { (make) in
             make.centerY.equalTo(sourceLabel.snp.centerY)
             make.left.equalTo(tagImageView1.snp.right).offset(8)
         }
         
         lineView.snp.makeConstraints { (make) in
             make.left.equalTo(titleLabel)
             make.right.equalToSuperview().offset(-15)
             make.bottom.equalToSuperview()
             make.height.equalTo(0.5)
         }
        
        kolUserHeadView.snp.makeConstraints { (make) in
            make.centerY.equalTo(sourceLabel.snp.centerY)
            make.left.equalTo(titleLabel.snp.left)
            make.size.equalTo(CGSize.init(width: 20, height: 20))
        }
        
        tagImageView2.snp.makeConstraints { (make) in
            make.centerY.equalTo(sourceLabel.snp.centerY)
            make.left.equalTo(sourceLabel.snp.right).offset(4)
            make.size.equalTo(CGSize.init(width: 16, height: 16))

        }
        
        tagImageView1.snp.makeConstraints { (make) in
            make.centerY.equalTo(sourceLabel.snp.centerY)
            make.size.equalTo(CGSize.init(width: 16, height: 16))
            make.centerX.equalTo(tagImageView2.snp.centerX).offset(4)
        }
        
         let rPadding: CGFloat = 15 + 109 + 13

         stockRocLabel.snp.makeConstraints { (make) in
             make.right.lessThanOrEqualToSuperview().offset(-rPadding)
             make.centerY.equalTo(stockBtn)
             make.left.equalTo(stockBtn.snp.right)
             make.height.equalTo(22)
         }
         
         stockBtn.snp.makeConstraints { (make) in
             make.left.equalTo(titleLabel)
             make.height.equalTo(22)
 //            make.bottom.equalToSuperview().offset(-44)
             make.top.equalTo(titleLabel.snp.bottom).offset(8)

         }
         
         jumView.snp.makeConstraints { (make) in
             make.height.bottom.right.equalTo(stockRocLabel)
             make.left.equalTo(stockBtn)
         }
         
         self.layoutIfNeeded()
         kolUserHeadView.layer.cornerRadius = kolUserHeadView.frame.size.width / 2;
         kolUserHeadView.layer.masksToBounds = true
         tagImageView1.layer.cornerRadius = tagImageView1.frame.size.width / 2;
         tagImageView1.layer.masksToBounds = true
         tagImageView2.layer.cornerRadius = tagImageView2.frame.size.width / 2;
         tagImageView2.layer.masksToBounds = true
     }
     
     func addKolTags(tags: [YXKOLHomeTagType]) {
        tagImageView1.isHidden = true
        tagImageView2.isHidden = true
        
         let tag1 = tags[safe: 0]
         let tag2 = tags[safe: 1]
         
         if let tag = tag1 {
             let t = tag as YXKOLHomeTagType
             let image = t.headIcon()
             tagImageView2.image = image
             tagImageView2.isHidden = false
            tagImageView2.snp.updateConstraints { (make) in
               make.size.equalTo(CGSize.init(width: 16, height: 16))
            }
         }

         if let tag = tag2 {
             let t = tag as YXKOLHomeTagType
             let image = t.headIcon()
             tagImageView1.image = image
             tagImageView1.isHidden = false
            tagImageView1.snp.updateConstraints { (make) in
               make.size.equalTo(CGSize.init(width: 16, height: 16))
            }
         }
        
//        tagImageView1.snp.updateConstraints { (make) in
//           make.size.equalTo(CGSize.init(width: 20, height: 20))
//        }
//        tagImageView2.snp.updateConstraints { (make) in
//           make.size.equalTo(CGSize.init(width: 20, height: 20))
//        }
     }

     
     required init?(coder aDecoder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
     
     @objc func clickStock(_ sender: UITapGestureRecognizer) {
         
         if let model = self.stockArticleData?.stocks?.first {
             self.clickStockCallBack?(model)
         }
     }
     
     @objc func refreshClick(_ sender: UIButton) {
         self.refreshCallBack?()
     }
 }

