//
//  ZFWebViewViewController.m
//  ZZZZZ
//
//  Created by YW on 16/8/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFWebViewViewController.h"
#import "JumpModel.h"
#import "JumpManager.h"
#import "ZFShareView.h"
#import "ZFShareTopView.h"
#import "NativeShareModel.h"
#import "ZFShareManager.h"
#import "ZFFrameDefiner.h"
#import "WebViewJavascriptBridge.h"
#import "UIImage+ZFExtended.h"
#import "ZFShareTopView.h"
#import "ZFCommunityShowPostViewController.h"
#import "ZFCommunityPostDetailPageVC.h"

#import "ZFCommunityPostResultModel.h"
#import "ZFKeychainDataManager.h"
#import "YWLocalHostManager.h"
#import "ZFThemeManager.h"
#import "ZFNavigationController.h"
#import <AppsFlyerLib/AppsFlyerTracker.h>
#import "NSStringUtils.h"
#import "ZFProgressHUD.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "NSDictionary+SafeAccess.h"
#import "ZFAnalytics.h"
#import "ExchangeManager.h"
#import "AccountManager.h"
#import "BannerManager.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "YSAlertView.h"
#import "ZFNetworkManager.h"
#import "Masonry.h"
#import "Configuration.h"
#import "YWLoginViewController.h"
#import "AppDelegate+ZFNotification.h"
#import <GGAppsflyerAnalyticsSDK/GGAppsflyerAnalytics.h>
#import <GGBrainKeeper/BrainKeeperManager.h>
#import <GGPaySDK/GGPaySDK.h>
#import "PYAssetModel.h"

@interface ZFWebViewViewController () <WKNavigationDelegate,WKUIDelegate,ZFShareViewDelegate>
@property (nonatomic, strong, readwrite) WKWebView        *webView;
@property (nonatomic, strong) UIActivityIndicatorView     *loadingActivityView;
@property (nonatomic, strong) UIProgressView              *progressView;
@property (nonatomic, strong) NSMutableDictionary         *params;
@property (nonatomic, strong) WebViewJavascriptBridge     *javaScriptBridge;
@property (nonatomic, assign) BOOL                        hasLoadingFinish;
@property (nonatomic, strong) NSString                    *linkUrl_beginTimer;
@property (nonatomic, strong) BKSpanModel                 *rpcSpan;
@end

@implementation ZFWebViewViewController

#pragma mark -===========生命周期方法===========
- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    if (!self.forbidObserverTitle) {
        [self.webView removeObserver:self forKeyPath:@"title"];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.webView.navigationDelegate = nil;
    self.webView.UIDelegate = nil;
    [self.webView stopLoading];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // url解码
    if (!ZFIsEmptyString(self.link_url)) {
        //去除首尾空格
        self.link_url = [self.link_url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        NSString *decodeValue = [self.link_url stringByRemovingPercentEncoding];
        if (!ZFIsEmptyString(decodeValue)) {
            self.link_url = decodeValue;
        }
    }
    
    // 请清除Cookie
    [[AccountManager sharedManager] clearWebCookie];
    
    // 初始化WKWebview
    [self configureWebView];
    
    // 注册H5与App之间相互调用的方法
    [self registerH5SeesawAppmethod];
    
    // 分享成功通知
    [self addNotification];
    
    // 兼容页面异常情况
    [self setupWebViewExceptionCase];
    
    [self showLoadingActivity:YES];
}

- (UIActivityIndicatorView *)loadingActivityView {
    if (!_loadingActivityView) {
        _loadingActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
        _loadingActivityView.color = ZFC0x2D2D2D();
        [_loadingActivityView hidesWhenStopped];
        CGFloat centerY = (KScreenHeight - (NAVBARHEIGHT + STATUSHEIGHT) ) / 2;
        _loadingActivityView.center = CGPointMake(KScreenWidth/2, centerY);
        [self.view addSubview:_loadingActivityView];
    }
    [self.view bringSubviewToFront:_loadingActivityView];
    return _loadingActivityView;
}

- (void)showLoadingActivity:(BOOL)show {
    if (show) {
        [self.loadingActivityView startAnimating];
    } else {
        [self.loadingActivityView stopAnimating];
    }
}

/**
 * 兼容页面异常情况
 */
- (void)setupWebViewExceptionCase {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if ([AFNetworkReachabilityManager sharedManager].reachable) {
            //进入页面指定先加载一个假的进度条防止页面长时间假死
//            if (self.progressView.progress < 0.1) {
//                [self.progressView setProgress:0.1 animated:YES];
//            }
        } else { // 添加无网络空白页
            [self addBlankPageFailView];
        }
    });
}

