//
//  STLActivityWWebCtrl.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/22.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLActivityWWebCtrl.h"
#import "OSSVDetailsVC.h"
#import "STLShareCtrl.h"
#import "OSSVAdvsEventsModel.h"
#import "OSSVAdvsEventsManager.h"
#import "WKWebViewPanelManager.h"
#import "OSSVConfigDomainsManager.h"
#import "RateModel.h"
#import "STLPushManager.h"
#import "STLALertTitleMessageView.h"
#import "OSSVCommonnRequestsManager.h"
#import "OSSVMySizeVC.h"
#import "Adorawe-Swift.h"
@import RangersAppLog;

@interface STLActivityWWebCtrl () <WKNavigationDelegate, WKUIDelegate,STLShareDelegate>

@property (nonatomic, strong) WKWebView *web;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic,strong) NSString *jsFunction;

@end

@implementation STLActivityWWebCtrl

#pragma mark - Life Cycle

- (void)dealloc
{
    [self.web removeObserver:self forKeyPath:@"loading" context:nil];
    [self.web removeObserver:self forKeyPath:@"title" context:nil];
    [self.web removeObserver:self forKeyPath:@"estimatedProgress" context:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotif_openPushSuccess object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.ActivityWKWebComplation) {
        self.ActivityWKWebComplation();
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [DotApi webView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentPageCode = @"";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openWebSwitch:) name:kNotif_openPushSuccess object:nil]; //开启推送的通知

    [self initWebView];
    
    
    if (!self.isModalPresent) {
        
    }
    
    if (self.isModalPresent) {
        
        UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceButtonItem.width = -10.0;

        UIButton *_rightButton = [[UIButton alloc] init];
        [_rightButton setImage:[UIImage imageNamed:@"close_18"] forState:UIControlStateNormal];
        [_rightButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
        _rightButton.imageView.contentMode = UIViewContentModeCenter;

        UIBarButtonItem *rihtItem = [[UIBarButtonItem alloc] initWithCustomView:_rightButton];
        self.navigationItem.rightBarButtonItem = rihtItem;
        
    } else {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] init];
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        ///当系统语言为阿拉伯语的时候，系统会自动置换
        leftBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -30, 0, 30);
        leftBtn.frame = CGRectMake(0, 0, 60, 30);
        [leftBtn setImage:[UIImage imageNamed:@"arrow_left_new"] forState:0];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            leftBtn.transform = CGAffineTransformMakeRotation(M_PI);
        }
        [leftBtn addTarget:self action:@selector(goBackAction) forControlEvents:UIControlEventTouchUpInside];
        item.customView = leftBtn;
        self.navigationItem.leftBarButtonItem = item;
    }
}

- (void)clickButtonAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)configWebViewUserAgent {
    
    NSString *platform = @"ios";
    NSString *device_id = [OSSVAccountsManager sharedManager].device_id;
    NSString *version = STLToString(kAppVersion);
    NSString *currency = [ExchangeManager localTypeCurrency];
    NSString *language = [STLLocalizationString shareLocalizable].nomarLocalizable;
    NSString *staging = [OSSVConfigDomainsManager isPreRelease] ? @"true" : @"false";
    
    NSString *customUserAgent = [NSString stringWithFormat:@"platform=%@&device_id=%@&version=%@&currency=%@&language=%@&staging=%@",platform, device_id, version, currency, language, staging];

    if (@available(iOS 12.0, *)){
            //由于iOS12的UA改为异步，所以不管在js还是客户端第一次加载都获取不到，所以此时需要先设置好再去获取（1、如下设置；2、先在AppDelegate中设置到本地）
            NSString *userAgent = [self.web valueForKey:@"applicationNameForUserAgent"];
            NSString *newUserAgent = [NSString stringWithFormat:@"%@%@",userAgent,@"自定义UA内容"];
            [self.web setValue:newUserAgent forKey:@"applicationNameForUserAgent"];
        }
        [self.web evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            NSString *userAgent = result;
            
            if ([userAgent rangeOfString:customUserAgent].location != NSNotFound) {
                return ;
            }
            NSString *newUserAgent = [userAgent stringByAppendingString:customUserAgent];
    //                NSLog(@"%@>>>%@>>>>>",userAgent,newUserAgent);
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:newUserAgent,@"UserAgent", nil];
            [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
            [[NSUserDefaults standardUserDefaults] synchronize];
             //不添加以下代码则只是在本地更改UA，网页并未同步更改
            if (@available(iOS 9.0, *)) {
                [self.web setCustomUserAgent:newUserAgent];
            } else {
                [self.web setValue:newUserAgent forKey:@"applicationNameForUserAgent"];
            }
        }]; //加载请求必须同步在设置UA的后面
}

