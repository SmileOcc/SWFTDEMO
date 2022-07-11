//
//  YXLiveChatLandscapeViewController.m
//  uSmartOversea
//
//  Created by suntao on 2021/2/1.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXLiveChatLandscapeViewController.h"
#import "YXLiveBackgroundTool.h"
#import "YXLiveChatLandscapeViewModel.h"
#import "YXLiveLandscapePlayView.h"
#import "uSmartOversea-Swift.h"
#import "YXFloatingView.h"
#import "YXFloatingAudioView.h"
#import <Masonry/Masonry.h>


@interface YXLiveChatLandscapeViewController ()

@property (nonatomic, strong) YXLiveChatLandscapeViewModel * viewModel;

@property (nonatomic, strong) YXLiveLandscapePlayView * playView;

@property (nonatomic, strong) YXLiveEndLandscapeView * endView;
@property (nonatomic, assign) YXTimerFlag countFlag;

@end

@implementation YXLiveChatLandscapeViewController
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.forceToLandscapeRight = YES;
    [self setupUI];
    
    
}


- (BOOL)preferredNavigationBarHidden {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [YXFloatingView.sharedView hideFloating];
    [YXFloatingAudioView.sharedView hideFloating];
    [self startCountTimer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
//    if (self.playView.txLivePlayer) {
//        [self.playView.txLivePlayer resume];
//    }
//
//    if (self.viewModel.isPrePlaying) {
//        self.viewModel.isPlaying = YES;
//    }else{
//        if (self.playView.txLivePlayer.isPlaying ) {
//            [self.playView.txLivePlayer pause];
//            self.viewModel.isPlaying = NO;
//        }
//    }
    self.playView.isPlaying = self.viewModel.isPlaying;

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
//    if (self.playView.txLivePlayer.isPlaying) {
//        [self.playView.txLivePlayer pause];
//    }
//    if ([YXFloatingView sharedView].hidden) {
//        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
//    }
    [self closeCountTimer];
}


-(void)setupUI
{
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.playView];
    
    [self.playView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    self.playView.showUrl = self.viewModel.liveModel.show_url;
    self.playView.liveModel = self.viewModel.liveModel;

}

#pragma mark - 定时刷新观看人数

- (void)startCountTimer {
    @weakify(self);
    self.countFlag = [[YXTimerSingleton shareInstance] transactOperation:^(YXTimerFlag flag) {
        @strongify(self);
        [self updateCountData];
    } timeInterval:5 repeatTimes:NSIntegerMax atOnce:NO];
}

- (void)closeCountTimer {
    if (self.countFlag > 0) {
        [[YXTimerSingleton shareInstance] invalidOperationWithFlag:self.countFlag];
    }
    [self.playView closeCommentTimer];

}

- (void)updateCountData {
    @weakify(self);
    [[self.viewModel.getwatchCountCommand execute: nil] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        if (self.viewModel.liveModel.status == 4 || self.viewModel.liveModel.status == 5) {
            // 直播结束
            [self showEndView];
        }
    }];
}

- (void)showEndView {
    
//    [self.playView.txLivePlayer stopPlay];
//    [self closeCountTimer];
//    [self.playView showTopBottomView];
//    if (!self.endView.superview) {
//        [self.view addSubview:self.endView];
//        self.endView.count = [NSString stringWithFormat:@"%ld",(long)self.viewModel.liveModel.watch_user_count] ;
//    }
}

- (void)stopPlay {
//    [self.playView.txLivePlayer stopPlay];
//    [self.playView.txLivePlayer removeVideoWidget];
 //   self.playView.txLivePlayer = nil;
}

- (YXLiveLandscapePlayView *)playView {
    if (_playView == nil) {
        _playView = [[YXLiveLandscapePlayView alloc] initWithFrame:CGRectZero];
        @weakify(self);
        _playView.closeBlock = ^{
            @strongify(self);
            [self stopPlay];
            [self closeCountTimer];
            [self.viewModel isPlayingFlag];
            [self.navigationController popViewControllerAnimated:NO];
        };
        
        _playView.toLoginBlock = ^{
            @strongify(self);
            @weakify(self);
            [(NavigatorServices *)self.viewModel.services pushToLoginVCFromeLandscapeWithCallBack:^(NSDictionary<NSString *,id> * _Nonnull dict) {
                @strongify(self);
                [self.playView updateCommentFromLogin];

            }];
           
        };
        
        _playView.playBlock = ^(BOOL isPlay) {
            @strongify(self);
            self.viewModel.isPlaying = isPlay;
        };

    }
    return _playView;
}

- (YXLiveEndLandscapeView *)endView {
    if (_endView == nil) {
        _endView = [[YXLiveEndLandscapeView alloc] initWithFrame:CGRectMake(0, 70, YXConstant.screenHeight, YXConstant.screenWidth-140)];
        
    }
    return _endView;
}

- (BOOL)shouldPopViewControllerByBackButtonOrPopGesture:(BOOL)byPopGesture {
    return NO;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
