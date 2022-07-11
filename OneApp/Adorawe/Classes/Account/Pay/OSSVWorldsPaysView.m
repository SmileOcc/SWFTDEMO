//
//  OSSVWorldsPaysView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/21.
//  Copyright © 2017年 XStarlinkProject. All rights reserved.
//

#import "OSSVWorldsPaysView.h"

@interface OSSVWorldsPaysView () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UIAlertViewDelegate, WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSDictionary *body;
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIButton *cancelBtn;
//@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, assign) STLOrderPayStatus status;
@property (nonatomic,strong) UIActivityIndicatorView *indicatorView;
@end

#define TAG_ALERT_GOBACK    77780

@implementation OSSVWorldsPaysView

- (void)setUrl:(NSString *)url body:(NSDictionary *)body {
    _url = url; _body = body;
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
        [self.webView loadHTMLString:resultString baseURL:nil];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        
        self.container = [[UIView alloc] initWithFrame:CGRectMake(5, 5, frame.size.width-10, frame.size.height-10)];
        self.container.backgroundColor = [UIColor whiteColor];
        self.container.layer.cornerRadius = 5;
        self.container.clipsToBounds = YES;
        self.container.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.container.layer.borderWidth = 1;
        [self addSubview:self.container];
        
        [self.container mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self).insets(UIEdgeInsetsMake(5, 5, 5, 5));
        }];
        
        self.webView = [[WKWebView alloc] init];
        self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.webView.backgroundColor = [UIColor whiteColor];
        self.webView.navigationDelegate = self;
        self.webView.UIDelegate = self;
        self.webView.scrollView.showsVerticalScrollIndicator = NO;
        self.webView.scrollView.showsHorizontalScrollIndicator = NO;
        self.webView.scrollView.emptyDataSetSource = self;
        self.webView.scrollView.emptyDataSetDelegate = self;
        [self.container addSubview:self.webView];
        
        [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.mas_equalTo(self);
            make.bottom.mas_equalTo(self.container.mas_bottom).mas_offset(-60);
        }];
        
        self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.cancelBtn.backgroundColor = OSSVThemesColors.col_FE6902;
        self.cancelBtn.layer.cornerRadius = 4;
        if (APP_TYPE == 3) {
            [self.cancelBtn setTitle:STLLocalizedString_(@"cancel", nil) forState:0];
        } else {
            [self.cancelBtn setTitle:STLLocalizedString_(@"cancel", nil).uppercaseString forState:0];
        }
        self.cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        [self.cancelBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        [self.container addSubview:self.cancelBtn];
        
        [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(10);
            make.trailing.mas_equalTo(-10);
            make.height.mas_equalTo(38);
            make.bottom.mas_equalTo(-12);
        }];
        
#if DEBUG
            UIButton *lbl = [[UIButton alloc] init];
            [lbl setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [lbl setTitle:@"Visa : 4263 9826 4026 9299(点击复制) \nDate : 02/18 \nCode : 837" forState:UIControlStateNormal];
            lbl.titleLabel.numberOfLines = 0;
            lbl.titleLabel.font = [UIFont boldSystemFontOfSize:11];
            [lbl addTarget:self action:@selector(copyClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:lbl];
            
            [lbl mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(20);
                make.trailing.mas_equalTo(-10);
                make.top.mas_equalTo(20);
            }];
#endif

//        [self.webView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
//        [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
//        [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
//
//        self.progressView = [[UIProgressView alloc] init];
//        self.progressView.backgroundColor = [UIColor redColor];
//        self.progressView.progressTintColor = OSSVThemesColors.col_FE6902;
//        [self.container addSubview:self.progressView];
//
//        [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.leading.top.trailing.mas_equalTo(self);
//            make.height.mas_equalTo(3);
//        }];
        [self.container addSubview:self.indicatorView];
        [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self.container);
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
    }
    return self;
}

#pragma mark - 长按订单号可以copy
-(void)copyClick:(UIButton*) btnClick {
    [self becomeFirstResponder];
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = @"4263982640269299";
    [HUDManager showHUDWithMessage:@"复制成功"];
}

/*成为第一响应者*/
-(BOOL)canBecomeFirstResponder {
    return YES;
}

/*可以响应的方法*/
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return (action == @selector(copy:));
}

- (void)copy:(id)sender{}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
//    if ([keyPath isEqualToString:@"estimatedProgress"]) {
//        self.progressView.progress = self.webView.estimatedProgress;
//    }
//
//    if (!self.webView.loading) {
//        [UIView animateWithDuration:0.5 animations:^{
//            self.progressView.alpha = 0;
//            self.progressView.progress = 0;
//        }];
//    } else {
//        self.progressView.alpha = 1;
//    }
//}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    WKNavigationActionPolicy actionPolicy = WKNavigationActionPolicyAllow;
    NSURL *url = navigationAction.request.URL;
    NSString *strUrl = url.absoluteString.lowercaseString;
    STLLog(@"URL : %@", url);
    
    self.status = STLOrderPayStatusUnknown;
    if ([strUrl containsString:@"paybck/paymentstatus"]) {
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

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == TAG_ALERT_GOBACK) {
        if (buttonIndex == 1) {
            _status = STLOrderPayStatusCancel;
            [self closeThis];
        }else{
            
        }
    }
}

- (void)goBack {
    if (_status != STLOrderPayStatusDone) {

        STLAlertViewController *alertController =  [STLAlertViewController alertControllerWithTitle: @"" message: STLLocalizedString_(@"cancelPay", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * doneAction = [UIAlertAction actionWithTitle:APP_TYPE == 3 ? STLLocalizedString_(@"no", nil) : STLLocalizedString_(@"no", nil).uppercaseString style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { }];
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

- (void)closeThis {
    [self removeFromSuperview];
    if (_callBackBlock) {
        _callBackBlock(_status);
    }
}

- (void)dealloc {
//    [self.webView removeObserver:self forKeyPath:@"loading" context:nil];
//    [self.webView removeObserver:self forKeyPath:@"title" context:nil];
//    [self.webView removeObserver:self forKeyPath:@"estimatedProgress" context:nil];
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