/**
 * 添加无网络空白页
 */
- (void)addBlankPageFailView {
    @weakify(self)
    self.webView.scrollView.requestFailBtnTitle = ZFLocalizedString(@"EmptyCustomViewManager_refreshButton",nil);
    self.webView.scrollView.blankPageViewActionBlcok = ^(ZFBlankPageViewStatus status){
        @strongify(self)
        
        if ([AFNetworkReachabilityManager sharedManager].reachable) {
            // 重新加载当前页面
            [self addWebCookieAndRequestUrl:self.link_url];
        } else {
            // 点击空白页面执行block时已经移除空白页,因此无网络时需要再次添加空白页
            [self.webView.scrollView showRequestTip:nil];
        }
    };
    [self.webView.scrollView showRequestTip:nil];
}

#pragma mark -===========通知相关===========

/**
 * 分享成功通知
 */
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareCompleteAction:) name:ZFShareCompleteNotification object:nil];
    //H5人脸引导发帖成功需要提示页面通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(faceRecognitionPostSuccessNotify:) name:kCommunityPostSuccessNotification object:nil];
    //监听UIWindow隐藏
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(endFullScreen) name:UIWindowDidBecomeHiddenNotification object:nil];
}

/**
 * 在部分机器上发现全屏播放完视频后会出现状态栏显示的bug
 */
- (void)endFullScreen {
    showSystemStatusBar();
}

/**
 * 分享完成后,SDK回调方法中发出来的通知
 */
- (void)shareCompleteAction:(NSNotification *)notify {
    NSDictionary *infoDic = [notify object];
    YWLog(@"notify===%@",infoDic);
    if (!infoDic) return;
    
    ZFShareType shareType = [ZFGetStringFromDict(infoDic, ZFShareTypeKey) integerValue];
    NSString *type = [ZFShareManager fetchShareTypePlatform:shareType];
    
    BOOL shareSuccess = [ZFGetStringFromDict(infoDic, ZFShareStatusKey) boolValue];
    NSString *status = shareSuccess ? @"1" : @"0";
    
    NSString *functionName = NullFilter(_params[@"callback"]);
    if ([functionName hasSuffix:@"()"]) {
        functionName = [functionName substringToIndex:(functionName.length-2)];
    }
    if (functionName.length==0) return;
    NSString  *jsFunction = [NSString stringWithFormat:@"%@('%@','%@')", functionName, status, type];
    [self.webView evaluateJavaScript:jsFunction completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        YWLog(@"分享完成后回传分享状态给H5=====%@",response);
    }];
}

#pragma mark -===========初始化WKWebView视图===========

- (void)configureWebView {
    [self configWebViewUserAgent];
    [self initWKWebView];
    [self initProgressView];
    [self observerKeypath];
}

- (void)goBackAction {
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)initWKWebView {
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.scrollView.showsVerticalScrollIndicator = NO;
    self.webView.scrollView.showsHorizontalScrollIndicator = NO;
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    [self.view addSubview:self.webView];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view).insets(UIEdgeInsetsZero);
    }];
    
    //加载文本页面
    [self addWebCookieAndRequestUrl:self.link_url];
}

#pragma mark -===========监听Web加载进度条===========

- (void)initProgressView {
//    CGFloat kScreenWidth = [[UIScreen mainScreen] bounds].size.width;
//    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 2)];
//    self.progressView.progressTintColor = ZFC0xFE5269();
//    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
//    [self.view addSubview:self.progressView];
}

- (void)observerKeypath {
//    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    if (!self.forbidObserverTitle) {
        [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    if (object == self.webView && [keyPath isEqualToString:@"estimatedProgress"]) {
//        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
//        if (newprogress == 1) {
//            [self.progressView setProgress:1.0 animated:YES];
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                self.progressView.hidden = YES;
//                [self.progressView setProgress:0 animated:NO];
//            });
//        }else {
//            self.progressView.hidden = NO;
//            [self.progressView setProgress:newprogress animated:YES];
//        }
//    } else

    if ([keyPath isEqualToString:@"title"]) {
        self.title = self.webView.title;
    }
}

#pragma mark -===========添加WebView Cookie===========

/**
 * 加载文本页面
 */
- (void)addWebCookieAndRequestUrl:(NSString *)loadUrl {
    /// ⚠️警告⚠️:仅供测试环境使用
    if (![YWLocalHostManager isDistributionOnlineRelease]
        && ZFIsEmptyString(self.link_url) && !ZFIsEmptyString(self.loadHtmlString)) {
        [self.webView loadHTMLString:self.loadHtmlString baseURL:nil];
        return;
    }
    
    if (ZFIsEmptyString(loadUrl)) return;
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:loadUrl] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:60];
    [self addWebHTTPCookie:loadUrl request:request];
    [self.webView loadRequest:request];
    YWLog(@"===== 加载文本页面完成 =====");
    
    //H5页面加载量事件
    [ZFAnalytics appsFlyerTrackEvent:@"af_webview_load" withValues:@{
        @"af_content_type" : @"H5",
        @"af_load_url" : ZFToString(loadUrl)
    }];
}

