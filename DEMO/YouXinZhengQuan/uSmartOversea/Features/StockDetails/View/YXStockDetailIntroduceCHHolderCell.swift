//
//  YXStockDetailIntroduceCHHolderCell.swift
//  uSmartOversea
//
//  Created by 井超 on 2019/9/30.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXStockDetailIntroduceCHHolderCell: UITableViewCell {
    
    var model: YXHSIntroduceHolder? {
        didSet {
            self.totalLabel.text = YXToolUtility.stockData(self.model?.holderNum ?? 0, deciPoint: 2, stockUnit: YXLanguageUtility.kLang(key: "stock_detail_Household"), priceBase: 0)
            self.avgLabel.text = YXToolUtility.stockData(self.model?.holdingEach ?? 0, deciPoint: 2, stockUnit: YXLanguageUtility.kLang(key: "stock_unit"), priceBase: 0)
            self.biggesLabel.text = (self.model?.topShareHolderName ?? "") + String(format: "(%.2f%%)", self.model?.topShareHoldingRate ?? 0)
            self.pledgeLabel.text = String(format: "%.2f%%", self.model?.pledgeNum ?? 0)
            self.tenHolderLabel.text = String(format: YXLanguageUtility.kLang(key: "total_shareholding_ratio"), self.model?.shareHoldingRate ?? 0)
            self.tenHolderFlowLabel.text = String(format: YXLanguageUtility.kLang(key: "total_shareholding_ratio"), self.model?.floatHoldingRate ?? 0)
            self.organholdersLabel.text = String(format: YXLanguageUtility.kLang(key: "total_shareholding_ratio"), self.model?.organHoldingRate ?? 0)
        }
    }
    
    let totalLabel = QMUILabel.init(with: QMUITheme().textColorLevel1(), font: UIFont.systemFont(ofSize: 14), text: "--") //户数
    let avgLabel = QMUILabel.init(with: QMUITheme().textColorLevel1(), font: UIFont.systemFont(ofSize: 14), text: "--") //均持股
    let biggesLabel = QMUILabel.init(with: QMUITheme().textColorLevel1(), font: UIFont.systemFont(ofSize: 14), text: "--") //最大股东
    let pledgeLabel = QMUILabel.init(with: QMUITheme().textColorLevel1(), font:  UIFont.systemFont(ofSize: 14), text: "--") //质押比例
    
    let tenHolderLabel = QMUILabel.init(with: QMUITheme().textColorLevel1(), font:  UIFont.systemFont(ofSize: 14), text: "--") //十大股东
    let tenHolderFlowLabel = QMUILabel.init(with: QMUITheme().textColorLevel1(), font: UIFont.systemFont(ofSize: 14), text: "--") //十大流通股东
    let organholdersLabel = QMUILabel.init(with: QMUITheme().textColorLevel1(), font:  UIFont.systemFont(ofSize: 14), text: "--") //机构投资者
    
    lazy var  tenHolderBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("", for: .normal)
        return btn
    }()
    
    lazy var  tenHolderFlowBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("", for: .normal)
        return btn
    }()
    
    lazy var  organholdersBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("", for: .normal)
        return btn
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


    }
    
    func initUI() {
        
        self.selectionStyle = .none
        
        let totalTitleLabel = QMUILabel.init(with: QMUITheme().textColorLevel2(), font: UIFont.systemFont(ofSize: 14), text: YXLanguageUtility.kLang(key: "holds_number"))
        totalTitleLabel.adjustsFontSizeToFitWidth = true
        totalTitleLabel.minimumScaleFactor = 0.3
        contentView.addSubview(totalTitleLabel)
        totalTitleLabel.textAlignment = .left
        totalTitleLabel.numberOfLines = 0
        
        let avgTitleLabel = QMUILabel.init(with: QMUITheme().textColorLevel2(), font:  UIFont.systemFont(ofSize: 14), text: YXLanguageUtility.kLang(key: "holding_each"))
        contentView.addSubview(avgTitleLabel)
        avgTitleLabel.adjustsFontSizeToFitWidth = true
        avgTitleLabel.minimumScaleFactor = 0.3
        avgTitleLabel.textAlignment = .left
        avgTitleLabel.numberOfLines = 0
        
        let biggesTitleLabel = QMUILabel.init(with: QMUITheme().textColorLevel2(), font:  UIFont.systemFont(ofSize: 14), text: YXLanguageUtility.kLang(key: "top_share_holder"))
        contentView.addSubview(biggesTitleLabel)
        biggesTitleLabel.adjustsFontSizeToFitWidth = true
        biggesTitleLabel.minimumScaleFactor = 0.3
        biggesTitleLabel.textAlignment = .left
        biggesTitleLabel.numberOfLines = 0
        
        let pledgeTitleLabel = QMUILabel.init(with: QMUITheme().textColorLevel2(), font:  UIFont.systemFont(ofSize: 14), text: YXLanguageUtility.kLang(key: "pledge_num"))
        contentView.addSubview(pledgeTitleLabel)
        pledgeTitleLabel.adjustsFontSizeToFitWidth = true
        pledgeTitleLabel.minimumScaleFactor = 0.3
        pledgeTitleLabel.textAlignment = .left
        pledgeTitleLabel.numberOfLines = 0
        
        let infoBtn = QMUIButton.init(type: .custom)
        infoBtn.setImage(UIImage(named: "stock_info"), for: .normal)
        infoBtn.alpha = 0.6
        infoBtn.rx.tap.subscribe(onNext: {
             _ in
        
            //取消
            let cancel = QMUIAlertAction(title: YXLanguageUtility.kLang(key: "common_iknow"), style: .default) { (alertController, action) in
                
            }
            cancel.buttonAttributes = [NSAttributedString.Key.foregroundColor : QMUITheme().mainThemeColor(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)]
            
            //弹框
            let alertController = QMUIAlertController.init(title: nil, message: YXLanguageUtility.kLang(key: "ashare_pledge_tips"), preferredStyle: .alert)
            alertController.alertContentMargin = UIEdgeInsets(top: 0, left: uniHorLength(28), bottom: 0, right: uniHorLength(28))
            alertController.alertContentMaximumWidth = YXConstant.screenWidth
            alertController.alertSeparatorColor = QMUITheme().separatorLineColor()
            let paragraph = NSMutableParagraphStyle()
            paragraph.paragraphSpacing = 8
            paragraph.lineSpacing = 3
            paragraph.headIndent = 14
            alertController.alertMessageAttributes = [NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel1(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .regular), NSAttributedString.Key.paragraphStyle : paragraph]
            alertController.alertContentCornerRadius = 20
            alertController.alertButtonHeight = 48
            alertController.alertHeaderInsets = UIEdgeInsets(top: 30, left: 20, bottom: 20, right: 20)
            alertController.alertTitleMessageSpacing = 20
            alertController.addAction(cancel)
            alertController.showWith(animated: true)
        }).disposed(by: rx.disposeBag)
        contentView.addSubview(infoBtn)
        
        let tenHolderTitleLabel = QMUILabel.init(with: QMUITheme().textColorLevel2(), font:  UIFont.systemFont(ofSize: 14), text: YXLanguageUtility.kLang(key: "stock_detail_top_ten_holder"))
        contentView.addSubview(tenHolderTitleLabel)
        tenHolderTitleLabel.adjustsFontSizeToFitWidth = true
        tenHolderTitleLabel.minimumScaleFactor = 0.3
        tenHolderTitleLabel.textAlignment = .left
        tenHolderTitleLabel.numberOfLines = 0
        
        let tenHolderFlowTitleLabel = QMUILabel.init(with: QMUITheme().textColorLevel2(), font: UIFont.systemFont(ofSize: 14), text: YXLanguageUtility.kLang(key: "ten_float_holds"))
        contentView.addSubview(tenHolderFlowTitleLabel)
        tenHolderFlowTitleLabel.adjustsFontSizeToFitWidth = true
        tenHolderFlowTitleLabel.minimumScaleFactor = 0.3
        tenHolderFlowTitleLabel.textAlignment = .left
        tenHolderFlowTitleLabel.numberOfLines = 0
        
        let organholdersTitleLabel = QMUILabel.init(with: QMUITheme().textColorLevel2(), font:  UIFont.systemFont(ofSize: 14), text: YXLanguageUtility.kLang(key: "ten_organ_holds"))
        contentView.addSubview(organholdersTitleLabel)
        organholdersTitleLabel.adjustsFontSizeToFitWidth = true
        organholdersTitleLabel.minimumScaleFactor = 0.3
        organholdersTitleLabel.textAlignment = .left
        organholdersTitleLabel.numberOfLines = 0
        
        let nextImageView1 = UIImageView()
        nextImageView1.image = UIImage(named: "market_more_arrow")
        contentView.addSubview(nextImageView1)
        
        let nextImageView2 = UIImageView()
        nextImageView2.image = UIImage(named: "market_more_arrow")
        contentView.addSubview(nextImageView2)
        
        let nextImageView3 = UIImageView()
        nextImageView3.image = UIImage(named: "market_more_arrow")
        contentView.addSubview(nextImageView3)
        
        let padding_x = 138
        
        totalTitleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(18)
            make.top.equalToSuperview()
            make.width.lessThanOrEqualTo(padding_x - 24)
            make.height.greaterThanOrEqualTo(20)
        }
        
        avgTitleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(totalTitleLabel)
            make.top.equalTo(totalTitleLabel.snp.bottom).offset(14)
            make.height.greaterThanOrEqualTo(20)
            make.width.lessThanOrEqualTo(padding_x - 24)
        }
        
        biggesTitleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(avgTitleLabel)
            make.top.equalTo(avgTitleLabel.snp.bottom).offset(14)
            make.height.greaterThanOrEqualTo(20)
            make.width.lessThanOrEqualTo(padding_x - 24)
        }
        
        pledgeTitleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(biggesTitleLabel)
            make.top.equalTo(biggesTitleLabel.snp.bottom).offset(14)
            make.height.greaterThanOrEqualTo(20)
            make.width.lessThanOrEqualTo(padding_x - 24 - 14)
        }
        
        infoBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(pledgeTitleLabel)
            make.left.equalTo(pledgeTitleLabel.snp.right).offset(2)
            make.height.width.equalTo(14)
        }
        
        tenHolderTitleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(pledgeTitleLabel)
            make.top.equalTo(pledgeTitleLabel.snp.bottom).offset(14)
            make.height.greaterThanOrEqualTo(20)
            make.width.lessThanOrEqualTo(padding_x - 24)
        }
        
        tenHolderFlowTitleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(tenHolderTitleLabel)
            make.top.equalTo(tenHolderTitleLabel.snp.bottom).offset(14)
            make.height.greaterThanOrEqualTo(20)
            make.width.lessThanOrEqualTo(padding_x - 24)
        }
        
        organholdersTitleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(tenHolderFlowTitleLabel)
            make.top.equalTo(tenHolderFlowTitleLabel.snp.bottom).offset(14)
            make.height.greaterThanOrEqualTo(20)
            make.width.lessThanOrEqualTo(padding_x - 24)
        }
        
        nextImageView1.snp.makeConstraints { (make) in
            make.centerY.equalTo(tenHolderTitleLabel)
            make.right.equalTo(contentView).offset(-18)
            make.width.height.equalTo(14)
        }
        
        nextImageView2.snp.makeConstraints { (make) in
            make.centerY.equalTo(tenHolderFlowTitleLabel)
            make.right.equalTo(contentView).offset(-18)
            make.width.height.equalTo(14)
        }
        
        nextImageView3.snp.makeConstraints { (make) in
            make.centerY.equalTo(organholdersTitleLabel)
            make.right.equalTo(contentView).offset(-18)
            make.width.height.equalTo(14)
        }
        
        contentView.addSubview(totalLabel)
        contentView.addSubview(avgLabel)
        contentView.addSubview(biggesLabel)
        contentView.addSubview(pledgeLabel)
        contentView.addSubview(tenHolderLabel)
        contentView.addSubview(tenHolderFlowLabel)
        contentView.addSubview(organholdersLabel)
        totalLabel.adjustsFontSizeToFitWidth = true
        avgLabel.adjustsFontSizeToFitWidth = true
        biggesLabel.adjustsFontSizeToFitWidth = true
        pledgeLabel.adjustsFontSizeToFitWidth = true
        tenHolderLabel.adjustsFontSizeToFitWidth = true
        tenHolderFlowLabel.adjustsFontSizeToFitWidth = true
        organholdersLabel.adjustsFontSizeToFitWidth = true
        
        totalLabel.minimumScaleFactor = 0.3
        avgLabel.minimumScaleFactor = 0.3
        biggesLabel.minimumScaleFactor = 0.3
        pledgeLabel.minimumScaleFactor = 0.3
        tenHolderLabel.minimumScaleFactor = 0.3
        tenHolderFlowLabel.minimumScaleFactor = 0.3
        organholdersLabel.minimumScaleFactor = 0.3
        
        biggesLabel.numberOfLines = 2
        pledgeLabel.numberOfLines = 2
        tenHolderLabel.numberOfLines = 2
        tenHolderFlowLabel.numberOfLines = 2
        organholdersLabel.numberOfLines = 2
        
        totalLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(padding_x)
            make.centerY.equalTo(totalTitleLabel.snp.centerY)
            make.trailing.equalToSuperview().offset(-18)
        }
        
        avgLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(padding_x)
            make.centerY.equalTo(avgTitleLabel.snp.centerY)
            make.trailing.equalToSuperview().offset(-18)
        }
        
        biggesLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(padding_x)
            make.centerY.equalTo(biggesTitleLabel.snp.centerY)
            make.trailing.equalToSuperview().offset(-18)
        }
        
        pledgeLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(padding_x)
            make.centerY.equalTo(pledgeTitleLabel)
            make.trailing.equalToSuperview().offset(-18)
        }
        
        tenHolderLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(padding_x)
            make.centerY.equalTo(tenHolderTitleLabel)
            make.right.greaterThanOrEqualTo(nextImageView1.snp.left).offset(-5)
        }
        
        tenHolderFlowLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(padding_x)
            make.centerY.equalTo(tenHolderFlowTitleLabel)
            make.right.greaterThanOrEqualTo(nextImageView2.snp.left).offset(-5)
        }
        
        organholdersLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(padding_x)
            make.centerY.equalTo(organholdersTitleLabel)
            make.right.greaterThanOrEqualTo(nextImageView3.snp.left).offset(-5)
        }
        
        contentView.addSubview(tenHolderBtn)
        contentView.addSubview(tenHolderFlowBtn)
        contentView.addSubview(organholdersBtn)
        
        tenHolderBtn.snp.makeConstraints { (make) in
            make.left.top.bottom.equalTo(tenHolderTitleLabel)
            make.right.equalTo(contentView)
        }
        
        tenHolderFlowBtn.snp.makeConstraints { (make) in
            make.left.top.bottom.equalTo(tenHolderFlowTitleLabel)
            make.right.equalTo(contentView)
        }
        
        organholdersBtn.snp.makeConstraints { (make) in
            make.left.top.bottom.equalTo(organholdersTitleLabel)
            make.right.equalTo(contentView)
        }
        
    }
    

}
