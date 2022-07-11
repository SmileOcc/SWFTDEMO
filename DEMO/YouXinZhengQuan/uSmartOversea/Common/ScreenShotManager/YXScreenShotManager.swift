//
//  YXScreenShotManager.swift
//  uSmartOversea
//
//  Created by youxin on 2019/5/28.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import RxSwift

class YXScreenShotManager: NSObject {
    
    @objc static let shared = YXScreenShotManager()
    
    private override init() {
        
    }
    
    override func copy() -> Any {
        self
    }
    
    override func mutableCopy() -> Any {
        self
    }
    
    // Optional
    func reset() -> Void {
        // Reset all properties to default value
    }
    
    func observerSystemScreenShotNotificatin() {
        
        _ = NotificationCenter.default.rx.notification(UIApplication.userDidTakeScreenshotNotification)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: {
                [weak self] noti in
                guard let strongSelf = self else { return }
                strongSelf.userDidTakeScreenshot()
            }).disposed(by: rx.disposeBag)
    }
    
    
    func userDidTakeScreenshot() {
        
        if self.isAllUnIntalled() {
            return
        }
        
        if UIDevice.current.orientation != .portrait {
            return;
        }
        
        if UIViewController.current().isKind(of: QMUIModalPresentationViewController.self) {
            return
        }
        
        if let root = UIApplication.shared.delegate as? YXAppDelegate {

            if let window = root.window, let image = UIImage.qmui_image(with: window, afterScreenUpdates: true) {
                let shareView = YXShareCommonView(frame: UIScreen.main.bounds)
                shareView.shareImage = image
                shareView.showShareView()
            }
        }
    }

    func isAllUnIntalled() -> Bool {
        var unintall = true

        if (YXShareSDKHelper.isClientIntalled(.typeFacebook) ||  YXShareSDKHelper.isClientIntalled(.typeWechat)
            || YXShareSDKHelper.isClientIntalled(.typeWhatsApp) || YXShareSDKHelper.isClientIntalled(.typeFacebookMessenger)) {
            unintall = false
        }
        return unintall
    }
}
