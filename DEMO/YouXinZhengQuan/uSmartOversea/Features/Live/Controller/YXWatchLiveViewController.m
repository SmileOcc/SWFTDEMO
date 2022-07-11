//
//  YXWatchLiveViewController.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/10.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXWatchLiveViewController.h"
#import "YXLiveChatRoomViewModel.h"
#import "YXLiveAuthorViewModel.h"
#import "YXLiveReplayListViewModel.h"
#import "YXLiveChatRoomViewController.h"
#import "YXLiveAuthorViewController.h"
#import "YXLiveReplayListViewController.h"
#import "YXWatchLiveViewModel.h"
#import "YXFloatingView.h"
#import "YXFloatingAudioView.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>
#import "UINavigationController+QMUI.h"
#import "YXLiveUserLevelView.h"
#import "YXLivePlayView.h"

@interface YXWatchLiveViewController ()<YXTabViewDelegate, QMUINavigationControllerDelegate, UINavigationControllerBackButtonHandlerProtocol>

@property (nonatomic, strong) YXTabView *tabView;
@property (nonatomic, strong) YXPageView *pageView;
@property (nonatomic, strong) NSArray<NSString *> *titles;
@property (nonatomic, strong) YXWatchLiveViewModel *viewModel;

@property (nonatomic, assign) YXTimerFlag countFlag;

@property (nonatomic, strong) YXLiveChatRoomViewModel *liveChatRoomViewModel;

@property (nonatomic, strong) YXLiveUserLevelView *levelView;

@property (nonatomic, strong) YXLiveWatchEndView *endView;

@property (nonatomic, strong) YXLiveChatRoomViewController *chatRoomVC;

@end

@implementation YXWatchLiveViewController
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUI];
    [self loadDetailData];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadUserRightData];    
    
    [[YXFloatingView sharedView] hideFloating];
    [[YXFloatingAudioView sharedView] hideFloating];
    [self startCountTimer];
}


- (BOOL)preferredNavigationBarHidden {
    return YES;
}

- (void)bindViewModel {
    [super bindViewModel];
    
    @weakify(self);
    [self.levelView setUpdateCallBack:^{
        @strongify(self);
        
        if ([YXUserManager isLogin]) {
            if (self.viewModel.require_right == 1 || self.viewModel.require_right == 2) {
                [YXWebViewModel pushToWebVC:[YXH5Urls goProCenterUrl]];
            } else if (self.viewModel.require_right == 4) {
                // 专业投资者
                [YXWebViewModel pushToWebVC:[YXH5Urls professionalUrl]];
            }
        } else {
            [(NavigatorServices *)self.viewModel.services pushToLoginVCWithCallBack:^(NSDictionary<NSString *,id> * _Nonnull dic) {
                            
            }];
        }
    }];
    
    
    self.viewModel.nextPlayBlock = ^(BOOL isPlay) {
        @strongify(self);
      
        self.playView.isPlaying = isPlay;
    };

}

- (void)startCountTimer {
    @weakify(self);
    if (self.viewModel.liveModel.status == 4 || self.viewModel.liveModel.status == 5) {
        // 直播结束 定时器结束
        return;
    }
    self.countFlag = [[YXTimerSingleton shareInstance] transactOperation:^(YXTimerFlag flag) {
        @strongify(self);
        [self updateCountData];
    } timeInterval:5 repeatTimes:NSIntegerMax atOnce:NO];
}

- (void)closeCountTimer {
    if (self.countFlag > 0) {
        [[YXTimerSingleton shareInstance] invalidOperationWithFlag:self.countFlag];
    }
}

- (void)loadDetailData {
    @weakify(self);
    [[self.viewModel.getLiveDetail execute:nil] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        if (self.viewModel.liveModel) {
            [self initChildViewControllers];
            
            self.title = self.viewModel.liveModel.title;
            self.liveChatRoomViewModel.liveModel = self.viewModel.liveModel;
            self.playView.countStr = self.viewModel.liveModel.watchUserCountChange;
            
            if (self.viewModel.has_right) {
                self.playView.showUrl = self.viewModel.liveModel.show_url;
            }
            [self updateCountData];
            [self startCountTimer];
            
            self.playView.liveModel = self.viewModel.liveModel;
        }
    }];
}