#pragma mark - Method
- (void)configShareButton
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] init];
    self.navigationItem.rightBarButtonItem= item;
    UIButton *rightItem = [UIButton buttonWithType:UIButtonTypeCustom];
    rightItem.frame = CGRectMake(0, 0, 20, 20);
    [rightItem setImage:[UIImage imageNamed:@"bannerShare"] forState:0];
    [rightItem addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    item.customView = rightItem;
}

#pragma mark - Action
- (void)share
{
    STLShareCtrl *shareVC = [[STLShareCtrl alloc] init];
    shareVC.shareContent = self.model.shareContent;
    shareVC.shareImage = self.model.shareImageURL;
    shareVC.shareURL =  self.model.shareLinkURL;
    shareVC.shareTitle = self.model.shareTitle;
    shareVC.shareSourceId = STLToString(self.strUrl);
    shareVC.shareSourcePageName = NSStringFromClass(self.class);
    shareVC.h5UrlStr = STLToString(self.strUrl);
    shareVC.type = 2;
    
    [self.navigationController presentTranslucentViewController:shareVC animated:NO completion:^{
    }];
}

-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

#pragma mark - MakeUI
- (void)initWebView
{
    if (self.model.isShare == 1) {
        [self configShareButton];
    }
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    ///往WKWebView里面注入 cookie
    DomainType type = [OSSVConfigDomainsManager domainEnvironment];
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.userContentController = userContentController;
    // 在iOS上默认为NO，表示不能自动通过窗口打开
    //    config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    
    WKWebView *web = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    web.navigationDelegate = self;
    web.UIDelegate = self;
    web.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    web.backgroundColor = [UIColor whiteColor];
    //隐藏滚动条
    web.scrollView.showsVerticalScrollIndicator = NO;
    web.scrollView.showsHorizontalScrollIndicator = NO;
    //    web.allowsBackForwardNavigationGestures = true;
    
    
    [self.view addSubview:web];
    [web mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(0);
        make.bottom.equalTo(self.view.mas_bottomMargin);
    }];
    self.web = web;
    
