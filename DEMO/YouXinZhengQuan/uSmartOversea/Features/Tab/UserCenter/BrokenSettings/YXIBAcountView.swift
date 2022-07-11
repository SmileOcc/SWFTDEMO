//
//  YXIBAcountView.swift
//  uSmartOversea
//
//  Created by ysx on 2021/7/16.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXIBAcountView: UIView {

    let titleView = UILabel()
    let secureView = UILabel()
    let detailView = UIView()
    let detalLabel = UILabel()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubView()  {
        
        titleView.textColor = QMUITheme().textColorLevel1()
        titleView.font = .systemFont(ofSize: 14)
        detalLabel.textColor = QMUITheme().textColorLevel1()
        detalLabel.font = .systemFont(ofSize: 14)
        
        detailView.addSubview(detalLabel)
        let iconView = UIImageView.init(image: UIImage.init(named: "settings_IB_tag"))
        detailView.addSubview(iconView)
        
        
        addSubview(titleView)
        addSubview(secureView)
        addSubview(detailView)
        detailView.isHidden = true
        
        titleView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(16)
            make.height.equalToSuperview()
            make.width.equalTo(120)
        }
        
        secureView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(66)
            make.height.equalToSuperview()
        }
        
        for i in 0...5 {
            let dotView = UIView()
            dotView.backgroundColor = UIColor.qmui_color(withHexString: "#C4C5CE")
            dotView.layer.cornerRadius = 3
            dotView.clipsToBounds = true
            
            secureView.addSubview(dotView)
            dotView.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(i*12)
                make.size.equalTo(CGSize.init(width: 6, height: 6))
            }
        }
        
        detailView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.height.equalToSuperview()
            make.left.greaterThanOrEqualTo(titleView.snp.right).offset(10)
        }
        
        iconView.snp.makeConstraints { (make) in
            make.right.centerY.equalToSuperview()
        }
        
        detalLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(iconView.snp.left).offset(-12)
            make.left.equalToSuperview()
            make.height.equalTo(20)
        }
        
        let tap = UITapGestureRecognizer()
        iconView.isUserInteractionEnabled = true
        tap.addActionBlock {[weak self] (_) in
            let pasteboard = UIPasteboard.general
            pasteboard.string = self?.detalLabel.text ?? ""
            YXProgressHUD.showSuccess(YXLanguageUtility.kLang(key: "copy_success"))
        }
        iconView.addGestureRecognizer(tap)
        
    }
    
    func setText(_ title:String,detail:String)  {
        titleView.text = title
        detalLabel.text = detail
    }
    
    func showSecure(_ show:Bool) {
        secureView.isHidden = !show
        detailView.isHidden = show
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
