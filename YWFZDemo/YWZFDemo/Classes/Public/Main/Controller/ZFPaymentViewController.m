//
//  ZFPaymentViewController.m
//  ZZZZZ
//
//  Created by YW on 2018/9/19.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFPaymentViewController.h"
#import "WebViewJavascriptBridge.h"
#import <WebKit/WebKit.h>
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "YWLocalHostManager.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "ZFProgressHUD.h"
#import "ZFLocalizationString.h"
#import "ZFAnalytics.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "YSAlertView.h"
#import "Masonry.h"
#import "Constants.h"
#import <GGBrainKeeper/BrainKeeperManager.h>

#define TAG_ALERT_GOBACK    77777
#define TAG_BUTTON_ACTION   77778
#define TAG_CONTAINER       77779

@interface ZFPaymentViewController () <WKNavigationDelegate, WKUIDelegate>

@property (nonatomic,strong) WKWebView *webView;
@property (nonatomic,assign) PaymentStatus status;
@property (nonatomic,strong) UIProgressView *progressView;
@property (nonatomic, strong) WebViewJavascriptBridge *javaScriptBridge;
///测试计算加载时间容器
@property (nonatomic, strong) NSMutableDictionary *testLoadingTimeOperation;
@property (nonatomic, strong) BKSpanModel *rpcSpan;
@end

@implementation ZFPaymentViewController

- (void)dealloc {
    HideLoadingFromView(nil);
    [self.webView removeObserver:self forKeyPath:@"loading" context:nil];
    [self.webView removeObserver:self forKeyPath:@"title" context:nil];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress" context:nil];
    [[WKWebsiteDataStore defaultDataStore] fetchDataRecordsOfTypes:[NSSet setWithObject:WKWebsiteDataTypeCookies] completionHandler:^(NSArray<WKWebsiteDataRecord *> * _Nonnull list) {
        [list enumerateObjectsUsingBlock:^(WKWebsiteDataRecord * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.displayName isEqualToString:@"ZZZZZ.net"] || [obj.displayName isEqualToString:@"ZZZZZ.com"]) {
                ///只清除自己网站的cookie
                [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:[NSSet setWithObject:WKWebsiteDataTypeCookies] forDataRecords:@[obj] completionHandler:^{}];
            }
        }];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = ZFLocalizedString(@"OrderDetail_Delivery_Cell_Payment", nil);
    self.fd_interactivePopDisabled = YES;
    [self initViewWithFrame:self.view.bounds];
    ShowLoadingToView(nil);
}

- (void)rightSearchBtnClick:(UIButton *)sender
{
    [self.webView reload];
}

