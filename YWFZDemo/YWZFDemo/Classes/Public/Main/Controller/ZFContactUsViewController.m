//
//  ZFUIWebViewVC.m
//  ZZZZZ
//
//  Created by YW on 2018/6/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFContactUsViewController.h"
#import "JumpModel.h"
#import "JumpManager.h"
#import "UIImage+ZFExtended.h"
#import "YWLocalHostManager.h"
#import "NSStringUtils.h"
#import "ZFProgressHUD.h"
#import "ZFLocalizationString.h"
#import "BannerManager.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"
#import <GGBrainKeeper/BrainKeeperManager.h>

@interface ZFContactUsViewController ()<UIWebViewDelegate>
@property (nonatomic, strong) UIWebView                   *webView;
@property (nonatomic, strong) NSMutableDictionary         *params;
@property (nonatomic, assign) BOOL                        isAddSMSCookie;
@property (nonatomic, strong) BKSpanModel                 *rpcSpan;
@end

@implementation ZFContactUsViewController

#pragma mark -===========生命周期方法===========

- (void)dealloc {
    YWLog(@"ZFContactUsViewController dealloc");
    self.webView.delegate = nil;
    [self.webView stopLoading];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[AccountManager sharedManager] clearWebCookie];
    [self initNavigationItem];
    [self initUIWebView];
    
    ShowLoadingToView(self.view);
    //添加Cookie, 加载文本页面
    [self addWebCookieAndRequestUrl:self.link_url];
}

#pragma mark -===========init UI===========

- (void)initUIWebView {
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}

- (void)initNavigationItem {
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"nav_arrow_left"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(goBackAction)];
}

- (void)goBackAction {
    if (self.webView.canGoBack) {
        [self.webView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] init];
        _webView.delegate = self;
        _webView.scalesPageToFit = YES;
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.scrollView.showsVerticalScrollIndicator = NO;
        _webView.scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _webView;
}

#pragma mark ===========添加WebView Cookie===========

/**
 * 添加Cookie, 加载文本页面
 */
- (void)addWebCookieAndRequestUrl:(NSString *)loadUrl
{
    if (loadUrl.length==0) return;
    
    //添加Web cookie
    [self addWebHTTPCookie];
    
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:loadUrl] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:60];
    
    if ([AccountManager sharedManager].isSignIn) {
        NSString *cookie = [self getCurrentCookie:loadUrl];
        if (cookie) {
            [request addValue:cookie forHTTPHeaderField:@"Cookie"];
        }
    } else {
        deleteZZZZZCookie();
    }
    [self.webView loadRequest:request];
}

/**
 * 添加Web cookie
 */
- (void)addWebHTTPCookie
{
    //cookie参数
    NSDictionary *cookies = @{
                              @"appLanguage" : ZFToString([ZFLocalizationString shareLocalizable].nomarLocalizable),
                              @"WEBF-email"  : ZFToString([AccountManager sharedManager].account.webf_email),
                              @"WEBF-email-sign" : ZFToString([AccountManager sharedManager].account.webf_email_sign),
                              @"WEBF-email-sign-expire" : ZFToString([AccountManager sharedManager].account.webf_email_sign_expire),
                              };
    
    NSMutableArray *cookieArray = [NSMutableArray array];
    NSMutableDictionary *cookiesDic = [NSMutableDictionary dictionary];
    cookiesDic[NSHTTPCookieExpires] = [NSDate dateWithTimeIntervalSinceNow:60*60*24];
    cookiesDic[NSHTTPCookieDiscard] = @"0";
    
    for (NSString *key in cookies.allKeys) {
        cookiesDic[NSHTTPCookieDomain] = @".ZZZZZ.com";
        cookiesDic[NSHTTPCookiePath] = @"/";
        cookiesDic[NSHTTPCookieName] = key;
        
        NSString *ZZZZZValue = cookies[key];
        if (!ZFIsEmptyString(ZZZZZValue)) {
            cookiesDic[NSHTTPCookieValue] = ZZZZZValue;
            NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:cookiesDic];
            [cookieArray addObject:cookie];
        }
        
        if (![YWLocalHostManager isPreRelease] && ![YWLocalHostManager isOnlineRelease]) {
            cookiesDic[NSHTTPCookieDomain] = @".egomsl.com";
            cookiesDic[NSHTTPCookiePath] = @"/";
            cookiesDic[NSHTTPCookieName] = key;
            
            NSString *egomslValue = cookies[key];
            if (!ZFIsEmptyString(egomslValue)) {
                cookiesDic[NSHTTPCookieValue] = egomslValue;
                NSHTTPCookie *egomslCookie = [[NSHTTPCookie alloc] initWithProperties:cookiesDic];
                [cookieArray addObject:egomslCookie];
            }
        }
    }
    
    if ([YWLocalHostManager isPreRelease]) {
        cookiesDic[NSHTTPCookieDomain] = @".ZZZZZ.com";
        cookiesDic[NSHTTPCookiePath] = @"/";
        cookiesDic[NSHTTPCookieName] = @"staging";
        cookiesDic[NSHTTPCookieValue] = @"true";
        NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:cookiesDic];
        [cookieArray addObject:cookie];
    }
    
    if (cookieArray.count>0 && self.link_url.length>0 && [self.link_url hasPrefix:@"http"]) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookieArray forURL:[NSURL URLWithString:self.link_url] mainDocumentURL:nil];
    }
}

/**
 * 获取已设置的Cookie
 */
