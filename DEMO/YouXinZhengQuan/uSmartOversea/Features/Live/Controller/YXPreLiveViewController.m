//
//  YXPreLiveViewController.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/9/7.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXPreLiveViewController.h"
#import "YXPreLiveViewModel.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>
#import <TCBeautyPanel/TCBeautyPanel.h>
#import <SDWebImage/SDWebImageDownloader.h>

@import TXLiteAVSDK_Professional;


@interface YXPreLiveViewController ()<TCBeautyPanelActionPerformer, TXLivePushListener, UINavigationControllerBackButtonHandlerProtocol>

@property (nonatomic, strong, readonly) YXPreLiveViewModel *viewModel;

@property (nonatomic, strong) UIView *localView;

@property (nonatomic, strong) TXLivePushConfig *config;


@property (nonatomic, strong) TCBeautyPanel *vBeauty;


@property (nonatomic, strong) YXLivePreView *preView;

@property (nonatomic, strong) YXLivingView *livingView;

@property (nonatomic, strong) YXLiveEndView *endView;

@property (nonatomic, strong) TXLivePush *livePusher;

@property (nonatomic, assign) BOOL firstAppear;

@property (nonatomic, assign) BOOL isLiving;

@property (nonatomic, assign) BOOL isMirror;

@property (nonatomic, assign) YXTimerFlag countFlag;

@end

@implementation YXPreLiveViewController

@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _firstAppear = YES;

    [self initUI];
    
    [self loadLiveData];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [center addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
            
    if (_firstAppear) {
        //是否有摄像头权限
        AVAuthorizationStatus statusVideo = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (statusVideo == AVAuthorizationStatusDenied) {
            return;
        }
        [self.livePusher startPreview:self.localView];
        _firstAppear = NO;
    }
}


- (BOOL)preferredNavigationBarHidden {
    return YES;
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.localView.frame = self.view.bounds;
}


- (BOOL)shouldPopViewControllerByBackButtonOrPopGesture:(BOOL)byPopGesture {
    return NO;
}


- (void)initUI {
    self.view.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.3];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom image:[UIImage imageNamed:@"user_back_icon"] target:self action:@selector(goBack)];
    [self.view addSubview:backBtn];
    
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.top.equalTo(self.view).offset(52);
        make.width.height.mas_equalTo(30);
    }];
    
    self.localView = [[UIView alloc] init];
    [self.view insertSubview:self.localView atIndex:0];
    
    self.config = [[TXLivePushConfig alloc] init];
    self.livePusher = [[TXLivePush alloc] initWithConfig:self.config];
    self.livePusher.delegate = self;
