//
//  OSSVNotificationSettingsVC.m
//  DressOnline
//
//  Created by 10010 on 20/7/13.
//  Copyright © 2016年 Sammydress. All rights reserved.
//

#import "OSSVNotificationSettingsVC.h"
#import "STLPushManager.h"
#import "AppDelegate+STLNotification.h"

@interface OSSVNotificationSettingsVC ()
{
    BOOL _firstEnter;
}

@property (nonatomic, assign) BOOL                       switchEnable;
@property (nonatomic, strong) UISwitch                   *pushEnableSwitch;
@property (nonatomic, strong) UILabel                    *stateLab;

@end

@implementation OSSVNotificationSettingsVC

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerNotificationSuccess) name:kNotif_NotificationSuccess object:nil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!_firstEnter) {
    }
    _firstEnter = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = OSSVThemesColors.col_F6F6F6;
    
    [self drawSubviews];
    [self updatePushState];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInform:) name:kAppDidBecomeActiveNotification object:nil];

}



- (void)drawSubviews {
//    for (UIView *v in self.view.subviews) {
//        [v removeFromSuperview];
//    }
    
    // 推送状态
    UIView *notiStateBgView = [[UIView alloc] init];
    notiStateBgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:notiStateBgView];
    [notiStateBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.leading.mas_equalTo(0);
        make.top.mas_equalTo(30);
        make.height.mas_equalTo(40);
    }];
    
    UIView *notiBottomLine = [[UIView alloc] init];
    notiBottomLine.backgroundColor = OSSVThemesColors.col_DDDDDD;
    [notiStateBgView addSubview:notiBottomLine];
    [notiBottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(0);
        make.height.mas_equalTo(MIN_PIXEL);
    }];
    
    UIView *topLine = [[UIView alloc] init];
    topLine.backgroundColor = OSSVThemesColors.col_DDDDDD;
    [notiStateBgView addSubview:topLine];
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.leading.mas_equalTo(0);
        make.height.mas_equalTo(MIN_PIXEL);
    }];

    UILabel *nameLab = [self createLabel];
    nameLab.text = STLLocalizedString_(@"notifications", nil);
    nameLab.textAlignment = [OSSVSystemsConfigsUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
    [notiStateBgView addSubview:nameLab];
    [nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.leading.mas_equalTo(10);
        make.width.mas_equalTo((SCREEN_WIDTH-20)/2.0);
        make.height.mas_equalTo(40);
    }];
    
    UILabel *stateLab = [self createLabel];
    stateLab.textColor = [UIColor grayColor];
    stateLab.textAlignment = [OSSVSystemsConfigsUtils isRightToLeftShow] ? NSTextAlignmentLeft : NSTextAlignmentRight;
    [notiStateBgView addSubview:stateLab];
    self.stateLab = stateLab;
    
    [stateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.leading.mas_equalTo(nameLab.mas_trailing);
        make.trailing.mas_equalTo(-10);
        make.height.mas_equalTo(40);
    }];
    
    [self.view addSubview:self.pushEnableSwitch];

    [self.pushEnableSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(notiStateBgView.mas_trailing).mas_offset(-16);
        make.centerY.mas_equalTo(notiStateBgView);
    }];
    
    UILabel *stateTipLab = [self createLabel];
    stateTipLab.text = STLLocalizedString_(@"enableNotifi", nil);
    stateTipLab.textColor = OSSVThemesColors.col_999999;
    [self.view addSubview:stateTipLab];
    [stateTipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(notiStateBgView.mas_bottom);
        make.leading.mas_equalTo(10);
        make.trailing.mas_equalTo(-10);
        make.height.mas_equalTo(50);
    }];
    
