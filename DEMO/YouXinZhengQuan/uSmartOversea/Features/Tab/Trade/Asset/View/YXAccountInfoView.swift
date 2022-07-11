//
//  YXAccountInfoView.swift
//  uSmartOversea
//
//  Created by 覃明明 on 2021/7/13.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXAccountInfoView: UIView {
    
    var didChoose:((_ type:YXBrokersBitType)->())?
    
    var model: YXAccountAssetResModel? {
        didSet {
            if let m = model {
                selectView.selectBroker = YXUserManager.shared().curBroker
                if YXUserManager.shared().curBroker == .sg {
                    selectView.frame = CGRect.init(x: 0, y: 14, width: 84, height: 16)
                    imageView.frame = CGRect.init(x: 88, y: 10, width: 11, height: 10)
                }else {
                    selectView.frame = CGRect.init(x: 0, y: 4, width: 106, height: 16)
                    imageView.frame = CGRect.init(x: 108, y: 10, width: 11, height: 10)
                }
               
            }
        }
    }

    lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "icon_allow_down"))
        return imageView
    }()

    lazy var selectView : YXBrokerSelectView = {
        let selectView = YXBrokerSelectView.init(frame: CGRect.init(x: 0, y: 14, width: 127, height: 16))
        selectView.selectBroker = YXUserManager.shared().curBroker
        selectView.didChoose = { [weak self] broker in
            if broker == YXUserManager.shared().curBroker {
                
            }else {
                let alertView = YXAlertView(title: "Sure you want to switch to " + broker.text + "?", message: "The current logged broker will be logged out", prompt: "", style: .default, messageAlignment: .center)
                alertView.clickedAutoHide = false

                alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "cancel_btn"), style: .cancel, handler: {[weak alertView] action in
                    alertView?.hide()
                }))

                alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "user_confirmLoginout"), style: .default, handler: {[weak alertView] action in
                    self?.didChoose?(broker)
                    alertView?.hide()
                }))
                alertView.showInWindow()
            }
        }
        return selectView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    lazy var accountIdLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor.qmui_color(withHexString: "#ffffff")?.withAlphaComponent(0.6)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    private lazy var infoView:UIView={
        let view = UIView()
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer()
        tap.addActionBlock { [weak self] _ in
            self?.selectView.showPop(from: view)
        }
        view.addGestureRecognizer(tap)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(infoView)
        
          infoView.addSubview(selectView)

          infoView.addSubview(accountIdLabel)
        
        if YXConstant.appTypeValue == .OVERSEA {
            infoView.addSubview(imageView)
        }
        
        infoView.frame = frame
        imageView.frame = CGRect.init(x: 108, y: 10, width: 11, height: 10)
        accountIdLabel.frame = CGRect.init(x: 0, y: 28, width: frame.width, height: 14)
        

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
