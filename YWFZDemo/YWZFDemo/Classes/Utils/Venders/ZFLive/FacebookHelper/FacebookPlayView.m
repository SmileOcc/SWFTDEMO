//
//  FacebookPlayView.m
//  ZZZZZ
//
//  Created by YW on 2019/4/3.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "FacebookPlayView.h"
#import "WKWebViewJavascriptBridge.h"
#import "Constants.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "ZFProgressHUD.h"


#define FacebookOrigin @"https://www.facebook.com"
#define FacebookOriginVideos @"https://www.facebook.com/facebook/videos/"
#define FacebookEmbedVideos @"https://www.facebook.com/video/embed?video_id="

@interface FacebookPlayView()<WKUIDelegate,WKNavigationDelegate,UIGestureRecognizerDelegate,WKScriptMessageHandler,ZFVideoLiveOperateDelegate>

@property (nonatomic,strong) WKWebViewJavascriptBridge      *bridge;

@property (nonatomic, assign) CGFloat                       durationTime;



@end

@implementation FacebookPlayView
@synthesize videoDetailID = _videoDetailID;

//播放器销毁
- (void)dealloc {
    YWLog(@"---------- FacebookPlayView dealloc");
    if (self.webView) {
        self.webView.navigationDelegate = nil;
        self.webView.UIDelegate = nil;
        [self.webView removeFromSuperview];
        self.webView = nil;
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame webView:[self seetingWebView]];
    return self;
}


- (void)startVideo {
    if (!ZFIsEmptyString(self.liveVideoID)) {
        [self webViewEvaluateJavaScript:[self jsPlayVideo]];
        self.currentPlayerState = PlayerStatePlaying;
        [self.operateView playViewState:YES];
    }
}

- (void)pauseVideo {
    if (!ZFIsEmptyString(self.liveVideoID)) {
        [self webViewEvaluateJavaScript:[self jsPauseVideo]];
        [self.operateView playViewState:NO];
        self.currentPlayerState = PlayerStatePaused;
    }
}


- (BOOL)basePlayVideoWithVideoID:(NSString *)videoID {
    
    self.liveVideoID = videoID;
    self.operateView.liveVideoAddress = ZFToString(videoID);
    
    NSString *playVideoUrl = FacebookOriginVideos;
    if (!ZFIsEmptyString(self.liveVideoID)) {
        playVideoUrl = [NSString stringWithFormat:@"%@%@",FacebookEmbedVideos,self.liveVideoID];
    }
    YWLog(@"---FB url: %@",playVideoUrl);
    //    @"https://www.facebook.com/video/embed?video_id=10153231379946729"
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:playVideoUrl]]];
    return YES;
}

- (void)baseSeekToSecondsPlayVideo:(float)seconds {
    [self webViewEvaluateJavaScript:[self seekTo:seconds]];
}


#pragma mark - Property Method

- (void)removeAllJavaScriptMethod
{
    [self.webView.configuration.userContentController removeAllUserScripts];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"videoStart"];
}


