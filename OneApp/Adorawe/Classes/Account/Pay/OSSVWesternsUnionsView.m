//
//  OSSVWesternsUnionsView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/26.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVWesternsUnionsView.h"

@interface OSSVWesternsUnionsView ()<DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UIAlertViewDelegate, WKNavigationDelegate, WKUIDelegate>

@property (nonatomic,weak) WKWebView *webView;

@property (nonatomic,weak) UIView *container;

@property (nonatomic,strong) UIProgressView *progressView;

@end

#define TAG_ALERT_GOBACK    77777
#define TAG_BUTTON_ACTION   77778
#define TAG_CONTAINER       77779

@implementation OSSVWesternsUnionsView

/*========================================分割线======================================*/

#pragma mark - Life Cycle
- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"loading" context:nil];
    [self.webView removeObserver:self forKeyPath:@"title" context:nil];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress" context:nil];
}

/*========================================分割线======================================*/

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initViewWithFrame:frame];
    }
    return self;
}

/*========================================分割线======================================*/

#pragma mark - UI
- (void)initViewWithFrame:(CGRect)frame {
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(5, 5, frame.size.width-10, frame.size.height-10)];
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    container.backgroundColor = [UIColor whiteColor];
    container.layer.cornerRadius = 5;
    container.clipsToBounds = YES;
    container.layer.borderColor = [UIColor lightGrayColor].CGColor;
    container.layer.borderWidth = 1;
    container.tag = TAG_CONTAINER;
    [self addSubview:container];
    self.container = container;
    
    /*WebView*/
//    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, container.bounds.size.width, container.bounds.size.height-60)];
    WKWebView *webView = [WKWebView new];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    webView.backgroundColor = [UIColor whiteColor];
    webView.navigationDelegate = self;
    webView.UIDelegate = self;
    webView.scrollView.showsVerticalScrollIndicator = NO;
    webView.scrollView.showsHorizontalScrollIndicator = NO;
    webView.scrollView.emptyDataSetSource = self;    //加载数据为空时的代理
    webView.scrollView.emptyDataSetDelegate = self;
    [container addSubview:webView];
    
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(@0);
        make.bottom.mas_equalTo(container.mas_bottom).offset(0);
    }];
    self.webView = webView;
    
    /*底部取消按钮*/
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.tag = TAG_BUTTON_ACTION;
//    btn.backgroundColor = OSSVThemesColors.col_FE6902;
//    btn.layer.cornerRadius = 4;
//    [btn setTitle:@"Cancel" forState:0];
//    btn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
//    [btn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
//    [container addSubview:btn];
//    
//    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(@10);
//        make.trailing.equalTo(@(-10));
//        make.height.equalTo(@38);
//        make.bottom.equalTo(@(-12));
//    }];
    
    /*添加KVO监听*/
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
    
    /*添加进入条*/
    self.progressView = [[UIProgressView alloc] init];
    self.progressView.progressTintColor = OSSVThemesColors.col_FE6902;
    [container addSubview:self.progressView];
    self.progressView.backgroundColor = [UIColor redColor];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.equalTo(@0);
        make.height.equalTo(@3);
    }];
}

/*========================================分割线======================================*/

#pragma mark - 加载外部传进来的链接
- (void)setUrl:(NSString *)url {
    _url = url;
    NSURL *webUrl = [NSURL URLWithString:_url];
    NSURLRequest *request =[NSURLRequest requestWithURL:webUrl cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:60];
    [self.webView loadRequest:request];
}

/*========================================分割线======================================*/

//#pragma mark - 加载外部传进来的链接
//-(void)goBack{
//    NSString *strMsg = @"Are you sure you want to leave?";
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:strMsg delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
//    alert.tag = TAG_ALERT_GOBACK;
//    [alert show];
//}

/*========================================分割线======================================*/

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"loading"]) {
        NSLog(@"loading");
    } else if ([keyPath isEqualToString:@"title"]) {
        
    } else if ([keyPath isEqualToString:@"estimatedProgress"]) {
        NSLog(@"progress: %f", self.webView.estimatedProgress);
        self.progressView.progress = self.webView.estimatedProgress;
    }
    
    // 加载完成
    if (!self.webView.loading) {
        [UIView animateWithDuration:0.5 animations:^{
            self.progressView.alpha = 0;
            self.progressView.progress = 0;
        }];
    }else{
        self.progressView.alpha = 1;
    }
}

/*========================================分割线======================================*/

//#pragma mark - alertViewDelegate
//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (alertView.tag == TAG_ALERT_GOBACK) {
//        if (buttonIndex == 1) {
//            [self removeFromSuperview];
//            if (_block) {
//                _block();
//            }
//        }else{
//            
//        }
//    }
//}

/*========================================分割线======================================*/

#pragma mark - DZNEmptyDataSetSource
- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
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

/*========================================分割线======================================*/

#pragma mark - DZNEmptyDataSetDelegate
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    return YES;
}

- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView {
    return YES;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
}

/*========================================分割线======================================*/

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    WKNavigationActionPolicy actionPolicy = WKNavigationActionPolicyAllow;
    NSURL *url = navigationAction.request.URL;
    NSString *strUrl = url.absoluteString.lowercaseString;
    STLLog(@"%@", url);
//    webaction://checkMyOrder?Order=checkMyOrder 跳转我的订单列表
    if ([url.host isEqualToString:@"checkMyOrder"])
    {
        [self removeFromSuperview];
        if (_block) {
            _block();
        }
    }
    
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
    }
    decisionHandler(actionPolicy);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
    STLLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    STLLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    STLLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    STLLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    STLLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    STLLog(@"%s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    
}

/*========================================分割线======================================*/

#pragma mark - WKUIDelegate
- (void)webViewDidClose:(WKWebView *)webView {
    STLLog(@"%s", __FUNCTION__);
}

/*========================================分割线======================================*/

@end