//    [[self.livePusher getBeautyManager] setBeautyLevel:9];
    
        
    [self.view addSubview:self.preView];
    [self.preView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-200);
        make.height.mas_equalTo(200);
    }];
    
    [self.view addSubview:self.livingView];
    [self.livingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    
    CGFloat bottomOffset = 0;
    if (@available(iOS 11, *)) {
        bottomOffset = UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom;
    }
    
    // 美颜放在最上面.
    CGFloat height = [TCBeautyPanel getHeight] + bottomOffset;
    TCBeautyPanelTheme *theme = [[TCBeautyPanelTheme alloc] init];
    theme.beautyPanelTitleColor = [UIColor.whiteColor colorWithAlphaComponent:0.3];
    theme.beautyPanelSelectionColor = UIColor.whiteColor;
    theme.sliderValueColor = [UIColor qmui_colorWithHexString:@"#191919"];
    theme.sliderMinColor = UIColor.whiteColor;
    theme.sliderThumbImage = [UIImage imageNamed:@"round"];
    theme.sliderMaxColor = [UIColor.whiteColor colorWithAlphaComponent:0.3];
    theme.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.9];
    theme.beautyPanelMenuSelectionBackgroundImage = [UIImage qmui_imageWithColor:UIColor.whiteColor];
    theme.mapDic = @{
        @"TC.Common.Clear": [YXLanguageUtility kLangWithKey:@"TC.Common.Clear"],
        @"TC.BeautySettingPanel.BeautySmooth" : [YXLanguageUtility kLangWithKey:@"TC.BeautySettingPanel.BeautySmooth"],
        @"TC.BeautySettingPanel.Beauty-Natural" : [YXLanguageUtility kLangWithKey:@"TC.BeautySettingPanel.Beauty-Natural"],
        @"TC.BeautySettingPanel.White" : [YXLanguageUtility kLangWithKey:@"TC.BeautySettingPanel.White"],
        @"TC.BeautySettingPanel.Ruddy" : [YXLanguageUtility kLangWithKey:@"TC.BeautySettingPanel.Ruddy"],
        @"TC.BeautyPanel.Menu.Beauty" : [YXLanguageUtility kLangWithKey:@"TC.BeautyPanel.Menu.Beauty"],
        @"TC.BeautyPanel.Menu.Filter" : [YXLanguageUtility kLangWithKey:@"TC.BeautyPanel.Menu.Filter"],
        @"TC.Common.Filter_original" : [YXLanguageUtility kLangWithKey:@"TC.Common.Filter_original"],
        @"TC.Common.Filter_normal" : [YXLanguageUtility kLangWithKey:@"TC.Common.Filter_normal"],
        @"TC.Common.Filter_yinghong" : [YXLanguageUtility kLangWithKey:@"TC.Common.Filter_yinghong"],
        @"TC.Common.Filter_yunshang" : [YXLanguageUtility kLangWithKey:@"TC.Common.Filter_yunshang"],
        @"TC.Common.Filter_chunzhen" : [YXLanguageUtility kLangWithKey:@"TC.Common.Filter_chunzhen"],
        @"TC.Common.Filter_bailan" : [YXLanguageUtility kLangWithKey:@"TC.Common.Filter_bailan"],
        @"TC.Common.Filter_yuanqi" : [YXLanguageUtility kLangWithKey:@"TC.Common.Filter_yuanqi"],
        @"TC.Common.Filter_chaotuo" : [YXLanguageUtility kLangWithKey:@"TC.Common.Filter_chaotuo"],
        @"TC.Common.Filter_xiangfen" : [YXLanguageUtility kLangWithKey:@"TC.Common.Filter_xiangfen"],
        @"TC.Common.Filter_white" : [YXLanguageUtility kLangWithKey:@"TC.Common.Filter_white"],
        @"TC.Common.Filter_langman" : [YXLanguageUtility kLangWithKey:@"TC.Common.Filter_langman"],
        @"TC.Common.Filter_qingxin" : [YXLanguageUtility kLangWithKey:@"TC.Common.Filter_qingxin"],
        @"TC.Common.Filter_weimei" : [YXLanguageUtility kLangWithKey:@"TC.Common.Filter_weimei"],
        @"TC.Common.Filter_fennen" : [YXLanguageUtility kLangWithKey:@"TC.Common.Filter_fennen"],
        @"TC.Common.Filter_huaijiu" : [YXLanguageUtility kLangWithKey:@"TC.Common.Filter_huaijiu"],
        @"TC.Common.Filter_landiao" : [YXLanguageUtility kLangWithKey:@"TC.Common.Filter_landiao"],
        @"TC.Common.Filter_qingliang" : [YXLanguageUtility kLangWithKey:@"TC.Common.Filter_qingliang"],
        @"TC.Common.Filter_rixi" : [YXLanguageUtility kLangWithKey:@"TC.Common.Filter_rixi"],
    };
    self.vBeauty = [[TCBeautyPanel alloc] initWithFrame:CGRectMake(0, self.view.mj_h-height, YXConstant.screenWidth, height) theme:theme actionPerformer:self];
    self.vBeauty.bottomOffset = bottomOffset;
    self.vBeauty.hidden = YES;
    [self.vBeauty resetAndApplyValues];
    [self.view addSubview:self.vBeauty];
}

