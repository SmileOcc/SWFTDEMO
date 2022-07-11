//
//  YXNoticeAppViewController.m
//  YouXinZhengQuan
//
//  Created by suntao on 2021/1/7.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXNoticeAppViewController.h"
#import "YXNoticeAppViewModel.h"
#import "uSmartOversea-Swift.h"
#import "YXMineNoticeCell.h"
#import "YXPushNewsSubCell.h"
#import "YXNoticeSettingModel.h"
#import "YXStareSignalModel.h"
#import <Masonry/Masonry.h>

@interface YXNoticeAppViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong, readonly) YXNoticeAppViewModel *viewModel;

@property (nonatomic, strong) UIView * tipView;

@end

@implementation YXNoticeAppViewController
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUI];
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidBecomeActiveNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self updateNoticeData];
    }];
}



- (void)initUI
{
    self.title = [YXLanguageUtility kLangWithKey:@"user_notice"];
//    self.navigationItem.rightBarButtonItem = self.messageItem;
    self.tableView.rowHeight = 44;
    [self.tableView registerClass:[YXMineNoticeCell class] forCellReuseIdentifier:NSStringFromClass([YXMineNoticeCell class])];
    [self.tableView registerClass:[YXPushNewsSubCell class] forCellReuseIdentifier:NSStringFromClass([YXPushNewsSubCell class])];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.top.equalTo(self.view);
    }];
    self.tableView.backgroundColor = [QMUITheme backgroundColor];
        
}

-(void)bindViewModel
{
    [super bindViewModel];
    @weakify(self);
    [self.viewModel.getSettingSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
    
    [self loadPushData];
    
}

#pragma mark - Private


//更新数据源
- (void)updateNoticeData {
    [self.viewModel resetData];
}

- (void)loadPushData {
    @weakify(self);
    [[self.viewModel.smLoadPushSettingListRequestCommand execute: nil] subscribeNext:^(NSArray *list) {
        @strongify(self);
        [self.tableView reloadData];
    }];
}


#pragma mark - TableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  self.viewModel.settingList.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    YXNoticeGroupSettingModel * group = self.viewModel.settingList[section];
    return group.settings.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    YXNoticeGroupSettingModel *group = self.viewModel.settingList[section];
    
    if ([group.gruopId isEqualToString:@"push_all_smart"]) {
        return CGFLOAT_MIN;
    }
    
    return group.title.length > 0 ? 30 : CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    YXNoticeGroupSettingModel *group = self.viewModel.settingList[section];
    if ([group.gruopId isEqualToString:@"push_all_smart"] && group.settings.count>0) {
        return self.tipView.mj_h;
    }
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    YXNoticeGroupSettingModel *group = self.viewModel.settingList[section];
    if ([group.gruopId isEqualToString:@"push_all_smart"]) {
        return  [UIView new];
    }
    if (group.title.length > 0) {
        YXNoticeGroupSettingModel *group = self.viewModel.settingList[section];
        UIView *v = [[UIView alloc] init];
        v.backgroundColor = [QMUITheme backgroundColor];
        UILabel *label = [UILabel labelWithText:group.title textColor:QMUITheme.textColorLevel3 textFont:[UIFont normalFont12]];
        label.frame = CGRectMake(16, 0, 200, 30);
        [v addSubview:label];
        return v;
    }
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    YXNoticeGroupSettingModel *group = self.viewModel.settingList[section];
    if ([group.gruopId isEqualToString:@"push_all_smart"] && group.settings.count>0) {
        return self.tipView;
    }
    return  [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YXNoticeGroupSettingModel * group = self.viewModel.settingList[indexPath.section];
    YXNoticeSettingModel * model = group.settings[indexPath.row];
    if ([group.gruopId isEqualToString:@"push_all_smart"] && group.settings.count>0) {
        return 48;
    }
    if (model.isSubCell) {
        return 38;
    }
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    YXNoticeGroupSettingModel *group = self.viewModel.settingList[indexPath.section];
    YXNoticeSettingModel *model = group.settings[indexPath.row];
     if ([model.httpDataKey isEqual:@"news"] && model.isSubCell) {
         YXPushNewsSubCell * cell = [YXPushNewsSubCell cellWithTableView:tableView];
         cell.model = model;
         @weakify(self)
         cell.selectedBlock = ^(YXNoticeSettingModel *  model) {
             @strongify(self)
             [[self.viewModel.updateSettingCommand execute:model] subscribeNext:^(NSNumber *  _Nullable success) {
                 NSString *title = @"";
             }];
         };
         return cell;
     }else{
         YXMineNoticeCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YXMineNoticeCell class])];
         if (cell == nil) {
             cell = [[YXMineNoticeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([YXMineNoticeCell class])];
         }
         cell.model = model;
         
         @weakify(self);
         [[[cell.switchView rac_signalForControlEvents:UIControlEventValueChanged] takeUntil:cell.rac_prepareForReuseSignal] subscribeNext:^(__kindof UISwitch * _Nullable st) {
             @strongify(self);
             model.isOn = !st.isOn;
             if ([model.settingId isEqualToString:@"smQuote"]) {
                 BOOL newValue = st.isOn;
                 NSDictionary *dic = @{
                     @"type": @(model.smType),
                     @"list": @[@{
                                    @"status": newValue ? @(1) : @(0),
                                    @"identifier": model.identifier?:@"",
                     }],
                 };
                 [[self.viewModel.smUpdatePushSettingListRequestCommand execute: dic] subscribeNext:^(id x) {
                     NSString *titleText = @"";
                    
                     if (x) {
                         if (newValue) {
                             titleText = @"monitor_push_open_success";
                         } else {
                             titleText = @"monitor_push_close_success";
                         }
                        
                         model.isOn = newValue;
                     } else {
                         if (newValue) {
                             titleText = @"monitor_push_open_fail";
                         } else {
                             titleText = @"monitor_push_close_fail";
                         }
                         model.isOn = !newValue;
                         [st setOn:model.isOn animated:YES];
                     }
                     [YXProgressHUD showMessage: [YXLanguageUtility kLangWithKey:titleText]];
                 }];
             }else{
                 BOOL openValue = st.isOn;
                 [[self.viewModel.updateSettingCommand execute:model] subscribeNext:^(NSNumber *  _Nullable success) {
                     NSString *titleText = @"";
                
                     if (success.boolValue) {
                         if (openValue) {
                             titleText = @"monitor_push_open_success";
                         } else {
                             titleText = @"monitor_push_close_success";
                         }
                         
                     }else{
                         if (success.intValue == 2) {
                             if (openValue) {
                                 titleText = @"monitor_push_open_fail";
                             } else {
                                 titleText = @"monitor_push_close_fail";
                             }
                         }
                     }
                     [YXProgressHUD showMessage: [YXLanguageUtility kLangWithKey:titleText]];
                 }];
             }
         
         }];
         
         return cell;
     }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    YXNoticeGroupSettingModel *group = self.viewModel.settingList[indexPath.section];
    if ([group.gruopId isEqualToString:@"push_all_smart"] && group.settings.count>0) {
        YXNoticeSettingModel * model = group.settings[0];
        if (!model.isOn) {
            [self alertPop];
        }else{
            [self gotoSetPush];
        }
        return;
    }
    
}

