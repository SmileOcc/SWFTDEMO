//
//  YXStockDetailMyRemindersController.m
//  uSmartOversea
//
//  Created by 姜轶群 on 2018/11/21.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "YXStockDetailMyRemindersController.h"
#import "YXStockDetailMyRemindersViewModel.h"
#import "YXStockDetailMyReimndersCell.h"
#import "YXAuthorityReminderTool.h"
#import "YXReminderModel.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXStockDetailMyRemindersController ()<YXAuthorityReminderToolDelegate>

@property (nonatomic, strong) YXStockDetailMyRemindersViewModel *viewModel;
//@property (nonatomic, strong) YXMyRemindersModel *remindModel;
@property (nonatomic, strong) NSArray *quotaArr;
@property (nonatomic, strong) YXAuthorityReminderTool *authorityTool;

@end

@implementation YXStockDetailMyRemindersController
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [YXLanguageUtility kLangWithKey:@"remind_my"];
    self.tableView.backgroundColor = QMUITheme.backgroundColor;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //加载数据(列表数据)
    [self loadFirstPage];
    
    // 加载列表成功
    [self remindListLoad];
    
    //涨跌幅度, 价格
    [self loadQuotaData];
    
    //删除提醒
    [self remindDeleteNotify];
    
}

- (void)loadQuotaData{
    
    @weakify(self);
    [self.viewModel.quotaSubject subscribeNext:^(NSArray *quotaArr) {
        @strongify(self);
        self.quotaArr = quotaArr;
        if (self.quotaArr.count == 0) {
            return ;
        }
        //涨跌幅
        for (YXV2Quote *quotaModel in self.quotaArr) {
            NSArray *arr = self.viewModel.dataSource[0];
            for (YXReminderListModel *model in arr) {
                if ([model.stockCode isEqualToString: quotaModel.symbol] && [model.stockMarket isEqualToString: quotaModel.market]) {
                    model.quotaModel = quotaModel;
                }
            }
        }
        [self.tableView reloadData];
    }];
    
}

- (void)remindListLoad {
    @weakify(self);
    [self.viewModel.remindListSubject subscribeNext:^(NSArray *quotaArr) {
        @strongify(self);
        if (quotaArr.count > 0) {
            //行情权限提示文案
            [self updateAuthorityUI];
        }
    }];
}

- (void)remindDeleteNotify{
    
    @weakify(self)
    [self.viewModel.deleteRemindNotifySubject subscribeNext:^(NSDictionary *paramDic) {
        @strongify(self)
        [self loadFirstPage];
    }];
    
}

- (void)updateAuthorityUI {
    if ([self.authorityTool isHKDelay] || [self.authorityTool isUSDelay]) {
//        NSString *text = @"该服务依赖于行情权限和手机消息推送系统，可能会出现通知延时";
//        [self.authorityTool showReminderText:text];
    }else {
//        [self.authorityTool removeReminderText];
    }
}

#pragma mark - delegate & dataource

- (NSString *)cellIdentifierAtIndexPath:(NSIndexPath *)aIndexPath {
    
    return @"myRemindersCellIdentity";
    
}

- (void)configureCell:(YXStockDetailMyReimndersCell *)cell atIndexPath:(NSIndexPath *)indexPath withObject:(YXReminderListModel *)remindModel{
    
    
    @weakify(self);
    cell.deleteRemindCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSDictionary *quotaDic) {
        
        @strongify(self);
        
//        remind_delete_remind
        YXAlertView *alertView = [YXAlertView alertViewWithMessage:[NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"remind_delete_remind"], quotaDic[@"name"]]];
        @weakify(alertView);
        
        [alertView addAction:[YXAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"common_cancel"] style:YXAlertActionStyleCancel handler:^(YXAlertAction *action) {
            @strongify(alertView)
            [alertView hideView];
        }]];
        [alertView addAction:[YXAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"common_confirm"] style:YXAlertActionStyleDefault handler:^(YXAlertAction *action) {
            if (self.viewModel.deleteRemindCommand) {
                [self.viewModel.deleteRemindCommand execute:@{@"market" : quotaDic[@"market"], @"symbol" : quotaDic[@"symbol"], @"index" : @(indexPath.row)}];
            }
        }]];
        YXAlertController *alertController = [YXAlertController alertControllerWithAlertView:alertView];
        [self presentViewController:alertController animated:YES completion:nil];
        
        return [RACSignal empty];
    }];
    
    cell.foldRemindCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSNumber *isFold) {
        @strongify(self);
        
        [self.tableView reloadData];
        return [RACSignal empty];
    }];
    cell.editRemindCommand = self.viewModel.editRemindCommand;
    cell.remindModel = self.viewModel.dataSource[indexPath.section][indexPath.row];
    
}

- (NSDictionary *)cellIdentifiers {
    return @{
             @"myRemindersCellIdentity" : @"YXStockDetailMyReimndersCell",
             };
}

- (double)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    YXReminderListModel *reminderDataModel = self.viewModel.dataSource[indexPath.section][indexPath.row];
    NSInteger count = reminderDataModel.stockNtfs.count + reminderDataModel.stockForms.count;
    CGFloat totalCellHeight = count * kSubTypeViewHeight;
    CGFloat bottomHeight = 0;
    if (count > kFolderCount) {
        if (reminderDataModel.isUnfold == NO) {
            totalCellHeight = 3 * kSubTypeViewHeight;
        } else {
            totalCellHeight = count * kSubTypeViewHeight;
        }
        bottomHeight = 33;
    }
    return 77 + 8 + totalCellHeight + bottomHeight;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 8;
}

- (UITableViewStyle)tableViewStyle {
    
    return UITableViewStylePlain;
    
}

#pragma mark - nodata
- (NSAttributedString *)customTitleForEmptyDataSet {
    NSString *text = [YXLanguageUtility kLangWithKey:@"remind_no_data"];
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:16],
                                 NSForegroundColorAttributeName: [QMUITheme textColorLevel3]};
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)customImageForEmptyDataSet {
    return [UIImage imageNamed:@"empty_noData"];
}

#pragma authorityTool

- (YXAuthorityReminderTool *)authorityTool {
    if (!_authorityTool) {
        _authorityTool = [[YXAuthorityReminderTool alloc] init];
        _authorityTool.delegate = self;
    }
    return _authorityTool;
}

- (UITableView *)needLayoutTableView {
    return self.tableView;
}

@end