- (void)loadUserRightData {

    if (self.viewModel.liveModel && self.viewModel.liveModel.status == 4) {
        return;
    }
    @weakify(self);
    [[self.viewModel.getUserRightCommand execute:nil] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
//        self.viewModel.has_right = NO;
//        self.viewModel.require_right = 4;
        if (self.viewModel.has_right) {
            if (self.playView.showUrl == nil) {
                self.playView.showUrl = self.viewModel.liveModel.show_url;
            }
            if (self.levelView.superview) {
                [self.levelView removeFromSuperview];
            }
        } else {
          //  [self.playView.txLivePlayer pause];
            [self showLevelView];
        }
    }];
}


- (void)updateCountData {
    if (self.viewModel.liveModel.id.length == 0) {
        return;
    }
    @weakify(self);
    [[self.viewModel.getwatchCountCommand execute: nil] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.playView.countStr = self.viewModel.liveModel.watchUserCountChange;
        if (self.viewModel.liveModel.status == 4 || self.viewModel.liveModel.status == 5) {
            // 直播结束
            if (self.playView.isFullScreen) {
                [self.playView closeFullScreen];
            }
            [self showEndView];
            [self closeCountTimer];
            if (self.viewModel.liveModel.demand_id.intValue > 0 ) { //直播已下线就去回放
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{                    
                    // 跳转回放
                    [YXWebViewModel pushToWebVC:[YXH5Urls playNewsRecordUrlWith:self.viewModel.liveModel.demand_id]];
                });
            }
        }
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
//    if (self.playView.txLivePlayer.isPlaying) {
//        [self.playView.txLivePlayer pause];
//    }
    
    if ([YXFloatingView sharedView].hidden) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    }
    
    [self closeCountTimer];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    if (self.playView.txLivePlayer) {
//        [self.playView.txLivePlayer resume];
//    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (BOOL)shouldPopViewControllerByBackButtonOrPopGesture:(BOOL)byPopGesture {
    if (byPopGesture) {
        return NO;
    }
    return YES;
}


- (void)didPopInNavigationControllerWithAnimated:(BOOL)animated {

    [self showFloatingView];

    [self stopPlay];
}

- (void)setUI {
    
    UIBarButtonItem *shareItem = [UIBarButtonItem qmui_itemWithImage:[UIImage imageNamed:@"watch_live_share_WhiteSkin"] target:self action:@selector(shareButtonAction)];
    self.navigationItem.rightBarButtonItems = @[shareItem];
    
    self.view.backgroundColor = UIColor.whiteColor;
    self.tabView.delegate = self;
    
    [self.view addSubview:self.tabView];
    [self.view addSubview:self.pageView];
    [self.view addSubview:self.playView];
    
    self.playView.frame = CGRectMake(0, 0, YXConstant.screenWidth, 211);
    
    [self.tabView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(211);
        make.height.mas_equalTo(40);
    }];
    [self.pageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.tabView.mas_bottom);
    }];

}

- (void)initChildViewControllers {
    
    YXLiveChatRoomViewModel *viewModel1 = [[YXLiveChatRoomViewModel alloc] initWithServices:self.viewModel.services params:@{}];
    self.liveChatRoomViewModel = viewModel1;
    YXLiveChatRoomViewController *vc1 = [[YXLiveChatRoomViewController alloc] initWithViewModel:viewModel1];
    self.chatRoomVC = vc1;
    
    YXLiveAuthorViewModel *viewModel2 = [[YXLiveAuthorViewModel alloc] initWithServices:self.viewModel.services params:@{}];
    viewModel2.liveModel = self.viewModel.liveModel;
    YXLiveAuthorViewController *vc2 = [[YXLiveAuthorViewController alloc] initWithViewModel:viewModel2];
    
    YXLiveReplayListViewModel *viewModel3 = [[YXLiveReplayListViewModel alloc] initWithServices:self.viewModel.services params:@{}];
    viewModel3.anchorId = self.viewModel.liveModel.anchor_id;
    YXLiveReplayListViewController *vc3 = [[YXLiveReplayListViewController alloc] initWithViewModel:viewModel3];
    
    self.tabView.titles = self.titles;
    self.pageView.viewControllers = @[vc1, vc2, vc3];
    
    [self.tabView reloadData];
    [self.pageView reloadData];
}

- (void)stopPlay {
//    [self.playView.txLivePlayer stopPlay];
//    [self.playView.txLivePlayer removeVideoWidget];
//    self.playView.txLivePlayer = nil;
}

