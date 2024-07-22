//
//  AlertWebView.m
//  ZZZZZ
//
//  Created by DBP on 17/3/8.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "AlertWebView.h"
#import <WebKit/WebKit.h>
#import "YWLocalHostManager.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"

@interface AlertWebView () <WKNavigationDelegate, WKUIDelegate>
@property (nonatomic, strong) UIView *backGroundView;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIButton *okBtn;
@property (nonatomic, strong) UIProgressView *progressView;
@end

@implementation AlertWebView

- (void)show {
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo([UIApplication sharedApplication].keyWindow).with.insets(UIEdgeInsetsZero);
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
    [self removeFromSuperview];
}

#pragma maek - init
- (instancetype)initWithUrlStr:(NSString *)urlStr {
    if (self = [super initWithFrame:CGRectZero]) {
        self.backgroundColor = ZFCOLOR(0,0,0,0.6);
        
        [self addSubview:self.backGroundView];
        [self.backGroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(40, 10, 40, 10));
        }];
        
        [self.backGroundView addSubview:self.progressView];
        [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.trailing.mas_equalTo(self.backGroundView);
            make.height.mas_equalTo(@3);
        }];
        
        [self.backGroundView addSubview:self.webView];
        [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(5, 10, 60, 10));
        }];
        
        [self.backGroundView addSubview:self.okBtn];
        [self.okBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.backGroundView.mas_leading).offset(10);
            make.trailing.mas_equalTo(self.backGroundView.mas_trailing).offset(-10);
            make.top.mas_equalTo(self.webView.mas_bottom).offset(10);
            make.height.mas_equalTo(40);
        }];
        
        if ([YWLocalHostManager isPreRelease]) {            
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:@[globaleZZZZZHTTPCookie()] forURL:[NSURL URLWithString:urlStr] mainDocumentURL:nil];
            
            NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:60];
            
            [request addValue:@"staging=true;" forHTTPHeaderField:@"Cookie"];
            [self.webView loadRequest:request];
        }else{
            NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:60];
            [self.webView loadRequest:request];
        }
    }
    return self;
}

// 页面加载完成之后调用
//- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation { // 类似 UIWebView 的 －webViewDidFinishLoad:
//    YWLog(@"didFinishNavigation");
//    NSString *doc = @"document.body.outerHTML";
//    [webView evaluateJavaScript:doc
//                     completionHandler:^(id _Nullable htmlStr, NSError * _Nullable error) {
//                         if (error) {
//                             NSLog(@"JSError:%@",error);
//                         }
//                         NSLog(@"html:%@",htmlStr);
//                     }] ;
//    
//}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        YWLog(@"progress: %f", self.webView.estimatedProgress);
        self.progressView.progress = self.webView.estimatedProgress;
    }
    
    // 加载完成
    if (!self.webView.loading || self.webView.estimatedProgress == 1.0) {
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

#pragma mark - Click

- (void)okBtnClick {
    [self removeFromSuperview];
}

#pragma mark - lazy
- (UIView *)backGroundView {
    if (!_backGroundView) {
        _backGroundView = [[UIView alloc] init];
        _backGroundView.backgroundColor = [UIColor whiteColor];
    }
    return _backGroundView;
}

- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] init];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _webView.backgroundColor = [UIColor whiteColor];
        //隐藏滚动条
        _webView.scrollView.showsVerticalScrollIndicator = NO;
        _webView.scrollView.showsHorizontalScrollIndicator = NO;
        [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    }
    return _webView;
}

- (UIButton *)okBtn {
    if (!_okBtn) {
        _okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _okBtn.backgroundColor = [UIColor blackColor];
        [_okBtn setTitle:ZFLocalizedString(@"OK", nil) forState:UIControlStateNormal];
        [_okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _okBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_okBtn addTarget:self action:@selector(okBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _okBtn;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
        _progressView.progressTintColor = ZFCOLOR(254, 105, 2, 1.0);
        _progressView.backgroundColor = [UIColor redColor];
    }
    return _progressView;
}

- (void)dealloc
{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress" context:nil];
    
}
@end
