//
//  YXOrgAccountListViewController.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/6/20.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXOrgAccountListViewController.h"
#import "YXOrgAccountListViewModel.h"
#import "YXOrgAccountCell.h"
#import "uSmartOversea-Swift.h"

@interface YXOrgAccountListViewController ()

@property (nonatomic, strong, readonly) YXOrgAccountListViewModel *viewModel;

@end

@implementation YXOrgAccountListViewController
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = [YXLanguageUtility kLangWithKey:@"trade_account_info"];
    [self initUI];
//    [self loadFirstPage];
    
    @weakify(self);
    [[self.viewModel.requestRemoteDataCommand execute:nil] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self.tableView reloadData];
    }];
    
    UILabel *headerLabel = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"trade_info_follow"] textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:20 weight:UIFontWeightMedium]];
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, 50)];
    headerLabel.frame = CGRectMake(14, 0, 300, 50);
    [tableHeaderView addSubview:headerLabel];
    self.tableView.tableHeaderView = tableHeaderView;
    
   NSString *tipStr = [NSString stringWithFormat:@"%@:\n%@", [YXLanguageUtility kLangWithKey:@"common_tips"], [YXLanguageUtility kLangWithKey:@"trade_account_modify_tip"]];
    UILabel *footerLabel = [UILabel labelWithText:tipStr textColor:QMUITheme.textColorLevel3 textFont:[UIFont systemFontOfSize:14]];
    footerLabel.numberOfLines = 0;
    
    CGSize size = [YXToolUtility getStringSizeWith:tipStr andFont:[UIFont systemFontOfSize:14] andlimitWidth:YXConstant.screenWidth - 28 andLineSpace:3];
    CGFloat height = size.height + 10;
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, height)];
    footerLabel.frame = CGRectMake(14, 0, YXConstant.screenWidth - 28, height);
    
    [tableFooterView addSubview:footerLabel];
    self.tableView.tableFooterView = tableFooterView;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)initUI {
    self.tableView.rowHeight = 48 * 5;
    self.view.backgroundColor = [UIColor qmui_colorWithHexString:@"#F8F8F8"];
}


- (void)bindViewModel {
    
}

- (NSDictionary *)cellIdentifiers {
    return @{
             @"YXOrgAccountCell" : @"YXOrgAccountCell"
             };
}

- (NSString *)cellIdentifierAtIndexPath:(NSIndexPath *)aIndexPath {
    return @"YXOrgAccountCell";
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withObject:(id)object {
    
    YXOrgAccountCell *accountCell = (YXOrgAccountCell *)cell;
    accountCell.model = self.viewModel.dataSource[indexPath.section].firstObject;
    
    @weakify(self);
    [accountCell setClickStatusCallBack:^(YXOrgAccountModel * _Nonnull model) {
        @strongify(self);
        NSString *confirmStr = @"";
        NSString *title = @"";
        if (model.traderStatus) {
            title = [YXLanguageUtility kLangWithKey:@"trade_disable_status"];
            confirmStr = [YXLanguageUtility kLangWithKey:@"trade_confirm_disable"];
            
        } else {
            title = [YXLanguageUtility kLangWithKey:@"trade_enable_status"];
            confirmStr = [YXLanguageUtility kLangWithKey:@"trade_confirm_enable"];
        }
        
        YXAlertView *alertView = [YXAlertView alertViewWithMessage:title];
        alertView.clickedAutoHide = NO;
        
        [alertView addAction:[YXAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"common_cancel"] style:YXAlertActionStyleCancel handler:^(YXAlertAction *action) {
            [alertView hideView];
        }]];
        
        [alertView addAction:[YXAlertAction actionWithTitle:confirmStr style:YXAlertActionStyleDefault handler:^(YXAlertAction *action) {
            [alertView hideView];
            [[self.viewModel.statusChangeCommand execute:model] subscribeNext:^(NSNumber *success) {
                @strongify(self);
                if (success.boolValue) {
                    model.traderStatus = !model.traderStatus;
                    [self.tableView reloadData];
                }
            }];
        }]];
        
        [alertView showInWindow];

    }];
    
    [accountCell setClickEmailOrPhoneCallBack:^(YXOrgAccountModel * _Nonnull model) {
        
        YXAlertView *alertView = [YXAlertView alertViewWithMessage:[YXLanguageUtility kLangWithKey:@"trade_confirm_id_change"]];
        alertView.clickedAutoHide = NO;
        [alertView addAction:[YXAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"common_iknow"] style:YXAlertActionStyleDefault handler:^(YXAlertAction *action) {
            [alertView hideView];
        }]];
        
        [alertView showInWindow];
    }];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *v = [[UIView alloc] init];
    v.backgroundColor = [QMUITheme backgroundColor];
    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *v = [[UIView alloc] init];
    v.backgroundColor = [QMUITheme backgroundColor];
    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YXOrgAccountModel *model = self.viewModel.dataSource[indexPath.section].firstObject;
    if (model.isMain) {
        return 62 * 4;
    } else {
        return 62 * 5;
    }
}


@end