- (void)bindViewModel {
    @weakify(self);
    [self.preView setBtnClickCallBack:^(UIButton *sender) {
        @strongify(self);
        switch (sender.tag) {
            case 0:
                {
                    self.vBeauty.hidden = NO;
                    self.preView.hidden = YES;
                    self.vBeauty.frame = CGRectMake(0, self.view.mj_h-[TCBeautyPanel getHeight] - self.vBeauty.bottomOffset , self.view.mj_w, [TCBeautyPanel getHeight] + self.vBeauty.bottomOffset);
                }
                break;
            case 1:
                {
                    if (!self.livePusher.frontCamera) {
                        [YXProgressHUD showSuccess:[YXLanguageUtility kLangWithKey:@"live_invalid_mirroring"]];
                        return;
                    }
                    self.isMirror = !self.isMirror;
                    sender.selected = !sender.selected;
                    [self.livePusher setMirror:self.isMirror];
                    if (self.isMirror) {
                        [YXProgressHUD showSuccess:[YXLanguageUtility kLangWithKey:@"live_view_same"]];
                    } else {
                        [YXProgressHUD showSuccess:[YXLanguageUtility kLangWithKey:@"live_view_dif"]];
                    }
                }
                break;
            case 2:
                {
                    [self.livePusher switchCamera];
                }
                break;
            case 3:
                {
                    if (self.viewModel.liveModel.push_url.length > 0) {
                        self.preView.hidden = YES;
                        YXLiveBeginCutdownView *cutDownView = [[YXLiveBeginCutdownView alloc] init];
                        [cutDownView begin];
                        [cutDownView setCutEndCallBack:^{
                            @strongify(self);
                            int status = [self.livePusher startPush:self.viewModel.liveModel.push_url];
                            if (status == 0) {
                                self.countFlag = [[YXTimerSingleton shareInstance] transactOperation:^(YXTimerFlag flag) {
                                    [self updateCountData];
                                } timeInterval:5 repeatTimes:NSIntegerMax atOnce:NO];
                                [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
                            }
                            self.livingView.liveModel = self.viewModel.liveModel;
                            self.isLiving = YES;
                            self.livingView.hidden = NO;
                            
                        }];
                    }
                }
                break;
                
            default:
                break;
        }
    }];
    
    [self.livingView setBtnClickCallBack:^(UIButton *sender) {
        @strongify(self);
        switch (sender.tag) {
            case 0:
                {
                    self.vBeauty.hidden = NO;
                    self.preView.hidden = YES;
                    self.vBeauty.frame = CGRectMake(0, self.view.mj_h-[TCBeautyPanel getHeight] - self.vBeauty.bottomOffset , self.view.mj_w, [TCBeautyPanel getHeight] + self.vBeauty.bottomOffset);
                }
                break;
            case 1:
                {
                    if (!self.livePusher.frontCamera) {
                        [YXProgressHUD showSuccess:[YXLanguageUtility kLangWithKey:@"live_invalid_mirroring"]];
                        return;
                    }
                    sender.selected = !sender.selected;
                    self.isMirror = !self.isMirror;
                    [self.livePusher setMirror:self.isMirror];
                    if (self.isMirror) {
                       [YXProgressHUD showSuccess:[YXLanguageUtility kLangWithKey:@"live_view_same"]];
                    } else {
                        [YXProgressHUD showSuccess:[YXLanguageUtility kLangWithKey:@"live_view_dif"]];
                    }
                }
                break;
            case 2:
                {
                    [self.livePusher switchCamera];
                }
                break;
            case 3:
                {
                    YXAlertView *alert = [YXAlertView alertViewWithMessage:[YXLanguageUtility kLangWithKey:@"live_is_out"]];
                    YXAlertAction *cancel = [[YXAlertAction alloc] initWithTitle:[YXLanguageUtility kLangWithKey:@"common_cancel"] style:YXAlertActionStyleCancel handler:^(YXAlertAction * _Nonnull action) {
                        [alert hideView];
                        
                    }];
                    YXAlertAction *confirm = [[YXAlertAction alloc] initWithTitle:[YXLanguageUtility kLangWithKey:@"common_confirm2"] style:YXAlertActionStyleDefault handler:^(YXAlertAction * _Nonnull action) {
                        @strongify(self);
                        [alert hideView];
                        [self showEndView];
                        [[self.viewModel.closeLiveCommand execute:nil] subscribeNext:^(id  _Nullable x) {
                        }];
                    }];
                    [alert addAction:cancel];
                    [alert addAction:confirm];
                    [alert showInWindow];
                }
                break;
                
            default:
                break;
        }
    }];
}

#pragma mark - action

- (void)goBack {

    [self destroyRoom];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)destroyRoom {
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    if (self.countFlag > 0) {
        [[YXTimerSingleton shareInstance] invalidOperationWithFlag:self.countFlag];
    }
    
    [self.livingView closeCommentTimer];
    self.vBeauty.actionPerformer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_vBeauty removeFromSuperview];
    _vBeauty = nil;
    
    self.livePusher.delegate = nil;
    [self.livePusher stopPreview];
    [self.livePusher stopPush];
    
    _livePusher = nil;
    _preView = nil;
    _livingView = nil;
}


