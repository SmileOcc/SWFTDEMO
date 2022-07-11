//
//  YXStareMyPushVC.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/2/6.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStareMyPushVC.h"
#import "uSmartOversea-Swift.h"
#import "YXStareMyPushViewModel.h"
#import "YXStareSignalModel.h"
#import <Masonry/Masonry.h>

@interface YXStareMyPushVC ()
@property (nonatomic, strong, readwrite) YXStareMyPushViewModel *viewModel;
@end

@implementation YXStareMyPushVC

@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = [YXLanguageUtility kLangWithKey:@"monitor_my_push"];
    self.tableView.backgroundColor = QMUITheme.foregroundColor;
}

#pragma mark - UITableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *arr = self.viewModel.dataSource[section];
    YXStarePushSettingSubModel *model = arr.lastObject;
    if (!model.isShow) {
        return 0;
    } else {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}

- (CGFloat)rowHeight {
    return 50;
}

- (NSArray<Class> *)cellClasses {
    return @[[YXPushSwitchCell class], [YXPushSwitchCell class], [YXPushSwitchCell class]];
}
 
- (void)configureCell:(YXPushSwitchCell *)cell atIndexPath:(NSIndexPath *)indexPath withObject:(id)object {
 
    NSArray *arr = self.viewModel.dataSource[indexPath.section];
    YXStarePushSettingSubModel *model = arr[indexPath.row];
    cell.label.font = [UIFont systemFontOfSize:14];
    cell.label.textColor = QMUITheme.textColorLevel2;
    if (model.type == 5) {
        cell.label.text = [YXLanguageUtility kLangWithKey:@"hold_holds"];
    } else if (model.type == 0) {
        cell.label.text = [YXLanguageUtility kLangWithKey:@"smart_selfStock"];
    } else {
        cell.label.text = model.name;
    }
    BOOL on = model.status;
    [cell.st setOn:on];
    @weakify(self);
    @weakify(model);
    @weakify(cell);
    [cell setStChangeCallBack:^(YXStareSignalSettingModel * _Nullable tmp) {
        @strongify(self);
        @strongify(model);
        @strongify(cell);
        BOOL newValue = cell.st.on;
        // 不用此tmp
        NSDictionary *dic = @{
            @"type": @(model.type),
            @"list": @[@{
                           @"status": newValue ? @(1) : @(0),
                           @"identifier": model.identifier?:@"",
            }],
        };
        [[self.viewModel.updatePushSettingListRequestCommand execute: dic] subscribeNext:^(id x) {
            if (x) {
                if (newValue) {
                    [QMUITips showWithText:[YXLanguageUtility kLangWithKey:@"monitor_push_open_success"]];
                } else {
                    [QMUITips showWithText:[YXLanguageUtility kLangWithKey:@"monitor_push_close_success"]];
                }
                model.status = newValue;
            } else {
                if (newValue) {
                    [QMUITips showWithText:[YXLanguageUtility kLangWithKey:@"monitor_push_open_fail"]];
                } else {
                    [QMUITips showWithText:[YXLanguageUtility kLangWithKey:@"monitor_push_close_fail"]];
                }
                model.status = !newValue;
                [cell.st setOn:model.status animated:YES];
            }
        }];
    }];
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self getSecontionViewWithSection:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = QMUITheme.foregroundColor;
    return view;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20;
}

- (UIView *)getSecontionViewWithSection:(NSInteger )section {
    
    NSArray *arr = self.viewModel.dataSource[section];
    YXStarePushSettingSubModel *model = arr.lastObject;
    NSString *title = [YXLanguageUtility kLangWithKey:@"option_and_hold"];
    if (model.type == 0 || model.type == 5) {
        title = [YXLanguageUtility kLangWithKey:@"option_and_hold"];
    } else if (model.type == 1) {
        title = [YXLanguageUtility kLangWithKey:@"industry"];
    } else {
        title = [YXLanguageUtility kLangWithKey:@"new_stock"];
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, 40)];
    view.backgroundColor = QMUITheme.foregroundColor;
    
//    UISwitch *st = [[UISwitch alloc] init];
//    st.transform = CGAffineTransformMakeScale(0.75, 0.75);
//
//    st.onTintColor = QMUITheme.themeTintColor;
    
    QMUIButton *btn = [[QMUIButton alloc] init];
    btn.imagePosition = QMUIButtonImagePositionRight;
    btn.spacingBetweenImageAndTitle = 4;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:QMUITheme.textColorLevel1 forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    [btn setImage:[UIImage imageNamed:@"market_arrow_WhiteSkin"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(sectionClick:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = section;
    [view addSubview:btn];
//    [view addSubview:st];

    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(view).offset(12);
        make.centerY.equalTo(view);
    }];
    
//    [st mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.trailing.equalTo(view).offset(-12);
//        make.centerY.equalTo(view);
//    }];
    
    return view;
}

- (void)sectionClick: (UIButton *)sender {
    YXStarePushSettingSubModel *model = [self.viewModel.dataSource[sender.tag] lastObject];
    model.isShow = !model.isShow;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sender.tag] withRowAnimation:UITableViewRowAnimationFade];
}

@end
