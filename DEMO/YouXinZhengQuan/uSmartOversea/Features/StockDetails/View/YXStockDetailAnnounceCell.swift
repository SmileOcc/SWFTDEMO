//
//  YXStockDetailAnnounceCell.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/7/4.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXStockDetailAnnounceCell: UITableViewCell {

    var titleLabel: QMUILabel
    var sourceLabel: QMUILabel
    var dateLabel: QMUILabel
    var bottomLineView: UIView
    
    var model: YXStockDetailAnnounceModel? {
        didSet{
            let mutString = NSMutableAttributedString.init(string: self.model?.infoTitle ?? "")
            mutString.yy_font = UIFont.systemFont(ofSize: 14)
            mutString.yy_lineSpacing = 5
            mutString.yy_color = QMUITheme().textColorLevel1()
            mutString.yy_lineBreakMode = .byTruncatingTail
            
            self.titleLabel.attributedText = mutString
            self.sourceLabel.text = self.model?.media
            self.dateLabel.text = YXDateHelper.commonDateString(self.model?.infoPubDate ?? "", format: .DF_MDYHMS)
            let sourceEmpty = self.model?.media?.isEmpty ?? false
            if sourceEmpty {
                dateLabel.snp.updateConstraints { (make) in
                    make.leading.equalTo(sourceLabel.snp.trailing).offset(0)
                }
            } else {
                dateLabel.snp.updateConstraints { (make) in
                    make.leading.equalTo(sourceLabel.snp.trailing).offset(5)
                }
            }
        }
    }
    
    var HSModel: YXStockDetailHSAnnounceModel? {
        didSet{
            let mutString = NSMutableAttributedString.init(string: self.HSModel?.titleTxt ?? "")
            mutString.yy_font = UIFont.systemFont(ofSize: 14)
            mutString.yy_lineSpacing = 5
            mutString.yy_color = QMUITheme().textColorLevel1()
            mutString.yy_lineBreakMode = .byTruncatingTail
            
            self.titleLabel.attributedText = mutString
            self.sourceLabel.text = ""
            self.dateLabel.text = self.HSModel?.collectDt
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
                
        titleLabel = QMUILabel()
        titleLabel.text = "--"
        titleLabel.numberOfLines = 0
        titleLabel.textColor = QMUITheme().textColorLevel1()
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        
        sourceLabel = QMUILabel()
        sourceLabel.text = "--"
        sourceLabel.textColor = QMUITheme().textColorLevel3()
        sourceLabel.font = UIFont.systemFont(ofSize: 12)
        
        dateLabel = QMUILabel()
        dateLabel.text = "--"
        dateLabel.textColor = QMUITheme().textColorLevel3()
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        
        bottomLineView = UIView.init()
        bottomLineView.backgroundColor = QMUITheme().separatorLineColor()
        bottomLineView.alpha = 0.5
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        
        backgroundColor = QMUITheme().foregroundColor()
        qmui_selectedBackgroundColor = QMUITheme().backgroundColor()
        contentView.addSubview(titleLabel)
        contentView.addSubview(sourceLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(bottomLineView)
        
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(18)
            make.top.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-18)
        }
        sourceLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel)
            make.bottom.equalToSuperview().offset(-14)
            make.height.equalTo(15)
//            make.top.equalTo(titleLabel.snp.bottom).offset(5)
        }
        
        dateLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(sourceLabel)
            make.leading.equalTo(sourceLabel.snp.trailing).offset(5)
        }
        
        bottomLineView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}


class YXAnnounceEventReminderCell: UITableViewCell {

    @objc var detailUrlClosure: ( (_ url: String) -> Void)?