- (void)showEndView {
    [self destroyRoom];
    self.endView.frame = CGRectMake(0, YXConstant.screenHeight, YXConstant.screenWidth, YXConstant.screenHeight);
    self.endView.liveModel = self.viewModel.liveModel;
    [self.view addSubview:self.endView];
    [UIView animateWithDuration:0.5 animations:^{
        self.endView.mj_y = 0;
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_vBeauty.hidden == NO) {
        _vBeauty.hidden = YES;
        if (!self.isLiving) {
            self.preView.hidden = NO;
        }
    }
}


- (void)loadLiveData {
    
    @weakify(self);
    [[self.viewModel.getLiveDetail execute:nil] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        
        NSInteger status = self.viewModel.liveModel.status;
        if (status > 4) {
            // 直播状态异常
            YXAlertView *alertView = [YXAlertView alertViewWithMessage:[YXLanguageUtility kLangWithKey:@"live_check"]];
            YXAlertAction *confirm = [[YXAlertAction alloc] initWithTitle:[YXLanguageUtility kLangWithKey:@"common_iknow"] style:YXAlertActionStyleDefault handler:^(YXAlertAction * _Nonnull action) {
                [alertView hideInWindow];
                [self showEndView];
            }];
            [alertView addAction:confirm];
            return;
        }
        
        if (status == 3) {
            [self.preView.beginBtn setTitle:[YXLanguageUtility kLangWithKey:@"live_continue"] forState:UIControlStateNormal];
        } else {
            [self.preView.beginBtn setTitle:[YXLanguageUtility kLangWithKey:@"live_start"] forState:UIControlStateNormal];
        }
        
        NSString *imageUrl = self.viewModel.liveModel.cover_images.image.firstObject;
        if (imageUrl.length > 0) {
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:imageUrl] completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                if (image) {
                    self.config.pauseImg = image;
                }
            }];
        }
    }];
    
}

- (void)updateCountData {
    @weakify(self);
    [[self.viewModel.getLiveCountCommand execute: nil] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.livingView.liveModel = self.viewModel.liveModel;
    }];
    [[self.viewModel.getwatchCountCommand execute: nil] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.livingView.liveModel = self.viewModel.liveModel;
    }];
}
#pragma mark - 美颜滤镜相关接口函数

- (void)setBeautyStyle:(TX_Enum_Type_BeautyStyle)beautyStyle beautyLevel:(float)beautyLevel whitenessLevel:(float)whitenessLevel ruddinessLevel:(float)ruddinessLevel {
    TXBeautyManager *manager = [_livePusher getBeautyManager];
    [manager setBeautyStyle:(TXBeautyStyle)beautyStyle];
    [manager setBeautyLevel:beautyLevel];
    [manager setWhitenessLevel:whitenessLevel];
    [manager setRuddyLevel:ruddinessLevel];
}

- (void)setBeautyStyle:(NSInteger)beautyStyle {
    [[_livePusher getBeautyManager] setBeautyStyle:beautyStyle];
}

- (void)setBeautyLevel:(float)level {
    [[_livePusher getBeautyManager] setBeautyLevel:level];
}

- (void)setWhitenessLevel:(float)level {
    [[_livePusher getBeautyManager] setWhitenessLevel:level];
}

- (void)setRuddyLevel:(float)level {
    [[_livePusher getBeautyManager] setRuddyLevel:level];
}

- (void)setFilter:(UIImage *)image {
    [[self.livePusher getBeautyManager] setFilter:image];
}
- (void)setFilterStrength:(float)level {
    [[self.livePusher getBeautyManager] setFilterStrength:level];
}

- (void)setEyeScaleLevel:(float)eyeScaleLevel {
    [[self.livePusher getBeautyManager] setEyeScaleLevel:eyeScaleLevel];
}

- (void)setFaceScaleLevel:(float)faceScaleLevel {
    [[self.livePusher getBeautyManager] setFaceSlimLevel:faceScaleLevel];
}

- (void)setSpecialRatio:(float)specialValue {
    [self.livePusher setSpecialRatio:specialValue];
}

- (void)setFaceVLevel:(float)faceVLevel {
    [[self.livePusher getBeautyManager] setFaceVLevel:faceVLevel];
}

- (void)setChinLevel:(float)chinLevel {
    [[self.livePusher getBeautyManager] setChinLevel:chinLevel];
}

- (void)setFaceShortLevel:(float)faceShortlevel {
    [[self.livePusher getBeautyManager] setFaceShortLevel:faceShortlevel];
}

- (void)setNoseSlimLevel:(float)noseSlimLevel {
    [[self.livePusher getBeautyManager] setNoseSlimLevel:noseSlimLevel];
}