/**
 *  两种方式添加WebCookie
 */
- (void)addWebHTTPCookie:(NSString *)loadUrl request:(NSMutableURLRequest *)request{
    if (ZFIsEmptyString(loadUrl)) return;

    // 一、操作Cookie
    if ([YWLocalHostManager isPreRelease]) {
        [request addValue:@"staging=true;" forHTTPHeaderField:@"Cookie"];
    } else {
        [request addValue:@"" forHTTPHeaderField:@"Cookie"];
    }
    
    NSMutableDictionary *cookiesDic = [NSMutableDictionary dictionary];
    cookiesDic[NSHTTPCookieDomain] = @".ZZZZZ.com";
    cookiesDic[NSHTTPCookiePath] = @"/";
    cookiesDic[NSHTTPCookieName] = @"staging";
    cookiesDic[NSHTTPCookieValue] = @"true";
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:cookiesDic];

    // 二、操作Cookie
    if (@available(iOS 11.0, *)) {
        if ([YWLocalHostManager isPreRelease]) {
            [[WKWebsiteDataStore defaultDataStore].httpCookieStore setCookie:cookie completionHandler:^{
                YWLog(@"iOS 11.0以上添加Cookie成功===%@", cookie);
            }];
        } else {
            [[WKWebsiteDataStore defaultDataStore].httpCookieStore deleteCookie:cookie completionHandler:^{
                YWLog(@"iOS 11.0以上删除Cookie成功===%@", cookie);
            }];
        }
    } else {
        if ([YWLocalHostManager isPreRelease]) {
            if (cookie && [loadUrl hasPrefix:@"http"]) { // 警告: 添加Cookie时的url一定只能以http开头
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:@[cookie] forURL:[NSURL URLWithString:loadUrl] mainDocumentURL:nil];
                YWLog(@"iOS 11.0以下添加Cookie成功===%@", cookie);
            }
        } else {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            YWLog(@"iOS 11.0以下删除Cookie成功===%@", cookie);
        }
    }
}

/** 通过修改全局UserAgent值来设置预发布
 *  这里是在原有基础上拼接自定义的字符串
 *  平台_设备ID_版本号_当前货币_语言_预发布参数
 */
