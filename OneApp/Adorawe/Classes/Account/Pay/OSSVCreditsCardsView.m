//
//  OSSVCreditsCardsView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/21.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCreditsCardsView.h"

#define TAG_ALERT_GOBACK    77780

@interface OSSVCreditsCardsView () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UIAlertViewDelegate, WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSDictionary *body;
@property (nonatomic,strong) WKWebView *webView;
@property (nonatomic,assign) STLOrderPayStatus status;
@property (nonatomic,strong) UIView *container;
//@property (nonatomic,strong) UIProgressView *progressView;
@property (nonatomic,strong) UIActivityIndicatorView *indicatorView;
@end

@implementation OSSVCreditsCardsView

#pragma mark - Life Cycle
- (void)dealloc
{
//    [self.webView removeObserver:self forKeyPath:@"loading" context:nil];
//    [self.webView removeObserver:self forKeyPath:@"title" context:nil];
//    [self.webView removeObserver:self forKeyPath:@"estimatedProgress" context:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self initViewWithFrame:frame];
    }
    return self;
}

#pragma mark - UI
- (void)initViewWithFrame:(CGRect)frame
{
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(5, 5, frame.size.width-10, frame.size.height-10)];
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    container.backgroundColor = [UIColor whiteColor];
    container.layer.cornerRadius = 5;
    container.clipsToBounds = YES;
    container.layer.borderColor = [UIColor lightGrayColor].CGColor;
    container.layer.borderWidth = 1;
    [self addSubview:container];
    _container = container;
    
    //    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, container.bounds.size.width, container.bounds.size.height-60)];
    WKWebView *webView = [WKWebView new];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    webView.backgroundColor = [UIColor whiteColor];
    webView.navigationDelegate = self;
    webView.UIDelegate = self;
    
    //隐藏滚动条
    webView.scrollView.showsVerticalScrollIndicator = NO;
    webView.scrollView.showsHorizontalScrollIndicator = NO;
    //修改颜色
    //    webView.scrollView.indicatorStyle=UIScrollViewIndicatorStyleWhite;
    //加载数据为空时的代理
    webView.scrollView.emptyDataSetSource = self;
    webView.scrollView.emptyDataSetDelegate = self;
    [container addSubview:webView];
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(@0);
        make.bottom.mas_equalTo(container.mas_bottom).offset(-60);
    }];
    self.webView = webView;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.tag = TAG_BUTTON_ACTION;
    //    btn.frame = EZRECT(10, self.bounds.size.height-10-50, self.bounds.size.width-30, 38);
    btn.backgroundColor = OSSVThemesColors.col_FE6902;
    btn.layer.cornerRadius = 4;
    if (APP_TYPE == 3) {
        [btn setTitle:STLLocalizedString_(@"cancel", nil) forState:0];
    } else {
        [btn setTitle:STLLocalizedString_(@"cancel", nil).uppercaseString forState:0];
    }
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    [btn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@10);
        make.trailing.equalTo(@(-10));
        make.height.equalTo(@38);
        make.bottom.equalTo(@(-12));
    }];
    
#if DEBUG
        //        UILabel *lbl = [[UILabel alloc] initWithFrame:EZRECT(5, 25, SCREEN_SIZE_WIDTH-10, 12)];
        UILabel *lbl = [UILabel new];
        lbl.textColor = [UIColor redColor];
        lbl.font = [UIFont systemFontOfSize:9];
        lbl.numberOfLines = 0;
        lbl.text = @"visa 4263 9826 4026 9299\n0218\n837";
        [self addSubview:lbl];
        [lbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(@10);
            make.trailing.equalTo(@(-10));
            make.height.equalTo(@40);
            make.top.equalTo(@10);
        }];
#endif
    
    // 添加KVO监听
//    [self.webView addObserver:self
//                   forKeyPath:@"loading"
//                      options:NSKeyValueObservingOptionNew
//                      context:nil];
//    [self.webView addObserver:self
//                   forKeyPath:@"title"
//                      options:NSKeyValueObservingOptionNew
//                      context:nil];
//    [self.webView addObserver:self
//                   forKeyPath:@"estimatedProgress"
//                      options:NSKeyValueObservingOptionNew
//                      context:nil];
    
    // 添加进入条
//    self.progressView = [[UIProgressView alloc] init];
//    self.progressView.progressTintColor = OSSVThemesColors.col_FE6902;
//    [container addSubview:self.progressView];
//    self.progressView.backgroundColor = [UIColor redColor];
//    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.top.trailing.equalTo(@0);
//        make.height.equalTo(@3);
//    }];
    [container addSubview:self.indicatorView];
    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(container);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
}

