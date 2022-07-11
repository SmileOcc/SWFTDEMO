//
//  YXFastNewsShareView.swift
//  YouXinZhengQuan
//
//  Created by lennon on 2021/11/23.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation

class YXFastNewsShareView: UIView {
    
    let topContentView:UIView = UIView.init()
    var topContentViewWidth = YXConstant.screenWidth - 36
    var topContentViewHeight:CGFloat = 0
    
    lazy var firstTitleLabel:UILabel = {
        let lab =  UILabel(text: YXLanguageUtility.kLang(key: "fast_new_share_title"), textColor: UIColor.qmui_color(withHexString: "#2B5080"), textFont: UIFont.systemFont(ofSize: 16), textAlignment: .left) ?? UILabel.init()
        return lab
    }()
    
    lazy var timeLabel:UILabel = {
        let lab =  UILabel(text: "", textColor: QMUITheme().textColorLevel1().withAlphaComponent(0.45), textFont: UIFont.systemFont(ofSize: 12), textAlignment: .left) ?? UILabel.init()
        return lab
    }()
    
    lazy var secondTitleLabel:UILabel = {
        let lab =  UILabel(text: "", textColor: QMUITheme().textColorLevel1(), textFont: UIFont.systemFont(ofSize: 16), textAlignment: .left) ?? UILabel.init()
        lab.numberOfLines = 0;
        return lab
    }()
    
    lazy var contentLabel:UILabel = {
        let lab =  UILabel(text: "", textColor: QMUITheme().textColorLevel1().withAlphaComponent(0.65), textFont: UIFont.systemFont(ofSize: 14), textAlignment: .left) ?? UILabel.init()
        lab.numberOfLines = 0;
        return lab
    }()
    
    var model:YXAllDayInfoModel? {
        didSet {
            
            if let date = model?.releaseTime, let dateStr = NSDate(timeIntervalSince1970: TimeInterval(date)).string(withFormat: "yyyyMMddHHmmss"), let content = model?.content, let title = model?.title  {
                
                let dateModel = YXDateToolUtility.dateTimeAndWeek(withTime: dateStr, addZone: false)
                timeLabel.text = String(format: "%@年%@月%@日 %@ %@:%@", dateModel.year, dateModel.month, dateModel.day, dateModel.week, dateModel.hour, dateModel.minute)
                secondTitleLabel.attributedText = YXToolUtility.attributedString(withText: title, font: UIFont.systemFont(ofSize: 16), textColor: QMUITheme().textColorLevel1(), lineSpacing: 2)
                
                let attStr = YXToolUtility.attributedString(withText: content, font: UIFont.systemFont(ofSize: 14), textColor: QMUITheme().textColorLevel1().withAlphaComponent(0.65), lineSpacing: 2)
                contentLabel.attributedText = attStr
                
                let  maxSize = CGSize(width: topContentViewWidth - 40, height: CGFloat(MAXFLOAT))
                let paragraph = NSMutableParagraphStyle.init()
                paragraph.lineSpacing = 2
                paragraph.alignment = .left
                paragraph.paragraphSpacing = 0
                paragraph.headIndent = 0
                let size = (content as NSString).boundingRect(with: maxSize, options: [.usesLineFragmentOrigin,.usesFontLeading], attributes: [.paragraphStyle : paragraph, .font:UIFont.systemFont(ofSize: 14)], context: nil).size
                let titleSize = (title as NSString).boundingRect(with: maxSize, options: [.usesLineFragmentOrigin,.usesFontLeading], attributes: [.paragraphStyle : paragraph, .font:UIFont.systemFont(ofSize: 16)], context: nil).size
                
                topContentViewHeight = 124 + size.height + titleSize.height;
                
                frame = CGRect(x:0, y:0, width:topContentViewWidth, height:topContentViewHeight);
                
                topContentView.frame = CGRect(x:0, y:0, width:topContentViewWidth, height:topContentViewHeight);
                
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initUI() {
        
        topContentView.backgroundColor = QMUITheme().foregroundColor()
        addSubview(topContentView)
        
        setUpTopSubview()
    }
    
    func setUpTopSubview()  {
        
        topContentView.addSubview(firstTitleLabel)
        firstTitleLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(topContentView).offset(20)
            make.top.equalTo(topContentView).offset(20)
            make.right.equalTo(topContentView).offset(20)
        })

        topContentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(topContentView).offset(20)
            make.top.equalTo(firstTitleLabel.snp.bottom).offset(5)
            make.right.equalTo(topContentView).offset(-20)
        })


        let lineView = UIView.init()
        lineView.backgroundColor = QMUITheme().separatorLineColor()
        topContentView.addSubview(lineView)
        lineView.snp.makeConstraints({ (make) in
            make.left.equalTo(topContentView);
            make.top.equalTo(timeLabel.snp.bottom).offset(10);
            make.right.equalTo(topContentView);
            make.height.equalTo(1);
        })
        
        topContentView.addSubview(secondTitleLabel)
        secondTitleLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(topContentView).offset(20)
            make.top.equalTo(lineView.snp.bottom).offset(14);
            make.right.equalTo(topContentView).offset(-20)
        })
    
        topContentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints({ (make) in
            make.left.equalTo(topContentView).offset(20)
            make.top.equalTo(secondTitleLabel.snp.bottom).offset(9);
            make.right.equalTo(topContentView).offset(-20)
        })
    }
}