    var model: YXStockEventReminderDetailInfo? {
        didSet{

            if let showYear = model?.showYear, showYear == true {
                yearLabel.isHidden = false
                yearLabel.snp.updateConstraints { (make) in
                    make.height.equalTo(20)
                }

                if let eventDate = model?.eventDate {
                    if eventDate.count >= 4 {
                        yearLabel.text = String(eventDate.prefix(4))
                    } else {
                        yearLabel.text = eventDate
                    }
                }
            } else {
                yearLabel.isHidden = true
                yearLabel.snp.updateConstraints { (make) in
                    make.height.equalTo(0)
                }
            }

            if let date = model?.eventDate, !date.isEmpty {
                if date.count >= 10 {
                    let prefix = String(date.prefix(10))
                    timeLabel.text = String(prefix.suffix(5))
                } else if date.count >= 5 {
                    timeLabel.text = String(date.suffix(5))
                } else {
                    timeLabel.text = date
                }
            } else {
                timeLabel.text = "--"
            }

            if let title = model?.eventTitle {
                titleLabel.text = title
            } else {
                titleLabel.text = ""
            }

            if let height = model?.titleHeight, height > 20 {
                titleLabel.snp.updateConstraints { (make) in
                    make.height.equalTo(height)
                }
            } else {
                titleLabel.snp.updateConstraints { (make) in
                    make.height.equalTo(20)
                }
            }

            let color = QMUITheme().itemBorderColor()
            if let content = model?.eventContent, !content.isEmpty {
                let detailText = " [\(YXLanguageUtility.kLang(key: "webview_detailTitle"))]"
                var wholeText = content
                var isExistUrl = false
                if let url = model?.detailUrl, !url.isEmpty {
                    wholeText = content + detailText
                    isExistUrl = true
                }
                let paragraph = NSMutableParagraphStyle()
                paragraph.lineSpacing = 1
                let commonAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : color, NSAttributedString.Key.paragraphStyle : paragraph]
                let highlightAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor :  QMUITheme().mainThemeColor(), NSAttributedString.Key.paragraphStyle : paragraph]
                contentLabel.truncationToken = nil
                let isExpand = model?.isExpand ?? false

                let size = CGSize(width: YXConstant.screenWidth - 78.0 - 18.0, height: CGFloat.greatestFiniteMagnitude)
                let layout = YYTextLayout(containerSize: size, text: NSAttributedString.init(string: wholeText, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)]))

                if let rowCount = layout?.rowCount, (rowCount <= 3 || rowCount > 3 && isExpand == false) {

                    let commonAttribuString = NSMutableAttributedString.init(string: wholeText, attributes: commonAttributes)

                    if let url = model?.detailUrl, !url.isEmpty {
                        let range = (wholeText as NSString).range(of: detailText)
                        commonAttribuString.addAttributes(highlightAttributes, range: range)
                        commonAttribuString.yy_setTextHighlight(range, color: QMUITheme().mainThemeColor(), backgroundColor: UIColor.clear) { [weak self] (view, attString, range, rect) in
                            guard let `self` = self else { return }
                            self.detailUrlClosure?(url)
                        }
                    }

                    contentLabel.attributedText = commonAttribuString

                    if !isExpand, rowCount > 3 {
                        contentLabel.numberOfLines = 3
                        let image = UIImage(named: "market_more_arrow")?.qmui_image(with: .right)
                        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 12))
                        imageView.image = image
                        let attchment = NSMutableAttributedString.yy_attachmentString(withContent: imageView, contentMode: .center, attachmentSize: CGSize(width: 10, height: 12), alignTo: UIFont.systemFont(ofSize: 12), alignment: .bottom)

                        if isExistUrl {
                            self.detailButton.setTitle(detailText, for: .normal)
                            let detailWidth = (detailText as NSString).boundingRect(with: CGSize(width: 300, height: 20), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: highlightAttributes, context: nil).width + 2
                            self.detailButton.frame = CGRect(x: 0, y: 0, width: detailWidth, height: 13)
                            let detailAttchment = NSMutableAttributedString.yy_attachmentString(withContent: self.detailButton, contentMode: .center, attachmentSize: CGSize(width: detailWidth, height: 13), alignTo: UIFont.systemFont(ofSize: 12), alignment: .center)
                            attchment.append(detailAttchment)
                        }

                        contentLabel.truncationToken = attchment
                    }
                } else {
                    if isExpand {
                        contentLabel.numberOfLines = 0
                        if let rowCount = layout?.rowCount, rowCount > 3 {

                            let commonAttribuString = NSMutableAttributedString.init(string: content, attributes: commonAttributes)

                            let image = UIImage(named: "market_more_arrow")?.qmui_image(with: .left)
                            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 12))
                            imageView.image = image
                            let attchment = NSMutableAttributedString.yy_attachmentString(withContent: imageView, contentMode: .center, attachmentSize: CGSize(width: 10, height: 12), alignTo: UIFont.systemFont(ofSize: 12), alignment: .bottom)
                            commonAttribuString.append(attchment)

                            if let url = model?.detailUrl, !url.isEmpty {

                                let detailAttributeString = NSAttributedString.init(string: detailText, attributes: highlightAttributes)
                                commonAttribuString.append(detailAttributeString)
                                let range = (commonAttribuString.string as NSString).range(of: detailText)
                                commonAttribuString.yy_setTextHighlight(range, color: QMUITheme().mainThemeColor(), backgroundColor: UIColor.clear) { [weak self] (view, attString, range, rect) in
                                    guard let `self` = self else { return }
                                    self.detailUrlClosure?(url)
                                }
                            }

                            contentLabel.attributedText = commonAttribuString
                        }
                    }
                }

            } else {
                contentLabel.attributedText = NSAttributedString.init(string: "", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : color])
            }
        }
    }



    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.selectionStyle = .none
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {

        backgroundColor = QMUITheme().foregroundColor()
        contentView.addSubview(yearLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(circleView)
        contentView.addSubview(lineView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(contentLabel)

        yearLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
            make.top.equalToSuperview()
            make.height.equalTo(0)
        }

        timeLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.top.equalTo(yearLabel.snp.bottom).offset(5)
        }

        circleView.snp.makeConstraints { (make) in
            make.centerY.equalTo(timeLabel)
            make.width.height.equalTo(8)
            make.left.equalToSuperview().offset(57)
        }

        circleView.layer.cornerRadius = 4
        circleView.layer.masksToBounds = true

        lineView.snp.makeConstraints { (make) in
            make.centerX.equalTo(circleView)
            make.top.equalTo(circleView.snp.bottom).offset(5)
            make.bottom.equalToSuperview().offset(-6)
            make.width.equalTo(1)
        }

        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(circleView.snp.right).offset(12)
            make.right.lessThanOrEqualToSuperview().offset(-18)
            make.top.equalTo(timeLabel.snp.top).offset(-1)
            make.height.equalTo(20)
        }

        contentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.left)
            make.right.lessThanOrEqualToSuperview().offset(-18)
            make.top.equalTo(titleLabel.snp.bottom).offset(3)
            make.bottom.equalToSuperview()
        }
    }

    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .left
        return label
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()

    lazy var contentLabel: YYLabel = {
        let label = YYLabel()
        label.numberOfLines = 0
        //label.lineBreakMode = .byCharWrapping
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 12)
        label.textVerticalAlignment = .top
        return label
    }()

    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().textColorLevel1()
        return view
    }()

    lazy var circleView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().mainThemeColor()
        return view
    }()


    lazy var yearLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .left
        label.isHidden = true
        return label
    }()

    lazy var detailButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.expandX = 5
        button.expandY = 5
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitleColor(QMUITheme().mainThemeColor(), for: .normal)
        button.addTarget(self, action: #selector(detailButtonAction), for: .touchUpInside)
        return button
    }()

    @objc func detailButtonAction() {
        if let detailUrl = model?.detailUrl, !detailUrl.isEmpty {
            self.detailUrlClosure?(detailUrl)
        }
    }
}

