//
//  OSSVMessageSystemDetailVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/22.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVMessageSystemDetailVC.h"
#import <WebKit/WebKit.h>

#define kMsgSystemDetailWebH  SCREEN_HEIGHT - 64

@interface OSSVMessageSystemDetailVC ()<WKNavigationDelegate>

@property (nonatomic, strong) UIScrollView  *bgScrollView;
@property (nonatomic, strong) UIView        *containerView;
@property (nonatomic, strong) UIView        *topView;
@property (nonatomic, strong) UIView        *topRangeView;
@property (nonatomic, strong) UILabel       *titleLabel;
@property (nonatomic, strong) UILabel       *timeLabel;
@property (nonatomic, strong) WKWebView     *webView;

@end

@implementation OSSVMessageSystemDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = OSSVThemesColors.col_F8F8F8;
    
    [self initView];
    [self initTest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView {
    
    [self.view addSubview:self.bgScrollView];
    [self.bgScrollView addSubview:self.containerView];
    self.containerView.backgroundColor = [UIColor whiteColor];
    [self.containerView addSubview:self.topView];
    [self.containerView addSubview:self.webView];
    
    [self.topView addSubview:self.topRangeView];
    [self.topView addSubview:self.titleLabel];
    [self.topView addSubview:self.timeLabel];
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@ Online Shopping",[OSSVLocaslHosstManager appName]];
    self.timeLabel.text = @"";
    
    [self.bgScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.bgScrollView);
        make.width.mas_equalTo(@(SCREEN_WIDTH));
    }];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.containerView);
    }];
    
    [self.topRangeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.topView);
        make.height.mas_equalTo(8);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.topView.mas_leading).mas_offset(16);
        make.trailing.mas_equalTo(self.topView.mas_trailing).mas_offset(-16);
        make.top.mas_equalTo(self.topView.mas_top).mas_offset(18);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(10);
        make.bottom.mas_equalTo(self.topView.mas_bottom).mas_offset(-10);
    }];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topView.mas_bottom).mas_offset(5);
        make.leading.mas_equalTo(self.containerView.mas_leading).mas_offset(10);
        make.trailing.mas_equalTo(self.containerView.mas_trailing).mas_offset(-10);
        make.bottom.mas_equalTo(self.containerView).mas_offset(-5);
        make.height.mas_equalTo(0);
    }];
}

- (void)initTest {
    
    //    NSString *imageTxt = @"<p>一个来自文件夹中的图像:</p><img src=\"https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=518955480,2376059867&fm=200&gp=0.jpg\" alt=\"GoogleChrome\" width=\"33\" height=\"32\"><p>一个来自W3Cschool教程的图像:</p><img src="" alt=\"w3cschool.cn\" width=\"247\" height=\"48\">";
    
    NSString *imageTxt = @"<p style=\"color:red;font-size:10px;\">一个来自文件夹中的图像:一个来自文件夹中的图像:一个来自文件夹中的图像:一个来自文件夹中的图像:一个来自文件夹中的图像:一个来自文件夹中的图像:一个来自文件夹中的图像:一个来自文件夹中的图像:一个来自文件夹中的图像:一个来自文件夹中的图像:一个来自文件夹中的图像:一个来自文件夹中的图像:一个来自文件夹中的图像:一个来自文件夹中的图像:一个来自文件夹中的图像:一个来自文件夹中的图像:一个来自文件夹中的图像:一个来自文件夹中的图像:一个来自文件夹中的图像:一个来自文件夹中的图像:一个来自文件夹中的图像:一个来自文件夹中的图像:一个来自文件夹中的图像:一个来自文件夹中的图像:</p><img src=\"https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=518955480,2376059867&fm=200&gp=0.jpg\" alt=\"GoogleChrome\" width=\"375\" height=\"32\"><p>一个教程的图像:这是一个树这是一个树这是一个树这是一个树这是一个树这是一个树这是一个树这是一个树这是一个树这是一个树</p><img src=\"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1529644327024&di=f49f4cf52b33f3c8000876f3b52fe07e&imgtype=0&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F0147885544dbe40000019ae944d59a.jpg%402o.jpg\" alt=\"w3cschool.cn\"> <p>一个教程的图像:这是一个树这是一个树这是一个树这是一个树这是一个树这是一个树这是一个树这是一个树这是一个树这是一个树</p>";
    
    
    //    NSMutableString *strTemplateHTML = [NSMutableString stringWithFormat:@"<html><head><style>img{max-width:%f;height:auto !important;width:auto !important;};</style></head><body style='margin:0; padding:0;'>%@</body></html>",SCREEN_WIDTH,imageTxt];
    
    NSMutableString *strTemplateHTML = [NSMutableString stringWithFormat:@"<html><head><style>img{max-width:%f;height:auto !important;width:auto !important;};</style></head><body style='margin:0; padding:0;'>%@</body></html>",SCREEN_WIDTH,imageTxt];
    
    
    [self.webView loadHTMLString:strTemplateHTML baseURL:nil];
}

#pragma mark - WKNavigationDelegate

//页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    // 此处js字符串采用scrollHeight而不是offsetHeight是因为后者并获取不到高度，看参考资料说是对于加载html字符串的情况下使用后者可以(@"document.getElementById(\"content\").offsetHeight;")，但如果是和我一样直接加载原站内容使用前者更合适
    [webView evaluateJavaScript:@"document.body.offsetHeight;" completionHandler:^(id _Nullable any, NSError * _Nullable error) {
        
        NSString *heightStr = [NSString stringWithFormat:@"%@",any];
        NSLog(@"------------- h: %@",heightStr);

        CGFloat contentH = heightStr.floatValue;
        [self.webView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(contentH);
        }];
    }];
}
#pragma mark - Loadlazy

- (UIScrollView *)bgScrollView {
    if (!_bgScrollView) {
        _bgScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _bgScrollView.showsVerticalScrollIndicator = NO;
    }
    return _bgScrollView;
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _topView;
}

- (UIView *)topRangeView {
    if (!_topRangeView) {
        _topRangeView = [[UIView alloc] initWithFrame:CGRectZero];
        _topRangeView.backgroundColor = OSSVThemesColors.col_F8F8F8;
    }
    return _topRangeView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = OSSVThemesColors.col_333333;
        _titleLabel.font = [UIFont boldSystemFontOfSize:18];
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.textColor = OSSVThemesColors.col_999999;
        _timeLabel.font = [UIFont systemFontOfSize:11];
    }
    return _timeLabel;
}

- (WKWebView *)webView {
    if (!_webView) {
        
        NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta); var imgs = document.getElementsByTagName('img');for (var i in imgs){imgs[i].style.maxWidth='100%';imgs[i].style.height='auto';}";
        
        WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        WKUserContentController *wkUController = [[WKUserContentController alloc] init];
        [wkUController addUserScript:wkUScript];
        
        WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
        wkWebConfig.userContentController = wkUController;
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0) configuration:wkWebConfig];
        _webView.navigationDelegate = self;
        _webView.scrollView.showsVerticalScrollIndicator = NO;
        _webView.scrollView.scrollEnabled = NO;
    }
    return _webView;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _containerView;
}
@end