#pragma mark - UI
- (void)initViewWithFrame:(CGRect)frame {
    self.testLoadingTimeOperation = [NSMutableDictionary dictionary];

    [self loadRequest];
    //修改颜色
    [self.view addSubview:self.webView];
    [self.webView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.bottom.mas_equalTo(self.view);
    }];
    
    self.progressView = [[UIProgressView alloc] init];
    self.progressView.progressTintColor = ZFCOLOR(254, 105, 2, 1.0);
    [self.view addSubview:self.progressView];
    self.progressView.backgroundColor = [UIColor redColor];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self.view);
        make.height.mas_equalTo(@3);
    }];
    
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchButton setFrame:CGRectMake(0, 0, NavBarButtonSize, NavBarButtonSize)];
    [searchButton setImage:ZFImageWithName(@"paymentRefresh") forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(rightSearchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    searchButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 12.0, 0.0, -12.0);
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    self.navigationItem.rightBarButtonItems = @[searchItem];
    
    if (![YWLocalHostManager isOnlineRelease]){
        UILabel *lblname = [UILabel new];
        lblname.tag = 0;
        lblname.textColor = [UIColor redColor];
        lblname.font = [UIFont systemFontOfSize:14.0];
        lblname.text = @"用户名（点击复制）：sammydress123@qq.com";
        lblname.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
        tapGesture1.numberOfTapsRequired = 1;
        [lblname addGestureRecognizer:tapGesture1];
        
        [self.view addSubview:lblname];
        [lblname mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.view.mas_trailing).offset(-10);
            make.height.mas_equalTo(@20);
            make.top.mas_equalTo(self.view.mas_top).offset(10);
        }];
        
        UILabel *lblpass = [UILabel new];
        lblpass.tag = 1;
        lblpass.textColor = [UIColor redColor];
        lblpass.font = [UIFont systemFontOfSize:14.0];
        lblpass.text = @"密码（点击复制）：123456789";
        lblpass.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
        tapGesture2.numberOfTapsRequired = 1;
        [lblpass addGestureRecognizer:tapGesture2];
        
        [self.view addSubview:lblpass];
        [lblpass mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(lblname.mas_leading);
            make.height.mas_equalTo(@20);
            make.top.mas_equalTo(lblname.mas_bottom);
        }];
    }
    
    // 添加KVO监听
    [self.webView addObserver:self
                   forKeyPath:@"loading"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    [self.webView addObserver:self
                   forKeyPath:@"title"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    [self.webView addObserver:self
                   forKeyPath:@"estimatedProgress"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    
    // 注册H5与App之间相互调用的方法
    if ([YWLocalHostManager isPreRelease]){
        [self registerH5SeesawAppmethod];
    }
}

-(void)goBackAction
{
    // 获取 body 中的 page 判断是否是第一页
    NSString *js = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].getAttribute('page')"];
    //NSString *page = [self.webView stringByEvaluatingJavaScriptFromString:js];
    [self.webView evaluateJavaScript:js completionHandler:^(NSString *page, NSError * _Nullable error) {
        // page == 0 表示是第一页，其他页不是
        if ([page isKindOfClass:[NSNull class]]) {
            if (self.webView.canGoBack) {
                [self.webView goBack];
            }else{
                [self close];
            }
        }else{
            if ([page boolValue] > 0) {
                [self.webView evaluateJavaScript:[NSString stringWithFormat:@"hideform()"] completionHandler:^(id _Nullable l, NSError * _Nullable error) {
                    YWLog(@"%@",error);
                }];
            }else{
                [self close];
            }
        }
    }];
}


#pragma mark -===========注册javaScript与原生App交互方法===========

/**
 * 注册H5与App之间相互调用的方法
 */
- (void)registerH5SeesawAppmethod
{
    //[WebViewJavascriptBridge enableLogging];
    self.javaScriptBridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    [self.javaScriptBridge setWebViewDelegate:self];
    
    //注册js调用App原生方法: H5调用App原生方法获取App是否为预发布
    [self.javaScriptBridge registerHandler:@"fetchReleaseStatus" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSNumber *status = [NSNumber numberWithInt:0];
        if ([YWLocalHostManager isPreRelease]){
            status = [NSNumber numberWithInt:1];
        }
        responseCallback(status);
    }];
}


/**
 双击复制用户名和密码
 
 @param label 双击的label
 */
-(void)tapClick:(UIGestureRecognizer *)sender {
    UILabel *label = (UILabel *)sender.view;
    if (label.tag == 0) {
        [UIPasteboard generalPasteboard].string = @"sammydress123@qq.com";
    } else if (label.tag == 1) {
        [UIPasteboard generalPasteboard].string = @"123456789";
    }
    
    ShowToastToViewWithText(nil, [NSString stringWithFormat:@"%@复制成功",[UIPasteboard generalPasteboard].string]);
}

- (void)close {
    self.status = PaymentStatusCancel;
    [self dismiss];
}

- (void)dismiss {
    if (self.status == PaymentStatusCancel || self.status == PaymentStatusUnknown) {
        NSString *message = ZFLocalizedString(@"SOAPayMentCancelContent", nil);
        NSArray *btnArr = @[ZFLocalizedString(@"Account_VC_SignOut_Alert_No",nil)];
        NSString *cancelTitle = ZFLocalizedString(@"Account_VC_SignOut_Alert_Yes",nil);
        @weakify(self)
        ShowAlertView(nil, message, btnArr, nil, cancelTitle, ^(id cancelTitle){
            @strongify(self)
            if (self.block) {
                self.block(self.status);
            }
 
            if (self.progressView && self.webView.estimatedProgress != 1) {
                NSString *label = [NSString stringWithFormat:@"email:%@,url:%@,progress:%f",[AccountManager sharedManager].account.email, self.webView.URL.absoluteString, self.webView.estimatedProgress];
                [ZFAnalytics clickButtonV380WithCategory:@"SOAPay" actionName:@"Progress" label:label];
            }
        });
    }else{
        if (self.block) {
            self.block(self.status);
        }
    }
}