- (void)setUrl:(NSString *)url body:(NSDictionary *)body
{
    _url = url;
    _body = body;
    
//    NSURL *webUrl = [NSURL URLWithString:_url];
    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:webUrl  cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:60];
//    [request setHTTPMethod: @"POST"];
//    [request setHTTPBody: [_body dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    [self.webView loadRequest:request];
    
    if(body) {
        NSMutableString *resultString = [NSMutableString stringWithCapacity:0];
        [resultString appendString: [NSString stringWithFormat:@"<html><body onload=\"document.forms[0].submit()\">"
                          "<form method=\"post\" action=\"%@\">", url]];
        
        NSArray* keys = [body allKeys];
        for (int i = 0; i < [keys count]; i++)  {
            [resultString appendString: [NSString stringWithFormat:@"<input type=\"hidden\" name=\"%@\" value=\"%@\" >\n", keys[i], body[keys[i]]]];
        }
        
        [resultString appendString: @"</input></form></body>"];
        [resultString stringByAppendingString:@"<script>var f=document.getElementsByTagName('form')[0];f.submit();</script>\n"];
        [resultString appendString: @"</html>"];
        //NSLog(@"%@", s);
        [self.webView loadHTMLString:resultString baseURL:nil];
    }
}

#pragma mark - KVO
//- (void)observeValueForKeyPath:(NSString *)keyPath
//                      ofObject:(id)object
//                        change:(NSDictionary<NSString *,id> *)change
//                       context:(void *)context
//{
//    if ([keyPath isEqualToString:@"loading"]) {
//        NSLog(@"loading");
//    } else if ([keyPath isEqualToString:@"title"]) {
//        
//    } else if ([keyPath isEqualToString:@"estimatedProgress"]) {
//        NSLog(@"progress: %f", self.webView.estimatedProgress);
//        self.progressView.progress = self.webView.estimatedProgress;
//    }
//    
//    // 加载完成
//    if (!self.webView.loading) {
//        [UIView animateWithDuration:0.5 animations:^{
//            self.progressView.alpha = 0;
//            self.progressView.progress = 0;
//        }];
//    }else{
//        self.progressView.alpha = 1;
//    }
//}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    WKNavigationActionPolicy actionPolicy = WKNavigationActionPolicyAllow;
    NSURL *url = navigationAction.request.URL;
    NSString *strUrl = url.absoluteString.lowercaseString;
    STLLog(@"%@", url);
    
    self.status = STLOrderPayStatusUnknown;
    
    if ([strUrl containsString:@"paybck/paymentstatus"])
    {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        if (url.query) {
            NSArray *arr = [url.query componentsSeparatedByString:@"&"];
            for (NSString *str in arr) {
                if ([str rangeOfString:@"="].location != NSNotFound) {
                    NSString *key   = [str componentsSeparatedByString:@"="][0];
                    NSString *value = [str componentsSeparatedByString:@"="][1];
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

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    [self.indicatorView startAnimating];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    [self.indicatorView stopAnimating];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    [self.indicatorView stopAnimating];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    [self.indicatorView stopAnimating];
}

#pragma mark - WKUIDelegate
- (void)webViewDidClose:(WKWebView *)webView
{
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - alertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_ALERT_GOBACK) {
        if (buttonIndex == 1) {
            _status = STLOrderPayStatusCancel;
            [self closeThis];
        }else{
            
        }
    }
}

#pragma mark - WebViewAction
-(void)goBack{
    //LOG(@"%d",_status);
    if (_status != STLOrderPayStatusDone) {
        
        STLAlertViewController *alertController =  [STLAlertViewController alertControllerWithTitle: @"" message: STLLocalizedString_(@"cancelPay", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * doneAction = [UIAlertAction actionWithTitle:APP_TYPE ? STLLocalizedString_(@"no", nil) : STLLocalizedString_(@"no", nil).uppercaseString style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { }];
        [alertController addAction:doneAction];
        
        UIAlertAction * sdoneAction = [UIAlertAction actionWithTitle:APP_TYPE == 3 ? STLLocalizedString_(@"yes", nil) : STLLocalizedString_(@"yes", nil).uppercaseString style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            _status = STLOrderPayStatusCancel;
            [self closeThis];
        }];
        [alertController addAction:sdoneAction];
        
        [self.viewController presentViewController:alertController animated:YES completion:nil];
        
    }else{
        [self closeThis];
    }
}

-(void)closeThis
{
    [self removeFromSuperview];
    
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

@end