//    if ([UIApplication sharedApplication].isRegisteredForRemoteNotifications) {
//        stateLab.text = STLLocalizedString_(@"enable", nil);
//    }else{
//        stateLab.text = STLLocalizedString_(@"disable", nil);
//        return;
//    }
//
//    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isRegisterNotification"])
//    {
//        stateLab.text = STLLocalizedString_(@"disable", nil);
//        return;
//    }
    
//    // Promotions and Sales
//    UIView *promotionsBgView = [[UIView alloc] init];
//    promotionsBgView.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:promotionsBgView];
//    [promotionsBgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(stateTipLab.mas_bottom);
//        make.leading.trailing.mas_equalTo(0);
//        make.height.mas_equalTo(40);
//    }];
//
//
//    UIView *bottomLine = [[UIView alloc] init];
//    bottomLine.backgroundColor = OSSVThemesColors.col_DDDDDD;
//    [promotionsBgView addSubview:bottomLine];
//    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.trailing.bottom.mas_equalTo(0);
//        make.height.mas_equalTo(MIN_PIXEL);
//    }];
//
//    UIView *line = [[UIView alloc] init];
//    line.backgroundColor = OSSVThemesColors.col_DDDDDD;
//    [promotionsBgView addSubview:line];
//    [line mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.trailing.leading.mas_equalTo(0);
//        make.height.mas_equalTo(MIN_PIXEL);
//    }];
//
//    UILabel *promotLab = [self createLabel];
//    promotLab.text = STLLocalizedString_(@"promotions", nil);
//    [promotionsBgView addSubview:promotLab];
//    [promotLab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(0);
//        make.leading.mas_equalTo(10);
//        make.width.mas_equalTo((SCREEN_WIDTH-20)/2.0);
//        make.height.mas_equalTo(40);
//    }];
//
//    UISwitch *promotSwitch = [[UISwitch alloc] init];
//    promotSwitch.onTintColor = OSSVThemesColors.col_FF6F00;
//    [promotSwitch addTarget:self action:@selector(promotSwitchState:) forControlEvents:UIControlEventValueChanged];
//    [promotionsBgView addSubview:promotSwitch];
//    [promotSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(5);
//        make.trailing.mas_equalTo(-10);
//        make.width.mas_equalTo(40);
//        make.height.mas_equalTo(30);
//    }];
    
    // Order Messages
//    UIView *orderBgView = [self createBgViewWithRect:CGRectMake(0, CGRectGetMaxY(promotionsBgView.frame), SCREEN_WIDTH, 40)];
//    [self.view addSubview:orderBgView];
//    
//    UILabel *orderLab = [self createLabelWithRect:CGRectMake(10, 0, SCREEN_WIDTH/2, 40)];
//    orderLab.text = STLLocalizedString_(@"orderMessages", nil);
//    [orderBgView addSubview:orderLab];
//    
//    UISwitch *orderSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 5, 40, 30)];
//    orderSwitch.onTintColor = OSSVThemesColors.col_FF6F00;
//    [orderSwitch addTarget:self action:@selector(orderSwitchState:) forControlEvents:UIControlEventValueChanged];
//    [orderBgView addSubview:orderSwitch];
    
    // 设置按钮默认状态
//    promotSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"promotionStatus"];
//    orderSwitch.on  = [[NSUserDefaults standardUserDefaults] boolForKey:@"orderMessageStatus"];

    
}

- (void)updateInform:(NSNotification *)notify {
    //进入【设置】修改通知后，在回到界面时，判断处理通知变化
    [self updatePushState];
}


- (void)updatePushState {
    
    //< ------- 第一种，不弹窗直接进入设置界面 ------- >
    @weakify(self)
    [STLPushManager isRegisterRemoteNotification:^(BOOL isRegister) {
        @strongify(self)
        self.switchEnable = isRegister;
        STLLog(@"--cccccccccc %i",isRegister);
    }];
    
    //< ------- 第二种，先弹窗 ------- >
    /**
    @weakify(self)
    [STLPushManager isRegisterRemoteNotification:^(BOOL isRegister) {
        @strongify(self)
        [self.pushAllowView hidden];
        self.switchEnable = isRegister;
        [self.tableView reloadData];
        STLLog(@"--cccccccccc %i",isRegister);
    }];
     */
}

