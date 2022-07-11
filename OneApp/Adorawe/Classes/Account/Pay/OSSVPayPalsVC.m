//
//  OSSVPayPalsVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/11/8.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVPayPalsVC.h"
#import "OSSVConfigDomainsManager.h"
#import "STLActivityWWebCtrl.h"
#import "OSSVAdvsEventsManager.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "Adorawe-Swift.h"

#define TAG_ALERT_GOBACK    77777
#define TAG_BUTTON_ACTION   77778
#define TAG_CONTAINER       77779

static NSString *commonGAEvent = @"commonEvent";

@interface OSSVPayPalsVC () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UIAlertViewDelegate, WKNavigationDelegate, WKUIDelegate,WKScriptMessageHandler>

@property (nonatomic,assign) STLOrderPayStatus           status;
@property (nonatomic,strong) WKWebView              *webView;
@property (nonatomic,strong) UIActivityIndicatorView *indicatorView;

///1.3.6 时长统计
@property (nonatomic,strong) NSDate *startDate;

@end

@implementation OSSVPayPalsVC

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fd_interactivePopDisabled = YES;
    self.title = [OSSVLocaslHosstManager appName];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"arrow_left_new"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        button.transform = CGAffineTransformMakeScale(-1.0,1.0);
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    [self.view addSubview:self.webView];
    self.webView.frame = self.view.bounds;
    
    [self.view addSubview:self.indicatorView];
    self.indicatorView.center = self.view.center;
    
    if (![OSSVConfigDomainsManager isDistributionOnlineRelease]) {

        DomainType type = [OSSVConfigDomainsManager domainEnvironment];
        if (type != DomainType_Release){
            UILabel *lbl = [UILabel new];
            lbl.textColor = [UIColor redColor];
            lbl.font = [UIFont systemFontOfSize:18];
            lbl.alpha = 0.2;
            lbl.userInteractionEnabled = YES;
            lbl.numberOfLines = 0;
            lbl.text = STLLocalizedString_(@"copyEmail", nil);
            [self.view addSubview:lbl];
            UITapGestureRecognizer *tapUserNameTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(copyUserName)];
            tapUserNameTap.numberOfTapsRequired = 2;
            [lbl addGestureRecognizer:tapUserNameTap];
            [lbl mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self.view.mas_leading);
                make.trailing.mas_equalTo(-100);
                make.top.equalTo(10);
            }];
            
            UILabel *lblPassword = [UILabel new];
            lblPassword.textColor = [UIColor redColor];
            lblPassword.font = [UIFont systemFontOfSize:18];
            lblPassword.alpha = 0.2;
            lblPassword.userInteractionEnabled = YES;
            lblPassword.text = STLLocalizedString_(@"copyPwd", nil);
            [self.view addSubview:lblPassword];
            UITapGestureRecognizer *tapPasswordTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(copyPassword)];
            tapPasswordTap.numberOfTapsRequired = 2;
            [lblPassword addGestureRecognizer:tapPasswordTap];
            [lblPassword mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self.view.mas_leading);
                make.top.equalTo(lbl.mas_bottom).offset(5);
            }];
            
        }
    }

}

- (void)copyUserName {
    [UIPasteboard generalPasteboard].string = @"sb-5orsz2831659@personal.example.com";
}

- (void)copyPassword {
    [UIPasteboard generalPasteboard].string = @"7t2h+H2I";
}

- (void)setUrl:(NSString *)url
{
    _url = STLToString(url);
#if DEBUG
    ///test 测试数据
//    _url = @"http://172.28.25.54:5500/test1.html";
//    _url = @"https://a266-43-128-47-103.ngrok.io/galaxy.html?is_app=1";
#endif
    
    NSURL *webUrl = [NSURL URLWithString:_url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:webUrl cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:60];
    [self.webView loadRequest:request];
}

-(void)backButtonAction{
    // 获取 body 中的 page 判断是否是第一页
    NSString *js = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].getAttribute('page')"];
    //NSString *page = [self.webView stringByEvaluatingJavaScriptFromString:js];
    [self.webView evaluateJavaScript:js completionHandler:^(NSString *page, NSError * _Nullable error) {
        // page == 0 表示是第一页，其他页不是
        if ([page isKindOfClass:[NSNull class]]) {
            if (self.webView.canGoBack) {
                [self.webView goBack];
            }
            else{
                [self goBack];
            }
        }else{
            if ([page boolValue] > 0) {
                [self.webView evaluateJavaScript:[NSString stringWithFormat:@"hideform()"] completionHandler:^(id _Nullable l, NSError * _Nullable error) {
                    NSLog(@"%@",error);
                }];
            }
            else{
                [self goBack];
            }
        }
    }];
}