- (WKWebView *)seetingWebView {
    WKWebViewConfiguration *configuration = [[NSClassFromString(@"WKWebViewConfiguration") alloc] init];
    NSString *jsStr = @"var meta=document.createElement('meta');meta.setAttribute('name','viewport');meta.setAttribute('content','width=device-width');document.getElementsByTagName('head')[0].appendChild(meta);";
    //注入js video代码
    jsStr = [NSString stringWithFormat:@"%@var video=%@;var playing=false;",jsStr, [self gainVideoElement]];
    //注入js 隐藏工具栏代码
    jsStr = [NSString stringWithFormat:@"%@%@", jsStr, [self hiddenFaceBookTools]];
    //注入js 设置背景代码
    jsStr = [NSString stringWithFormat:@"%@%@", jsStr, [self jsVideoBackgroundColor]];
    //注入js 窗口播放代码
    jsStr = [NSString stringWithFormat:@"%@%@", jsStr, [self inlinePlayVideo:YES]];
    //注入js 适配播放窗口个代码
    jsStr = [NSString stringWithFormat:@"%@%@", jsStr, [self videoObjectFit]];
    //注入js 设置播放时间代码
    jsStr = [NSString stringWithFormat:@"%@%@", jsStr, [self jsFunctionSeekTo]];
    //注入js 播放video代码
    jsStr = [NSString stringWithFormat:@"%@%@", jsStr, [self jsFunctionPlayVideo]];
    //注入js 暂停video代码
    jsStr = [NSString stringWithFormat:@"%@%@", jsStr, [self jsFunctionPauseVideo]];
    //注入js 获取当前播放时间代码
    jsStr = [NSString stringWithFormat:@"%@%@", jsStr, [self jsFunctionGetCurrentTime]];
    //注入js 获取当前视频是否可播放状态
    jsStr = [NSString stringWithFormat:@"%@%@", jsStr, [self jsFunctionGetVideoReadyStatus]];
    //注入js 获取当前播放器播放状态
    jsStr = [NSString stringWithFormat:@"%@%@", jsStr, [self jsFunctionGetVideoPlayStatus]];
    //注入js 获取播放video的总时长
    jsStr = [NSString stringWithFormat:@"%@%@", jsStr, [self jsFunctionGetVideoTotalTime]];
    //注入js 监听video播放
    jsStr = [NSString stringWithFormat:@"%@%@", jsStr, [self jsFunctionAddEventVideoUpdateTime]];
    //        jsStr = @"";
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:jsStr injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    [userContentController addScriptMessageHandler:self name:@"videoStart"];
    configuration.userContentController = userContentController;
    [configuration.userContentController addUserScript:userScript];
    WKPreferences *prefer = [[WKPreferences alloc] init];
    prefer.javaScriptEnabled = YES;
    prefer.javaScriptCanOpenWindowsAutomatically = YES;
    configuration.preferences = prefer;
    configuration.allowsInlineMediaPlayback = YES;//控制视频播放默认不是全屏播放
    if (kiOSSystemVersion >= 10 ) {
        configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeAll;
    }
    WKWebView *tempWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) configuration:configuration];
    tempWebView.backgroundColor = [UIColor blackColor];
    tempWebView.scrollView.scrollEnabled = NO;
    for (UIView *view in tempWebView.subviews) {
        view.backgroundColor = [UIColor blackColor];
    }
    tempWebView.UIDelegate= self;
    tempWebView.navigationDelegate = self;
    tempWebView.userInteractionEnabled = NO;
    tempWebView.alpha = 0.0;
    
    return tempWebView;
}



#pragma mark - webView UI delegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self startVideo];
    [self.operateView videoIsCanPlay];
    
    // 加载时有白屏
    self.webView.alpha = 0.0;
    self.webView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.webView.alpha = 1.0;
    }];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    YWLog(@"----kk %@",error);
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    //ShowToastToViewWithText(nil, message);
    completionHandler();
}

- (void)webViewEvaluateJavaScriptHasBlock:(NSString *)jsFunction completion:(void (^ _Nullable)(_Nullable id params, NSError * _Nullable error))completion
{
    [self.webView evaluateJavaScript:jsFunction completionHandler:^(id _Nullable params, NSError * _Nullable error) {
        if (completion) {
            completion(params, error);
        }
    }];
}

- (void)webViewEvaluateJavaScript:(NSString *)jsFunction
{
    [self webViewEvaluateJavaScriptHasBlock:jsFunction completion:^(id _Nullable params, NSError * _Nullable error) {
        if (error) {
            YWLog(@"%@", error);
        }
    }];
}

#pragma mark - js call back

/// 实时返回时间
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([message.name isEqualToString:@"videoStart"]) {
        if (ZFJudgeNSDictionary(message.body)) {
            NSString *startTime = ZFToString(message.body[@"currentTime"]);
            NSString *endTime = ZFToString(message.body[@"totalTime"]);
            if ([startTime isEqualToString:endTime]) {
                [self.operateView startTime:startTime endTime:endTime isEnd:YES];
            } else {
                [self.operateView startTime:startTime endTime:endTime isEnd:NO];
            }
        }
    }
}

#pragma mark - 客户端调用代码

//开始播放，或者暂停
- (NSString *)jsPlayVideo
{
    return @"jsPlayVideo()";
}