//    self.strUrl = @"https://app.adorawe.com/wap/ramadan-festival?lang=en";
    
    NSString *purposeUrl = STLToString(self.strUrl);
    
    if (type == DomainType_Pre_Release) {
        if ([purposeUrl rangeOfString:@"?"].location != NSNotFound) {
            purposeUrl = [NSString stringWithFormat:@"%@&staging=%@",purposeUrl,@"1"];
        } else {
            purposeUrl = [NSString stringWithFormat:@"%@?staging=%@",purposeUrl,@"1"];
        }
    }
    
    NSString *lang = [STLLocalizationString shareLocalizable].nomarLocalizable; //语言
    RateModel *rate = [ExchangeManager localCurrency]; //当前货币
    NSString  *versionStr = kAppVersion; //APP版本号
    NSString *device_id = [OSSVAccountsManager sharedManager].device_id;
    NSString *platform = @"ios";
    //应该不需要的
    NSString *channel = @"";//STLToString([OSSVAccountsManager sharedManager].shareChannelSource);
    
    NSString *sensorId = STLToString(SensorsAnalyticsSDK.sharedInstance.anonymousId);
    //参数去重
    NSMutableString *purposeUrlNew = [[NSMutableString alloc] initWithString:purposeUrl];
    if (![purposeUrlNew containsString:@"device_id"]) {
        [purposeUrlNew appendFormat:@"&device_id=%@",STLToString(device_id)];
    }
    if (![purposeUrlNew containsString:@"currency"]) {
        [purposeUrlNew appendFormat:@"&currency=%@",STLToString(rate.code)];
    }
    if (![purposeUrlNew containsString:@"lang"]) {
        [purposeUrlNew appendFormat:@"&lang=%@",STLToString(lang)];
    }
    if (![purposeUrlNew containsString:@"version"]) {
        [purposeUrlNew appendFormat:@"&version=%@",STLToString(versionStr)];
    }
    if (![purposeUrlNew containsString:@"platform"]) {
        [purposeUrlNew appendFormat:@"&platform=%@",STLToString(platform)];
    }
    if (![purposeUrlNew containsString:@"token"] && OSSVAccountsManager.sharedManager.isSignIn) {
        [purposeUrlNew appendFormat:@"&token=%@",STLToString(USER_TOKEN)];
    }
    if (![purposeUrlNew containsString:@"anonymousId"]) {
        [purposeUrlNew appendFormat:@"&anonymousId=%@",sensorId];
    }
    
    ///AB 推荐参数
    NSString *newRecommand_ab = [BDAutoTrack ABTestConfigValueForKey:@"Recommand_Ab" defaultValue:@("")];
    if (OSSVAccountsManager.sharedManager.sysIniModel.recommend_abtest_switch && ![purposeUrlNew containsString:@"ab"]){
        [purposeUrlNew appendFormat:@"&ab=%@",STLToString(newRecommand_ab)];
    }
    
    //注入cookie
    NSURL *webUrl = [NSURL URLWithString:purposeUrlNew.copy];
    
    NSMutableString *headerParams = [NSMutableString stringWithFormat:@"onesite=true;appLanguage=%@;currencyCate=%@;version=%@;device_id=%@;anonymousId=%@",lang,rate.code,versionStr,device_id,sensorId];
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
//        
//        headerParams = [NSMutableString stringWithFormat:@"onesite=true;appLanguage=%@;currencyCate=%@;is_app=1;version=%@;device_id=%@",lang,rate.code,versionStr,device_id];
//    }
    if (USER_TOKEN && OSSVAccountsManager.sharedManager.isSignIn) {
        [headerParams appendFormat:@";token=%@",STLToString(USER_TOKEN)];
    }
     
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:webUrl];
    [request addValue:headerParams forHTTPHeaderField:@"Cookie"];
    [self.web loadRequest:request];

    
    

    // 添加KVO监听
    [self.web addObserver:self
               forKeyPath:@"loading"
                  options:NSKeyValueObservingOptionNew
                  context:nil];
    [self.web addObserver:self
               forKeyPath:@"title"
                  options:NSKeyValueObservingOptionNew
                  context:nil];
    [self.web addObserver:self
               forKeyPath:@"estimatedProgress"
                  options:NSKeyValueObservingOptionNew
                  context:nil];
    
    // 添加进入条
    self.progressView = [[UIProgressView alloc] init];
    self.progressView.progressTintColor = OSSVThemesColors.col_FDD835;
    self.progressView.frame = self.view.bounds;
    [self.view addSubview:self.progressView];
