//
//  ZFWebViewViewController.h
//  ZZZZZ
//
//  Created by YW on 16/8/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBaseViewController.h"
#import <WebKit/WebKit.h>


typedef void(^walletChangePasswordBlock)(void);

@interface ZFWebViewViewController : ZFBaseViewController

/**
 * 链接地址
 */
@property (nonatomic, copy) NSString   *link_url;

@property (nonatomic, strong, readonly) WKWebView *webView;

/// 禁止监听H5的标题 (默认为: NO)
@property (nonatomic, assign) BOOL forbidObserverTitle;

///电子钱包修改密码回调
@property (nonatomic, copy) walletChangePasswordBlock walletChangePasswordBlock;


/// 如果是本地文件URL, (⚠️警告⚠️:只会在非生产环境生效)
@property (nonatomic, copy) NSString *loadHtmlString;

/**
 子类拦截WebView 加载事件
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;

@end