- (void)loadRequest
{
    if (!self.url) {
        //如果没有传入url，就初始化一个空的webview
        self.webView = [[WKWebView alloc] init];
        self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.webView.backgroundColor = [UIColor whiteColor];
        self.webView.navigationDelegate = self;
        self.webView.UIDelegate = self;
        return;
    }
//    _url = @"https://www.baidu.com";
//    _url = @"https://cashier.rosegal.com/?token=O180926007191013306210&lang=fr&from=app";
    NSString *containUserTokenUrl = [NSString stringWithFormat:@"%@",_url];
    NSURL *webUrl = [NSURL URLWithString:containUserTokenUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:webUrl];
    
    WKWebViewConfiguration *webViewConfig = [[WKWebViewConfiguration alloc] init];
    if ([YWLocalHostManager isPreRelease]) {
        NSMutableString *script = [[NSMutableString alloc] init];
        NSMutableString *cookieString = [[NSMutableString alloc] init];

        [script appendString:[NSString stringWithFormat:@"document.cookie='%@';",@"staging=true"]];
        [cookieString appendString:@"staging=true"];
        [request setValue:cookieString forHTTPHeaderField:@"Cookie"];

        WKUserContentController *userContentController = [[WKUserContentController alloc] init];
        WKUserScript *cookieInScript = [[WKUserScript alloc] initWithSource:script
                                                              injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                                           forMainFrameOnly:NO];
        [userContentController addUserScript:cookieInScript];

        webViewConfig.userContentController = userContentController;
    }
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:webViewConfig];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;

    //隐藏滚动条
    self.webView.scrollView.showsVerticalScrollIndicator = NO;
    self.webView.scrollView.showsHorizontalScrollIndicator = NO;
    [self.webView loadRequest:request];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"loading"]) {
        YWLog(@"loading");
    } else if ([keyPath isEqualToString:@"title"]) {
        
    } else if ([keyPath isEqualToString:@"estimatedProgress"]) {
        YWLog(@"progress: %f", self.webView.estimatedProgress);
        self.progressView.progress = self.webView.estimatedProgress;
    }
    
    // 加载完成
    if (!self.webView.loading || self.webView.estimatedProgress == 1.0) {
        [UIView animateWithDuration:0.5 animations:^{
            self.progressView.alpha = 0;
            self.progressView.progress = 0;
        }];
        HideLoadingFromView(nil);
    }else{
        self.progressView.alpha = 1;
    }
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView evaluateJavaScript:@"var a = document.getElementsByTagName('a');for(var i=0;i<a.length;i++){a[i].setAttribute('target','');}" completionHandler:nil];
    }
    //如果是跳转一个新页面
    if (navigationAction.targetFrame == nil) {
        [webView loadRequest:navigationAction.request];
    }