//    self.progressView.backgroundColor = [UIColor redColor];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"loading"]) {
        NSLog(@"loading");
    } else if ([keyPath isEqualToString:@"title"]) {
        if (!self.isIgnoreWebTitle) {
            self.title = self.web.title;
        }
    } else if ([keyPath isEqualToString:@"estimatedProgress"]) {
        NSLog(@"progress: %f", self.web.estimatedProgress);
        self.progressView.progress = self.web.estimatedProgress;
    }
    
    // 加载完成
    if (!self.web.loading) {
        // 手动调用JS代码
        // 每次页面完成都弹出来，大家可以在测试时再打开
        //        NSString *js = @"callJsAlert()";
        //        [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        //            NSLog(@"response: %@ error: %@", response, error);
        //            NSLog(@"call js alert by native");
        //        }];
        
        [UIView animateWithDuration:0.5 animations:^{
            self.progressView.alpha = 0;
            self.progressView.progress = 0;
        }];
    }else{
        self.progressView.alpha = 1;
    }
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    WKNavigationActionPolicy actionPolicy = WKNavigationActionPolicyAllow;
    NSURL *url = navigationAction.request.URL;
    DLog(@"[URL: %@]", url);
    DLog(@"[lowercaseString: %@]",url.scheme.lowercaseString);
    DLog(@"[host: %@]",url.host);

