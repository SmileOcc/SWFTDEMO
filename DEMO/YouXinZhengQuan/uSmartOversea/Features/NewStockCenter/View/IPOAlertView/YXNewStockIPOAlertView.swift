//
//  YXNewStockIPOAlertView.swift
//  YouXinZhengQuan
//
//  Created by Mac on 2020/2/11.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

import SnapKit

class YXNewStockIPOAlertView: UIView {
    
    
    var nowBuyBlock:(() -> Void)?
    
    let nowBuyBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        btn.setDisabledTheme(6)
        btn.setTitle(YXLanguageUtility.kLang(key: "newStock_detail_purchase_now"), for: .normal)
        return btn
    }()

    init(frame: CGRect, premarketList: [YXNewStockCenterPreMarketStockModel]) {
        
        super.init(frame: frame)
        
        
        backgroundColor = QMUITheme().foregroundColor()
        isUserInteractionEnabled = true
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
        
        let topImgView = UIImageView(image: UIImage(named: "ipo_alert_top_img"))
        topImgView.backgroundColor = UIColor.red
        topImgView.contentMode = .scaleAspectFit
        addSubview(topImgView)
        topImgView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            //make.height.equalTo(79)
        }
        
        let titleLab = UILabel()
        titleLab.textColor = QMUITheme().foregroundColor()
        titleLab.font = UIFont.systemFont(ofSize: 28)
        titleLab.text = YXLanguageUtility.kLang(key: "ipo_stock_alert_title")
        addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-13)
            make.top.equalToSuperview().offset(19)
        }
        
        let whiteBgView = UIView()
        whiteBgView.backgroundColor = QMUITheme().foregroundColor()
        whiteBgView.layer.cornerRadius = 20
        whiteBgView.layer.masksToBounds = true
        addSubview(whiteBgView)
        whiteBgView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(topImgView.snp.bottom)
        }
                
        let menuView = YXNewStockIPOAlertMenuView(frame: CGRect.zero)
        menuView.update(with: YXLanguageUtility.kLang(key: "ipo_stock_name"), priceTip: YXLanguageUtility.kLang(key: "ipo_stock_entrance_fee"))
        whiteBgView.addSubview(menuView)
        menuView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(41)
        }
        
        var topConstraint:SnapKit.ConstraintItem = menuView.snp.bottom
        //计算AlertView的高度
        var alertHeight: CGFloat = 30
        var count = premarketList.count
        var moreThan3 = false
        if 3 < count {
            count = 3
            alertHeight = 62
            moreThan3 = true
        }
        alertHeight = alertHeight + 100 + 41 + 68.0
        for i in 0 ..< count {
            let model = premarketList[i]
            let (canIPO, canEcm) = fetchAdmissionFeeType(with: model)
            
            var itemHeight: CGFloat = 64.0
            if canIPO && canEcm {
                itemHeight = 74.0
            }
            alertHeight = alertHeight + itemHeight
            
            let subView = YXNewStockIPOAlertSubView(frame: CGRect.zero)
            subView.update(with: model,canIPO:canIPO, canEcm:canEcm)
            whiteBgView.addSubview(subView)
            subView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.height.equalTo(itemHeight)
                make.top.equalTo(topConstraint)
            }
            topConstraint = subView.snp.bottom
        }
        
        let alertWidth: CGFloat = 300
        let alertX = (YXConstant.screenWidth - alertWidth) / 2.0
        let alertY = (YXConstant.screenHeight - alertHeight) / 2.0 - 25
        
        self.frame = CGRect(x: alertX, y: alertY, width: alertWidth, height: alertHeight)
        
        if moreThan3 {
            let moreBtn = UIButton(type: .custom)
            moreBtn.setTitle(YXLanguageUtility.kLang(key: "share_info_more"), for: .normal)
            moreBtn.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
            moreBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            whiteBgView.addSubview(moreBtn)
            moreBtn.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(topConstraint).offset(20)
            }
            moreBtn.addTarget(self, action: #selector(nowBuyAction), for: .touchUpInside)
        }
        
        //立即认购
        whiteBgView.addSubview(nowBuyBtn)
        nowBuyBtn.snp.makeConstraints { (make) in
            make.width.equalTo(161)
            make.height.equalTo(48)
            make.top.equalTo(topConstraint).offset( moreThan3 ? 62 : 30)
            make.centerX.equalToSuperview()
        }
        nowBuyBtn.addTarget(self, action: #selector(nowBuyAction), for: .touchUpInside)
        
    }
    
    @objc func nowBuyAction() {
        if let block = nowBuyBlock {
            block()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class YXNewStockIPOAlertMenuView: UIView {
    let nameLab: UILabel = {
        let lab = UILabel()
        lab.textColor = QMUITheme().textColorLevel3()
        lab.font = UIFont.systemFont(ofSize: 12)
        return lab
    }()
    
    let priceRangeLab: UILabel = {
        let lab = UILabel()
        lab.textColor = QMUITheme().textColorLevel3()
        lab.font = UIFont.systemFont(ofSize: 12)
        return lab
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(nameLab)
        nameLab.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().offset(15)
        }
        
        addSubview(priceRangeLab)
        priceRangeLab.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with name:String, priceTip:String) {
        nameLab.text = name
        priceRangeLab.text = priceTip
    }
}

class YXNewStockIPOAlertSubView: UIView {
    let nameLab: UILabel = {
        let lab = UILabel()
        lab.textColor = QMUITheme().textColorLevel1()
        lab.font = UIFont.systemFont(ofSize: 16)
        return lab
    }()
    
    let symbolLab: UILabel = {
        let lab = UILabel()
        lab.textColor = QMUITheme().textColorLevel2()
        lab.font = UIFont.systemFont(ofSize: 14)
        return lab
    }()
    
    //倍数
    let multipleBtn: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.backgroundColor = QMUITheme().sell()
        btn.layer.cornerRadius = 2
        btn.layer.masksToBounds = true
        btn.contentEdgeInsets = UIEdgeInsets(top: 1, left: 5, bottom: 1, right: 5)
        return btn
    }()
    
    let admissionFeeLab: UILabel = {
        let lab = UILabel()
        lab.textColor = QMUITheme().textColorLevel1()
        lab.font = UIFont.systemFont(ofSize: 16)
        lab.adjustsFontSizeToFitWidth = true
        lab.minimumScaleFactor = 0.3
        lab.textAlignment = .right
        return lab
    }()
    
    lazy var admissionFee2Lab: UILabel = {
        let lab = UILabel()
        lab.textColor = QMUITheme().textColorLevel1()
        lab.font = UIFont.systemFont(ofSize: 16)
        lab.adjustsFontSizeToFitWidth = true
        lab.minimumScaleFactor = 0.3
        lab.textAlignment = .right
        return lab
    }()
    //国际配售
    private lazy var guojiTipLab: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        btn.setTitle("  \(YXLanguageUtility.kLang(key: "newStock_internal_placement"))  ", for: .normal)
        if let color1 = UIColor.qmui_color(withHexString: "#435CE7"), let color2 = UIColor.qmui_color(withHexString: "#7167EF") {
            let image = UIImage.init(gradientColors: [color1, color2])
            btn.setBackgroundImage(image, for: .normal)
        }
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.titleLabel?.minimumScaleFactor = 0.3
        btn.layer.cornerRadius = 2
        btn.layer.masksToBounds = true
        return btn
    }()
    
    //公开发售
    private lazy var gongkaiTipLab: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        btn.setTitle("  \(YXLanguageUtility.kLang(key: "ipo_stock_public_sell"))  ", for: .normal)
        if let color1 = UIColor.qmui_color(withHexString: "#27D0AB"), let color2 = UIColor.qmui_color(withHexString: "#45A4B9") {
            let image = UIImage.init(gradientColors: [color1, color2])
            btn.setBackgroundImage(image, for: .normal)
        }
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.titleLabel?.minimumScaleFactor = 0.3
        btn.layer.cornerRadius = 2
        btn.layer.masksToBounds = true
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(nameLab)
        nameLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(10)
        }
        
        addSubview(symbolLab)
        symbolLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(nameLab.snp.bottom).offset(3)
        }
        
        addSubview(multipleBtn)
        multipleBtn.snp.makeConstraints { (make) in
            make.left.equalTo(symbolLab.snp.right).offset(6)
            make.centerY.equalTo(symbolLab)
        }
        
        addSubview(admissionFeeLab)
        admissionFeeLab.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-15)
            make.left.greaterThanOrEqualTo(nameLab.snp.right).offset(2)
        }
        
        let bottomLine = UIView()
        bottomLine.backgroundColor = QMUITheme().separatorLineColor()
        addSubview(bottomLine)
        bottomLine.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with model: YXNewStockCenterPreMarketStockModel, canIPO:Bool,canEcm:Bool) {
        nameLab.text = model.stockName
        symbolLab.text = model.stockCode
        
        if let financingMultiple = model.ordinaryFinancingMultiple {
            multipleBtn.isHidden = false
            multipleBtn.setTitle(String(format: YXLanguageUtility.kLang(key: "ipo_times_leverage"), financingMultiple), for: .normal)
        } else {
            multipleBtn.isHidden = true
        }
        
        //货币单位
        var unit = YXLanguageUtility.kLang(key: "exchange_unit_hk")
        if model.exchangeType == 5 {
            unit = YXLanguageUtility.kLang(key: "exchange_unit_us")
        }
        
        if canIPO && canEcm {
            addSubview(guojiTipLab)
            addSubview(admissionFee2Lab)
            addSubview(gongkaiTipLab)
            
            //股票
            nameLab.snp.remakeConstraints { (make) in
                make.left.equalToSuperview().offset(15)
                make.top.equalToSuperview().offset(15)
            }
            //国际配售 数字
            admissionFeeLab.snp.remakeConstraints { (make) in
                make.top.equalToSuperview().offset(14)
                make.right.equalToSuperview().offset(-15)
            }
            //国际配售
            guojiTipLab.snp.remakeConstraints { (make) in
                make.height.equalTo(15)
                make.width.equalTo(50)
                make.top.equalToSuperview().offset(17)
                make.right.equalToSuperview().offset(-uniHorLength(105, uniWidth: 375))
                make.right.equalTo(admissionFeeLab.snp.left).offset(-3)
                make.left.equalTo(nameLab.snp.right).offset(2)
            }
            //公开发售 数字
            admissionFee2Lab.snp.remakeConstraints { (make) in
                make.centerY.equalTo(symbolLab)
                make.right.equalTo(admissionFeeLab)
            }
            //公开发售
            gongkaiTipLab.snp.remakeConstraints { (make) in
                make.height.equalTo(15)
                make.width.equalTo(50)
                make.centerY.equalTo(admissionFee2Lab)
                make.right.equalToSuperview().offset(-uniHorLength(105, uniWidth: 375))
                make.right.equalTo(admissionFee2Lab.snp.left).offset(-3)
                make.left.greaterThanOrEqualTo(multipleBtn.snp.right).offset(2)
            }
            //国际
            if let fee = model.ecmLeastAmount {
                admissionFeeLab.text = YXNewStockMoneyFormatter.shareInstance.formatterMoney(fee) + unit
            }
            //公开
            if let fee = model.leastAmount {
                admissionFee2Lab.text = YXNewStockMoneyFormatter.shareInstance.formatterMoney(fee) + unit
            }
        } else if canEcm {
            //国际
            if let fee = model.ecmLeastAmount {
                admissionFeeLab.text = YXNewStockMoneyFormatter.shareInstance.formatterMoney(fee) + unit
            }
        } else {
            //公开
            if let fee = model.leastAmount {
                admissionFeeLab.text = YXNewStockMoneyFormatter.shareInstance.formatterMoney(fee) + unit
            }
        }
        
    }
}