//    NSDictionary *headerFields = navigationAction.request.allHTTPHeaderFields;
//    NSString *cookie = headerFields[@"Cookie"];
//    YWLog(@"headerFields cookie - %@", cookie);
//    YWLog(@"headerFields - %@", headerFields);
//
//    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:navigationAction.request.URL];
//    YWLog(@"cookies - %@", cookies);

    WKNavigationActionPolicy actionPolicy = WKNavigationActionPolicyAllow;
    NSURL *url = navigationAction.request.URL;
    NSString *strUrl = url.absoluteString.lowercaseString;
    YWLog(@"#####:%@", strUrl);
    self.status = PaymentStatusUnknown;
    
    // 统计代码
    if ([strUrl isEqualToString:self.url.lowercaseString]) {
        // 链路代码
        self.rpcSpan = [[BrainKeeperManager sharedManager] startNetWithPageName:nil event:nil target:self url:self.url parentId:nil isNew:NO isChained:NO];
    }
    
    //拦截后台HUD显示链接
    if ([strUrl containsString:@"cashier_app_api/dismissloading"]) {
        HideLoadingFromView(nil);
    }else if([strUrl containsString:@"cashier_app_api/showloading"]){
        ShowLoadingToView(nil);
    }

    //设置打点时间
    NSString *timer = [NSStringUtils getCurrentMSimestamp];
    [self.testLoadingTimeOperation setObject:timer forKey:strUrl];
    
    ////soa_pay/result/?status=1&msg=   备注：status=1表示成功，status=2表示失败,status=3表示取消
    if ([strUrl containsString:@"/soa_pay/result/?status=1"]) {
        ///SOA 支付成功
        actionPolicy = WKNavigationActionPolicyCancel;
        self.status = PaymentStatusDone;
        [self dismiss];
    }else if ([strUrl containsString:@"/soa_pay/result/?status=2"]){
        ///SOA 失败
        actionPolicy = WKNavigationActionPolicyCancel;
        self.status = PaymentStatusFail;
        [self dismiss];
    }else if ([strUrl containsString:@"/soa_pay/result/?status=3"]){
        ///SOA 取消
        actionPolicy = WKNavigationActionPolicyCancel;
        self.status = PaymentStatusCancel;
        [self dismiss];
    }
    
    //快捷支付拦截器
    if ([strUrl containsString:QUICK_FILTER_CATCH_URL]) {
        NSURLComponents *components = [[NSURLComponents alloc] initWithString:strUrl];
        __block NSString *token = @"",*payid = @"";
        [components.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem *_Nonnull obj,
                                                            NSUInteger idx, BOOL *_Nonnull stop) {
            if([obj.name isEqualToString:@"token"]) {
                token = obj.value;
            } else if([obj.name isEqualToString:@"payerid"]) {
                payid = obj.value;
            }
        }];
        if (self.fastCallBackHandler) {
            self.fastCallBackHandler(token,payid);
        }
        actionPolicy = WKNavigationActionPolicyCancel;
    }else if ([strUrl containsString:QUICK_FILTER_CANCEL_URL]) {
        // 用户点击了取消
        actionPolicy = WKNavigationActionPolicyCancel;
        self.status = PaymentStatusCancel;
        [self dismiss];
    }
    
    decisionHandler(actionPolicy);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    if ([navigationResponse.response isKindOfClass:[NSHTTPURLResponse class]]) {
        
        NSHTTPURLResponse * response = (NSHTTPURLResponse *)navigationResponse.response;
        if (response.statusCode != 200) {
        }
    }
    
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if (!webView.isLoading) {
        if (self.loadBlock) {
            self.loadBlock();
        }
    }
    HideLoadingFromView(nil);
    NSURL *url = self.webView.URL;
    NSString *strUrl = url.absoluteString.lowercaseString;
    if ([strUrl isEqualToString:self.url.lowercaseString]) {
        // 链路代码  网页加载不需要传render
        if (self.rpcSpan) {
            [self.rpcSpan end];
            [[BrainKeeperManager sharedManager] subTrackWithPageName:nil event:nil target:self];
        }
    }
    double currentTime = [NSStringUtils getCurrentMSimestamp].doubleValue;
    double lastTime = [[self.testLoadingTimeOperation objectForKey:strUrl] doubleValue];
    YWLog(@"加载URL - %@ 消耗时间(ms):%f", strUrl, (currentTime - lastTime));
    [ZFAnalytics logSpeedWithCategory:@"PayTime" eventName:@"SOA" interval:(currentTime - lastTime) label:[NSString stringWithFormat:@"url:%@", strUrl]];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    // 统计代码
    NSString *tmpUrl = webView.URL.absoluteString.lowercaseString;
    if ([tmpUrl isEqualToString:self.url.lowercaseString]) {
        // 链路代码  网页加载不需要传render
        if (self.rpcSpan) {
            [self.rpcSpan endWithError:error.localizedDescription statusCode:@""];
            [[BrainKeeperManager sharedManager] subTrackWithPageName:nil event:nil target:self];
        }
    }
    HideLoadingFromView(nil);
}

#pragma mark - WKUIDelegate
//1.创建一个新的WebVeiw
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    WKFrameInfo *frameInfo = navigationAction.targetFrame;
    if (![frameInfo isMainFrame]) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}


@end
