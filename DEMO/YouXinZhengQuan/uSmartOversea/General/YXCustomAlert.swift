//
//  YXCustomAlert.swift
//  uSmartOversea
//
//  Created by 覃明明 on 2021/7/27.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

//enum YXAlertStyle: Int {
//    case normal
//    case customView
//}

class YXCustomAlert: NSObject {
    
    @objc var customView: UIView?
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel1()
        label.textAlignment = .center
        
        return label
    }()
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        label.textColor = QMUITheme().textColorLevel1()
        
        return label
    }()
    
    lazy var sureButton: UIButton = {
        let button = creatButton()
        button.setTitleColor(.white, for: .normal)
        button.setTitle("", for: .normal)
        button.backgroundColor = QMUITheme().mainThemeColor()
        _ = button.rx.tap.asControlEvent().takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] (btn) in
            
        })
        return button
    }()
    
    lazy var cancelButton: UIButton = {
        let button = creatButton()
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        button.setTitle("", for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = QMUITheme().pointColor().cgColor
        _ = button.rx.tap.asControlEvent().takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] (btn) in
            
        })
        return button
    }()
    
    func creatButton() -> QMUIButton {
        let button = QMUIButton()
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        return button
    }
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 20
        return stackView
    }()
    
    lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }()
    
    @objc func showAlert(title: String? = nil, msg: String? = nil, cancelButtonTitle: String? = nil, sureButtonTitle: String, cancelAction: (() -> Void)? = nil, sureAction: (() -> Void)? = nil) {
        
        titleLabel.text = title
        
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        
        contentStackView.addArrangedSubview(titleLabel)
        if let custom = self.customView {
            contentStackView.addArrangedSubview(custom)
        }else {
            if let text = msg {
                contentStackView.addArrangedSubview(messageLabel)
                messageLabel.text = text
            }
        }
        
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(sureButton)
        
        view.addSubview(contentStackView)
        view.addSubview(buttonStackView)
        
        
        contentStackView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(20)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(contentStackView.snp.bottom).offset(20)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(36)
        }
        
        let alertVC = YXAlertController.init(alert: view)!
        alertVC.alertStyleEdging = 45
        
        if let cancelTitle = cancelButtonTitle {
            cancelButton.setTitle(cancelTitle, for: .normal)
            _ = cancelButton.rx.tap.takeUntil(view.rx.deallocated).subscribe {[weak alertVC] _ in
                
                alertVC?.dismiss(animated: true) {
                    cancelAction?()
                }
            }

        }else {
            cancelButton.isHidden = true
        }
        
        sureButton.setTitle(sureButtonTitle, for: .normal)
        _ = sureButton.rx.tap.takeUntil(view.rx.deallocated).subscribe {[weak alertVC] _ in
            
            alertVC?.dismiss(animated: true) {
                sureAction?()
            }
        }
        
        let vc = UIViewController.current()
        vc.present(alertVC, animated: true, completion: nil)
    }

}
