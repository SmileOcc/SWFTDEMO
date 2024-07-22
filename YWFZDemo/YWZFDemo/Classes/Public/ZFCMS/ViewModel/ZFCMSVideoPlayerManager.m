//
//  ZFCMSVideoPlayerManager.m
//  ZZZZZ
//
//  Created by YW on 2019/9/12.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCMSVideoPlayerManager.h"
#import "YouTuBePlayerView.h"
#import "ZFNetworkManager.h"
#import "ZFCMSVideoCCell.h"

typedef NS_ENUM(NSInteger) {
    PlayerManagerState_Stop,
    PlayerManagerState_Playing,
}PlayerManagerState;

typedef NS_ENUM(NSInteger) {
    VideoViewPlayerState_AutoPlayer,        //自动播放
    VideoViewPlayerState_UserClick          //用户自己控制
}VideoViewPlayerState;

@interface ZFCMSVideoPlayerManager ()
<
    ZFLiveBaseViewDelegate
>
@property (nonatomic, strong, readwrite) ZFLiveBaseView *currentPlayer;
@property (nonatomic, weak) UIView *superView;
@property (nonatomic, assign) PlayerManagerState managerPlayerState;
@property (nonatomic, strong) NSMutableDictionary <NSString *, ZFLiveBaseView *> *playerSets;
@property (nonatomic, assign) VideoViewPlayerState userPlayerState;

@end

@implementation ZFCMSVideoPlayerManager
@synthesize currentPlayer = _currentPlayer;

+ (instancetype)manager:(ZFVideoPlayerType)type superView:(UIView *)superView
{
    ZFCMSVideoPlayerManager *manager = [[ZFCMSVideoPlayerManager alloc] init];
    manager.playerType = type;
    manager.superView = superView;
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.playerSets = [[NSMutableDictionary alloc] init];
        self.userPlayerState = VideoViewPlayerState_AutoPlayer;
    }
    return self;
}

- (void)startPlayer:(NSString *)videoId frame:(CGRect)frame
{
    if (ZFIsEmptyString(videoId)) {
        YWLog(@"视频id不能为空");
        return;
    }
    if (self.playerType == ZFVideoPlayerType_OnlyOne) {
        [self stopCurrentPlayer];
        ZFLiveBaseView *liveView = [self.playerSets objectForKey:videoId];
        if (liveView) {
            CGRect oldFrame = liveView.frame;
            if (!CGRectContainsRect(oldFrame, frame)) {
                liveView.frame = frame;
            }
            if (!liveView.superview) {
                [self.superView addSubview:liveView];
            }
            [liveView startVideo];
            
            UIActivityIndicatorView *indicatorView = [liveView viewWithTag:10011];
            if (indicatorView) {
                [indicatorView startAnimating];
            }
        } else {
            liveView = [self youTuBePlayerView:videoId frame:frame];
            
            UIActivityIndicatorView *indicatorView = [self activityIndicatorView:frame];
            [liveView addSubview:indicatorView];
            [indicatorView startAnimating];
        }
        self.currentPlayer = liveView;
    }
}

//- (void)startindicatorHiddenCuntDownTime:(UIActivityIndicatorView *)indicatorView
//{
//    [indicatorView startAnimating];
//    dispatch_queue_t queue = dispatch_get_main_queue();
//    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
//    __block NSInteger index = 0;
//    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC, 1.0 * NSEC_PER_SEC);
//    dispatch_source_set_event_handler(timer, ^{
//        if (index) {
//            [indicatorView stopAnimating];
//            dispatch_cancel(timer);
//        }
//        index++;
//    });
//    dispatch_resume(timer);
//}

- (YouTuBePlayerView *)youTuBePlayerView:(NSString *)videoId frame:(CGRect)frame
{
    YouTuBePlayerView *liveView = [[YouTuBePlayerView alloc] initWithFrame:frame];
    liveView.hideFullScreenView = YES;
    liveView.hideTopOperateView = YES;
    liveView.hideEyesNumsView = YES;
    liveView.hideAllAlertTipView = YES;
    [liveView basePlayVideoWithVideoID:videoId];
    [liveView startVideo];
    @weakify(liveView)
    liveView.videoPlayStatusChange = ^(PlayerState playerState) {
        @strongify(liveView)
        if (playerState == PlayerStateEnded) {
            [liveView removeFromSuperview];
        }
        if (playerState == PlayerStatePlaying) {
            UIActivityIndicatorView *indicatorView = [liveView viewWithTag:10011];
            [indicatorView stopAnimating];
        }
    };
    liveView.delegate = self;
    [self.superView addSubview:liveView];
    [self.playerSets setObject:liveView forKey:videoId];
    return liveView;
}

- (UIActivityIndicatorView *)activityIndicatorView:(CGRect)superFrame
{
    CGFloat x = (superFrame.size.width - 30) / 2;
    CGFloat y = (superFrame.size.height - 30) / 2;
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicatorView.frame = CGRectMake(x, y, 30, 30);
    indicatorView.tag = 10011;
    return indicatorView;
}

- (void)stopCurrentPlayer
{
    if (self.currentPlayer) {
        [self.currentPlayer removeFromSuperview];
        [self.currentPlayer pauseVideo];
    }
}

- (void)videoPlayerScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
//        [self stopVideoWithScroller:scrollView];
    }
}

- (void)videoPlayerScrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect cellFrameInSuperview = [scrollView convertRect:self.currentPlayer.frame toView:scrollView.superview];
    BOOL show = CGRectIntersectsRect(self.superView.frame, cellFrameInSuperview);
    if (!show) {
        [self stopCurrentPlayer];
    }
}

- (void)videoPlayerScrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    [self stopVideoWithScroller:scrollView];
}

- (void)stopVideoWithScroller:(UIScrollView *)scrollView
{
    //停止滑动
    BOOL isWifi = [ZFNetworkManager isReachableViaWiFi];
    PlayerState state = self.currentPlayer.currentPlayerState;
    if (state == PlayerStatePlaying || state == PlayerStateBuffering || state == PlayerStatePaused) {
        return;
    }
    if (isWifi && self.userPlayerState == VideoViewPlayerState_AutoPlayer) {
        if ([scrollView isKindOfClass:[UICollectionView class]]) {
            NSArray <UICollectionViewCell *> *visiCell = [(UICollectionView *)scrollView visibleCells];
            [visiCell enumerateObjectsUsingBlock:^(UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CGRect cellFrameInSuperview = [scrollView convertRect:obj.frame toView:scrollView.superview];
                BOOL show = CGRectContainsRect(scrollView.superview.frame, cellFrameInSuperview);
                if ([obj isKindOfClass:[ZFCMSVideoCCell class]] && show) {
                    ZFCMSVideoCCell *videoCell = (ZFCMSVideoCCell *)obj;
                    [self startPlayer:videoCell.itemModel.video_id frame:videoCell.frame];
                    *stop = YES;
                }
            }];
        }
    }
}

#pragma delelgate

- (void)zfLiveBasePlayer:(ZFLiveBaseView *)playerView player:(BOOL)playerStatus
{
    self.userPlayerState = VideoViewPlayerState_UserClick;
}

#pragma mark - Property Method

- (void)setCurrentPlayer:(ZFLiveBaseView *)currentPlayer
{
    _currentPlayer = currentPlayer;
}

- (ZFLiveBaseView *)currentPlayer
{
    return _currentPlayer;
}

@end
