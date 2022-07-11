//
//  YXProgressHUD.swift
//  uSmartOversea
//
//  Created by mac on 2019/3/26.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import MBProgressHUD
import YXKit
import RxSwift
import RxCocoa
import Lottie

let kHUDAlpha = 0.8


var hudContentColor = UIColor.themeColor(withNormal: UIColor.white, andDarkColor: UIColor.qmui_color(withHexString: "#D3D4E6")!)
var hudBackgroundColor = UIColor.themeColor(withNormalHex: "#2A2A34", andDarkColor: "#2A2A34").withAlphaComponent(0.9)

@objc enum YXLoadingAnimationType: Int {
    case color
    case netWork
    
    var lottieAnimationName: String {
        switch self {
        case .color:
            return "loading"
        case .netWork:
            return YXThemeTool.isDarkMode() ? "netWorkLoading_dark" : "netWorkLoading"
        }
    }
}

public class YXProgressHUD: MBProgressHUD {
    @objc func showLoading(_ message: String?, in view: UIView! = YXConstant.sharedAppDelegate?.window!) {
        if (view == nil) {return}
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.hideHud), object: nil)
        isUserInteractionEnabled = true
        self.commonAppearance()
        mode = .indeterminate
        removeFromSuperViewOnHide = true
        detailsLabel.text = message
        setOffset()
        
        view.addSubview(self)
        
        show(animated: true)
    }

    @objc func showLoading(inViewController viewcontroller: UIViewController, message: String?) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.hideHud), object: nil)
        isUserInteractionEnabled = true
        mode = .indeterminate
        self.commonAppearance()
        removeFromSuperViewOnHide = true
        detailsLabel.text = message
        setOffset()
        
        viewcontroller.view.addSubview(self)
        
        show(animated: true)
    }

    @objc func showMessage(_ message: String?, in view: UIView! = YXConstant.sharedAppDelegate?.window!, hideAfter delay:CGFloat = 2) {
        if (view == nil) {return}
        isUserInteractionEnabled = false
        mode = .customView
        let image: UIImage? = UIImage(named: "Hud_done")?.withRenderingMode(.alwaysTemplate)
        customView = UIImageView(image: image)
        self.commonAppearance()
        detailsLabel.text = message
        removeFromSuperViewOnHide = true
        setOffset()
        
        view.addSubview(self)
        show(animated: true)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.hideHud), object: nil)
        perform(#selector(self.hideHud), with: nil, afterDelay: TimeInterval(delay))
    }
    
    @objc func showSuccess(_ message: String?, in view: UIView! = YXConstant.sharedAppDelegate?.window!, hideAfter delay:CGFloat = 2) {
        if (view == nil) {return}
        isUserInteractionEnabled = false
        mode = .customView
        let image = UIImage(named: "Hud_done")?.withRenderingMode(.alwaysTemplate)
        customView = UIImageView(image: image)
        self.commonAppearance()
        detailsLabel.text = message
        removeFromSuperViewOnHide = true
        setOffset()
        view.addSubview(self)
        show(animated: true)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.hideHud), object: nil)
        perform(#selector(self.hideHud), with: nil, afterDelay: TimeInterval(delay))
    }
    
    @objc func showError(_ message: String?, in view: UIView! = YXConstant.sharedAppDelegate?.window!, hideAfter delay:CGFloat = 2) {
        if (view == nil) {return}
        isUserInteractionEnabled = false
        mode = .customView
        let image = UIImage(named: "Hud_error")?.withRenderingMode(.alwaysTemplate)
        customView = UIImageView(image: image)
        self.commonAppearance()
        detailsLabel.text = message
        removeFromSuperViewOnHide = true
        setOffset()
        
        view.addSubview(self)
        show(animated: true)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.hideHud), object: nil)
        perform(#selector(self.hideHud), with: nil, afterDelay: TimeInterval(delay))
    }
    
    @objc func hideHud() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.hideHud), object: nil)
        removeFromSuperViewOnHide = true
        hide(animated: false)
    }
    
    private func setOffset(isSet :Bool = false) {
        
        if isSet {
            if QMUIKeyboardManager.isKeyboardVisible() {
                
                offset = CGPoint(x: 0, y: -detailsLabel.sizeThatFits(self.bounds.size).height / 2 - 40)
            } else {
                offset = CGPoint(x: 0, y: 0)
            }
        }
    }
    

    @objc @discardableResult class func showLoading(_ message: String?, in view: UIView!) -> YXProgressHUD {
        if (view == nil) {return YXProgressHUD()}
        let hud = YXProgressHUD(view: view)
        hud.commonAppearance()
        hud.removeFromSuperViewOnHide = true
        hud.detailsLabel.text = message
        hud.setOffset()
        
        view.addSubview(hud)
        hud.show(animated: true)
        return hud
    }
    
    @objc class func showLoading(_ message: String?) -> YXProgressHUD {
        YXProgressHUD.showLoading(message, in: YXConstant.sharedAppDelegate?.window!)
    }
    
    @objc class func showMessage(_ message: String?, in view: UIView!, hideAfterDelay delay: CGFloat) {
        if (view == nil) {return}
        YXProgressHUD.showMessage(message, in: view, hideAfterDelay: delay, userInteractionEnabled: true)
    }
    
    @objc class func showMessage(_ message: String?, in view: UIView!) {
        if (view == nil) {return}
        YXProgressHUD.showMessage(message, in: view, hideAfterDelay: 2)
    }
    
    @objc class func showMessage(_ message: String?) {
        YXProgressHUD.showMessage(message, in: YXConstant.sharedAppDelegate?.window!, hideAfterDelay: 2)
    }
    
    @objc class func showMessage(_ message: String?, in view: UIView!, hideAfterDelay delay: CGFloat, userInteractionEnabled enabled: Bool) {
        if (view == nil) {return}
        
        let hud = YXProgressHUD.showLoading(message, in: view)
        hud.commonAppearance()
        hud.isUserInteractionEnabled = !enabled
        hud.removeFromSuperViewOnHide = true
        hud.mode = .customView
        hud.customView = nil
        hud.detailsLabel.text = message
        hud.hide(animated: true, afterDelay: TimeInterval(delay))
    }
    
    @objc class func showMessage(_ message: String?, in view: UIView?, userInteractionEnabled enabled: Bool) {
        if (view == nil) {return}
        YXProgressHUD.showMessage(message, in: view, hideAfterDelay: 2, userInteractionEnabled: enabled)
    }
    
    @objc class func showMessage(_ message: String?, userInteractionEnabled enabled: Bool) {
        YXProgressHUD.showMessage(message, in: YXConstant.sharedAppDelegate?.window!, hideAfterDelay: 2, userInteractionEnabled: enabled)
    }
    
    @objc class func showError(_ message: String?, in view: UIView?, hideAfterDelay delay: CGFloat) {
        if (view == nil) {return}
        YXProgressHUD.showMessage(message, in: view, hideAfterDelay: delay, userInteractionEnabled: true)
    }
    
    @objc class func showError(_ message: String?, in view: UIView?) {
        if (view == nil) {return}
        YXProgressHUD.showError(message, in: view, hideAfterDelay: 2)
    }
    
    @objc class func showError(_ message: String?) {
        
        YXProgressHUD.showError(message, in: YXConstant.sharedAppDelegate?.window!, hideAfterDelay: 2)
    }
    
    @objc class func showError(_ message: String?, in view: UIView?, hideAfterDelay delay: CGFloat, userInteractionEnabled enabled: Bool) {
        if (view == nil) {return}
        let hud = YXProgressHUD.showLoading(message, in: view)
        hud.commonAppearance()
        hud.isUserInteractionEnabled = !enabled
        hud.removeFromSuperViewOnHide = true
        hud.mode = .customView
        let image = UIImage(named: "Hud_error")?.withRenderingMode(.alwaysTemplate)
        hud.customView = UIImageView(image: image)
        hud.detailsLabel.text = message
        hud.hide(animated: true, afterDelay: TimeInterval(delay))
    }
    
    @objc class func showError(_ message: String?, in view: UIView?, userInteractionEnabled enabled: Bool) {
        if (view == nil) {return}
        YXProgressHUD.showError(message, in: view, hideAfterDelay: 2, userInteractionEnabled: enabled)
    }
    
    @objc class func showError(_ message: String?, userInteractionEnabled enabled: Bool) {
        YXProgressHUD.showError(message, in: YXConstant.sharedAppDelegate?.window!, hideAfterDelay: 2, userInteractionEnabled: enabled)
    }
    
    @objc class func showSuccess(_ message: String?, in view: UIView?, hideAfterDelay delay: CGFloat) {
        if (view == nil) {return}
        YXProgressHUD.showSuccess(message, in: view, hideAfterDelay: delay, userInteractionEnabled: true)
    }
    
    @objc class func showSuccess(_ message: String?, in view: UIView?) {
        if (view == nil) {return}
        YXProgressHUD.showSuccess(message, in: view, hideAfterDelay: 2)
    }
    
    @objc class func showSuccess(_ message: String?) {
        
        YXProgressHUD.showSuccess(message, in: YXConstant.sharedAppDelegate?.window!, hideAfterDelay: 2)
    }
    
    @objc class func showSuccess(_ message: String?, in view: UIView?, hideAfterDelay delay: CGFloat, userInteractionEnabled enabled: Bool) {
        if (view == nil) {return}
        let hud = YXProgressHUD.showLoading(message, in: view)
        hud.commonAppearance()
        hud.isUserInteractionEnabled = !enabled
        hud.removeFromSuperViewOnHide = true
        hud.mode = .customView
        let image = UIImage(named: "Hud_done")?.withRenderingMode(.alwaysTemplate)
        hud.customView = UIImageView(image: image)
        hud.detailsLabel.text = message
        hud.hide(animated: true, afterDelay: TimeInterval(delay))
    }
    
    @objc class func showSuccess(_ message: String?, in view: UIView?, userInteractionEnabled enabled: Bool) {
        if (view == nil) {return}
        YXProgressHUD.showSuccess(message, in: view, hideAfterDelay: 2, userInteractionEnabled: enabled)
    }
    
    @objc class func showSuccess(_ message: String?, userInteractionEnabled enabled: Bool) {
        YXProgressHUD.showSuccess(message, in: YXConstant.sharedAppDelegate?.window!, hideAfterDelay: 2, userInteractionEnabled: enabled)
    }


    /// 带button的HudView
    /// - Parameters:
    ///   - message: 内容
    ///   - superview: 展示在那个view上
    ///   - buttonTitle: 按钮标题
    ///   - interval: 延时消失时长
    ///   - clickCallback: 按钮点击回调
    @objc class func showMessage(message: String, inView superview: UIView, buttonTitle:String, delay interval: TimeInterval, clickCallback: (() -> Void)?) {
        let view = superview.viewWithTag(98763)
        if view != nil {
            view?.removeFromSuperview()
        }
   
        let hudView = UIView()
        hudView.tag = 98763
        hudView.backgroundColor = hudBackgroundColor
        hudView.layer.cornerRadius = 4
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "stock_check")
        hudView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.width.equalTo(16)
            make.height.equalTo(17)
        }
        
        
        if !buttonTitle.isEmpty {
            let button = YXExpandAreaButton()
            button.tag = 98767
            button.setTitle(buttonTitle, for: .normal)
            button.setTitleColor(hudContentColor, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            _ = button.rx.tap.takeUntil(hudView.rx.deallocated)
                .subscribe(onNext: {
                [weak weakHud = hudView] _ in
                weakHud?.removeFromSuperview()
                clickCallback?()
            })

            hudView.addSubview(button)
            button.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.right.equalToSuperview().offset(-16)
            }
            button.sizeToFit()
        }
        

        let messageLabel = UILabel()
        messageLabel.text = message        
        messageLabel.textColor = hudContentColor
        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.textAlignment = .left
        hudView.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(imageView.snp.right).offset(12)
            if buttonTitle.isEmpty {
                make.right.equalToSuperview().offset(-16)
            } else {
                make.right.equalToSuperview().offset(-60)
            }
        }

        superview.addSubview(hudView)
        hudView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            if buttonTitle.isEmpty {
                make.left.greaterThanOrEqualToSuperview().offset(16)
                make.right.lessThanOrEqualToSuperview().offset(-16)
            } else {
                make.left.equalToSuperview().offset(16)
                make.right.equalToSuperview().offset(-16)
            }
            
            make.height.equalTo(48)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            hudView.removeFromSuperview()
        }
    }

}

