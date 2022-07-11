//
//  PrivacySheet.swift
//  Adorawe
//
//  Created by fan wang on 2021/9/22.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

class PrivacySheet: UIView {
    
    @objc var isShow:Bool = false

    weak var closeBtn:UIButton!
    weak var desclbl:YYLabel!
    weak var agreeBtn:UIButton!
    
    @objc var notification:Notification?
    
    let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupViews(){
        let closeBtn = UIButton()
        addSubview(closeBtn)
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.08).cgColor
        layer.shadowRadius = 12
        layer.shadowOpacity = 1.0
        self.closeBtn = closeBtn
        closeBtn.setImage(UIImage(named: "privacy_close"), for: .normal)
        closeBtn.rx.tap.subscribe(onNext:{[weak self] in
            self?.dismiss()
            if let notification = self?.notification {
                let noti = Notification(name: notification.name, object: notification.object, userInfo: ["privacyClose":"1"])
                NotificationCenter.default.post(noti)
            }
           
        }).disposed(by: disposeBag)
        
        layer.cornerRadius = 6
        
        closeBtn.snp.makeConstraints { make in
            make.width.height.equalTo(36)
            make.top.equalTo(3)
            make.trailing.equalTo(-3)
        }
        
        let desclbl = YYLabel()
        desclbl.numberOfLines = 0
        desclbl.preferredMaxLayoutWidth = CGFloat.screenWidth - 24 - 41;
        let str = STLLocalizedString_("agree_text")!
        let actionStr = STLLocalizedString_("aggree_privacy_action")!
        let attrStr = NSMutableAttributedString(string: str)
        if let range = str.range(of: actionStr){
            attrStr.yy_setUnderlineColor(OSSVThemesColors.col_0D0D0D(), range: NSRange(range, in: str))
            attrStr.yy_setUnderlineStyle(.single, range:  NSRange(range, in: str))
            attrStr.yy_setTextHighlight(NSRange(range, in: str), color: nil, backgroundColor: nil) {[weak self] view, attr, range, rect in
                self?.showProvicy()
            }
        }
        attrStr.yy_font = UIFont.systemFont(ofSize: 14)
        


        desclbl.attributedText = attrStr
        self.desclbl = desclbl
        addSubview(desclbl)
        desclbl.textAlignment = .center
        desclbl.text = str
        
        desclbl.snp.makeConstraints { make in
            make.leading.equalTo(20.5)
            make.trailing.equalTo(-20.5)
            make.top.equalTo(47)
        }
        
        let agreeBtn = UIButton()
        addSubview(agreeBtn)
        self.agreeBtn = agreeBtn
        
        agreeBtn.setTitle(STLLocalizedString_("agree")?.uppercased(), for: .normal)
        agreeBtn.titleLabel?.font = UIFont.stl_buttonFont(12)
        agreeBtn.backgroundColor = OSSVThemesColors.col_0D0D0D()
        agreeBtn.snp.makeConstraints { make in
            make.leading.equalTo(20.5)
            make.trailing.equalTo(-20.5)
            make.bottom.equalTo(-20)
            make.height.equalTo(36)
            make.top.equalTo(desclbl.snp.bottom).offset(20)
        }
        
        agreeBtn.rx.tap.subscribe(onNext:{[weak self] in
            self?.dismiss()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ClosePrivacy"), object: nil)
            STLPreference.setObject(true, key: "noNeedShowPrivacy")
            if let notification = self?.notification {
                NotificationCenter.default.post(notification)
            }
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(Notification.Name("ClosePrivacy"), object: nil).subscribe(onNext:{[weak self] _ in
            self?.dismiss()
        }).disposed(by: disposeBag)
        
    }
    
    @objc func showIn(parentView:UIView,bottomAncher:UIView?,offset:NSNumber?){
        self.removeFromSuperview()
        parentView.addSubview(self)
        self.layer.zPosition = 1000
        self.backgroundColor = UIColor.white
        isShow = true
        self.snp.makeConstraints { make in
            make.leading.equalTo(12)
            make.trailing.equalTo(-12)
            if let ancher = bottomAncher{
                make.bottom.equalTo(ancher.snp.top).offset(-(offset?.floatValue ?? -8))
            }else{
                make.bottom.equalTo(parentView.snp.bottomMargin).offset(-(offset?.floatValue ?? -8))
            }
           
        }
    }
    
    func showProvicy() {
//        print("showProvicy")
        
        let privacy = STLWKWebCtrl()
        privacy.urlType = SystemURLType.privacyPolicy
        privacy.title = STLLocalizedString_("PrivacyPolicy")
        privacy.isNoNeedsWebTitile = true
        privacy.showClose = true
        
        let nav = OSSVNavigationVC(rootViewController: privacy)
        nav.modalPresentationStyle = .pageSheet
        
        viewController().present(nav, animated: true, completion: nil)
    }
    
    @objc func dismiss(){
        isShow = false
        self.removeFromSuperview()
    }
    
}
