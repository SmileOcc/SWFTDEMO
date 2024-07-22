//
//  YouTuBePlayerView.m
//  YouTuBePlayer
//
//  Created by liwei on 2017/5/13.
//  Copyright © 2017年 liwei. All rights reserved.
//`

#import "YouTuBePlayerView.h"
#import "UIView+ZFViewCategorySet.h"

#import "WKWebViewJavascriptBridge.h"
#import "Constants.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"


#define YouTubeOrigin @"https://www.youtube.com"
@interface YouTuBePlayerView ()
<WKUIDelegate,
WKNavigationDelegate,
UIGestureRecognizerDelegate,
ZFVideoLiveOperateDelegate
>

@property (nonatomic,strong) NSURL                    *originalURL;


/** 第一次真实播放*/
@property (nonatomic, assign) BOOL                    firstReallyPlay;


@property (nonatomic, assign) CGFloat                 durationTime;


@end

@implementation YouTuBePlayerView
@synthesize videoDetailID = _videoDetailID;

//播放器销毁
- (void)dealloc {
    YWLog(@"---------- YouTuBePlayerView dealloc");
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


#pragma mark - Action

/**
 * (V3.9.0添加)由于上面的bridge无法执行来监听播放状态, add by: YW
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURL *url = navigationAction.request.URL;
    NSString *scheme = [url scheme];
    if ([scheme isEqualToString:@"wabridge"]) {
        [self notifyDelegateOfYouTubeCallbackUrl:url];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)notifyDelegateOfYouTubeCallbackUrl: (NSURL *) url {
    
    if (ZFIsEmptyString(self.liveVideoID)) {
        return;
    }
    NSString *action = url.host;
    NSString *query = url.query;
    NSString *data;
    NSString *playTime = @"";
    NSString *videoTime = @"";
    if (query) {
        data = [[query componentsSeparatedByString:@"data="] lastObject];
        if (data && data.length>0) {
            if ([action isEqualToString:@"onPlayTime"]) {
                playTime = [NSString stringWithFormat:@"%.f",[data floatValue]];
            } else if ([action isEqualToString:@"onPlayerReady"]) {
                videoTime = [NSString stringWithFormat:@"%.f",[data floatValue]];
            }
            data = [data substringToIndex:1];
        }
    }
    

    if ([action isEqualToString:@"onPlayerReady"]) {//已经触发开始播放
        if (self.videoPlayStatusChange) {
            self.videoPlayStatusChange(PlayerStatePlaying);
        }
        
        YWLog(@"-------playState onPlayerReady");
        self.currentPlayerState = PlayerStatePlaying;
        [self.operateView playViewState:YES];
        [self.operateView videoIsCanPlay];
        
        self.durationTime = [videoTime floatValue];
        [self.operateView startTime:nil endTime:videoTime isEnd:NO];

        // 加载时有白屏
        self.webView.alpha = 0.0;
        self.webView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.webView.alpha = 1.0;
        }];
        
    } else if ([action isEqualToString:@"onPlayTime"]) {
        
//        YWLog(@"-------onPlayTime: %f",[playTime floatValue]);
        [self.operateView startTime:playTime endTime:nil isEnd:NO];
        if (self.durationTime > 0) {
            // 防止最后结束时，没填满
            self.progressView.progress = ([playTime floatValue] + 1.0) / self.durationTime;
        }
        
    } else if ([action isEqualToString:@"onPlayerStateChange"]) {
        YWLog(@"-------playState onPlayerStateChange: %@",data);

        PlayerState state = PlayerStateUnStarted;
        if ([data isEqualToString:@"0"]) {
            state = PlayerStateEnded;
            [self.operateView startTime:nil endTime:nil isEnd:YES];
            self.operateView.progressSlider.value = 1.0f;
            self.progressView.progress = 1.0f;
            
        } else if ([data isEqualToString:@"1"]) {
            state = PlayerStatePlaying;
            [self.operateView playViewState:YES];

        } else if ([data isEqualToString:@"2"]) {
            state = PlayerStatePaused;
            
        } else if ([data isEqualToString:@"3"]) {
            state = PlayerStateBuffering;
            
        } else if ([data isEqualToString:@"5"]) {
            state = PlayerStateUnStarted;
            
        } else if ([data isEqualToString:@"-1"]) {
            state = PlayerStateUnStarted;
        }
        
        self.currentPlayerState = state;
        if (self.videoPlayStatusChange) {
            self.videoPlayStatusChange(state);
        }
        
        if (self.videoRealStartPlay && [data isEqualToString:@"1"] && !self.firstReallyPlay) {
            self.firstReallyPlay = YES;
            self.videoRealStartPlay();
        }
        
    }
}

- (void)baseSeekToSecondsPlayVideo:(float)seconds {
    [self seekToSecondsPlayVideo:seconds allowSeekAhead:YES];
}
/**
 play video with videoId
 **/
- (BOOL)basePlayVideoWithVideoID:(NSString *)videoId {
    // controls设置成0，就不显示滑块控件  rel:0/1,默认为1显示，播放器是否应显示相关视频
    
    NSDictionary *dic = @{@"autoplay":@1,@"controls":self.isShowSystemView ? @2 : @0,@"playsinline":@1,@"rel":@0,@"origin":YouTubeOrigin};
    return  [self playVideoWithVideoId:videoId playerVars:dic];
}

/**
 play video with videoId and playerVars
 **/
- (BOOL)playVideoWithVideoId:(NSString *)videoId playerVars:(NSDictionary *)playerVars {
    if (!playerVars) {
        playerVars = @{};
    }
    self.liveVideoID = videoId;
    self.operateView.liveVideoAddress = ZFToString(videoId);
    NSDictionary *playerParams = @{ @"videoId" : videoId, @"playerVars" : playerVars };
    return [self playVideoWithParams:playerParams];
}

/*
 play video with playerVars
 **/
- (BOOL)playVideoWithParams:(NSDictionary *)additionalPlayerParams {
    NSDictionary *playerCallbacks = @{
                                      @"onReady" : @"onPlayerReady",
                                      @"onStateChange" : @"onPlayerStateChange",
                                      @"onError" : @"onPlayerError"
                                      };
    NSMutableDictionary *playerParams = [[NSMutableDictionary alloc] init];
    if (additionalPlayerParams) {
        [playerParams addEntriesFromDictionary:additionalPlayerParams];
    }
    if (![playerParams objectForKey:@"height"]) {
        [playerParams setValue:@"100%" forKey:@"height"];
    }
    if (![playerParams objectForKey:@"width"]) {
        [playerParams setValue:@"100%" forKey:@"width"];
    }
    
    [playerParams setValue:playerCallbacks forKey:@"events"];
    
    if ([playerParams objectForKey:@"playerVars"]) {
        NSMutableDictionary *playerVars = [[NSMutableDictionary alloc] init];
        [playerVars addEntriesFromDictionary:[playerParams objectForKey:@"playerVars"]];
        
        if (![playerVars objectForKey:@"origin"]) {
            self.originalURL = [NSURL URLWithString:YouTubeOrigin];
        } else {
            self.originalURL = [NSURL URLWithString: [playerVars objectForKey:@"origin"]];
        }
    } else {
        // This must not be empty so we can render a '{}' in the output JSON
        [playerParams setValue:[[NSDictionary alloc] init] forKey:@"playerVars"];
    }
    NSString *html = [[NSBundle mainBundle] pathForResource:@"youtube" ofType:@"html"];
    NSString *htmlStr = [NSString stringWithContentsOfFile:html encoding:NSUTF8StringEncoding error:nil];
    NSError *jsonRenderingError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:playerParams
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&jsonRenderingError];
    NSString *playerVarsJsonString =
    [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *embedHTML = [NSString stringWithFormat:htmlStr, playerVarsJsonString];
    [self.webView loadHTMLString:embedHTML baseURL: self.originalURL];
    
    return YES;

}

#pragma mark - 播放设置

- (void)currentTime:(void (^)(float, NSError *))complentionHandler {

    [self.webView evaluateJavaScript:@"player.getCurrentTime();" completionHandler:^(id returnValue, NSError * _Nullable error) {
        float currentTime = [returnValue floatValue];
        complentionHandler(currentTime,error);
    }];
}

- (void)startVideo {
    if (!ZFIsEmptyString(self.liveVideoID)) {
        [self.operateView playViewState:YES];
        [self.webView evaluateJavaScript:@"player.playVideo();" completionHandler:nil];
    }
}

- (void)stopVideo {

    if (self.webView.isLoading) {
        [self.webView stopLoading];
    }
    [self.operateView playViewState:NO];
    [self.webView evaluateJavaScript:@"player.stopVideo();" completionHandler:nil];
}

- (void)pauseVideo {

    if (self.webView.isLoading) {
        [self.webView stopLoading];
    }
    [self.operateView playViewState:NO];
    [self.webView evaluateJavaScript:@"player.pauseVideo();" completionHandler:nil];
    
}

/*
 play video with seconds
 
 allowSeekAhead:是否允许从头开始跳
 
 跳转到指定时间播放视频
 **/

- (void)seekToSecondsPlayVideo:(float)seconds allowSeekAhead:(BOOL)allowSeekAhead {

    NSString *command = [NSString stringWithFormat:@"player.seekTo(%@,%@);",[NSNumber numberWithFloat:seconds],allowSeekAhead ? @"true":@"false"];

    [self.webView evaluateJavaScript:command completionHandler:nil];
}


- (void)playVideoDurationTime {
//    AVPlayerItem AVPlayer
    NSString *command = [NSString stringWithFormat:@"player.getDuration();"];
    [self.webView evaluateJavaScript:command completionHandler:^(id returnValue, NSError * _Nullable error) {
        float currentTime = [returnValue floatValue];
        YWLog(@"-------durationTime: %f",currentTime);
    }];
}

- (void)setLoop:(BOOL)loop {
    NSString *loopPlayListValue = [self stringForJSBoolean:loop];
    NSString *command = [NSString stringWithFormat:@"player.setLoop(%@);", loopPlayListValue];
    [self.webView evaluateJavaScript:command completionHandler:nil];
}

- (void)cancelSettingOperateView {
    self.operateView.hidden = YES;
    self.webView.userInteractionEnabled = YES;
    self.isShowSystemView = YES;
    if (self.pan) {
        self.pan.enabled = NO;
    }
    if (self.tap) {
        self.tap.enabled = NO;
    }
}

- (NSString *)stringForJSBoolean:(BOOL)boolValue {
    return boolValue ? @"true" : @"false";
}

#pragma mark - WKNavigationDelegate and WKUIDelegate
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling,nil);
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    [webView reload];
}


