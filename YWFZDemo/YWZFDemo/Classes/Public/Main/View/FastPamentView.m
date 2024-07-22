//
//  FastPamentView.m
//  ZZZZZ
//
//  Created by DBP on 17/3/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "FastPamentView.h"
#import "YWLocalHostManager.h"
#import "ZFThemeManager.h"
#import "ZFProgressHUD.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"

@interface FastPamentView () <UIAlertViewDelegate, WKNavigationDelegate, WKUIDelegate>
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIButton *closeBtn;
@end

@implementation FastPamentView

#pragma mark - Life Cycle
- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"loading" context:nil];
    [self.webView removeObserver:self forKeyPath:@"title" context:nil];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress" context:nil];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initViewWithFrame:frame];
    }
    return self;
}

#pragma mark - UI
- (void)initViewWithFrame:(CGRect)frame {
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
    self.container = [[UIView alloc] initWithFrame:CGRectZero];
    self.container.backgroundColor = [UIColor whiteColor];
    self.container.layer.cornerRadius = 5;
    self.container.clipsToBounds = YES;
    self.container.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.container.layer.borderWidth = 1;
    [self addSubview:self.container];
    
    [self.container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).with.insets(UIEdgeInsetsMake(5, 5, 5, 5));
    }];
    
    // 添加进入条
    self.progressView = [[UIProgressView alloc] init];
    self.progressView.progressTintColor = ZFCOLOR(254, 105, 2, 1.0);
    [self.container addSubview:self.progressView];
    self.progressView.backgroundColor = [UIColor redColor];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self.container);
        make.height.mas_equalTo(@3);
    }];
    
    self.webView = [WKWebView new];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    
    //隐藏滚动条
    self.webView.scrollView.showsVerticalScrollIndicator = NO;
    self.webView.scrollView.showsHorizontalScrollIndicator = NO;
    //修改颜色
    [self.container addSubview:self.webView];
    [self.webView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.container).with.insets(UIEdgeInsetsMake(3, 0, 0, 0));
    }];
    
    //#if 0
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeBtn.backgroundColor = ZFCOLOR(254, 105, 2, 1.0);
    self.closeBtn.backgroundColor = [UIColor clearColor];
    [self.closeBtn setImage:[UIImage imageNamed:@"cancle"] forState:UIControlStateNormal];
    [self.closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.container addSubview:self.closeBtn];
    [self.closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.container.mas_leading).offset(5);
        make.width.height.mas_equalTo(@25);
        make.top.mas_equalTo(self.container.mas_top).offset(10);
    }];
    
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
        
        [self addSubview:lblname];
        [lblname mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.closeBtn.mas_trailing).offset(10);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-10);
            make.height.mas_equalTo(@20);
            make.top.mas_equalTo(self.mas_top).offset(10);
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
        
        [self addSubview:lblpass];
        [lblpass mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.closeBtn.mas_trailing).offset(10);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-10);
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
    
    
}

- (void)setUrl:(NSString *)url {
    _url = url;
    // 预发布设置
    if ([YWLocalHostManager isPreRelease]) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:@[globaleZZZZZHTTPCookie()] forURL:[NSURL URLWithString:url] mainDocumentURL:nil];
        
        NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:60];
        
        [request addValue:@"staging=true;" forHTTPHeaderField:@"Cookie"];
        [self.webView loadRequest:request];
    }else{
        NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:60];
        [self.webView loadRequest:request];
    }
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
    [self dismiss];
}

- (void)show {
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo([UIApplication sharedApplication].keyWindow).with.insets(UIEdgeInsetsMake(20, 0, 0, 0));
    }];
    
    CGFloat duration = 0.3;
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.values = @[@(0.8), @(1), @(1.05), @(1)];
    animation.keyTimes = @[@(0), @(0.3), @(0.5), @(1.0)];
    animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    animation.duration = duration;
    [self.layer addAnimation:animation forKey:@"bouce"];
}

- (void)dismiss {
    CGFloat duration = 0.2;
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.container.transform = CGAffineTransformMakeScale(0.4, 0.4);
    } completion:^(BOOL finished) {
        self.container.transform = CGAffineTransformMakeScale(1, 1);
    }];
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
    NSURL *url = navigationAction.request.URL;
    NSString *strUrl = url.absoluteString.lowercaseString;
    YWLog(@"#####:%@", strUrl);
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
        if (self.paymentCallBackBlock) {
            self.paymentCallBackBlock(token,payid);
        }
        [self dismiss];
    }else if ([strUrl containsString:QUICK_FILTER_CANCEL_URL]) {
        // 用户点击了取消
        [self dismiss];
    }
    decisionHandler(WKNavigationActionPolicyAllow);

}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    if ([navigationResponse.response isKindOfClass:[NSHTTPURLResponse class]]) {
        
        NSHTTPURLResponse * response = (NSHTTPURLResponse *)navigationResponse.response;
        if (response.statusCode != 200) {
        }
    }
    
    decisionHandler(WKNavigationResponsePolicyAllow);
    YWLog(@"%s", __FUNCTION__);
}

#pragma mark - WKUIDelegate
- (void)webViewDidClose:(WKWebView *)webView {
    YWLog(@"%s", __FUNCTION__);
}

//1.创建一个新的WebVeiw
-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}


@end