- (NSString *)getCurrentCookie:(NSString *)loadUrl {
    NSMutableString *cookieStr = [[NSMutableString alloc] init];
    NSArray *array =  [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:loadUrl]];
    if ([array count] > 0) {
        for (NSHTTPCookie *cookie in array) {
            [cookieStr appendFormat:@"%@=%@;",cookie.name,cookie.value];
        }
        //删除最后一个分号 “；”
        [cookieStr deleteCharactersInRange:NSMakeRange(cookieStr.length - 1, 1)];
    }
    
    if ([loadUrl rangeOfString:@"ticket/ticket"].location != NSNotFound) {
        _isAddSMSCookie = YES;
    }
    return cookieStr;
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
    YWLog(@"\n==================== 参数 =====================\n👉: %@", self.params);
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
        @weakify(self)
        [self judgePresentLoginVCCompletion:^{
            @strongify(self)
            [self postLoginInfoToH5];
        }];
        
    } else if ([NullFilter(_params[@"isAlert"]) isEqualToString:@"0"]) {
        if ([[AccountManager sharedManager] isSignIn]) {
            [self postLoginInfoToH5];
        }
    }
}

/**
 * 重新跳转H5传过来的链接
 */
- (void)postLoginInfoToH5 {
    if (ZFGetStringFromDict(_params, @"redirect").length>0) {
        NSString *reload_ref = ZFGetStringFromDict(_params, @"redirect");
        if ([reload_ref hasPrefix:@"http"]) {
            [self addWebCookieAndRequestUrl:reload_ref];
        }
    }
}

/**
 * 判断下载PDF文件保存到相册
 */
- (void)judgeDownloadFileSaveToAlbum:(NSString *)filePath
{
    if (!filePath) return;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *fileData = [NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]];
        if ([fileData isKindOfClass:[NSData class]]) {
            UIImage *image = [UIImage fetchPDFImageWithData:fileData];
            if ([image isKindOfClass:[UIImage class]]) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    ShowLoadingToView(self.view);
                    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                });
            }
        }
    });
}

/**
 * 保存图片到相册代理, 然后走deeplink跳转
 */
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    HideLoadingFromView(self.view);
    YWLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
    if (!error) {
        ShowToastToViewWithText(self.view, ZFLocalizedString(@"ZFPayStateSuccess", nil));
    }
}

#pragma mark - UIWebViewDelegate methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    // 防止加载内部js一直不走finish方法
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        HideLoadingFromView(self.view);
    });
    
    YWLog(@"request url == %@\n\n",request.URL);
    YWLog(@"Request Header == %@ \n\n",request.allHTTPHeaderFields);
    NSURL *tempUrl = request.URL;
    
    // 统计代码
    if ([tempUrl.absoluteString.lowercaseString isEqualToString:self.link_url.lowercaseString]) {
        // 链路代码
        self.rpcSpan = [[BrainKeeperManager sharedManager] startNetWithPageName:nil event:nil target:self url:self.link_url parentId:nil isNew:NO isChained:NO];
    }
    
    //判断在客服页面需要下载PDF文件保存到相册
    if ([tempUrl.absoluteString containsString:@"get-download-rma-file"]) {
        [self judgeDownloadFileSaveToAlbum:tempUrl.absoluteString];
    }
    
    // 如果请求头部不包含cookie值, 就强制设置Cookie
    if ([AccountManager sharedManager].isSignIn &&
        [tempUrl.absoluteString rangeOfString:@"ticket/ticket"].location != NSNotFound &&
          !_isAddSMSCookie) {
             NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:tempUrl];
             NSString *cookie = [self getCurrentCookie:tempUrl.absoluteString];
             [request addValue:cookie forHTTPHeaderField:@"Cookie"];
             [webView loadRequest:request];
            return NO;
    }
    
    //保存url参数
    [self parseURLParams:tempUrl];
    
    NSString *scheme = [tempUrl scheme];
    if ([scheme isEqualToString:kZZZZZScheme]) {
        [self deeplinkHandle];
        return NO;
        
    } else if ([scheme isEqualToString:@"webaction"]) {
        if ([tempUrl.host isEqualToString:@"login"]){
            [self jsLoginHandle];
            
        } else if ([tempUrl.host isEqualToString:@"popBack"]){
            [self goBackAction];
        }
        return NO;
    }
    return YES;
}

/**
 * 取加载html文件的标题名
 */
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *strUrl = webView.request.URL.absoluteString.lowercaseString;
    if ([strUrl isEqualToString:self.link_url.lowercaseString]) {
        // 链路代码  网页加载不需要传render
        if (self.rpcSpan) {
            [self.rpcSpan end];
            [[BrainKeeperManager sharedManager] subTrackWithPageName:nil event:nil target:self];
        }
    }
    HideLoadingFromView(self.view);
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (title) {
        self.title = title;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSString *strUrl = webView.request.URL.absoluteString.lowercaseString;
    if ([strUrl isEqualToString:self.link_url.lowercaseString]) {
        // 链路代码  网页加载不需要传render
        if (self.rpcSpan) {
            [self.rpcSpan endWithError:error.localizedDescription statusCode:@""];
            [[BrainKeeperManager sharedManager] subTrackWithPageName:nil event:nil target:self];
        }
    }
    HideLoadingFromView(self.view);
}

#pragma mark - Getter
- (NSMutableDictionary *)params {
    if (!_params) {
        _params = [NSMutableDictionary dictionary];
    }
    return  _params;
}

@end