-(void)goBack {
    
    if (_status != STLOrderPayStatusDone) {
        
//        NSString *msg = [NSString stringWithFormat:@"%@ %@",STLLocalizedString_(@"pay_want_cancel_payment",nil),STLLocalizedString_(@"pay_canceld_order_24",nil)];
//        NSString *msg = STLLocalizedString_(@"pay_want_cancel_payment_messNew", nil);
//        NSString *pay = STLLocalizedString_(@"pay_PAYMENT",nil);
//        NSString *cancel = STLLocalizedString_(@"pay_CANCEL",nil);

        NSArray *titleUpper = @[STLLocalizedString_(@"pay_CANCEL",nil).uppercaseString,STLLocalizedString_(@"pay_PAYMENT",nil).uppercaseString];
        NSArray *titleLowser = @[STLLocalizedString_(@"pay_CANCEL",nil), STLLocalizedString_(@"pay_PAYMENT",nil)];
        
        [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:YES showHeightIndex:1 title:STLLocalizedString_(@"pay_want_cancel_payment",nil) message:STLLocalizedString_(@"pay_want_cancel_payment_messNew", nil) buttonTitles:APP_TYPE == 3 ? titleLowser : titleUpper buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
            
            if (index == 0) {
                [GATools logOrderCancelAlertWithAction:@"Canncel"];
                _status = STLOrderPayStatusCancel;
                [self closeThis];
            }else{
                [GATools logOrderCancelAlertWithAction:@"continue_to_pay"];
            }
        }];
        
    }else{
        [self closeThis];
    }
}

#pragma mark - alertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == TAG_ALERT_GOBACK) {
        if (buttonIndex == 1) {
            _status = STLOrderPayStatusCancel;
            [self closeThis];
        }
    }
}

#pragma mark - DZNEmptyDataSetSource
- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    if (self.webView.isLoading) {
        return nil;
    }
    
    NSString *text = @"";//@"网络很差哦，检查一下网络再试一下吧";
    UIColor *textColor = [UIColor colorWithRed:125/255.0 green:127/255.0 blue:127/255.0 alpha:1.0];
    
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    paragraph.lineSpacing = 2.0;
    
    [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    [attributes setObject:paragraph forKey:NSParagraphStyleAttributeName];
    
    return [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
}

#pragma mark - DZNEmptyDataSetDelegate
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return YES;
}

- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView
{
    return YES;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return YES;
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    WKNavigationActionPolicy actionPolicy = WKNavigationActionPolicyAllow;
    NSURL *url = navigationAction.request.URL;
    NSString *strUrl = url.absoluteString.lowercaseString;
    STLLog(@"%@", url);
    
    self.status = STLOrderPayStatusUnknown;
    
    if (navigationAction.targetFrame == nil) {
        [webView loadRequest:navigationAction.request];
        actionPolicy = WKNavigationActionPolicyCancel;
    }
    
//    if ([strUrl containsString:@"adorawe/wap/sindex-accountsupportcenter"]) {
//        NSString *appH5Url = [[OSSVConfigDomainsManager sharedInstance] appH5Url];
//        STLActivityWWebCtrl *webViewController = [STLActivityWWebCtrl new];
//        NSString *webUrl = [NSString stringWithFormat:@"%@%@", appH5Url, STLLocalizedString_(@"articles_supportCenter", nil)];
//        webViewController.strUrl = webUrl;
//        UIViewController *topVC = [OSSVAdvsEventsManager gainTopViewController];
//        [topVC.navigationController pushViewController:webViewController animated:YES];
//        webViewController.ActivityWKWebComplation = ^{
//            self.view.alpha = 1;
//        };
//        self.view.alpha = 0;
//        actionPolicy = WKNavigationActionPolicyCancel;
//    }
    
    if ([strUrl containsString:@"paybck/paymentstatus"])
    {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        if (url.query) {
            NSString *queryStr = REMOVE_URLENCODING(STLToString(url.query));
            NSArray *arr = [queryStr componentsSeparatedByString:@"&"];
            for (NSString *str in arr)
            {
                NSRange range = [str rangeOfString:@"="];
                if (range.location != NSNotFound) {
                    NSString *key   = [str substringToIndex:range.location];
                    NSString *value = [str substringFromIndex:range.location+1];
                    [params setObject:value forKey:key];
                }
            }
        }
        
        NSString *paymentStatus = params[@"status"];
        if ([paymentStatus isEqualToString:@"1"]) {
            _status = STLOrderPayStatusDone;
        }else if ([paymentStatus isEqualToString:@"2"]){
            _status = STLOrderPayStatusFailed;
        }else if ([paymentStatus isEqualToString:@"3"]){
            _status = STLOrderPayStatusCancel;
        }else if ([paymentStatus isEqualToString:@"4"]){
            _status = STLOrderPayStatusPaypalFast;
            if (self.ppFastBlock) {
                self.ppFastBlock(params);
            }
        }else{
            _status = STLOrderPayStatusUnknown;
        }
        
        if (_status > STLOrderPayStatusUnknown) {
            [self closeThis];
            actionPolicy = WKNavigationActionPolicyCancel;
        }
    }
    
    decisionHandler(actionPolicy);
}