#pragma mark - Property Method

- (WKWebView *)seetingWebView {
    WKWebViewConfiguration *configuration = [[NSClassFromString(@"WKWebViewConfiguration") alloc] init];
    NSString *jsStr = @"var meta=document.createElement('meta');meta.setAttribute('name','viewport');meta.setAttribute('content','width=device-width');document.getElementsByTagName('head')[0].appendChild(meta);";
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:jsStr injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    configuration.preferences = [NSClassFromString(@"WKPreferences") new];
    configuration.userContentController = [NSClassFromString(@"WKUserContentController") new];
    [configuration.userContentController addUserScript:userScript];
    WKPreferences *prefer = [[WKPreferences alloc] init];
    prefer.javaScriptEnabled = YES;
    prefer.javaScriptCanOpenWindowsAutomatically = YES;
    configuration.preferences = prefer;
    configuration.allowsInlineMediaPlayback = YES;//控制视频播放默认不是全屏播放
    if (kiOSSystemVersion >= 10 ) {
        configuration.mediaTypesRequiringUserActionForPlayback = NO;
    }
    WKWebView *tempWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) configuration:configuration];
    tempWebView.backgroundColor = [UIColor clearColor];
    tempWebView.scrollView.scrollEnabled = NO;
    for (UIView *view in tempWebView.subviews) {
        view.backgroundColor = [UIColor clearColor];
    }
    tempWebView.UIDelegate= self;
    tempWebView.navigationDelegate = self;
    tempWebView.userInteractionEnabled = NO;
    
    tempWebView.hidden = YES;
    return tempWebView;
}


- (void)setVideoDetailID:(NSString *)videoDetailID {
    _videoDetailID = videoDetailID;
    self.operateView.videoDetailID = videoDetailID;
}

@end
