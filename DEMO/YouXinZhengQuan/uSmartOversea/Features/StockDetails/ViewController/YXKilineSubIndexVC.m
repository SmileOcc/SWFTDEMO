//
//  YXKilineSubIndexVC.m
//  uSmartOversea
//
//  Created by chenmingmao on 2019/12/17.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXKilineSubIndexVC.h"
#import "YXKlineSubIndexViewModel.h"
#import "YXKlineSubIndexCell.h"
#import "YXKLineConfigManager.h"
#import "uSmartOversea-Swift.h"
#import "YXStockConfig.h"
#import <YXKit/YXKit.h>
#import <Masonry/Masonry.h>

@interface YXKilineSubIndexVC ()

@property (nonatomic, strong, readwrite) YXKlineSubIndexViewModel *viewModel;

@property (nonatomic, assign) BOOL hasChangeCycleValue;

@end

@implementation YXKilineSubIndexVC
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *title = [YXKLineConfigManager getTitleWithType:self.viewModel.indexType];
    if ([YXUserManager isENMode]) {
        self.title = [NSString stringWithFormat:@"%@ %@", title, [YXLanguageUtility kLangWithKey:@"user_set"]];
    } else {
        self.title = [NSString stringWithFormat:@"%@%@", title, [YXLanguageUtility kLangWithKey:@"user_set"]];
    }
    self.view.backgroundColor = [QMUITheme foregroundColor];
    self.tableView.backgroundColor = [QMUITheme foregroundColor];
    [self initUI];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
        
    if (self.hasChangeCycleValue) {
        // 清除k线数据
        [[YXQuoteManager sharedInstance] removeKlinePool];
    }    
    // 同步模型
    [[YXKLineConfigManager shareInstance] synConfigWithModel:self.viewModel.model];
    [[YXKLineConfigManager shareInstance] saveData];
}

- (void)initUI {


    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:[YXLanguageUtility kLangWithKey:@"restore_default"] style:(UIBarButtonItemStylePlain) target:self action:@selector(rightBarButtonItemAction)];

    [rightItem setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14], NSForegroundColorAttributeName : [QMUITheme textColorLevel1]} forState:UIControlStateNormal];
    [rightItem setTitleTextAttributes:@{} forState:UIControlStateNormal];
    [rightItem setTitleTextAttributes:@{} forState:UIControlStateNormal];

    self.navigationItem.rightBarButtonItems = @[rightItem];
    
    // 底部的view
    CGSize size = [YXToolUtility getStringSizeWith:self.viewModel.model.explain andFont:[UIFont systemFontOfSize:12 weight:UIFontWeightRegular] andlimitWidth:YXConstant.screenWidth - 32 andLineSpace:3];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, size.height + 50)];
    UILabel *explainLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, YXConstant.screenWidth - 32, size.height + 10)];
    explainLabel.numberOfLines = 0;
    footerView.backgroundColor = [QMUITheme foregroundColor];
    NSAttributedString *att = [YXToolUtility attributedStringWithText:self.viewModel.model.explain font:[UIFont systemFontOfSize:12 weight:UIFontWeightRegular] textColor:[QMUITheme textColorLevel2] lineSpacing:3];
    explainLabel.attributedText = att;
    [footerView addSubview:explainLabel];
    
    self.tableView.tableFooterView = footerView;
}

- (void)rightBarButtonItemAction {
    // 重置
    [[[YXKLineConfigManager shareInstance] getConfigWithModelWithType:self.viewModel.indexType] setDefault];
    [self.viewModel resetData];
    [self.tableView reloadData];
    [QMUITips showWithText:[YXLanguageUtility kLangWithKey:@"setting_already_default"]];
    self.hasChangeCycleValue = YES;
}

- (CGFloat)tableViewTop {
    if (@available(iOS 13.0, *)) {
        return 0;
    } else {
        return YXConstant.navBarHeight;
    }
}

- (CGFloat)rowHeight {
    return 50;
}

- (NSArray<Class> *)cellClasses {
    return @[[YXKlineSubIndexCell class], [YXKlineSubIndexCell class]];
}
 
- (void)configureCell:(YXKlineSubIndexCell *)cell atIndexPath:(NSIndexPath *)indexPath withObject:(id)object {
    NSArray *arr = self.viewModel.dataSource[indexPath.section];
    cell.model = arr[indexPath.row];
    @weakify(self)
    [cell setChangeCycleCallBack:^{
        @strongify(self)
        self.hasChangeCycleValue = YES;
    }];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if (self.viewModel.indexType == YXStockMainAcessoryStatusMA || self.viewModel.indexType == YXStockSubAccessoryStatus_MAVOL) {
            return [self getSecontionViewWithTitle:[YXLanguageUtility kLangWithKey:@"moving_average_period"]];
        } else {
            return [self getSecontionViewWithTitle:[YXLanguageUtility kLangWithKey:@"indicator_settings"]];
        }
    } else if (section == 1) {
        if (self.viewModel.indexType == YXStockMainAcessoryStatusMA || self.viewModel.indexType == YXStockSubAccessoryStatus_MAVOL) {
            return [self getSecontionViewWithTitle:[YXLanguageUtility kLangWithKey:@"indicator_description"]];
        } else {
            return [self getSecontionViewWithTitle:[YXLanguageUtility kLangWithKey:@"indicator_line"]];
        }
    } else {
        return [self getSecontionViewWithTitle:[YXLanguageUtility kLangWithKey:@"indicator_description"]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (UIView *)getSecontionViewWithTitle:(NSString *)title {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, 40)];
    view.backgroundColor = QMUITheme.blockColor;
    UILabel *label = [UILabel labelWithText:title textColor:QMUITheme.textColorLevel3 textFont:[UIFont systemFontOfSize:14 weight:UIFontWeightRegular] textAlignment:NSTextAlignmentLeft];
    label.frame = CGRectMake(16, 0, 200, 40);
    [view addSubview:label];
    
    return view;
}



@end