//    NSString *cookie = @"starlink=always";
//    if ([navigationAction.request allHTTPHeaderFields][@"Cookie"] && [[navigationAction.request allHTTPHeaderFields][@"Cookie"] rangeOfString:cookie].length > 0) {
//        actionPolicy = WKNavigationActionPolicyAllow;
//    } else {
//        NSMutableURLRequest *request= [NSMutableURLRequest requestWithURL:navigationAction.request.URL];
//        [request setValue:cookie forHTTPHeaderField:@"Cookie"];
//        [webView loadRequest:request];
//        actionPolicy = WKNavigationActionPolicyCancel;
//    }
    
    _jsFunction = @"";
    if ([url.scheme.lowercaseString isEqualToString:@"webaction"]) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        if (url.query) {
            
            NSArray *arr = [url.query componentsSeparatedByString:@"&"];
            DLog(@"**** 哈哈 %@ ***",arr);
            for (NSString *str in arr) {
                
                NSRange range = [str rangeOfString:@"="];
                if (range.location != NSNotFound) {
                    NSString *key   = [str substringToIndex:range.location];
                    NSString *value = [str substringFromIndex:range.location+1];
                    [params setObject:value forKey:key];
                }
            }
        }
        
        // webAction://login?callback=userinfo()&isAlert=0  触发客户端登录事件, callback 指定登录回调事件, 用以接收客户端传出的用户标识  isAlert:是否弹窗   0不弹    1弹
        if ([url.host isEqualToString:@"login"])
        {
            if (params.count > 0) {
                NSString *jsFunction = params[@"callback"];
                BOOL isAlert = [STLToString(params[@"isAlert"]) boolValue];
                [self callBackLogin:jsFunction isAlert:isAlert];
            }
        }
        
        // webAction://textcopy?text=abc
        if ([url.host isEqualToString:@"textcopy"])
        {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = params[@"text"];
        }
        
        // webAction://sharing?shareUrl=http://www.google.com &shareContent=测试一个分享数据&imageUrl=https://www.google.com/images/nav_logo242.png&callback=shareSuccess()
        
        if ([url.host isEqualToString:@"sharing"])
        {
            // 处理分享
            if (params.count>0) {
                
                _jsFunction = params[@"callback"];
                STLShareCtrl *shareVC = [[STLShareCtrl alloc] init];
                shareVC.isAddUser = YES;
                shareVC.delegate = self;
                shareVC.shareImage = params[@"imageUrl"];
                shareVC.shareContent = REMOVE_URLENCODING(STLToString(params[@"shareContent"]));
                shareVC.shareURL =  REMOVE_URLENCODING(STLToString(params[@"shareUrl"]));
                shareVC.shareTitle = REMOVE_URLENCODING(STLToString(params[@"shareTitle"]));
                shareVC.shareSourceId = STLToString(self.strUrl);
                shareVC.shareSourcePageName = NSStringFromClass(self.class);
                shareVC.h5UrlStr = STLToString(self.strUrl);
                shareVC.type = 2;
                [self.navigationController presentTranslucentViewController:shareVC animated:NO completion:^{
                }];

            }
        }
         // webAction://checkMyOrder?Order=checkMyOrder
        
        // webAction://isApp?callback=isAppRes()  此链接是否在APP中打开
        if ([url.host isEqualToString:@"isApp"])
        {
            if (params.count > 0) {
                NSString *jsFunction = params[@"callback"];
                [self callBackIsAppOpen:jsFunction];
            }
        }
        //是否开启推送
        // webAction://isOpenPush?callback=openPushCallback()
        if ([url.host isEqualToString:@"isOpenPush"]) {
            NSString *callBackString = @"";
            if (params.count > 0) {
                callBackString =  params[@"callback"];
//                callBackString = @"remindMeStatus";
                NSLog(@"回调函数：%@", callBackString);
                @weakify(self)
                [STLPushManager isRegisterRemoteNotification:^(BOOL isRegister) {
                    @strongify(self)
                                //未开启推送
                                if (!isRegister) {
                                    NSLog(@"未开启推送");
                                        [STLALertTitleMessageView alertWithAlerTitle:@"" alerMessage:STLLocalizedString_(@"OpenPushTitle", nil) otherBtnTitles:@[STLLocalizedString_(@"later",nil).uppercaseString,STLLocalizedString_(@"open", nil).uppercaseString] otherBtnAttributes:nil alertCallBlock:^(NSInteger buttonIndex, NSString *title) {

                                            if (buttonIndex == 1) {
                                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
//                                                [self callBackIsOpenPush:callBackString resultValue:1];

                                            } else {
                                                [self callBackIsOpenPush:callBackString resultValue:0];
                                            }
                                        }];

                                } else {
                                    NSLog(@"已开启推送");
                                    [self callBackIsOpenPush:callBackString resultValue:1];                    }
                            }];

            }
            
        }
        
        //webAction://measure
        if ([url.host isEqualToString:@"measure"]) {
            if (![OSSVAccountsManager sharedManager].isSignIn) {
                SignViewController *sign = [SignViewController new];
                sign.modalPresentationStyle = UIModalPresentationFullScreen;
                //如果登录后再执行block中的方法
                @weakify(self)
                sign.signBlock = ^{
                    @strongify(self)
                    OSSVMySizeVC *sizeVC = [OSSVMySizeVC new];
                    sizeVC.isModalPresent = self.isModalPresent;
                    [self.navigationController pushViewController:sizeVC animated:YES];
                };
                [self presentViewController:sign animated:YES completion:nil];
            }else{
                OSSVMySizeVC *sizeVC = [OSSVMySizeVC new];
                sizeVC.isModalPresent = self.isModalPresent;
                [self.navigationController pushViewController:sizeVC animated:YES];
            }
            
        }

        // webAction://pointChanged?amount=100  积分变化, 传出新的积分数量
        if ([url.host isEqualToString:@"pointChanged"])
        {
            
        }
        
        // webAction://couponAdded?code=abc123 coupon增加, 传出新增的coupon
        if ([url.host isEqualToString:@"couponAdded"])
        {
            
            // 处理coupon事件
        }
        
        // webAction://market
        if ([url.host isEqualToString:@"market"])
        {
            NSURL *urlMarket = [NSURL URLWithString:[OSSVLocaslHosstManager appStoreDownUrl]];
            if ([[UIApplication sharedApplication] canOpenURL:urlMarket]) {
                [[UIApplication sharedApplication] openURL:urlMarket options:@{} completionHandler:nil];
             }
        }
        
        actionPolicy = WKNavigationActionPolicyCancel;
    }
