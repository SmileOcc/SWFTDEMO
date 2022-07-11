//
//  YXStareSettingVC.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/1/20.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStareSettingVC.h"
#import "uSmartOversea-Swift.h"
#import "YXStareSettingViewModel.h"
#import "YXStareSignalModel.h"
#import "YXStareMyPushViewModel.h"
#import <Masonry/Masonry.h>
#import "YXStareMyPushVC.h"

@interface YXStareSettingVC ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) YXTableView *tableView;
@property (nonatomic, strong) YXStareSettingViewModel *viewModel;

@property (nonatomic, assign) BOOL isOpenWetChat;

@property (nonatomic, assign) BOOL isIntelligentPush;

@end

@implementation YXStareSettingVC
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = [YXLanguageUtility kLangWithKey:@"monitor_push_setting"];
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadPushData];
}

- (void)initUI {

    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:[YXLanguageUtility kLangWithKey:@"monitor_my_push"] style:(UIBarButtonItemStylePlain) target:self action:@selector(rightBarItemAction)];
    [rightBarItem setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14], NSForegroundColorAttributeName : QMUITheme.textColorLevel1} forState:UIControlStateNormal];
    [rightBarItem setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14], NSForegroundColorAttributeName : QMUITheme.textColorLevel1} forState:UIControlStateSelected];
    self.navigationItem.rightBarButtonItems = @[rightBarItem];
    [self.view addSubview:self.tableView];
    
    
    [self.tableView registerClass:[YXPushNotiCell class] forCellReuseIdentifier:@"YXPushNotiCell"];
    [self.tableView registerClass:[YXPushRangeCell class] forCellReuseIdentifier:@"YXPushRangeCell"];
    [self.tableView registerClass:[YXPushSwitchCell class] forCellReuseIdentifier:@"YXPushSwitchCell"];
    
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.top.equalTo(self.view);
    }];
    
    [self loadSignalData];
}

- (void)rightBarItemAction {
    NSDictionary *dic = @{};
    if (self.viewModel.pushList) {
        dic = @{@"list": self.viewModel.pushList};
    }
    YXStareMyPushViewModel *viewModel = [[YXStareMyPushViewModel alloc] initWithServices:self.viewModel.services params:dic];
    YXStareMyPushVC *vc = [[YXStareMyPushVC alloc] initWithViewModel:viewModel];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)loadSignalData {
    @weakify(self);
    [[self.viewModel.loadSettingListRequestCommand execute: nil] subscribeNext:^(NSArray *list) {
        @strongify(self);
        [self.tableView reloadData];
    }];
}

