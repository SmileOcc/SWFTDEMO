//
//  YXStockReminderTypeController.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/26.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStockReminderTypeController.h"
#import "YXStockReminderTypeViewModel.h"
#import "YXStockReminderTypeCell.h"
#import "YXReminderModel.h"
#import "YXRemindTool.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXStockReminderTypeController ()

@property (nonatomic, strong) YXStockReminderTypeViewModel *viewModel;

@end

@implementation YXStockReminderTypeController

@dynamic viewModel;


- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
}

- (void)bindViewModel {
    [super bindViewModel];
}


- (void)initUI {
    self.title = [YXLanguageUtility kLangWithKey:@"remind_alert_type"];
    self.tableView.backgroundColor = QMUITheme.foregroundColor;
    self.tableView.rowHeight = 51;
    self.tableView.sectionFooterHeight = 0.01;
    
    UIBarButtonItem *backItem = [UIBarButtonItem qmui_itemWithImage:[UIImage imageNamed:@"nav_back"] target:self action:@selector(goback)];
    self.navigationItem.leftBarButtonItems = @[backItem];
    
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = NO;
    }
}


- (void)goback {
    if (self.viewModel.comeFromPop) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
                    
        }];
    }
}


#pragma mark - tableView

- (NSDictionary *)cellIdentifiers {
    return @{@"YXStockReminderTypeCell": @"YXStockReminderTypeCell"};
}

- (NSString *)cellIdentifierAtIndexPath:(NSIndexPath *)aIndexPath {
    return @"YXStockReminderTypeCell";
}

- (void)configureCell:(YXStockReminderTypeCell *)cell atIndexPath:(NSIndexPath *)indexPath withObject:(NSNumber *)remindIndex{
    
//    cell.iconImageView.image = [UIImage imageNamed:[YXRemindTool getImageNameWithType:remindIndex.integerValue]];
    cell.nameLabel.text = [YXRemindTool getTitleWithType:remindIndex.integerValue];
    
    if (remindIndex.integerValue == self.viewModel.selecType) {
        cell.selectImageView.hidden = NO;
    } else {
        cell.selectImageView.hidden = YES;
    }
    
    if ([self.viewModel isEnableWithType:remindIndex.integerValue]) {
        cell.isDisable = NO;
    } else {
        cell.isDisable = YES;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, 35)];
    view.backgroundColor = QMUITheme.backgroundColor;
    UILabel *label = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel3 textFont:[UIFont systemFontOfSize:14]];
    label.frame = CGRectMake(16, 0, 200, 35);
    [view addSubview:label];
    
    if (section == 0) {
        label.text = [YXLanguageUtility kLangWithKey:@"remind_price"];
    } else if(section == 1) {
        label.text = [YXLanguageUtility kLangWithKey:@"remind_handicap"];
    } else if(section == 2) {
        label.text = [YXLanguageUtility kLangWithKey:@"remind_event_alert"];
    } else if(section == 3) {
        label.text = [YXLanguageUtility kLangWithKey:@"remind_long_short_signal_alert"];
    } else if(section == 4) {
        label.text = [YXLanguageUtility kLangWithKey:@"remind_other_signal"];
    }
    
    return view;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 36;
}


@end