//    url = @"Adorawe://action?actiontype=7&url=https://twitter.com/intent/tweet?url=https://www.youtube.com/watch?v=h4MLcHXHiTw&text=";
    if ([url.scheme.lowercaseString isEqualToString:[[OSSVLocaslHosstManager appName] lowercaseString]])
    {
//        
//        NSString *strUrl = @"Adorawe://action?actiontype=7&url=https%3A%2F%2Ftwitter.com%2Fintent%2Ftweet%3Furl%3Dhttps%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3Dh4MLcHXHiTw%26text%3D";
//        url = [NSURL URLWithString:strUrl];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        if (url.query) {
            NSArray *arr = [url.query componentsSeparatedByString:@"&"];
            for (NSString *str in arr) {
                if ([str rangeOfString:@"="].location != NSNotFound) {
                    NSString *key   = [str componentsSeparatedByString:@"="][0];
                    NSString *value = [str componentsSeparatedByString:@"="][1];
                    //先把参数decode一下
                    value = REMOVE_URLENCODING(STLToString(value));
                    [params setObject:value forKey:key];
                }
            }
        }
        
        OSSVAdvsEventsModel *advEventModel = [[OSSVAdvsEventsModel alloc] init];
        advEventModel.actionType = AdvEventTypeDefault;
        advEventModel.url  = @"";
        advEventModel.name = @"";
        advEventModel.webtype = @"";
        if (params.count>0) {
            advEventModel.actionType = [params[@"actiontype"] integerValue];
            advEventModel.url        = STLToString(params[@"url"]);
            advEventModel.name       = STLToString(params[@"name"]);
            advEventModel.webtype    = STLToString(params[@"webtype"]);
            advEventModel.request_id = [ABTestTools Recommand_abWithRequestId:STLToString(params[@"request_id"])];
        }
        
        //web页面跳转到deeplink
        [OSSVAdvsEventsManager advEventTarget:self withEventModel:advEventModel];
        
        actionPolicy = WKNavigationActionPolicyCancel;
    }
    
    if([url.host.lowercaseString isEqualToString:@"itunes.apple.com"] || [url.scheme.lowercaseString isEqualToString:@"itms-apps"]) {
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                if (success) {
//                    actionPolicy = WKNavigationActionPolicyCancel;
                    NSLog(@"已跳转至App Store");
                }
            }];
            
         }
     }
    
    self.progressView.alpha = 1.0;
    decisionHandler(actionPolicy);
    
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    decisionHandler(WKNavigationResponsePolicyAllow);
    STLLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    STLLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    STLLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    STLLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation
{
    STLLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    STLLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    [WKWebViewPanelManager presentAlertOnController:self.view.window.rootViewController title:@"Alert" message:message handler:completionHandler];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    [WKWebViewPanelManager presentConfirmOnController:self.view.window.rootViewController title:@"Confirm" message:message handler:completionHandler];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    [WKWebViewPanelManager presentPromptOnController:self.view.window.rootViewController title:@"Prompt" message:prompt defaultText:defaultText handler:completionHandler];
}

#pragma mark - WKUIDelegate
- (void)webViewDidClose:(WKWebView *)webView {
    STLLog(@"%s", __FUNCTION__);
}

