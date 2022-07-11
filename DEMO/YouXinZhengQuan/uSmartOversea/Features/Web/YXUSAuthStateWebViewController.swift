//
//  YXUSAuthStateWebViewController.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/5/29.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import WebKit
import YXKit
import MJRefresh
import QMUIKit

class YXUSAuthStateWebViewController: YXWebViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        
        
        var backItem = UIBarButtonItem.qmui_item(with: UIImage(named: "nav_back") ?? UIImage(), target: self, action: nil)
        backItem.rx.tap.bind { [weak self] in
            
            if let model = self?.viewModel as? YXUSAuthStateWebViewModel, model.isFromeRegister {
                if let webView = self?.webView {
                    YXJSActionUtil.invokeJSFunc(withWebview: webView, paramsJsonData: [
                        "canGoBack": NSNumber(value: webView.canGoBack)
                    ], callback: "javascript:window.h5HistoryBack", completionCallback: { (result, error) in
                        let resultBool: Bool = (result as? NSNumber)?.boolValue ?? false
                        if result != nil && resultBool {
                            log(.verbose, tag: kModuleViewController, content: "window.h5HistoryBack running")
                        } else {
                            if webView.canGoBack {
                                webView.goBack()
                                self?.handleGoBackOrFinishEvent()
                            } else {
                            }
                        }
                        
                    })
                }
            } else {
                self?.jumpAuthority()
            }
            }.disposed(by: disposeBag)
        
        self.navigationItem.leftBarButtonItems = [backItem]
    }
    
    override func shouldPopViewController(byBackButtonOrPopGesture byPopGesture: Bool) -> Bool {
        return false
    }
    
    override func setupWebView() {
        super.setupWebView()
        
        if let vm = viewModel as? YXUSAuthStateWebViewModel,vm.dragStyle {
            self.webView?.frame = CGRect.init(x: 0, y: 0, width: YXConstant.screenWidth, height: YXConstant.screenHeight - YXConstant.navBarHeight())
        } else {
            self.webView?.frame = CGRect.init(x: 0, y: YXConstant.navBarHeight(), width: YXConstant.screenWidth, height: YXConstant.screenHeight - YXConstant.navBarHeight())
        }
        
        
        self.webView?.scrollView.mj_header = YXRefreshHeader.init(refreshingBlock: { [weak self] in
            if self?.webView?.isLoading ?? true {
                self?.webView?.stopLoading()
            }
            
            if (self?.webView?.url) != nil {
                self?.webView?.reload()
            } else {
                
                if let model = self?.viewModel as? YXUSAuthStateWebViewModel, let url = URL.init(string: YXH5Urls.YX_US_STOCK_MARKET_STATEMENT_URL(model.isHideSkip)) {
                    self?.webView?.load(URLRequest.init(url: url))
                }
            }
        })
    }
    
    override func webViewLoadRequest() {
        super.webViewLoadRequest()
        
        let model = viewModel as! YXUSAuthStateWebViewModel
        
        if let url = URL.init(string: YXH5Urls.YX_US_STOCK_MARKET_STATEMENT_URL(model.isHideSkip)) {
            self.webView?.load(URLRequest.init(url: url))
        }
    }

    //跳过
    func jumpAuthority()  {
        // 更新用户美股行情权限状态
        let extendStatusBit = YXUserManager.shared().curLoginUser?.extendStatusBit ?? 0 | YXExtendStatusBitType.hqAuthority.rawValue
        YXUserManager.shared().curLoginUser?.extendStatusBit = extendStatusBit
        
        //2.2更新用户信息数据
        YXUserManager.getUserInfo(complete: nil)
        
        //2.3发送通知
        NotificationCenter.default.post(name: NSNotification.Name(YXUserManager.notiUpdateUserInfo), object: nil)
        
        self.poptoVC(true)
    }
    
    //返回的 回调
    func backAlert() {
        self.view.endEditing(true)
        
        
        if let model = self.viewModel as? YXUSAuthStateWebViewModel, model.isFromeRegister {
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
                            //                                self.finish()
                        }
                    }
                    
                })
            }
        } else {
            
            let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "webview_usAuthStateBackTip"))
            alertView.clickedAutoHide = false
            alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: {[weak alertView] action in
                alertView?.hide()
            }))
            
            alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_confirm"), style: .default, handler: {[weak alertView, weak self] action in
                alertView?.hide()
                YXUserManager.loginOut(request: true)
                self?.poptoVC(false)
                
            }))
            alertView.showInWindow()
        }
        
        
        
    }
    
    fileprivate func poptoVC(_ shouldCallBack:Bool) {
        
        if YXUserManager.isShowLoginRegister() {
            YXUserManager.registerLoginInitRootViewControler()
            YXLaunchGuideManager.setGuideToLogin(withFlag: false)   //关闭从引导页到登录的标记
            return
        }
        let block: (() -> Void)? = { [weak self] in
            guard let strongSelf = self else {return}
            if shouldCallBack {
                //loginCallBack的回调
                if let loginCallBack = strongSelf.viewModel.loginCallBack {
                    loginCallBack(YXUserManager.userInfo)
                }
            }
        }
        if YXLaunchGuideManager.isGuideToLogin() == false {
            if let sourceVC = self.viewModel.sourceVC {
                if self.navigationController?.viewControllers.contains(sourceVC) ?? false {
                    self.navigationController?.qmui_pop(to: sourceVC, animated: true, completion: block)
                } else {
                    self.navigationController?.qmui_popToRootViewController(animated: true, completion: block)
                }
            } else {
                self.navigationController?.qmui_popViewController(animated: true, completion: block)
            }
        } else {
            //loginCallBack的回调
            if let loginCallBack = self.viewModel.loginCallBack {
                loginCallBack(YXUserManager.userInfo)
            }
            YXLaunchGuideManager.setGuideToLogin(withFlag: false)   //关闭从引导页到登录的标记
        }
    }
}
//MARK: 代理重写
extension YXUSAuthStateWebViewController {
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
}
//MARK: 协议
extension YXUSAuthStateWebViewController {
    func onCommandConfirmUSQuoteStatement(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
   
        self.jumpAuthority()
        
        if let successCallback = successCallback, let webView = self.webView, !successCallback.isEmpty {
            YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: "success", callback: successCallback)
        }
    }
    //token_failure
    func onCommandTokenFailure(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        YXUserManager.shared().tokenFailureAction()
        if let successCallback = successCallback, let webView = self.webView, !successCallback.isEmpty {
            YXJSActionUtil.invokeJSCallbackForSuccess(withWebview: webView, data: "success", callback: successCallback)
        }
    }
}