-(void)pushSwitchAction:(UISwitch *)sender {
    
    //< ------- 第一种，不弹窗直接进入设置界面 ------- >
    // 注册远程推送通知
    self.switchEnable = sender.isOn;
    BOOL isPopAlert = [STLUserDefaultsGet(kHadShowSystemNotificationAlert) boolValue];
    if (isPopAlert) {
        //如果已经弹出过，就直接进入到系统推送页面
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        
    }else{
        [STLPushManager saveShowAlertTimestamp];

        [AppDelegate stlRegisterRemoteNotification:^(NSInteger openFlag) {
            /**
             * ⚠️⚠️⚠️⚠️⚠️
             * 需要在这里回调，从系统设置再次进入app时，
             * 1、先触发重新活动的通知触发的方法，通知更新的信息方法，不是最新状态，自己获取的状态可能是错的
             * 2、在重新更新状态
             */
            [self updatePushState];
        }];
    }
    
    //< ------- 第二种，先弹窗 ------- >
    /**
     * ⚠️⚠️⚠️⚠️⚠️
     * 需要在这里回调，从系统设置再次进入app时，
     * 1、先触发重新活动的通知触发的方法，通知更新的信息方法，不是最新状态，自己获取的状态可能是错的
     * 2、在重新更新状态
     */
    /**
     self.switchEnable = sender.isOn;
     @weakify(self)
     [self.pushAllowView noLimitShow:PushAllowViewType_Msg operateBlock:^(BOOL flag) {
         @strongify(self)
         [self updatePushState];
     }];
     */
}

-(void)setSwitchEnable:(BOOL)switchEnable
{
    _switchEnable = switchEnable;
    
    if (_switchEnable) {
        self.stateLab.hidden = NO;
        self.pushEnableSwitch.hidden = YES;
        self.stateLab.text = STLLocalizedString_(@"enable", nil);
    }else{
        self.stateLab.hidden = YES;
        self.pushEnableSwitch.hidden = NO;
        [self.pushEnableSwitch setOn:NO];
    }
}

- (UISwitch *)pushEnableSwitch
{
    if (!_pushEnableSwitch) {
        _pushEnableSwitch = ({
            UISwitch *cellSwitch = [[UISwitch alloc] init];
            [cellSwitch addTarget:self action:@selector(pushSwitchAction:) forControlEvents:UIControlEventValueChanged];
            cellSwitch;
        });
    }
    return _pushEnableSwitch;
}

- (UIView *)createBgViewWithRect:(CGRect)rect
{
    UIView *bgView = [[UIView alloc] initWithFrame:rect];
    bgView.backgroundColor = [UIColor whiteColor];
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, bgView.bounds.size.height-MIN_PIXEL, SCREEN_WIDTH, MIN_PIXEL)];
    bottomLine.backgroundColor = OSSVThemesColors.col_DDDDDD;
    [bgView addSubview:bottomLine];
    
    return bgView;
}

- (UILabel *)createLabel
{
    UILabel *lab = [[UILabel alloc] init];
    lab.font = [UIFont systemFontOfSize:14];
    lab.numberOfLines = 0;
    return lab;
}

#pragma mark - Action
- (void)promotSwitchState:(UISwitch *)promotSwitch
{
    
    [[NSUserDefaults standardUserDefaults] setBool:promotSwitch.on forKey:@"promotionStatus"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    

}

- (void)orderSwitchState:(UISwitch *)orderSwitch
{
    
    [[NSUserDefaults standardUserDefaults] setBool:orderSwitch.on forKey:@"orderMessageStatus"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)registerNotificationSuccess
{
    STLLog(@"通知");
    [self drawSubviews];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
