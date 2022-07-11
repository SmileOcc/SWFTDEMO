//
//  YXIBCaptchaView.swift
//  uSmartOversea
//
//  Created by ysx on 2021/7/16.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXIBCaptchaView: UIView {

    typealias Click = ()->()
    
    var leftClick : Click?
    var rightClick : Click?
    
    lazy var titleLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = .black
        lab.textAlignment = .center
        lab.font = .systemFont(ofSize: 16)
        return lab
    }()
    
    lazy var descLabel : UILabel = {
        let lab = UILabel()
        lab.textColor = QMUITheme().textColorLevel1()
        lab.font = .systemFont(ofSize: 14)
        lab.textAlignment = .center
        lab.numberOfLines = 0
        return lab
    }()
    
    private var scrollView : UIScrollView = {
       let scroView = UIScrollView()
        scroView.showsVerticalScrollIndicator = false
        scroView.shouldHideToolbarPlaceholder = false
        return scroView
    }()
    
    lazy var inputTextField : YXTimeTextField = {
        let input = YXTimeTextField.init(defaultTip: "", placeholder: "")
        return input
    }()
    
    lazy var errorLabel: UILabel = {
        let lab = UILabel()
      //  lab.text = "Verification code error"
        lab.textAlignment = .center
        lab.font = .systemFont(ofSize: 12)
        lab.textColor = UIColor.qmui_color(withHexString: "#EE3D3D")
        lab.numberOfLines = 2
       // lab.isHidden = true
        return lab
    }()
    
    lazy var leftBtn : QMUIButton = {
        let btn = QMUIButton()
        btn.layer.cornerRadius = 4
        btn.clipsToBounds = true
        btn.layer.borderWidth = 1
        btn.layer.borderColor = QMUITheme().pointColor().cgColor
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14.sacel375f())
        btn.setTitle(YXLanguageUtility.kLang(key: "common_cancel"), for: .normal)
        return btn
    }()
    
    lazy var rightBtn : QMUIButton = {
        let btn = QMUIButton()
        btn.layer.cornerRadius = 4
        btn.clipsToBounds = true
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14.sacel375f())
        btn.backgroundColor = QMUITheme().mainThemeColor()
        btn.setTitle(YXLanguageUtility.kLang(key: "common_confirm"), for: .normal)
        return btn
    }()
    
    func updateError(_ msg:String){
        self.errorLabel.text = msg
//        errorLabel.snp.updateConstraints { (make) in
//            make.height.equalTo(msg.count > 0 ? 14 : 0)
//        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubView()  {
        addSubview(scrollView)
        backgroundColor  = .clear
        scrollView.backgroundColor = .clear
        
        let containView = UIView()
        containView.backgroundColor = QMUITheme().foregroundColor()
        containView.layer.cornerRadius = 7
        containView.clipsToBounds = true

        scrollView.addSubview(containView)
        containView.addSubview(titleLabel)
        containView.addSubview(descLabel)
        containView.addSubview(inputTextField)
        containView.addSubview(leftBtn)
        containView.addSubview(rightBtn)
        containView.addSubview(errorLabel)
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        containView.snp.makeConstraints { (make) in
            make.left.equalTo(45)
            make.right.equalTo(self.snp.right).offset(-45)
            make.centerY.equalToSuperview()
            //make.bottom.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(20)
            make.left.equalTo(16)
            make.right.equalToSuperview().offset(-16)
        }
    
        descLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
        }
        
        inputTextField.snp.makeConstraints { (make) in
            make.left.right.equalTo(descLabel)
            make.top.equalTo(descLabel.snp.bottom).offset(12)
            make.height.equalTo(50)
        }
        
        errorLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(inputTextField)
            make.top.equalTo(inputTextField.snp.bottom).offset(4)
           // make.height.equalTo(0)
        }
        
        leftBtn.snp.makeConstraints { (make) in
            make.top.equalTo(errorLabel.snp.bottom).offset(20)
            make.left.equalTo(16)
            make.height.equalTo(36)
            make.bottom.equalTo(containView.snp.bottom).offset(-20)
        }
        
        rightBtn.snp.makeConstraints { (make) in
            make.top.equalTo(leftBtn)
            make.left.equalTo(leftBtn.snp.right).offset(13)
            make.right.equalToSuperview().offset(-16)
            make.size.equalTo(leftBtn)
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
