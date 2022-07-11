//
//  YXStareBMPDefaultCollectionViewCell.swift
//  uSmartOversea
//
//  Created by suntao on 2020/12/23.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXStareBMPDefaultCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = QMUITheme().foregroundColor()
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        
        bgView.addSubview(tipsLabel)
        bgView.addSubview(fetchNowButton)
        contentView.addSubview(bgView)
        
        bgView.snp.makeConstraints { (make) in
            make.top.equalTo(4)
            make.leading.equalTo(12)
            make.trailing.equalTo(-12)
            make.bottom.equalTo(-13)
        }
        
        fetchNowButton.snp.makeConstraints { (make) in
            make.width.equalTo(70)
            make.height.equalTo(37)
            make.right.equalTo(-12)
            make.centerY.equalToSuperview()
        }
        
        tipsLabel.snp.makeConstraints { (make) in
            make.left.equalTo(12)
            make.top.equalTo(bgView)
            make.height.equalTo(37)
            make.right.equalTo(fetchNowButton.snp.left).offset(-5)

        }
    }
    
    @objc func fetchButtonAction () {
        
        let request = YXRequest.init(request: YXGetTokenRequestModel.init())
        request.startWithBlock { model in
            
            if  let  model = model as? YXGetTokenResponse {
                var set = NSCharacterSet.urlQueryAllowed
                set.remove(charactersIn: "!*'();:@&=+$,/?%#[]")
                let jumpUrl = "/pricing?tab=2"
                let path = jumpUrl.addingPercentEncoding(withAllowedCharacters: set)
                
                if let path = path, let url = URL(string: YXH5Urls.OPTION_BUY_ON_LINE_URL(model.tokenKey, and: path)) {
                    UIApplication.shared.open(url)
                }
            }
        } failure: { (_) in
            
        }
    }
    
    var bgView : UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().textColorLevel1().withAlphaComponent(0.05)
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        
        return view
    } ()
    
    lazy var tipsLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1() 
        label.text = YXLanguageUtility.kLang(key: "stockST_BMP_nonsupport_viewing")
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textAlignment = .left
        
        return label
    }()
    
    lazy var fetchNowButton: QMUIButton = {
        let button = QMUIButton()
        button.setTitle(YXLanguageUtility.kLang(key: "stock_detail_eagerly_fetch"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.8
        button.setImage(UIImage.init(named: "stare_fetchMore"), for: .normal)
        button.imagePosition = .right
        button.titleLabel?.baselineAdjustment = .alignCenters
        button.spacingBetweenImageAndTitle = 2
        button.setTitleColor(QMUITheme().themeTintColor(), for: .normal)
        button.contentHorizontalAlignment = .right
        button.addTarget(self, action: #selector(fetchButtonAction), for: .touchUpInside)
        
        return button
    }()
    

    
}
