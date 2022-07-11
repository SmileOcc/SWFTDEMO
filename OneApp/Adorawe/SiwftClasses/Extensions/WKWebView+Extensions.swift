//
//  WKWebView+Extensions.swift
//  Adorawe
//
//  Created by fan wang on 2021/10/19.
//  Copyright © 2021 starlink. All rights reserved.
//

import Foundation

extension WKWebView{
    ///接收js数据
    static var eventToInject = """
function sendData(data){
    window.webkit.messageHandlers.commonEvent.postMessage(
        data
    );
}

window.WebViewJavascriptBridge = {
    callHandler:function(eventName,data,callback = null){
        sendData({
            'eventName':eventName,
            'data':data
        });
        if(callback != null){
            callback()
        }
    }
}

"""
    
    static var getContH = """
window.onload = ()=>{
  let bodyH = document.body.clientHeight
  window.webkit.messageHandlers.getWkWebViewHeight.postMessage(
              {bodyH:bodyH}
  );
}
"""
    
    
    @objc func injectEventHandler(){
        let userScript = WKUserScript(source: WKWebView.eventToInject, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: true)
        self.configuration.userContentController.addUserScript(userScript)
    }
    
    @objc func injectGetHeight(){
        let userScript = WKUserScript(source: WKWebView.getContH, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: true)
        self.configuration.userContentController.addUserScript(userScript)
    }

}
