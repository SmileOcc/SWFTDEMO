//
//  STLPinterestCtrl.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/16.
//  Copyright (c) 2016 XStarlinkProject. All rights reserved.
//

#import "STLPinterestCtrl.h"
#import <WebKit/WebKit.h>

@interface STLPinterestCtrl ()<WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler,UIAlertViewDelegate,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@property (nonatomic,assign) BOOL finished;
@property (nonatomic,strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, assign) BOOL firstEnter;

@end

@implementation STLPinterestCtrl
#pragma mark - Life cycle
-(void)dealloc
{
    _webView.UIDelegate = nil;
    _webView.navigationDelegate = nil;

    [self.webView removeObserver:self forKeyPath:@"loading"context:nil];
    [self.webView removeObserver:self forKeyPath:@"title"context:nil];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"context:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _firstEnter = YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _url = [[NSString alloc] init];
        _image = [[NSString alloc] init];
        _content = [[NSString alloc] init];
        _finished = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithTitle:APP_TYPE ? STLLocalizedString_(@"cancel",nil) : STLLocalizedString_(@"cancel",nil).uppercaseString
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(closeThis)];
    [self.navigationItem setRightBarButtonItem:btnCancel];

    [self configWKWebView];
    [self configProgressView];
    [self loadURL];
}

#pragma mark - init
- (void)configWKWebView
{
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    //注册js方法
    [config.userContentController addScriptMessageHandler:self name:@"webViewApp"];
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    webView.navigationDelegate = self;
    webView.UIDelegate = self;
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    webView.backgroundColor = [UIColor whiteColor];
    
    //隐藏滚动条
    webView.scrollView.showsVerticalScrollIndicator = NO;
    webView.scrollView.showsHorizontalScrollIndicator = NO;
    
    webView.allowsBackForwardNavigationGestures = true;
    //加载数据为空时的代理
    webView.scrollView.emptyDataSetSource = self;
    webView.scrollView.emptyDataSetDelegate = self;
    [self.view addSubview:webView];
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsZero);
    }];
    self.webView = webView;
}

- (void)configProgressView
{
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
    
    // 添加进入条
    self.progressView = [[UIProgressView alloc] init];
    [self.view addSubview:self.progressView];
    self.progressView.progressTintColor = [UIColor redColor];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake([UIScreen mainScreen].bounds.size.width, 2));
    }];
}


-(void)loadURL{

    NSString *strUrl = @"http://pinterest.com/pin/create/button/?url=";
    strUrl = [strUrl stringByAppendingString:_url];
    strUrl = [strUrl stringByAppendingString:@"&media="];
    strUrl = [strUrl stringByAppendingString:_image];
    strUrl = [strUrl stringByAppendingString:@"&description="];
    strUrl = [strUrl stringByAppendingString:_content];
    strUrl = URLENCODING(strUrl);
    NSURL *webUrl = [NSURL URLWithString:strUrl];
    NSURLRequest *request =[NSURLRequest requestWithURL:webUrl cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:60];
    [self.webView loadRequest:request];
    
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
        self.title = self.webView.title;
    } else if ([keyPath isEqualToString:@"estimatedProgress"]) {
        NSLog(@"progress: %f", self.webView.estimatedProgress);
        self.progressView.progress = self.webView.estimatedProgress;
    }
    // 加载完成
    if (!self.webView.loading) {
        [UIView animateWithDuration:0.5 animations:^{
            self.progressView.alpha = 0;
        }];
    }
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    [self closeThis];
}

#pragma mark - Action
-(void)closeThis{
    [self dismissViewControllerAnimated:YES completion:^{
        [_delegate dismissPinterest];
        
    }];
}

#pragma mark - Private method
-(NSString*)formStyleSheet{
    NSString *js = @""\
    "$('#Bookmarklet').css({'margin':'0','width':'100%','overflow':'hidden'});"\
    "$('#AddForm').css({'width':'100%','padding':'0','text-align':'center'});"\
    "$('.ImagePicker').css({'float':'none','margin':'0 auto','width':'300px','clear':'both','text-align':'center'});"\
    ""\
    "$('.PinForm').css({'margin':'0 auto','padding-top':'10px','clear':'both','width':'300px','text-align':'left'});"\
    "$('.BoardList').css({'margin':'0 auto','width':'300px'});"\
    "$('.DescriptionTextarea').css({'height':'120px'});"\
    "$('.PinForm').css({'margin':'0 auto','padding-top':'10px','clear':'both','width':'300px','text-align':'left'});"\
    "$('.NagDownloadApp').css({display:none;});";
    
    return js;
}

#pragma mark - WKNavigationDelegate
// 页面开始加载时调用 // 类似UIWebView的 -webViewDidStartLoad:
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"didStartProvisionalNavigation");
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"didCommitNavigation");
}
// 页面加载完成之后调用 // 类似 UIWebView 的 －webViewDidFinishLoad:
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"didFinishNavigation");
    if (webView.title.length > 0) {
        self.title = webView.title;
    }
    
    if (_finished) {
        _finished = NO;
        
        STLAlertViewController *alertController =  [STLAlertViewController alertControllerWithTitle: @"" message: @"Success" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * doneAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { }];
        [alertController addAction:doneAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
        
    }
}

// 页面加载失败时调用 // 类似 UIWebView 的- webView:didFailLoadWithError:
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
    NSLog(@"didFailProvisionalNavigation");
}

// 在发送请求之前，决定是否跳转 // 类似 UIWebView 的 -webView: shouldStartLoadWithRequest: navigationType:
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSLog(@"4.%@",navigationAction.request);
    
    NSString *requestString = navigationAction.request.URL.absoluteString;
    
    if ([requestString isEqualToString:@"http://m.pinterest.com/pin/create/button/"]) {
        _finished = YES;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
    
}

// 实现JS交互
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    [self.webView evaluateJavaScript:[self formStyleSheet] completionHandler:nil];
}

@end