//开始播放，或者暂停
- (NSString *)jsPauseVideo
{
    return @"jsPauseVideo()";
}


//跳转到某个时间播放 必须大于等于0
- (NSString *)seekTo:(NSInteger)seconds
{
    if (seconds < 0) {
        return @"seekTo(seconds)";
    }
    return [NSString stringWithFormat:@"seekTo(%d)", seconds];
}

//获取当前播放时间
- (NSString *)getCurrentTime
{
    return @"getCurrentTime()";
}

//获取是否可以播放状态  =4时可以播放, =0不可播放
- (NSString *)getVideoReadyStatus
{
    return @"getFVideoStatus()";
}

//获取播放器当前播放状态 0=playing 1=暂停
- (NSString *)getVideoPlayStatus
{
    return @"getVideoPlayStatus()";
}

//获取视频总时长 单位是 秒
- (NSString *)getVideoTotalTime
{
    return @"getVideoTotalTime()";
}

#pragma mark - js 代码

//隐藏facebook播放栏
- (NSString *)hiddenFaceBookTools
{
    return @"var originalController=document.getElementById('u_0_3');originalController.style.display='none';";
}

//设置背景色
- (NSString *)jsVideoBackgroundColor
{
    return @"document.body.style.backgroundColor='black';";
}

//设置小窗播放
- (NSString *)inlinePlayVideo:(BOOL)isInline
{
    NSString *jsIsInline = @"true";
    if (!isInline) {
        jsIsInline = @"false";
    }
    return [NSString stringWithFormat:@"video.setAttribute('playsinline','%@');", jsIsInline];
}

//设置video播放适配条件
- (NSString *)videoObjectFit
{
    return [NSString stringWithFormat:@"video.setAttribute('style','object-fit:contain');"];
}

//播放video or 暂停video
- (NSString *)jsFunctionPlayVideo
{
    return [NSString stringWithFormat:@"function %@\
                                        {\
                                        playing = true;\
                                        video.play();\
                                        };", [self jsPlayVideo]];
}

//播放video or 暂停video
- (NSString *)jsFunctionPauseVideo
{
    return [NSString stringWithFormat:@"function %@\
            {\
            playing = false;\
            video.pause();\
            };", [self jsPauseVideo]];
}


//跳转到播放时间js代码
- (NSString *)jsFunctionSeekTo
{
    return [NSString stringWithFormat:@"function %@\
                                        {\
                                          video.currentTime=seconds;\
                                        };", [self seekTo:-1]];
}

//获取当前播放时间
- (NSString *)jsFunctionGetCurrentTime
{
    return [NSString stringWithFormat:@"function %@\
                                        {\
                                        return video.currentTime;\
                                        };", [self getCurrentTime]];
}

//获取视频源是否可以播放状态
- (NSString *)jsFunctionGetVideoReadyStatus
{
    return [NSString stringWithFormat:@"function %@\
                                        {\
                                            return video.readyState;\
                                        };", [self getVideoReadyStatus]];
}

//获取播放器当前状态
- (NSString *)jsFunctionGetVideoPlayStatus
{
    return [NSString stringWithFormat:@"function %@\
                                        {\
                                            return video.paused;\
                                        };", [self getVideoPlayStatus]];
}

//获取视频总时长
- (NSString *)jsFunctionGetVideoTotalTime
{
    return [NSString stringWithFormat:@"function %@\
                                        {\
                                            return video.duration;\
                                        };", [self getVideoTotalTime]];
}

//监听video开始播放
- (NSString *)jsFunctionAddEventVideoUpdateTime
{
    return [NSString stringWithFormat:@"\
            video.ontimeupdate = function(){\
            var videoParams = {'currentTime' : video.currentTime, 'totalTime' : video.duration};\
            window.webkit.messageHandlers.videoStart.postMessage(videoParams);};\
            "];
}

//获取video element
- (NSString *)gainVideoElement
{
    return @"document.getElementsByTagName(\"video\")[0];";
}

- (void)setVideoDetailID:(NSString *)videoDetailID {
    _videoDetailID = videoDetailID;
    self.operateView.videoDetailID = videoDetailID;
}

@end
