//
//  STLAlertTempView.swift
// XStarlinkProject
//
//  Created by odd on 2021/7/14.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit


class STLAlertTempView : UIView {
    
    @objc init(frame:CGRect, message:String!, buttonTitle:String!) {
        super.init(frame: frame)
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        createView(message: message,buttonTitle: buttonTitle)
    }
    
    func createView(message: String!, buttonTitle: String!) {
        self.addSubview(self.contentView)
        self.contentView.addSubview(self.closeButton)
        self.contentView.addSubview(self.confirmButton)
        self.contentView.addSubview(self.messageLabel)
        
        self.contentView.snp.makeConstraints { make in
            make.leading.equalTo(self).offset(36)
            make.trailing.equalTo(self).offset(-36)
            make.centerY.equalTo(self)
        }
        // 12 12
        self.closeButton.snp.makeConstraints { make in
            make.top.equalTo(6)
            make.trailing.equalTo(-4)
        }
        
        self.messageLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.contentView.snp.leading).offset(20)
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-20)
            make.top.equalTo(self.closeButton.snp.bottom).offset(12)
        }
        
        self.confirmButton.snp.makeConstraints { make in
            make.leading.equalTo(self.contentView.snp.leading).offset(20)
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-20)
            make.top.equalTo(self.messageLabel.snp.bottom).offset(20)
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-20)
            make.height.equalTo(36)
        }
        
        self.messageLabel.text = message
        self.confirmButton .setTitle(buttonTitle, for: .normal)
        
        showAlert()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - setter
    lazy var contentView: UIView = {
        let view: UIView = UIView(frame: .zero)
        view.backgroundColor = OSSVThemesColors.stlWhiteColor()
        view.layer.cornerRadius = 6.0
        view.layer.masksToBounds = true
        return view
    }()
    lazy var closeButton: UIButton = {
        let btn: UIButton = UIButton(type: .custom)
        btn.setImage(UIImage(named: "close_18"), for: .normal)
        btn.addTarget(self, action: #selector(colseAction), for: .touchUpInside)
        btn.contentEdgeInsets = UIEdgeInsets.init(top: 6, left: 8, bottom: 0, right: 8)
        return btn
    }()
    
    lazy var confirmButton: UIButton = {
        let btn: UIButton = UIButton(type: .custom)
        btn.backgroundColor = OSSVThemesColors.col_0D0D0D()
        btn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        btn.titleLabel?.font = UIFont.stl_buttonFont(12)
        return btn
    }()
    
    lazy var messageLabel: UILabel = {
        let msgLabel = UILabel(frame: CGRect.zero)
        msgLabel.numberOfLines = 0
        msgLabel.textAlignment = .center
        msgLabel.textColor = OSSVThemesColors.col_0D0D0D()
        msgLabel.font = UIFont.systemFont(ofSize: 14)
        return msgLabel
    }()
    
    typealias alertTempBlock = ()->Void
    @objc var dismissBlock: alertTempBlock?
    @objc var confirmBlock: alertTempBlock?

    //MARK: - action
    @objc func colseAction() {
        dismiss()
    }
    
    @objc func confirmAction() {
        self.confirmBlock?()
        dismiss()
    }
    
    @objc func showAlert() {
        self.alpha = 0.0
        self.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
        let window: UIWindow? = keyWindow()
        if (window != nil) {
            window?.endEditing(true)
            window?.addSubview(self)
            
            self.contentView.transform = CGAffineTransform.init(scaleX: 1.12, y: 1.12)
            UIView.animate(withDuration: 0.15) {
                self.alpha = 1;
                self.contentView.transform = CGAffineTransform.identity
            }
        }
    }
    
    @objc func dismiss() {
        UIView.animate(withDuration: 0.1) {
            self.alpha = 0.0
            self.contentView.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
            
        }completion: { finished in
            self.dismissBlock?()
            self.removeFromSuperview()
        }
    }
    
    func keyWindow() -> UIWindow? {
        var window: UIWindow? = nil
        if #available(iOS 13.0, *) {
            for windowScene:UIWindowScene in (UIApplication.shared.connectedScenes as? Set<UIWindowScene>)! {
                if windowScene.activationState == .foregroundActive {
                    window = windowScene.windows.first
                }
                break
            }
        } else {
            window = UIApplication.shared.keyWindow
        }
        return window
    }
    
}