- (void)shareButtonAction {
    
    if (self.viewModel.liveModel == nil) {
        return;
    }
    
    [YXLiveShareTool shareWithLiveModel:self.viewModel.liveModel viewController:self];
    
}

- (void)tabView:(YXTabView *)tabView didSelectedItemAtIndex:(NSUInteger)index withScrolling:(BOOL)scrolling {
    
    NSString *name = @"";
    if (index == 0) {
        return;
    } else if (index == 1) {
        name = @"简介";
    } else if (index == 2) {
        name = @"回看";
    }
}

-(void)gotoLandscapeVC
{
    [self.chatRoomVC.chatRoomView hideStockPopupView:NO];
    [self.view endEditing:YES];
   // self.viewModel.isPlaying = self.playView.txLivePlayer.isPlaying;
    [self.viewModel.gotoLiveChatLandscapeCommand execute:nil ];
}


- (void)showLevelView {
    [self.levelView removeFromSuperview];
    self.levelView.frame = self.playView.frame;
    self.levelView.require_right = self.viewModel.require_right;
    [self.view addSubview:self.levelView];

}

- (void)showEndView {
    
//    [self.playView.txLivePlayer stopPlay];
    
    [self closeCountTimer];
    
    if (self.levelView.superview) {
        [self.levelView removeFromSuperview];
    }
    
    if (!self.endView.superview) {
        [self.view addSubview:self.endView];
        self.endView.countLabel.text = self.viewModel.liveModel.watchUserCountChange;
        [self.endView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.playView);
        }];
    }
}

#pragma mark - lazy load

- (YXLivePlayView *)playView {
    if (_playView == nil) {
        _playView = [[YXLivePlayView alloc] init];
        @weakify(self);
        [_playView setScaleCallBack:^(BOOL isFullScreen) {
            @strongify(self);
            [self gotoLandscapeVC];
        }];
    }
    return _playView;
}

- (YXTabView *)tabView {
    if (_tabView == nil) {
        YXTabLayout *layout = [YXTabLayout defaultLayout];
        layout.lrMargin = 0;
        layout.tabMargin = 0;
        layout.titleColor = QMUITheme.textColorLevel2;
        layout.lineCornerRadius = 2;
        layout.lineWidth = 16;
        layout.lineHeight = 4;
        NSInteger count = self.titles.count;
        layout.tabWidth = (YXConstant.screenWidth)/count;
        layout.linePadding = 1;
        _tabView = [[YXTabView alloc] initWithFrame:CGRectMake(0, 0, 30, 30) withLayout:layout];
      
        _tabView.backgroundColor = UIColor.whiteColor;
//        _tabView.titles = self.titles;
        _tabView.pageView = self.pageView;
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 30, 1)];
        lineView.backgroundColor = [[UIColor qmui_colorWithHexString:@"#191919"] colorWithAlphaComponent:0.05];
        [_tabView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(_tabView);
            make.height.mas_equalTo(1);
        }];
    }
    
    return _tabView;
}

- (YXPageView *)pageView {
    if (_pageView == nil) {
        _pageView = [[YXPageView alloc] initWithFrame:CGRectZero];
        _pageView.parentViewController = self;
        _pageView.contentView.scrollEnabled = YES;
    }
    return _pageView;
}

- (NSArray<NSString *> *)titles {
    if (_titles == nil) {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        [arr addObject:[YXLanguageUtility kLangWithKey:@"live_chat"]];
        [arr addObject:[YXLanguageUtility kLangWithKey:@"live_introduction"]];
        [arr addObject:[YXLanguageUtility kLangWithKey:@"live_replay"]];
        
        
        _titles = [arr copy];
    }
    return _titles;
}

- (void)showFloatingView {
//    if ([self.playView.txLivePlayer isPlaying]) {
//        YXFloatingView *floatingView = [YXFloatingView sharedView];
//        floatingView.liveId = self.viewModel.liveModel.id;
//        [floatingView startPlay:self.viewModel.liveModel.show_url isPortrait:self.playView.isPortrait];
//        floatingView.liveModel = self.viewModel.liveModel;
//    }
}

- (YXLiveUserLevelView *)levelView {
    if (_levelView == nil) {
        _levelView = [[YXLiveUserLevelView alloc] init];
    }
    return _levelView;
}

- (YXLiveWatchEndView *)endView {
    if (_endView == nil) {
        _endView = [[YXLiveWatchEndView alloc] init];
        _endView.userInteractionEnabled = NO;
    }
    return _endView;
}


@end
