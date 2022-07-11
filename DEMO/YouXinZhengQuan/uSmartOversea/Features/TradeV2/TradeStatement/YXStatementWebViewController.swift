//
//  YXStatementWebViewController.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/7/20.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import WebKit

class YXStatementWebViewController: YXViewController {
    
    var webViewModel:YXStatementWebViewModel {
        return self.viewModel as! YXStatementWebViewModel
    }
    
    lazy var webView:WKWebView = {
        let web = WKWebView()
        web.navigationDelegate = self
        web.uiDelegate = self
        return web
    }()
    
    lazy private var progressView:UIProgressView = {
        let view = UIProgressView()
        view.progressTintColor = QMUITheme().themeTextColor()
        view.progress = 0.05
        view.trackTintColor = UIColor(red: 240.0/255, green: 240.0/255, blue: 240.0/255, alpha: 1.0)
        return view
    }()

    let pdfModel:YXStatementPdfModel = YXStatementPdfModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title =  YXLanguageUtility.kLang(key: "statement_jiedan")
 
        self.navigationItem.rightBarButtonItems = [messageItem]
        
        self.view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.webView.addSubview(self.progressView)
        self.progressView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(2)
        }
        self.webView.addObserver(self, forKeyPath: "estimatedProgress" , options: .new, context: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.webViewModel.pdfUrl.count > 0 {
            let name:String = pdfModel.pdfName(self.webViewModel.pdfUrl)
            let documentPath:String = pdfModel.cachePdfPath(name)
            let url = URL.init(fileURLWithPath: documentPath)
            
            var data: Data?
            do { try data = Data(contentsOf: url) } catch {}
            if let d = data {
                self.webView.load(d, mimeType: "application/pdf", characterEncodingName: "utf-8", baseURL: url)
            }
        }
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            self.progressView.alpha = 1.0
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            if webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.8, options: .curveEaseOut) {
                    self.progressView.alpha = 0
                } completion: { finish in
                    self.progressView.setProgress(0.0, animated: false)
                }
            }
        }
    }
    
}

extension YXStatementWebViewController: WKNavigationDelegate, WKUIDelegate{
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//        webView.load(<#T##data: Data##Data#>, mimeType: <#T##String#>, characterEncodingName: <#T##String#>, baseURL: <#T##URL#>)
        decisionHandler(.allow)
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
    }
}