//注意这是给预发布,有些测试环境https证书过期了 可以直接删除
#if DEBUG
-(void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *card = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, card);
    }
}
#endif


- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    self.startDate = [NSDate date];
    [self.indicatorView startAnimating];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    [self.indicatorView stopAnimating];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    NSDate *now = [NSDate date];
    NSTimeInterval coastTime = [now timeIntervalSinceDate:self.startDate];
    [self.indicatorView stopAnimating];
    
    NSString *startTime = [NSString stringWithFormat:@"%.0f", self.startDate.timeIntervalSince1970 * 1000];
    NSString *endTime = [NSString stringWithFormat:@"%.0f", now.timeIntervalSince1970 * 1000];
    NSString *timeLeng = [NSString stringWithFormat:@"%.0f", coastTime * 1000];
    
    NSString *url = [[self.url componentsSeparatedByString:@"?"] firstObject];
    
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"key_page_load" parameters:@{@"$screen_name":@"Payment",
                                                                              @"$referrer":@"",
                                                                              @"$title":@"Payment",
                                                                                @"$url":STLToString(url),
                                                                                @"load_begin":startTime,
                                                                                @"load_end":endTime,
                                                                              @"load_time":timeLeng}];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    [self.indicatorView stopAnimating];
}

#pragma mark - WKUIDelegate
- (void)webViewDidClose:(WKWebView *)webView
{
    STLLog(@"%s", __FUNCTION__);
}

#pragma mark - WebAction
-(void)closeThis {
    
    [self.navigationController popViewControllerAnimated:YES];
    
    if (_block) {
        _block(_status);
    }
}

#pragma mark - setter and getter
-(UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = ({
            UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
            indicatorView.hidesWhenStopped = YES;
            indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
            indicatorView;
        });
    }
    return _indicatorView;
}

- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        WKUserContentController *userCC = [WKUserContentController new];
        config.userContentController = userCC;
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        
    
        [userCC addScriptMessageHandler:self name:commonGAEvent];
        
        //隐藏滚动条
        _webView.scrollView.showsVerticalScrollIndicator = NO;
        _webView.scrollView.showsHorizontalScrollIndicator = NO;
        //修改颜色
        //    webView.scrollView.indicatorStyle=UIScrollViewIndicatorStyleWhite;
        //加载数据为空时的代理
        _webView.scrollView.emptyDataSetSource = self;
        _webView.scrollView.emptyDataSetDelegate = self;
        [_webView injectEventHandler];
    }
    return _webView;
}

-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if ([message.name isEqualToString:commonGAEvent]) {
        //
        NSLog(@"%@\n%@",message.name,message.body);
        if(STLJudgeNSDictionary(message.body)){
            ///添加埋点 add_payment_info
            NSDictionary* data = message.body[@"data"];
            if (STLJudgeNSDictionary(data) && [data[@"eventAction"] isEqualToString:@"add_payment_info"]){
                
                NSDictionary* checkOut = data[@"ecommerce"][@"checkout"];
                if (STLJudgeNSDictionary(checkOut)) {
                    NSString* paymentType = checkOut[@"actionField"][@"option"];
                    float price = [checkOut[@"value"] floatValue];
                    NSMutableArray *items = [[NSMutableArray alloc] init];
                    NSArray *products = checkOut[@"products"];
                    if(STLJudgeNSArray(products)){
                        for (NSDictionary *itemDic in products) {
                            GAEventItems *item = [[GAEventItems alloc] initWithItem_id:STLToString(itemDic[@"id"])
                                                        item_name:STLToString(itemDic[@"name"])
                                                       item_brand:STLToString(itemDic[@"brand"]) item_category:@""
                                                     item_variant:STLToString(itemDic[@"variant"])
                                                            price:STLToString(itemDic[@"price"])
                                                         quantity:@([itemDic[@"quantity"] integerValue])
                                                         currency:@"USD"
                                                            index:nil];
                            [items addObject:item];
                        }
                    }
                    [GATools logAddpaymentInfoWithValue:price coupon:@"" paymentType:STLToString(paymentType) items:items];
                }
            }
            
            ///输入支付信息
            if (STLJudgeNSDictionary(data) && [data[@"eventAction"] isEqualToString:@"payment"]) {
                [GATools logFillInPaymentInfo];
            }
            
            ///取消订单
            if (STLJudgeNSDictionary(data) && [data[@"eventAction"] isEqualToString:@"cancel_payment"]) {
                NSString *eventLabel = data[@"eventLabel"];
                [GATools logOrderCancelAlertWithAction:STLToString(eventLabel)];
            }
        }
    }
}

-(void)dealloc{
    WKUserContentController *userCC = self.webView.configuration.userContentController;
    [userCC removeScriptMessageHandlerForName:commonGAEvent];
}

@end

