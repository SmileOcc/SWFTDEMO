//
//  YXOnlineServiceViewController.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/5/16.
//  Copyright © 2019 RenRenDai. All rights reserved.
//
///帮助与客服
import UIKit

class YXOnlineServiceViewController: YXWebViewController {

    let IM_USER_KEY = "1d3057dc2828babd2206deb4b35c747a"
    
    lazy var DeskURL: String = {
        switch YXUserManager.curLanguage() {
        case .CN:
                return "https://yxzq.udesk.cn/im_client/?web_plugin_id=70131&group_id=107091&language=zh-cn"
        case .HK,
             .unknown:
                return "https://yxzq.udesk.cn/im_client/?web_plugin_id=70131&group_id=107091&language=zh-HK"
        case .EN:
                return "https://yxzq.udesk.cn/im_client/?web_plugin_id=70131&group_id=107091&language=en-us"
        case .ML:
            return "https://yxzq.udesk.cn/im_client/?web_plugin_id=70131&group_id=107091&language=ms"
        case .TH:
            return "https://yxzq.udesk.cn/im_client/?web_plugin_id=70131&group_id=107091&language=th"
        }
    }()
    lazy var serviceUrl: String = {
        let random = arc4random() % 100
        let userUUID = YXUserManager.userUUID()
        let uuidStr = String(format: "%llu", userUUID)
        let timestamp = TimeInterval(Date().timeIntervalSince1970 * 1000)
        let timestampStr = String(format: "%.0lf", timestamp)
        let str = "nonce=\(random)&timestamp=\(timestampStr)&web_token=\(uuidStr)"
        let sha1Str = "\(str)&\(IM_USER_KEY)".sha1().uppercased()
        let url = "\(DeskURL)&signature=\(sha1Str)&c_cf_uuid=\(uuidStr)&\(str)"
        return url
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_ :)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func webViewLoadRequest() {
        super.webViewLoadRequest()
        if let url = URL(string: self.serviceUrl) {
            self.webView?.load(URLRequest(url: url))
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        
        let duration: Double = (userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        
        let keyboardF: CGRect = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? CGRect.zero
        
        UIView.animate(withDuration: TimeInterval(duration), animations: {
            if keyboardF.origin.y > self.view.frame.height {
                var frame: CGRect = self.webView?.frame ?? CGRect.zero
                frame.origin.y = self.view.frame.height - (self.webView?.frame.height ?? 0.0)
                self.webView?.frame = frame
            } else {
                var frame: CGRect = self.webView?.frame ?? CGRect.zero
                frame.origin.y = keyboardF.origin.y - (self.webView?.frame.height ?? 0.0)
                self.webView?.frame = frame
            }
        })
    }
}