- (void)configWebViewUserAgent {
    NSString *platform = @"ios";
    NSString *device_id = [AccountManager sharedManager].device_id;
    NSString *version = ZFToString(GetUserDefault(APPVIERSION));
    NSString *currency = [ExchangeManager localCurrencyName];
    NSString *language = [ZFLocalizationString shareLocalizable].nomarLocalizable;
    NSString *staging = [YWLocalHostManager isPreRelease] ? @"true" : @"false";
    NSString *countryCode =  ZFToString(GetUserDefault(kLocationInfoCountryCode));
    NSString *pepiLine = ZFToString(GetUserDefault(kLocationInfoPipeline));
    NSString *appsflyerid = ZFToString([[AppsFlyerTracker sharedTracker] getAppsFlyerUID]);
    NSString *glogrow_id = [GGAppsflyerAnalytics getAppsflyerDeviceId];  // 大数据统计id
    
    UIWebView *uiWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    NSString *defaultUserAgent = ZFToString([uiWebView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"]);
    NSString *customUserAgent = [NSString stringWithFormat:@"[ZZZZZ]platform=%@&device_id=%@&version=%@&currency=%@&language=%@&staging=%@&country_code=%@&pipeline=%@&appsflyer_device_id=%@&glogrow_id=%@",platform, device_id, version, currency, language, staging, countryCode, pepiLine, appsflyerid, glogrow_id];
    
    if (![defaultUserAgent containsString:customUserAgent]) {
        NSString *newUserAgent = [defaultUserAgent stringByAppendingString:customUserAgent];
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent": newUserAgent}];
    }
}

#pragma mark -===========保存请求Url参数===========
/**
 * 保存跳转参数
 */
- (void)parseURLParams:(NSURL *)url {
    if (![url.scheme isEqualToString:kZZZZZScheme] && ![url.scheme isEqualToString:@"webaction"]) {
        return;
    }
    [self.params removeAllObjects];
    self.params = [BannerManager parseDeeplinkParamDicWithURL:url];
}

#pragma mark -===========处理Url事件跳转===========

/**
 * 跳转deeplink
 */
- (void)deeplinkHandle {
    [BannerManager jumpDeeplinkTarget:self deeplinkParam:_params];
}

/**
 * 判断登录
 */
- (void)jsLoginHandle {
    if ([NullFilter(_params[@"isAlert"]) isEqualToString:@"1"]) {
        if ([[AccountManager sharedManager] isSignIn]) {
            [self postLoginInfoToH5];
        } else {
            YWLoginViewController *loginVC = [[YWLoginViewController alloc] init];
            loginVC.deepLinkSource = _params[@"source"];
            @weakify(self)
            [loginVC setSuccessBlock:^{
                @strongify(self)
                [self postLoginInfoToH5];
            }];
            [loginVC setCancelSignBlock:^{
                @strongify(self)
                [self postLoginInfoToH5];
            }];
            ZFNavigationController *nav = [[ZFNavigationController alloc] initWithRootViewController:loginVC];
            [self presentViewController:nav animated:YES completion:nil];
        }
    } else if ([NullFilter(_params[@"isAlert"]) isEqualToString:@"0"]) {
        [self postLoginInfoToH5];
    }
}

/**
 * 把用户登录信息传给前端  1 弹出  0 不弹
 * webAction://login?callback=appUserInfo()&isAlert=1
 */
- (void)postLoginInfoToH5 {
    if (ZFGetStringFromDict(_params, @"callback").length>0) {
        NSString *functionName;
        NSRange range = [NullFilter(_params[@"callback"]) rangeOfString:@"()" options:NSBackwardsSearch];
        if (range.location != NSNotFound) {
            functionName = [NullFilter(_params[@"callback"]) substringToIndex:range.location];
        }
        NSString *jsFunction = [NSString stringWithFormat:@"%@('%@','%@','%@')", functionName, USERID,TOKEN,NullFilter(_params[@"redirect"])];
        YWLog(@"把用户登录信息传给前端===%@", jsFunction);
        [self.webView evaluateJavaScript:jsFunction completionHandler:^(id _Nullable response, NSError * _Nullable error) {
            
        }];
    }
}

/**
 * 给前端传递当前货币符号
 * webaction://currency?callback=getIosCurrencyInfo()
 */
- (void)postCurrencyToH5 {
    NSString *functionName;
    NSRange range = [NullFilter(_params[@"callback"]) rangeOfString:@"()" options:NSBackwardsSearch];
    if (range.location != NSNotFound) {
        functionName = [NullFilter(_params[@"callback"]) substringToIndex:range.location];
    }
    NSString *jsFunction = [NSString stringWithFormat:@"%@('%@')", functionName, [ExchangeManager localCurrencyName]];
    [self.webView evaluateJavaScript:jsFunction completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        
    }];
}

/**
 * webAction://sharing?shareType=facebook&shareUrl=&shareTitle=&imageUrl=
 */
- (void)callNativeShareFunction {
    ZFShareTopView *shareTopView = [[ZFShareTopView alloc] init];
    [shareTopView updateImage:[_params[@"imageUrl"] stringByRemovingPercentEncoding]
                        title:[_params[@"shareTitle"] stringByRemovingPercentEncoding]
                      tipType:ZFShareDefaultTipTypeCommon];
    
    [ZFShareManager authenticatePinterest];
    
    ZFShareView *shareView = [[ZFShareView alloc] init];
    shareView.topView = shareTopView;
    shareView.delegate = self;
    [shareView open];
}

/**
 * 弹出原生分享视图
 */
- (void)zfShsreView:(ZFShareView *)shareView didSelectItemAtIndex:(NSUInteger)index {
    NativeShareModel *model = [[NativeShareModel alloc] init];
    model.share_url = [[_params ds_stringForKey:@"shareUrl"] stringByRemovingPercentEncoding];
    model.share_imageURL = shareView.topView.imageName;
    model.share_description = shareView.topView.title;
    model.sharePageType = ZFSharePage_H5_ShareType;
    [ZFShareManager shareManager].model = model;
    [ZFShareManager shareManager].currentShareType = index;
    
    switch (index) {
        case ZFShareTypeWhatsApp: {
            [[ZFShareManager shareManager] shareToWhatsApp];
        }
            break;
        case ZFShareTypeFacebook: {
            [[ZFShareManager shareManager] shareToFacebook];
        }
            break;
        case ZFShareTypeMessenger: {
            [[ZFShareManager shareManager] shareToMessenger];
        }
            break;
        case ZFShareTypePinterest: {
            [[ZFShareManager shareManager] shareToPinterest];
        }
            break;
        case ZFShareTypeCopy: {
            [[ZFShareManager shareManager] copyLinkURL];
        }
            break;
        case ZFShareTypeMore: {
            [[ZFShareManager shareManager] shareToMore];
        }
            break;
        case ZFShareTypeVKontakte: {
            [[ZFShareManager shareManager] shareVKontakte];
        }
            break;
    }
}

/**
 * web中直接拉起Messenger分享,不弹分享抽奖框
 */
- (void)shareToMessenger:(NSString *)url
{
    YWLog(@"直接拉起messenger分享");
    if (url.length==0) return;
    NSString *shareUrl = nil;
    
    NSArray *shareLinkeArr = [url componentsSeparatedByString:@"link="];
    if (shareLinkeArr.count == 2) {
        shareUrl = [shareLinkeArr lastObject];
    }
    
    if (!shareUrl || shareUrl.length == 0) return;
    NSString *shareContentUrl = [shareUrl stringByRemovingPercentEncoding];
    NSString *shareTitle = _params[@"shareTitle"];
    NSString *shareDesc = shareTitle ? [shareTitle stringByRemovingPercentEncoding] : shareContentUrl;
    
    NativeShareModel *model = [[NativeShareModel alloc] init];
    model.share_url = shareContentUrl;
    model.share_description = shareDesc;
    model.sharePageType = ZFSharePage_H5_ShareType;
    [ZFShareManager shareManager].model = model;
    [ZFShareManager shareManager].currentShareType = ZFShareTypeMessenger;
    [[ZFShareManager shareManager] shareToMessenger];
}

#pragma mark -===========WKWebView代理WKNavigationDelegate===========

/// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    self.hasLoadingFinish = YES;
    
    // 统计代码
    NSString *tmpUrl = webView.URL.absoluteString.lowercaseString;
    if ([tmpUrl isEqualToString:self.link_url.lowercaseString]) {
        // 链路代码  网页加载不需要传render
        if (self.rpcSpan) {
            [self.rpcSpan end];
            [[BrainKeeperManager sharedManager] subTrackWithPageName:nil event:nil target:self];
        }
        double currentTime = [NSStringUtils getCurrentMSimestamp].doubleValue;
        double lastTime = [self.linkUrl_beginTimer doubleValue];
        YWLog(@"加载URL - %@ 消耗时间(ms):%f", tmpUrl, (currentTime - lastTime));
        NSString *title = webView.title ? : self.title;
        [ZFAnalytics logSpeedWithCategory:@"PayTime" eventName:ZFToString(title) interval:(currentTime - lastTime) label:[NSString stringWithFormat:@"url:%@", tmpUrl]];
    }
    [self showLoadingActivity:NO];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    YWLog(@"didFailProvisionalNavigation");
    [self showLoadingActivity:NO];
    
    // 统计代码
    NSString *tmpUrl = webView.URL.absoluteString.lowercaseString;
    if ([tmpUrl isEqualToString:self.link_url.lowercaseString]) {
        // 链路代码  网页加载不需要传render
        if (self.rpcSpan) {
            [self.rpcSpan endWithError:error.localizedDescription statusCode:@""];
            [[BrainKeeperManager sharedManager] subTrackWithPageName:nil event:nil target:self];
        }
    }
    
    if (error && !self.hasLoadingFinish) {
        [self addBlankPageFailView];
        [webView.scrollView showRequestTip:nil];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    // 防止加载失败一直显示空白页面
    [webView.scrollView removeOldTipBgView];
    
    if (!navigationAction.targetFrame.isMainFrame) { //规避链接新打开窗口
        [webView evaluateJavaScript:@"var a = document.getElementsByTagName('a');for(var i=0;i<a.length;i++){a[i].setAttribute('target','');}" completionHandler:nil];
    }
    if (navigationAction.targetFrame == nil) {
        [webView loadRequest:navigationAction.request];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    NSURL *url = navigationAction.request.URL;
    NSString *scheme = [url scheme];
    [self parseURLParams:url];
    YWLog(@"\n=========================== 链接地址 ======================\n👉URL👈: %@", url);
    
    // 统计代码
    if ([url.absoluteString.lowercaseString isEqualToString:self.link_url.lowercaseString]) {
        self.linkUrl_beginTimer = [NSStringUtils getCurrentMSimestamp];
        // 链路代码
        self.rpcSpan = [[BrainKeeperManager sharedManager] startNetWithPageName:nil event:nil target:self url:self.link_url parentId:nil isNew:NO isChained:NO];
    }

    //清除WebView的缓存
    if ([url.absoluteString containsString:@"is_clear"]) {
        
        NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            YWLog(@"清除WebView的缓存 成功1");
        }];
        
        WKWebsiteDataStore *dateStore = [WKWebsiteDataStore defaultDataStore];
        [dateStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes]
                         completionHandler:^(NSArray<WKWebsiteDataRecord *> * __nonnull records) {
                             for (WKWebsiteDataRecord *record in records) {
                                 //可以针对某域名清除，否则是全清
                                 //if ([record.displayName containsString:@"baidu"]) {
                                 [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:record.dataTypes forDataRecords:@[record] completionHandler:^{
                                     YWLog(@"清除WebView的缓存 %@",record.displayName);
                                 }];
                             }
                         }];
    }
    
    //清除WebView浏览过的历史y压栈的url
    if ([url.absoluteString containsString:@"clear_history"]) {
        
        WKBackForwardList *backForwardList = webView.backForwardList;
        SEL cleanSel = NSSelectorFromString(@"_removeAllItems");
        if (backForwardList && [backForwardList respondsToSelector:cleanSel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [backForwardList performSelector:cleanSel];
#pragma clang diagnostic pop
        }
    }
    
    if ([scheme isEqualToString:kZZZZZScheme]) {
        [self deeplinkHandle];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
        
    } else if ([scheme isEqualToString:@"webaction"]) {
        
        if ([url.host isEqualToString:@"currency"]) {
            [self postCurrencyToH5];
            
        } else if ([url.host isEqualToString:@"login"]){
            [self jsLoginHandle];
            
        } else if ([url.host isEqualToString:@"popBack"]){
            [self goBackAction];
            
        } else if ([url.host isEqualToString:@"sharing"]) {
            [self callNativeShareFunction];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
        
    } else if ([scheme isEqualToString:@"fb-messenger"]) {
        [self shareToMessenger:[url absoluteString]];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    if ([url.absoluteString containsString:@"surveymonkey"] && [url.absoluteString rangeOfString:@"close-window"].location != NSNotFound) {
        //如果监听到是问卷调查页面，并且是close-window,就退出到首页
        decisionHandler(WKNavigationActionPolicyCancel);
        JumpModel *model = [[JumpModel alloc] init];
        model.actionType = JumpHomeActionType;
        [JumpManager doJumpActionTarget:self withJumpModel:model];
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    ShowAlertView(@"Alert", message, nil, nil, ZFLocalizedString(@"OK",nil), ^(id cancelTitle) {
        completionHandler();
    });
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
    
    //注册js调用App原生方法
    [self registerJsCallAppMethod];
    
    //注册App调用JS方法
    [self registerAppCallJsMethod];
}

/**
 * 注册js调用App原生方法
 */
- (void)registerJsCallAppMethod
{
    if (!self.javaScriptBridge) return;
    @weakify(self)
    
    //需求1: H5调用App原生方法获取App是否为预发布
    [self.javaScriptBridge registerHandler:@"fetchReleaseStatus" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSNumber *status = [NSNumber numberWithInt:0];
        if ([YWLocalHostManager isPreRelease]){
            status = [NSNumber numberWithInt:1];
        }
        responseCallback(status);
    }];
    
    //需求2: ZZZZZ店庆v2版小测试结果页h5生成图片，提示授权保存图片到本地
    [self.javaScriptBridge registerHandler:@"decodedImage" handler:^(id data, WVJBResponseCallback responseCallback) {
        @strongify(self)
        [self decodedImage:data];
        responseCallback(nil);
    }];
    
    //需求3: V3.6.1H5人脸识别需求, 下载H5中的图片, 下载完之后把图片带入社区普通发帖
    [self.javaScriptBridge registerHandler:@"downLoadingFaceRecognitionImage" handler:^(id data, WVJBResponseCallback responseCallback) {
        @strongify(self)
        [self downLoadingFaceRecognitionImage:data];
        responseCallback(nil);
    }];
    
    //V4.5.3当用户在APP内嵌H5拼团详情页首次发起拼团时，需要判断用户是否开始push通知权限
    [self.javaScriptBridge registerHandler:@"showGroupPushDialog" handler:^(id data, WVJBResponseCallback responseCallback) {
        @strongify(self)
        [self registerZFRemoteNotification];
        responseCallback(nil);
    }];
    
    //v5.2.0电子钱包回调
    [self.javaScriptBridge registerHandler:@"walletChangePasswordSuccess" handler:^(id data, WVJBResponseCallback responseCallback) {
        @strongify(self);
        if (self.walletChangePasswordBlock) {
            self.walletChangePasswordBlock();
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    //用户开通学生卡回调接口
    [self.javaScriptBridge registerHandler:@"userJoinStudentVipSuccess" handler:^(id data, WVJBResponseCallback responseCallback) {
        //收到通知，刷新用户数据
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserJoinStudentVipSuccessKey object:nil];
    }];
        
    //H5告诉App关闭加载转圈的回调
    [self.javaScriptBridge registerHandler:@"h5DomLoaded" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self showLoadingActivity:NO];
    }];
}

/**
 * 注册App调用JS方法
 */
- (void)registerAppCallJsMethod
{
    if (!self.javaScriptBridge) return;
    
    //需求1: xxx
    /**
     [self.javaScriptBridge callHandler:@"testJavascriptHandler" data:@{ @"foo":@"before ready" } responseCallback:^(id responseData) {
     YWLog(@"testJavascriptHandler callHandler=====%@", responseData);
     }];
     */
    //需求2: 。。。
}

#pragma mark -===========处理javaScript与原生App回调方法===========

/**
 * 需求背景:
 * 1. 点击H5按钮, 根据返回的一段文字, 把文字打水印在本地的一张图片上然后保存到相册
 * 2. 保存成功后再根据deeplink进行跳转原生页面,引导用户分享到社区
 */
- (void)decodedImage:(NSDictionary *)dataDic
{
    if (!dataDic || !ZFJudgeNSDictionary(dataDic)) return;
    NSString *deepLinkUrl = dataDic[@"deepLinkUrl"];
    
    //拼接deepLink跳转参数
    if (ZFJudgeNSString(deepLinkUrl) && deepLinkUrl.length>0) {
        [self parseURLParams:[NSURL URLWithString:deepLinkUrl]];
        
        //给背景图片打水印
        NSString *watermarkStr = dataDic[@"watermarkStr"];
        if (ZFJudgeNSString(watermarkStr) && watermarkStr.length>0) {
            UIImage *bgImage = ZFImageWithName(@"letter_activityBg");
            
            CGFloat topSpace = 120;
            CGFloat leftSpace = 53;
            CGFloat watemarkTextW = bgImage.size.width - leftSpace *2;
            CGFloat watemarkTextH = bgImage.size.height;
            //水印文字位置
            CGRect drawRect = CGRectMake(leftSpace, topSpace, watemarkTextW, watemarkTextH);
            
            //水印文字字体
            NSMutableAttributedString *arrtStr = [[NSMutableAttributedString alloc] initWithString:watermarkStr];
            
            NSMutableDictionary *arrtDic = [NSMutableDictionary dictionary];
            arrtDic[NSFontAttributeName] = ZFFontSystemSize(30);
            arrtDic[NSForegroundColorAttributeName] = ZFCOLOR_WHITE;
            [arrtStr setAttributes:arrtDic range:NSMakeRange(0, watermarkStr.length)];
            
            NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineSpacing = 20;
            paragraphStyle.alignment = NSTextAlignmentLeft;
            [arrtStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, watermarkStr.length)];
            
            UIImage *shareImage = [bgImage addWatemarkWithAttrStr:arrtStr
                                                       drawInRect:drawRect];
            if (ZFJudgeClass(shareImage, @"UIImage")) {
                //保存图片到相册
                ShowLoadingToView(self.view);
                UIImageWriteToSavedPhotosAlbum(shareImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            }
        }
    }
}

/**
 * 保存图片到相册代理, 然后走deeplink跳转
 */
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    [self showLoadingActivity:NO];
    HideLoadingFromView(self.view);
    
    YWLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
    if (error) {
        ShowToastToViewWithText(nil, ZFLocalizedString(@"WebView_SaveImageFailTip", nil));
    } else {
        ShowToastToViewWithText(nil, ZFLocalizedString(@"WebView_SaveImageSuccessTip", nil));
        //保存到相册成功后走deeplink跳转
        [self deeplinkHandle];
    }
}

/**
 * V3.6.1需求背景:
 * H5中人脸识别需求, 下载H5中的图片, 下载完之后把图片带入社区普通发帖
 */
- (void)downLoadingFaceRecognitionImage:(NSDictionary *)dataDic
{
    if (!dataDic || !ZFJudgeNSDictionary(dataDic)) return;
    NSString *imageUrl = dataDic[@"imageUrl"];
    NSString *topicTaget = dataDic[@"topic"];

    //拼接deepLink跳转参数
    if (ZFIsEmptyString(imageUrl)) {
        ShowToastToViewWithText(self.view, ZFLocalizedString(@"EmptyCustomViewManager_titleLabel", nil));
        return;
    }    
    
    ShowLoadingToView(self.view);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:imageUrl];
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            HideLoadingFromView(self.view);
            
            BOOL showAlertTip = YES;
            if ([imageData isKindOfClass:[NSData class]]) {
                UIImage *image = [UIImage imageWithData:imageData];
                if ([image isKindOfClass:[UIImage class]]) {
                    
                    showAlertTip = NO;
                    @weakify(self)
                    [self judgePresentLoginVCCompletion:^{
                        @strongify(self)
                        ZFCommunityShowPostViewController *postVC = [[ZFCommunityShowPostViewController alloc] init];
                        postVC.title = ZFToString(topicTaget);
                        
                        ZFCommunityHotTopicModel *hotTopicModel = [[ZFCommunityHotTopicModel alloc] init];
                        hotTopicModel.label = topicTaget;
                        postVC.selectHotTopicModel = hotTopicModel;
                        PYAssetModel *assetModel = [[PYAssetModel alloc] init];
                        assetModel.orderNumber = 1;
                        assetModel.localIdentifier = [NSString stringWithFormat:@"%@_%@",NSStringFromClass(self.class),[NSStringUtils getCurrentTimestamp]];
                        assetModel.originImage = image;
                        postVC.selectAssetModelArray = [NSMutableArray arrayWithObject:assetModel];
                        postVC.comeFromeType = 1;//1:H5页面人脸识别发帖
                        ZFNavigationController *nav = [[ZFNavigationController alloc] initWithRootViewController:postVC];
                        [self presentViewController:nav animated:YES completion:nil];
                    }];
                    return ;
                }
            }
            if (showAlertTip) {
                ShowToastToViewWithText(self.view, ZFLocalizedString(@"EmptyCustomViewManager_titleLabel", nil));
            }
        });
    });
}

