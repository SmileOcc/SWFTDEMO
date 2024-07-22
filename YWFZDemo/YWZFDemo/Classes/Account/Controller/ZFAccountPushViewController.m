//
//  ZFAccountPushViewController.m
//  ZZZZZ
//
//  Created by YW on 2018/8/16.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFAccountPushViewController.h"
#import "ZFAccountPushTableViewCell.h"
#import "AppDelegate+ZFNotification.h"
#import "ZFNewPushAllowView.h"
#import "ZFThemeManager.h"
#import "ZFAppsflyerAnalytics.h"
#import "ZFInitViewProtocol.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "ZFAnalytics.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFAccountPushViewController ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    ZFAccountPushTableViewCellDelegate,
    ZFInitViewProtocol
>
@property (nonatomic, strong) UITableView                *tableView;
@property (nonatomic, assign) BOOL                       switchEnable;

@property (nonatomic, strong) ZFNewPushAllowView        *pushAllowView;


@end

@implementation ZFAccountPushViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self zfInitView];
    [self zfAutoLayoutView];
    [self updatePushState];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInform:) name:kAppDidBecomeActiveNotification object:nil];
}

#pragma mark  <ZFInitViewProtocol>

- (void)zfInitView {
    self.title = ZFLocalizedString(@"Push_Notifications_Settings", nil);
    [self.view addSubview:self.tableView];
}

- (void)zfAutoLayoutView {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

#pragma mark - action

- (void)updateInform:(NSNotification *)notify {
    //进入【设置】修改通知后，在回到界面时，判断处理通知变化
    [self updatePushState];
}

- (void)updatePushState {
    
    //< ------- 第一种，不弹窗直接进入设置界面 ------- >
    @weakify(self)
    [ZFPushManager isRegisterRemoteNotification:^(BOOL isRegister) {
        @strongify(self)
        self.switchEnable = isRegister;
        [self.tableView reloadData];
        YWLog(@"--cccccccccc %i",isRegister);
    }];
    
    //< ------- 第二种，先弹窗 ------- >
    /**
    @weakify(self)
    [ZFPushManager isRegisterRemoteNotification:^(BOOL isRegister) {
        @strongify(self)
        [self.pushAllowView hidden];
        self.switchEnable = isRegister;
        [self.tableView reloadData];
        YWLog(@"--cccccccccc %i",isRegister);
    }];
     */
}

-(void)zfAccountPushTableViewCellDidClickSwitch:(UISwitch *)sender {
    
    //< ------- 第一种，不弹窗直接进入设置界面 ------- >
    // 注册远程推送通知
    self.switchEnable = sender.isOn;
    BOOL isPopAlert = [GetUserDefault(kHasShowSystemNotificationAlert) boolValue];
    if (isPopAlert) {
        //如果已经弹出过，就直接进入到系统推送页面
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        
    }else{
        [ZFPushManager saveShowAlertTimestamp];
        [ZFAppsflyerAnalytics analyticsPushEvent:@"Setting" remoteType:ZFOperateRemotePush_guide_yes];
        [AppDelegate registerZFRemoteNotification:^(NSInteger openFlag){
            /**
             * ⚠️⚠️⚠️⚠️⚠️
             * 需要在这里回调，从系统设置再次进入app时，
             * 1、先触发重新活动的通知触发的方法，通知更新的信息方法，不是最新状态，自己获取的状态可能是错的
             * 2、在重新更新状态
             */
            [self updatePushState];
            [ZFAnalytics appsFlyerTrackEvent:@"af_subscribe" withValues:@{}];
            
            // 统计推送点击量
            ZFOperateRemotePushType remoteType = ZFOperateRemotePush_sys_unKonw;
            if (openFlag == 1) {
                remoteType = ZFOperateRemotePush_sys_yes;
            } else if (openFlag == 0) {
                remoteType = ZFOperateRemotePush_sys_no;
            }
            [ZFAppsflyerAnalytics analyticsPushEvent:@"Setting" remoteType:remoteType];            
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

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFAccountPushTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.switchEnable = self.switchEnable;
    cell.delegate = self;
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UITableViewHeaderFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"footer"];
    if (!footerView) {
        footerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"footer"];
        UILabel *label = [[UILabel alloc] init];
        label.text = ZFLocalizedString(@"Push_Enable_Disable_Setting>Notifications>ZZZZZ", nil);
        [label convertTextAlignmentWithARLanguage];
        label.textColor = ColorHex_Alpha(0x999999, 1.0);
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:12];
        [footerView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(footerView).mas_offset(16);
            make.trailing.mas_equalTo(footerView.mas_trailing).mas_offset(-16);
            make.top.mas_equalTo(footerView).mas_offset(10);
            //make.bottom.mas_equalTo(footerView).mas_offset(-10);
        }];
    }
    return footerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = ZFC0xF2F2F2();
    return headerView;
}

#pragma mark - setter and getter

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
            tableView.backgroundColor = ZFC0xF2F2F2();
            tableView.showsVerticalScrollIndicator = NO;
            tableView.showsHorizontalScrollIndicator = NO;
            tableView.estimatedSectionFooterHeight = UITableViewAutomaticDimension;
            tableView.sectionFooterHeight = 120;
            tableView.separatorStyle = NO;
            tableView.delegate = self;
            tableView.dataSource = self;
            [tableView registerClass:[ZFAccountPushTableViewCell class] forCellReuseIdentifier:@"Cell"];
            tableView;
        });
    }
    return _tableView;
}

- (ZFNewPushAllowView *)pushAllowView {
    if (!_pushAllowView) {
        _pushAllowView = [[ZFNewPushAllowView alloc] init];
    }
    return _pushAllowView;
}

@end
