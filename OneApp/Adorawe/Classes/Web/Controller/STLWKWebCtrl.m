//
//  STLWKWebCtrl.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/21.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLWKWebCtrl.h"
#import <WebKit/WebKit.h>
#import "OSSVConfigDomainsManager.h"
#import "Adorawe-Swift.h"

NSString *const ScriptMessageHandlerName = @"webViewApp";

@interface STLWKWebCtrl ()<WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@property (nonatomic,weak) WKWebView *webView;
@end

@implementation STLWKWebCtrl

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    if (STLIsEmptyString(self.url)) {
        [self initURL];        
    }
    [self loadURL:self.url];
    
    if (self.showClose) {
        UIButton *button = [[UIButton alloc] init];
        [button setImage:[UIImage imageNamed:@"privacy_close"] forState:UIControlStateNormal];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        
        [button addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)closeAction{
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:true];
    }else{
        [self dismissViewControllerAnimated:true completion:nil];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 注册 JS 方法
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:ScriptMessageHandlerName];
    
    if (self.showClose) {
        [UIApplication sharedApplication].keyWindow.backgroundColor = [UIColor blackColor];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (self.showClose) {
        [UIApplication sharedApplication].keyWindow.backgroundColor = [UIColor blackColor];
    }
   
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (self.showClose) {
        [UIApplication sharedApplication].keyWindow.backgroundColor = [UIColor whiteColor];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 记得移除 JS 方法
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:ScriptMessageHandlerName];
}

#pragma mark - Method
- (void)initURL {
    NSString *appH5Url = [[OSSVConfigDomainsManager sharedInstance] appH5Url];
    switch (self.urlType) {
        case SystemURLTypeDefault:
            //这里是作为默认跳转，url直接通过KVC赋值
            break;
        case SystemURLTypeAboutUs:
            self.url = [OSSVLocaslHosstManager appHelpUrl:HelpTypeAboutUs];
            break;
        case SystemURLTypeTermsOfUs:
            self.url = [OSSVLocaslHosstManager appHelpUrl:HelpTypeTermOfUsage];
            break;
        case SystemURLTypePrivacyPolicy:
            self.url = [OSSVLocaslHosstManager appHelpUrl:HelpTypePrivacyPolicy];
            break;
        default:
            break;
    }
}

#pragma mark  加载webView数据请求
-(void)loadURL:(NSString *)urlString{
    NSURL *webUrl = [NSURL URLWithString:urlString];

//    DomainType type = [OSSVConfigDomainsManager domainEnvironment];
//    if ([OSSVConfigDomainsManager isDistributionOnlineRelease] || type == DomainType_Release) {
//
//        NSString *domaniString = webUrl.host;
//        domaniString = [NSString stringWithFormat:@".%@",domaniString];
//        NSHTTPCookie *cookie = [[NSHTTPCookie alloc]initWithProperties:@{
//                                                                         NSHTTPCookieName:@"onesite",
//                                                                         NSHTTPCookieValue:@"true",
//                                                                         NSHTTPCookieDomain:STLToString(domaniString),
//                                                                         NSHTTPCookiePath:@"/",
//                                                                         }];
//        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:@[cookie] forURL:webUrl mainDocumentURL:nil];
//        NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:webUrl cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:60];
//        [request setValue:@"onesite=true;" forHTTPHeaderField:@"Cookie"];
//        [self.webView loadRequest:request];
//    } else {
        NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:webUrl cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:60];
        [request setValue:@"onesite=true;" forHTTPHeaderField:@"Cookie"];
        [self.webView loadRequest:request];
//    }
    
}

#pragma mark  Present cancel Methods
// 当Present的时候，返回
- (void)dismissAction:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MakeUI
- (void)initView {
    self.view.backgroundColor = [UIColor whiteColor];
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    webView.navigationDelegate = self;
    webView.UIDelegate = self;
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    webView.backgroundColor = [UIColor whiteColor];
    //隐藏滚动条
    webView.scrollView.showsVerticalScrollIndicator = NO;
    webView.scrollView.showsHorizontalScrollIndicator = NO;
    webView.allowsBackForwardNavigationGestures = true;
    //修改颜色
    //    webView.scrollView.indicatorStyle=UIScrollViewIndicatorStyleWhite;
    //加载数据为空时的代理
    webView.scrollView.emptyDataSetSource = self;
    webView.scrollView.emptyDataSetDelegate = self;
    [self.view addSubview:webView];
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
//        if (kIS_IPHONEX) {
//            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, STL_TABBAR_IPHONEX_H, 0));
//        } else {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
//        }
    }];
    self.webView = webView;
    
    if (self.isPresentVC) {
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:[OSSVSystemsConfigsUtils isRightToLeftShow] ? @"arrow_right_new" : @"arrow_left_new"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissAction:)];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            [self.navigationItem.leftBarButtonItem setImageInsets:UIEdgeInsetsMake(8, 10, 0, 0)];
        } else {
            [self.navigationItem.leftBarButtonItem setImageInsets:UIEdgeInsetsMake(8, -6, 0, 0)];
        }
    }
}

