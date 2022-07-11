//
//  YXAllDayInfoCell.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/9/7.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit


class YXAllDayInfoCell: UITableViewCell {
    
    let dateFormatter = DateFormatter.en_US_POSIX()
    
    var clickStockCallBack: ((YXAllDayInfoStockModel) -> ())?
    
    var model: YXAllDayInfoModel? {
        didSet {
            
            var color: UIColor?
            if self.model?.isRead ?? false {
                color = QMUITheme().textColorLevel2()
            } else {
                color = QMUITheme().textColorLevel1()
            }
            
            if let time = self.model?.releaseTime {
                let date = Date.init(timeIntervalSince1970: TimeInterval(time))
                let timeStr = self.dateFormatter.string(from: date)
                self.timeLabel.text = timeStr
            } else {
                self.timeLabel.text = ""
            }
            self.titleLabel.attributedText = YXToolUtility.attributedString(withText: self.model?.title ?? "", font: .systemFont(ofSize: 16), textColor: color, lineSpacing: 5)
            self.contenLabel.attributedText = YXToolUtility.attributedString(withText: self.model?.content ?? "", font: .systemFont(ofSize: 12), textColor: UIColor.black.withAlphaComponent(0.4), lineSpacing: 2)
            self.contenLabel.lineBreakMode = .byTruncatingTail
            self.titleLabel.lineBreakMode = .byTruncatingTail
            
            if model?.isShow ?? false {
                self.contenLabel.numberOfLines = 0
                self.titleLabel.numberOfLines = 0
            } else {
                self.contenLabel.numberOfLines = 3
                self.titleLabel.numberOfLines = 2
            }
            self.flowView.qmui_removeAllSubviews()
            // 添加股票
            if let list = self.model?.stockArr {
                for index in 0..<list.count {
                    let model = list[index]
                    let btn = QMUIButton.init()
                    var rocStr = ""
                    //roc
                    if let roc = model.roc {
                        let number = YXToolUtility.stockPercentData(Double(roc), priceBasic: 2, deciPoint: 2)
                        let symbol = "(" + (model.symbol ?? "--") + ")"
                        rocStr = (model.name ?? "--") + symbol + (number ?? "")
                        btn.setTitleColor(YXToolUtility.changeColor(Double(roc)), for: .normal)
                    } else {
                        rocStr = ""
                    }
                    btn.titleLabel?.font = .systemFont(ofSize: 13)
                    btn.setTitle(rocStr, for: .normal)
                    btn.addTarget(self, action: #selector(self.clickStock(_:)), for: .touchUpInside)
                    btn.tag = index
                    self.flowView.addSubview(btn)
                }
            }
        }
    }

    let circleView = UIView.init()
    
    let timeLabel = UILabel.init(with: UIColor.black.withAlphaComponent(0.3), font: .systemFont(ofSize: 12), text: "--")
    //数据来源
    private lazy var dataSourceLabel: UILabel = {
        let label = UILabel.init(with: UIColor.black.withAlphaComponent(0.5), font: .systemFont(ofSize: 12), text: "")
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .right
        label.minimumScaleFactor = 0.2
        return label
    }()
    
    let titleLabel = UILabel.init(with: .black, font: .systemFont(ofSize: 16), text: "--")
    
    let contenLabel = UILabel.init(with: UIColor.black.withAlphaComponent(0.4), font: .systemFont(ofSize: 12), text: "--")
    
    let stockLabel = YYLabel.init()
    
    let flowView = QMUIFloatLayoutView.init()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let count = self.model?.stockArr.count ?? 0
        if count > 0 {
            let height = CGFloat(((count + 1) / 2) * 35)
            flowView.frame = CGRect.init(x: 46, y: self.mj_h - height, width: self.mj_w - 46 - 15, height: height)
        } else {
            flowView.frame = CGRect.init(x: 46, y: 0, width: 0, height: 0)
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let  path = UIBezierPath()

        let  p0 = CGPoint(x: 27, y: 20)
        path.move(to: p0)

        let  p1 = CGPoint(x: 27, y: self.bounds.maxY)
        path.addLine(to: p1)

        let  dashes: [ CGFloat ] = [ 4, 2 ]
        path.setLineDash(dashes, count: dashes.count, phase: 0.0)

        path.lineWidth = 1
        path.lineCapStyle = .butt
        QMUITheme().themeTextColor().set()
        path.stroke()
    }
    
    func initUI() {
        
        dateFormatter.dateFormat = "HH:mm"
        flowView.itemMargins = UIEdgeInsets.init(top: 0, left: 5, bottom: 2, right: 5)
        contentView.addSubview(flowView)
        
        self.selectionStyle = .none
        circleView.layer.cornerRadius = 9
        circleView.clipsToBounds = true
        circleView.backgroundColor = QMUITheme().themeTextColor()
        
        titleLabel.numberOfLines = 2
        contenLabel.numberOfLines = 3
        
        contentView.addSubview(circleView)
        contentView.addSubview(timeLabel)
        contentView.addSubview(dataSourceLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(contenLabel)
        
        circleView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(18)
            make.top.equalToSuperview().offset(0)
            make.width.height.equalTo(18)
        }
        timeLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(circleView)
            make.leading.equalTo(circleView.snp.trailing).offset(10)
            make.height.equalTo(17)
        }
        
        dataSourceLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(circleView)
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(17)
            make.leading.equalTo(timeLabel.snp.trailing).offset(2)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(timeLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(46)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        contenLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel)
            make.trailing.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
        }
        
        let longGes = UILongPressGestureRecognizer.init(target: self, action: #selector(self.longPress(_:)))
        contentView.addGestureRecognizer(longGes)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        if let model = self.model, let title = model.title, let content = model.content {
            var titleH = YXToolUtility.getStringSize(with: title, andFont: UIFont.systemFont(ofSize: 16), andlimitWidth: Float(YXConstant.screenWidth - 46 - 15 - 40), andLineSpace: 5).height
            var contentH = YXToolUtility.getStringSize(with: content, andFont: UIFont.systemFont(ofSize: 12), andlimitWidth: Float(YXConstant.screenWidth - 46 - 15 - 40), andLineSpace: 2).height
            if !model.isShow {
                if contentH > 47 {
                    contentH = 47
                }
            }
            
            if !model.isShow {
                if titleH > 44 {
                    titleH = 44
                }
            }
            
            var rocHeight: CGFloat = 0
            let count = self.model?.stockArr.count ?? 0
            if count > 0 {
                rocHeight = CGFloat(((count + 1) / 2) * 35)
            }
            size.height = 20 + titleH + contentH + 30 + rocHeight
        } else {
            size.height = 80
        }
        return size
    }
    ///是否展示DataSource。
    ///flag=true，展示；falg=false ,不展示
    func showDataSource(with flag: Bool) {
        dataSourceLabel.isHidden = !flag
        if flag {
            dataSourceLabel.text = YXLanguageUtility.kLang(key: "news_all_day_data_source")
        }
    }
    
    @objc func clickStock(_ sender: UIButton) {
        
        if let model = self.model?.stockArr[sender.tag] {
            self.clickStockCallBack?(model)
        }
    }
    
    @objc func longPress(_ sender: UILongPressGestureRecognizer) {
        if let content = self.model?.content {
            if sender.state == .began {
                UIPasteboard.general.string = content
                YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "copied_clipboard"))
            }
        }
    }
}