- (void)setMotionTmpl:(NSString *)tmplName inDir:(NSString *)tmplDir {
    [[self.livePusher getBeautyManager] setMotionTmpl:tmplName inDir:tmplDir];
}

- (void)setGreenScreenFile:(NSString *)file {
    [[self.livePusher getBeautyManager] setGreenScreenFile:file];
}

#pragma mark - TXLivePushListener
-(void) onPushEvent:(int)EvtID withParam:(NSDictionary*)param {
    if (EvtID == PUSH_EVT_PUSH_BEGIN) {
//        [self onPushBegin];
    } else if (EvtID == PUSH_ERR_NET_DISCONNECT || EvtID == PUSH_ERR_INVALID_ADDRESS) {
        
//        NSString *errMsg = @"推流断开，请检查网络设置";
//        if (self.createRoomCompletion) {
//            self.createRoomCompletion(ROOM_ERR_CREATE_ROOM, errMsg);
//            self.createRoomCompletion = nil;
//
//        } else if (self.joinAnchorCompletion) {
//            self.joinAnchorCompletion(ROOM_ERR_PUSH_DISCONNECT, errMsg);
//        } else {
//            dispatch_async(self.delegateQueue, ^{
//                [self.delegate onError:ROOM_ERR_PUSH_DISCONNECT errMsg:errMsg extraInfo:nil];
//            });
//        }
//        [YXProgressHUD showMessage:@"推流断开，请检查网络设置"];
        
        YXAlertView *alert = [YXAlertView alertViewWithMessage:[YXLanguageUtility kLangWithKey:@"live_retry"]];
        YXAlertAction *cancel = [[YXAlertAction alloc] initWithTitle:[YXLanguageUtility kLangWithKey:@"common_cancel"] style:YXAlertActionStyleCancel handler:^(YXAlertAction * _Nonnull action) {
            [alert hideView];
            
        }];
        @weakify(self)
        YXAlertAction *confirm = [[YXAlertAction alloc] initWithTitle:[YXLanguageUtility kLangWithKey:@"common_confirm2"] style:YXAlertActionStyleDefault handler:^(YXAlertAction * _Nonnull action) {
            @strongify(self)
            
            [alert hideView];
            [self.livePusher stopPush];
            [self.livePusher startPush:self.viewModel.liveModel.push_url];
        }];
        [alert addAction:cancel];
        [alert addAction:confirm];
        [alert showInWindow];
        
    } else if (EvtID == PUSH_WARNING_NET_BUSY)  {
        // 网络差
        [YXProgressHUD showMessage:[YXLanguageUtility kLangWithKey:@"live_network"]];
    } else if (EvtID == PUSH_ERR_OPEN_CAMERA_FAIL) {
        NSString *errMsg = [YXLanguageUtility kLangWithKey:@"live_obtain_camera"];
        [YXProgressHUD showMessage:errMsg];
    } else if (EvtID == PUSH_ERR_OPEN_MIC_FAIL) {
        NSString *errMsg = [YXLanguageUtility kLangWithKey:@"live_obtain_micro"];
        [YXProgressHUD showMessage:errMsg];
    }
}

#pragma mark - 前后台切换
- (void)willResignActive:(NSNotification *)notification {
    if (self.isLiving) {
        [self.livePusher pausePush];
    }
}

- (void)didBecomeActive:(NSNotification *)notification {
    if (self.isLiving) {
        [self.livePusher resumePush];
    }
}


#pragma mark - lazy load
- (YXLivePreView *)preView {
    if (_preView == nil) {
        _preView = [[YXLivePreView alloc] init];
    }
    return _preView;
}

- (YXLivingView *)livingView {
    if (_livingView == nil) {
        _livingView = [[YXLivingView alloc] init];
        _livingView.hidden = YES;
    }
    return _livingView;
}

- (YXLiveEndView *)endView {
    if (_endView == nil) {
        _endView = [[YXLiveEndView alloc] init];
        
        @weakify(self);
        [_endView setBtnClickCallBack:^(UIButton * _Nonnull sender) {
            @strongify(self);
            switch (sender.tag) {
                case 0:
                {
                    // 关闭
                    [self.navigationController popViewControllerAnimated:YES];
                }
                    break;
                case 1:
                {
                    
                }
                    break;
                    
                default:
                    break;
            }
        }];
    }
    return _endView;
}

@end