/**
 * H5人脸引导发帖成功需要提示页面, 需要跳转到帖子详情页面
 */
- (void)faceRecognitionPostSuccessNotify:(NSNotification *)notification{
    ShowToastToViewWithText(self.view, ZFLocalizedString(@"Success",nil));
    
    NSDictionary *noteDict = notification.object;
    ZFCommunityPostResultModel *model = [[noteDict ds_arrayForKey:@"model"] firstObject];
    
    if ([model isKindOfClass:[ZFCommunityPostResultModel class]]) {
        ZFCommunityPostDetailPageVC *detailViewController = [[ZFCommunityPostDetailPageVC alloc] initWithReviewID:model.reviewId title:@""];

        [self.navigationController pushViewController:detailViewController animated:NO];
    }
}

/**
 检测是否开始push通知权限
 */
- (void)registerZFRemoteNotification {
    BOOL isPopAlert = [GetUserDefault(kGroupShowSystemNotificationAlert) boolValue];
    if (isPopAlert == NO) {
        [AppDelegate registerZFRemoteNotification:^(NSInteger openFlag){
            if (openFlag == 0) {
                [YSAlertView alertWithTitle:nil message:ZFLocalizedString(@"group_congrats", nil) cancelButtonTitle:ZFLocalizedString(@"GuideReviewAppStore_NotNow", nil) cancelButtonBlock:nil otherButtonBlock:^(NSInteger buttonIndex, id buttonTitle) {
                    if (buttonIndex == 0) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }
                } otherButtonTitles: ZFLocalizedString(@"OK", nil), nil];
            }
        }];
        SaveUserDefault(kGroupShowSystemNotificationAlert, @(YES));
    }
}

#pragma mark - Getter
- (NSMutableDictionary *)params {
    if (!_params) {
        _params = [NSMutableDictionary dictionary];
    }
    return  _params;
}

@end