#pragma mark - WKScriptMessageHandlerDelegate
//实现js调用iOS的handle委托
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    //接受传过来的消息从而决定app调用的方法
    NSDictionary *dict = message.body;
    NSString *method = [dict objectForKey:@"method"];
    if ([method isEqualToString:@"hello"]) {
        [self hello:[dict objectForKey:@"param1"]];
    }else if ([method isEqualToString:@"Call JS"]){
        [self callJS];
    }else if ([method isEqualToString:@"Call JS Msg"]){
        [self callJSMsg:[dict objectForKey:@"param1"]];
    }
}

//直接调用js
//webView.evaluateJavaScript("hi()", completionHandler: nil)
//调用js带参数
//webView.evaluateJavaScript("hello('liuyanwei')", completionHandler: nil)
//调用js获取返回值
//webView.evaluateJavaScript("getName()") { (any,error) -> Void in
//    NSLog("%@", any as! String)
//}
- (void)hello:(NSString *)param{
    [self showAlert:param Title:@"js Call iOS"];
}

- (void)callJS{
    [self.webView evaluateJavaScript:@"iOSCallJSNO()" completionHandler:nil];
}

- (void)callJSMsg:(NSString *)msg{
    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"iOSCallJS('%@')",msg] completionHandler:nil];
}
#pragma mark - WKNavigationDelegate
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation { // 类似UIWebView的 -webViewDidStartLoad:
    NSLog(@"didStartProvisionalNavigation");
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"didCommitNavigation");
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation { // 类似 UIWebView 的 －webViewDidFinishLoad:
    NSLog(@"didFinishNavigation");
    //[self resetControl];
    if (!self.isNoNeedsWebTitile && webView.title.length > 0) {
        self.title = webView.title;
    }
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    // 类似 UIWebView 的- webView:didFailLoadWithError:
    NSLog(@"didFailProvisionalNavigation");
}


// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    
    decisionHandler(WKNavigationResponsePolicyAllow);
}

// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    // 类似 UIWebView 的 -webView: shouldStartLoadWithRequest: navigationType:
    NSLog(@"4.%@",navigationAction.request);
    //    NSString *url = [navigationAction.request.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //    NSString *url = navigationAction.request.URL.absoluteString;
    decisionHandler(WKNavigationActionPolicyAllow);
    
}

// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"didReceiveServerRedirectForProvisionalNavigation");
}


- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *internal))completionHandler {
    //    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling,internal);
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *card = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential,card);
    }
}

#pragma mark - WKUIDelegate
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    // 接口的作用是打开新窗口委托
    //[self createNewWebViewWithURL:webView.URL.absoluteString config:Web];
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    
    return nil;
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{    // js 里面的alert实现，如果不实现，网页的alert函数无效

    [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:0 title:@"" message:message buttonTitles:APP_TYPE == 3 ? @[STLLocalizedString_(@"ok", @"ok")] : @[STLLocalizedString_(@"ok", @"ok").uppercaseString] buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
        completionHandler();
    }];
    
}

//  js 里面的alert实现，如果不实现，网页的alert函数无效
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    NSArray *upperTitle = @[STLLocalizedString_(@"cancel",nil).uppercaseString,STLLocalizedString_(@"ok",nil).uppercaseString];
    NSArray *lowserTitle = @[STLLocalizedString_(@"cancel",nil),STLLocalizedString_(@"ok",nil)];
    [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:1 title:@"" message:message buttonTitles:APP_TYPE == 3 ? lowserTitle : upperTitle buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
        if (index == 1) {
            completionHandler(YES);
        } else {
            completionHandler(NO);
        }
    }];
    
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *))completionHandler {
    
    completionHandler(@"Client Not handler");
    
}

#pragma mark - Prviate Method
- (void)showAlert:(NSString *)content Title:(NSString *)title{
    STLAlertViewController *alertController = [STLAlertViewController alertControllerWithTitle:title
                                                                             message:content
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:APP_TYPE == 3 ? STLLocalizedString_(@"ok", nil) : STLLocalizedString_(@"ok", nil).uppercaseString
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          [self.navigationController popToRootViewControllerAnimated:YES];
                                                      }]];
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}

-(void)goBackAction{
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }else{
        [self closeAction];
    }
}
@end