extension YXProgressHUD {
    @objc func commonAppearance() {
        self.bezelView.style = .solidColor;
        self.bezelView.layer.cornerRadius = 4.0;
        self.contentColor = hudContentColor
        self.bezelView.color = hudBackgroundColor
        self.detailsLabel.font = UIFont.systemFont(ofSize: 14)
        for subview in self.bezelView.subviews {
            if subview.isKind(of: UIActivityIndicatorView.self), let indicatorView = subview as? UIActivityIndicatorView  {
            
                indicatorView.style = .white
            }
            
        }
    }
    
    @objc func showLoading(in view: UIView! = UIViewController.current().view, type: YXLoadingAnimationType = .color) {
        if (view == nil) {return}
        isUserInteractionEnabled = true
        mode = .customView
        backgroundView.style = .solidColor
        backgroundView.color = .clear
        bezelView.style = .solidColor
        bezelView.color = .clear
        let animation = LOTAnimationView.init(name: type.lottieAnimationName)
        animation.play()
        animation.size = CGSize(width: 30, height: 30)
        animation.snp.makeConstraints { make in
            make.width.equalTo(60)
        }
        animation.contentMode = .scaleAspectFit
        animation.loopAnimation = true
      //  animation.backgroundBehavior = .pauseAndRestore
        customView = animation

        removeFromSuperViewOnHide = true
        setOffset()
        
        view.addSubview(self)
        show(animated: true)
    }
}

extension Reactive where Base: YXProgressHUD {
    
    public var isShowNetWorkLoading: Binder<Bool> {
        return Binder.init(self.base) { hud, isShow in
            if isShow {
                hud.showLoading(type: .netWork)
            }else {
                hud.hideHud()
            }
        }
    }
}
