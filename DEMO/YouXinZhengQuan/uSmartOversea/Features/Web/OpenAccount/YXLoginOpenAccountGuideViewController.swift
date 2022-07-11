//
//  YXLoginOpenAccountGuideViewController.swift
//  uSmartOversea
//
//  Created by 欧冬冬 on 2022/5/13.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import WebKit
import YXKit
import MJRefresh
import QMUIKit

class YXLoginOpenAccountGuideViewController: YXWebViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        
        
        let backItem = UIBarButtonItem.qmui_item(with: UIImage(named: "nav_back") ?? UIImage(), target: self, action: nil)
        backItem.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            
            if let webView = self.webView {
                YXJSActionUtil.invokeJSFunc(withWebview: webView, paramsJsonData: [
                    "canGoBack": NSNumber(value: webView.canGoBack)
                    ], callback: "javascript:window.h5HistoryBack", completionCallback: { (result, error) in
                        let resultBool: Bool = (result as? NSNumber)?.boolValue ?? false
                        if result != nil && resultBool {
                            log(.verbose, tag: kModuleViewController, content: "window.h5HistoryBack running")
                        } else {
                            if webView.canGoBack {
                                webView.goBack()
                                self.handleGoBackOrFinishEvent()
                            } else {
                                self.restRootVC()
                            }
                        }
                        
                })
            } else {
                self.restRootVC()
            }
            
        }.disposed(by: disposeBag)
        
        let closeItem = UIBarButtonItem.qmui_item(with: UIImage(named: "nav_close") ?? UIImage(), target: self, action: nil)
        closeItem.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            self.restRootVC()
            
        }.disposed(by: disposeBag)
        
        backItem.imageInsets = UIEdgeInsets(top: 0, left: -3.0, bottom: 0, right: 3.0)
        closeItem.imageInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 20)
        
        self.navigationItem.leftBarButtonItems = [backItem,closeItem]
        // titleView的最大宽度为减去左右两边预留的按钮宽度；
        self.titleView?.maximumWidth = YXConstant.screenWidth - ((44 + 8) * 2 * 2)
    }
    
    override func shouldPopViewController(byBackButtonOrPopGesture byPopGesture: Bool) -> Bool {
        return false
    }
    
    override func setupWebView() {
        super.setupWebView()
        
        self.webView?.frame = CGRect.init(x: 0, y: YXConstant.navBarHeight(), width: YXConstant.screenWidth, height: YXConstant.screenHeight - YXConstant.navBarHeight())
        
        self.webView?.scrollView.mj_header = YXRefreshHeader.init(refreshingBlock: { [weak self] in
            if self?.webView?.isLoading ?? true {
                self?.webView?.stopLoading()
            }
            
            if (self?.webView?.url) != nil {
                self?.webView?.reload()
            }
        })
    }
    
    override func webViewLoadRequest() {
        super.webViewLoadRequest()
        
        if let url = URL.init(string: YXH5Urls.YX_OPEN_ACCOUNT_APPLY_URL(true)) {
            self.webView?.load(URLRequest.init(url: url))
        }
    }

    fileprivate func restRootVC() {
        YXLaunchGuideManager.setGuideToLogin(withFlag: false)
        YXUserManager.registerLoginInitRootViewControler()
    }
}
//MARK: 代理重写
extension YXLoginOpenAccountGuideViewController {
    override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        super.webView(webView, didFinish: navigation)
        if let mj_header = self.webView?.scrollView.mj_header {
            mj_header.endRefreshing()
        }
    }
    
    override func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: Error) {
        super.webView(webView, didFailProvisionalNavigation: navigation, withError: error)
        if let mj_header = self.webView?.scrollView.mj_header {
            mj_header.endRefreshing()
        }
    }
    
    // 登录注册页开户完成 关闭网页事件
    override func onCommandCloseWebView(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        self.restRootVC()
    }
    
    // 登录注册页开户 网页内容返回事件
    override func onCommandGoBack(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        if self.webView != nil {
            if self.webView?.canGoBack ?? false {
                self.webView?.goBack()
                self.handleGoBackOrFinishEvent()
            } else {
                self.restRootVC()
            }
        } else {
            self.restRootVC()
        }
    }
}
