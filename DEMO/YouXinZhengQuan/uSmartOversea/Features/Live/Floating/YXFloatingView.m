//
//  YXFloatingView.m
//  uSmartOversea
//
//  Created by Apple on 2020/10/12.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXFloatingView.h"
#import "uSmartOversea-Swift.h"
#import "YXWatchLiveViewModel.h"
#import <Masonry/Masonry.h>
#import "YXLiveBackgroundTool.h"

@interface YXFloatingView ()//<TXLiveAudioSessionDelegate>

@property (nonatomic, strong) UIButton *floatingButton;

@property (nonatomic, assign) BOOL isPortrait;

@end

@implementation YXFloatingView

+ (YXFloatingView *)sharedView {
    static YXFloatingView *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YXFloatingView alloc] init];
        [UIApplication.sharedApplication.keyWindow.rootViewController.view addSubview:instance];
    });
    
    return instance;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, 171, 96)];
    if (self) {
        self.isPortrait = NO;
        self.hidden = YES;
        self.backgroundColor = [UIColor blackColor];
//        self.txLivePlayer = [[TXLivePlayer alloc] init];
//        [self.txLivePlayer setupVideoWidget:self.bounds containView:self insertIndex:0];
        
        self.floatingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.floatingButton setImage:[UIImage imageNamed:@"floating_close"] forState:UIControlStateNormal];
        [self addSubview:self.floatingButton];
        
        [self.floatingButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self);
            make.top.equalTo(self);
            make.height.width.mas_equalTo(24);
        }];
        
        @weakify(self)
        [self.floatingButton setQmui_tapBlock:^(__kindof UIControl *sender) {
            @strongify(self);
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            [self hideFloating];
        }];
        
        [self setClickDragViewBlock:^(WMDragView *dragView) {
            @strongify(self);
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            if (self.sourceViewController) {
                [[UIViewController currentViewController].navigationController popToViewController:self.sourceViewController animated:YES];
                self.sourceViewController = nil;
            } else {
                YXAppDelegate *delegate = (YXAppDelegate *)UIApplication.sharedApplication.delegate;
                YXWatchLiveViewModel *viewModel = [[YXWatchLiveViewModel alloc] initWithServices:delegate.navigator params:@{@"liveId": self.liveId}];
                [delegate.navigator pushViewModel:viewModel animated:YES];
            }

            [self hideFloating];
        }];
        // 监听屏幕旋转
        [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification  object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(loginOut) name:YXUserManager.notiLoginOut object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        //[TXLiveBase setAudioSessionDelegate:self];
        
    }
    return self;
}

- (void)hideFloating {
    self.sourceViewController = nil;
    self.hidden = YES;
   // [self.txLivePlayer stopPlay];
}

- (void)startPlay:(NSString *)showUrl isPortrait:(BOOL)isPortrait
{
    self.hidden = NO;
    self.isPortrait = isPortrait;
    [self resetFrame];
   // [self.txLivePlayer startPlay:showUrl type:PLAY_TYPE_LIVE_FLV];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)resetFrame {
    if (self.isPortrait) {
        CGFloat originX = YXConstant.screenWidth - 96 - 22;
        CGFloat originY = YXConstant.screenHeight - 171 - self.freeRect.size.height/4;
        self.frame = CGRectMake(originX, originY, 96, 171);
    } else {
        CGFloat originX = YXConstant.screenWidth - 171 - 22;
        CGFloat originY = YXConstant.screenHeight - 96 - self.freeRect.size.height/4;
        self.frame = CGRectMake(originX, originY, 171, 96);
    }
}

// 屏幕旋转通知回调
- (void)orientationDidChange:(NSNotification *)notification {
    
    if (!CGSizeEqualToSize(self.freeRect.size, self.superview.bounds.size)) {
        CGRect oldFreeRect = self.freeRect;
        self.freeRect = (CGRect){CGPointZero,self.superview.bounds.size};

        CGFloat originX = self.frame.origin.x;
        CGFloat originY = self.frame.origin.y;
        
        CGFloat centerX = oldFreeRect.origin.x + (oldFreeRect.size.width - self.frame.size.width)/2;
        CGFloat centerY = oldFreeRect.origin.y + (oldFreeRect.size.height - self.frame.size.height)/2;
        
        if (originX > centerX) {
            originX = self.freeRect.size.width - self.frame.size.width - 22;
        } else {
            originX = 22;
        }
        
        if (originY > centerY) {
            originY = self.freeRect.size.height - self.frame.size.height - self.freeRect.size.height/4;
        } else {
            originY = self.freeRect.size.height/4;
        }
        
        self.frame = (CGRect){CGPointMake(originX, originY),self.bounds.size};
    }
}

#pragma mark - 前后台切换
- (void)willResignActive:(NSNotification *)notification {
//    if (self.txLivePlayer.isPlaying) {
//        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
//        [YXLiveBackgroundTool setBackGroundWithLive:self.liveModel andCallBack:^(YXPlayEvent event) {
//            if (event == YXPlayEventPlay) {
//                [self.txLivePlayer resume];
//            } else {
//                [self.txLivePlayer pause];
//            }
//        }];
//    }
}

- (void)didBecomeActive:(NSNotification *)notification {
//    if (self.txLivePlayer.isPlaying) {
////        [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
//    }
}

- (BOOL)setCategory:(NSString *)category withOptions:(AVAudioSessionCategoryOptions)options error:(NSError *__autoreleasing *)outError {
    
    AVAudioSession*session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    NSError *error;
    BOOL result = [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    return result;
}


- (void)loginOut {
    [self hideFloating];
}

@end