#pragma mark - WebAction
- (void)callBackLogin:(NSString *)jsFunction isAlert:(BOOL)isAlert {
    if (![OSSVAccountsManager sharedManager].isSignIn) {
        if (isAlert) {
            SignViewController *sign = [SignViewController new];
            sign.modalPresentationStyle = UIModalPresentationFullScreen;
            //如果登录后再执行block中的方法
            sign.signBlock = ^{
                [self callBackLogin:jsFunction isAlert:isAlert];
            };
            //            OSSVNavigationVC *nav = [[OSSVNavigationVC alloc] initWithRootViewController:sign];
            [self presentViewController:sign animated:YES completion:nil];
        }else{
            // 不弹登录窗口
            NSRange range = [jsFunction rangeOfString:@"()" options:NSBackwardsSearch];
            if (range.location != NSNotFound) {
                jsFunction = [jsFunction substringToIndex:range.location];
            }
//            NSString *encodeUserid = [OSSVNSStringTool encryptWithStr:[@(USERID) stringValue]];
            NSString *encodeToken = STLToString(USER_TOKEN);
            jsFunction = [NSString stringWithFormat:@"%@('%@')", jsFunction, encodeToken];
            
            [self.web evaluateJavaScript:jsFunction completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                STLLog(@"response: %@ error: %@", response, error);
            }];
        }
    } else {
        NSRange range = [jsFunction rangeOfString:@"()" options:NSBackwardsSearch];
        if (range.location != NSNotFound) {
            jsFunction = [jsFunction substringToIndex:range.location];
        }
//        NSString *encodeUserid = [OSSVNSStringTool encryptWithStr:[@(USERID) stringValue]];
        NSString *encodeToken = STLToString(USER_TOKEN);
        jsFunction = [NSString stringWithFormat:@"%@('%@')", jsFunction, encodeToken];
        
        [self.web evaluateJavaScript:jsFunction completionHandler:^(id _Nullable response, NSError * _Nullable error) {
            STLLog(@"response: %@ error: %@", response, error);
        }];
    }
}

- (void)callBackIsAppOpen:(NSString *)jsFunction {
    NSRange range = [jsFunction rangeOfString:@"()" options:NSBackwardsSearch];
    if (range.location != NSNotFound) {
        jsFunction = [jsFunction substringToIndex:range.location];
    }
    jsFunction = [NSString stringWithFormat:@"%@('%@')", jsFunction, @(TRUE)];
    [self.web evaluateJavaScript:jsFunction completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        STLLog(@"response: %@ error: %@", response, error);
    }];
}

//开启推送通知的回调

- (void)callBackIsOpenPush:(NSString *)callBackString resultValue:(NSInteger)resultValue {
    NSRange range = [callBackString rangeOfString:@"()" options:NSBackwardsSearch];
    if (range.location != NSNotFound) {
        callBackString = [callBackString substringToIndex:range.location];
    }
    callBackString = [NSString stringWithFormat:@"%@(%@)", callBackString, @(resultValue)];

    [self.web evaluateJavaScript:callBackString completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        STLLog(@"response: %@ error: %@", response, error);
    }];

}
- (void)goBackAction {
    if (self.web.canGoBack) {
        [self.web goBack];
    }else{
        [self closeAction];
    }
}

- (void)closeAction {
    if (self.isModalPresent) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - STLShareDelegate
- (void)STL_dismissViewControllerAnimated:(BOOL)flag channel:(NSString *)channel success:(BOOL)isSuccess completion:(void (^)(void))completion {
    if (!STLIsEmptyString(_jsFunction)) {
        
        NSString *jsEvent = _jsFunction;
        NSRange range = [_jsFunction rangeOfString:@"()" options:NSBackwardsSearch];
        if (range.location != NSNotFound) {
            jsEvent = [_jsFunction substringToIndex:range.location];
        }
        NSString *jsFunction = [NSString stringWithFormat:@"%@('%@')", jsEvent, STLToString(channel)];

        [self.web evaluateJavaScript:jsFunction completionHandler:^(id _Nullable response, NSError * _Nullable error) {
            STLLog(@"response: %@ error: %@", response, error);
        }];
    }

    _jsFunction = @"";
}


- (void)STL_shareFailWithError:(NSError *)error {
}

#pragma mark ---开启推送的通知
- (void)openWebSwitch:(NSNotification *)notification {
    NSDictionary *dic  = notification.userInfo;
    NSInteger resultValue = [dic[@"value"] intValue];
    [self callBackIsOpenPush:@"openPushCallback" resultValue:resultValue];
}
@end