-(void)alertPop
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[YXLanguageUtility kLangWithKey:@"mine_send_noti"]  message:[YXLanguageUtility kLangWithKey:@"mine_noti"]  preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"mine_no_allow"]  style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }];
    @weakify(self)
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"mine_allow"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self)
        [self gotoSetPush];
    }];

    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}



-(void)gotoSetPush
{
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([application canOpenURL:url]) {
        [application openURL:url options:@{} completionHandler:nil];
    }
}

#pragma mark - Getter

-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style: UITableViewStyleGrouped];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.contentInset = UIEdgeInsetsMake(8, 0, 0, 0);
        _tableView.contentOffset = CGPointMake(0, 8);
    }
    return _tableView;
}

-(UIView *)tipView
{
    if (!_tipView) {
        
        NSString *tipStr = [YXLanguageUtility kLangWithKey:@"mine_noti_close"];
        CGFloat height = [YXToolUtility getStringSizeWith:tipStr andFont:[UIFont normalFont12] andlimitWidth:YXConstant.screenWidth - 32].height;
        
        _tipView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, height + 16)];
        _tipView.backgroundColor = QMUITheme.foregroundColor;
        UILabel * label = [[UILabel alloc] init];
        label.font = [UIFont normalFont12];
        label.text = tipStr;
        label.textColor = QMUITheme.textColorLevel4;
        label.numberOfLines = 0;
        [_tipView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(16);
            make.top.bottom.equalTo(self.tipView);
            make.right.mas_equalTo(-16);
        }];
    }
    
    return  _tipView;
}



@end