- (void)loadPushData {
    @weakify(self);
    [[self.viewModel.loadPushSettingListRequestCommand execute: nil] subscribeNext:^(NSArray *list) {
        @strongify(self);
        for (YXStarePushSettingModel *model in self.viewModel.pushList) {
            if (model.type == 4) {
                // 微信
                for (YXStarePushSettingSubModel *subModel in model.list) {
                    self.isOpenWetChat = subModel.status;
                }
            } else if (model.type == 2) {
                // 智能筛选
                for (YXStarePushSettingSubModel *subModel in model.list) {
                    self.isIntelligentPush = subModel.status;
                }
            }
            
        }
        [self.tableView reloadData];
    }];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 1;
    } else {
        return self.viewModel.signalList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    @weakify(self);
    if (indexPath.section == 0) {
        YXPushNotiCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YXPushNotiCell" forIndexPath:indexPath];
        cell.wetchatNotiBtn.selected = self.isOpenWetChat;
        cell.yxNotiBtn.selected = !self.isOpenWetChat;
        [cell setClickBtnCallBack:^(BOOL on) {
            @strongify(self);
            NSDictionary *dic = @{
                @"type": @(4),
                @"list": @[@{
                               @"status": on ? @(1) : @(0),
                               @"identifier": @"",
                }],
            };
            [[self.viewModel.updatePushSettingListRequestCommand execute: dic] subscribeNext:^(id x) {
//                NSString *title = @"";
//                if (on) {
//                    title = [YXLanguageUtility kLangWithKey:@"push_type_wechat"];
//                } else {
//                    title = [YXLanguageUtility kLangWithKey:@"push_type_app"];
//                }
                if (x) {
                    [QMUITips showWithText:[YXLanguageUtility kLangWithKey:@"monitor_push_open_success"]];
                    self.isOpenWetChat = on;
                } else {
                    [QMUITips showWithText:[YXLanguageUtility kLangWithKey:@"monitor_push_open_fail"]];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
            }];
            
        }];
        
        [cell setBindWetChatCallBack:^{
            //@strongify(self);
            [YXWebViewModel pushToWebVC:YXH5Urls.YX_BIND_WECHAT_PAGE_URL];
        }];
        
        return cell;
    } else if (indexPath.section == 1) {
        YXPushRangeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YXPushRangeCell" forIndexPath:indexPath];
        cell.globalPushBtn.selected = !self.isIntelligentPush;
        cell.intelligentPushBtn.selected = self.isIntelligentPush;
        
        [cell setClickBtnCallBack:^(BOOL on) {
            @strongify(self);
            NSDictionary *dic = @{
                @"type": @(2),
                @"list": @[@{
                               @"status": on ? @(1) : @(0),
                               @"identifier": @"",
                }],
            };
            [[self.viewModel.updatePushSettingListRequestCommand execute: dic] subscribeNext:^(id x) {
//                NSString *title = @"";
//                if (on) {
//                    title = [YXLanguageUtility kLangWithKey:@"push_area_smart"];
//                } else {
//                    title = [YXLanguageUtility kLangWithKey:@"push_area_all"];
//                }
                if (x) {
                    [QMUITips showWithText:[YXLanguageUtility kLangWithKey:@"monitor_push_open_success"]];
                    self.isIntelligentPush = on;
                } else {
                    [QMUITips showWithText:[YXLanguageUtility kLangWithKey:@"monitor_push_open_fail"]];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
            }];
        }];
        
        return cell;
    } else {
        YXPushSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YXPushSwitchCell" forIndexPath:indexPath];
        YXStareSignalSettingModel *model = self.viewModel.signalList[indexPath.row];
        cell.model = model;
        
        [cell setStChangeCallBack:^(YXStareSignalSettingModel * _Nullable model) {
            @strongify(self);
            [[self.viewModel.updateSettingListRequestCommand execute: nil] subscribeNext:^(id x) {
                if (x) {
                    if (model.Defult == 1) {
                        [QMUITips showWithText:[YXLanguageUtility kLangWithKey:@"monitor_push_open_success"]];
                    } else {
                        [QMUITips showWithText:[YXLanguageUtility kLangWithKey:@"monitor_push_close_success"]];
                    }

                } else {
                    if (model.Defult == 1) {
                        [QMUITips showWithText:[YXLanguageUtility kLangWithKey:@"monitor_push_open_fail"]];
                    } else {
                        [QMUITips showWithText:[YXLanguageUtility kLangWithKey:@"monitor_push_close_fail"]];
                    }
                    model.Defult = (model.Defult == 0) ? 1 : 0;
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
            }];
        }];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 78;
    } else if (indexPath.section == 1) {
        return 44;
    } else {
        return 44;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return [self getSectionViewWithTitle:[YXLanguageUtility kLangWithKey:@"push_type_setting"]];
    } else if (section == 1) {
        return [self getSectionViewWithTitle:[YXLanguageUtility kLangWithKey:@"push_area_setting"]];
    } else {
        return [self getSectionViewWithTitle:[YXLanguageUtility kLangWithKey:@"push_condition_setting"]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.1f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (UIView *)getSectionViewWithTitle: (NSString *)title {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, 30)];
    view.backgroundColor = QMUITheme.foregroundColor;
    UILabel *label = [UILabel labelWithText:title textColor:QMUITheme.textColorLevel3 textFont:[UIFont systemFontOfSize:14]];
    label.frame = CGRectMake(12, 0, 200, 30);
    [view addSubview:label];
    
    return view;
}

#pragma mark - 懒加载
- (YXTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[YXTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = QMUITheme.foregroundColor;
    }
    return _tableView;
}

@end
