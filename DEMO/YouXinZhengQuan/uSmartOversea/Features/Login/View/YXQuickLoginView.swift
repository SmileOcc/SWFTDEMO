//
//  YXSignInBottomView.swift
//  OpenSourceStd
//
//  Created by usmart on 2021/3/31.
//

import UIKit


class YXQuickLoginView: UIView {

    lazy var titLabel : QMUILabel = {
        let lab = QMUILabel()
        lab.text = YXLanguageUtility.kLang(key: "quick_login")
        lab.textAlignment = .center
        lab.backgroundColor = QMUITheme().foregroundColor()
        lab.textColor = QMUITheme().textColorLevel4()
        lab.contentEdgeInsets = UIEdgeInsets.init(top: 4, left: 8, bottom: 4, right: 8)
        lab.font = .systemFont(ofSize: 14, weight: .regular)
        return lab
    }()
    
    lazy var lineView : UIView = {
        let line = UIView.init()
        line.backgroundColor = QMUITheme().pointColor()
        
        return line
    }()
    
    lazy var faceBookBtn : QMUIButton = {
        let btn = QMUIButton()
        btn.setImage(UIImage.init(named: "icon_signin_fb"), for: .normal)
        return btn
    }()
    
    lazy var googleBtn : QMUIButton = {
        let btn = QMUIButton()
        btn.setImage(UIImage.init(named: "icon_signin_google"), for: .normal)
        return btn
    }()
    
    lazy var weChatBtn : QMUIButton = {
        let btn = QMUIButton()
        btn.setImage(UIImage.init(named: "icon_signin_wechat"), for: .normal)
        return btn
    }()
    
    lazy var appleBtn : QMUIButton = {
        let btn = QMUIButton()
        btn.setImage(UIImage.init(named: "icon_signin_apple"), for: .normal)
        return btn
    }()
    
    lazy var lineBtn : QMUIButton = {
       let btn = QMUIButton()
        btn.setImage(UIImage.init(named: "icon_signin_line"), for: .normal)
        return btn
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var showWechat = false
    
    convenience init(hasWeChat:Bool) {
        self.init(frame: .zero)
        self.showWechat = hasWeChat
        setupUI()
    }
    
    func setupUI()  {
        
        var btns:[UIButton] = [faceBookBtn,googleBtn]
       
        addSubview(lineView)
        addSubview(titLabel)
        
        lineView.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.width.equalTo(167)
            make.top.equalTo(11.5)
            make.centerX.equalToSuperview()
        }
        
        titLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 95, height: 24))
            make.top.equalToSuperview()
        }
        
        
        weChatBtn.isHidden = !showWechat
        if showWechat {
            btns.append(weChatBtn)
        }
        
        btns.append(lineBtn)
        //ios 13.0及以上支持Apple ID
        if #available(iOS 13.0, *) {
            btns.append(appleBtn)
        }
        
        let itmeCount:CGFloat = CGFloat(btns.count)
        
        let spascing = (UIScreen.main.bounds.size.width - 60 - itmeCount * 40) / (itmeCount - 1)
        var lastBtn = UIView()
        for i in 0..<btns.count {
            let btn = btns[i]
            addSubview(btn)
            btn.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize.init(width: 40, height: 40))
                make.top.equalTo(titLabel.snp.bottom).offset(20)
                if i == 0 {
                    make.left.equalTo(30)
                }else {
                    make.left.equalTo(lastBtn.snp.right).offset(spascing)
                }
            }
            lastBtn = btn
        }
        
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}


