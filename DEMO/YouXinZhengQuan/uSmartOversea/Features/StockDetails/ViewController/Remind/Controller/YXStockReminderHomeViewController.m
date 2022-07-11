//
//  YXStockReminderHomeViewController.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/26.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStockReminderHomeViewController.h"
#import "YXStockReminderHomeViewModel.h"
#import "YXReminderStockView.h"
#import "YXStockReminderTypeViewModel.h"
#import "YXReminderSingleView.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

#define kStockDetailHeight 77

@interface YXStockReminderHomeViewController ()

@property (nonatomic, strong) YXStockReminderHomeViewModel *viewModel;

@property (nonatomic, strong) YXReminderStockView *stockView;

@property (nonatomic, strong) YXQuoteRequest *quoteRequest;

@property (nonatomic, strong) UIView *tipView;

@property (nonatomic, strong) QMUIMarqueeLabel *tipLabel;

@end

@implementation YXStockReminderHomeViewController

@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
    
    if (@available(iOS 13.0, *)) {
    } else {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadQuoteData];
    
    [self loadFirstPage];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.quoteRequest cancel];

}
- (void)initUI {
        
    self.tableView.backgroundColor = QMUITheme.foregroundColor;
    self.title = [YXLanguageUtility kLangWithKey:@"remind_price_title"];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [btn setTitle:[YXLanguageUtility kLangWithKey:@"remind_my"] forState:UIControlStateNormal];
    [btn setTitleColor:QMUITheme.textColorLevel1 forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItems = @[item];
    
    [self.view addSubview:self.tipView];
    [self.view addSubview:self.stockView];
    
    [self.tipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.mas_equalTo(0);
    }];
    self.tipView.hidden = YES;
    
    [self.stockView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.tipView.mas_bottom);
        make.height.mas_equalTo(kStockDetailHeight);
    }];
    
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.stockView.mas_bottom);
        make.bottom.equalTo(self.view).offset(-(YXConstant.tabBarPadding + 48));
    }];
    self.tableView.rowHeight = 69;
    self.tableView.sectionFooterHeight = 0.1;
    self.tableView.sectionHeaderHeight = 6;
    
    // 底部的view
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = QMUITheme.foregroundColor;
    
    QMUIButton *addBtn = [QMUIButton buttonWithType:UIButtonTypeCustom title:[YXLanguageUtility kLangWithKey:@"remind_add"] font:[UIFont normalFont16] titleColor:QMUITheme.textColorLevel1 target:self action:@selector(addBtnClick:)];
    [addBtn setImage:[UIImage imageNamed:@"remind_add"] forState:UIControlStateNormal];
    addBtn.imagePosition = QMUIButtonImagePositionLeft;
    addBtn.spacingBetweenImageAndTitle = 4;
    
    UIView *lineView = [UIView lineView];
    
    [bottomView addSubview:addBtn];
    [bottomView addSubview:lineView];
    [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bottomView).offset(16);
        make.height.mas_equalTo(22);
        make.centerX.equalTo(bottomView);
    }];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(bottomView);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(YXConstant.tabBarPadding + 48);
    }];
    
    if ([self isShowTip]) {
        if ([self isBmp]) {
            self.tipLabel.text = [YXLanguageUtility kLangWithKey:@"reminder_bmp_tip"];
        } else if ([self isDelay]){
            self.tipLabel.text = [YXLanguageUtility kLangWithKey:@"reminder_delay_tip"];
        }
        self.tipView.hidden = NO;
        [self.tipLabel requestToStartAnimation];
        [self.tipView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(40);
        }];
    }
    
}

- (BOOL)isShowTip {
    if ([self isBmp]) {
        return YES;
    }
    if ([self isDelay]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isBmp {
    if ([self.viewModel.market isEqualToString:kYXMarketHK] && [[YXUserManager shared] getLevelWith:kYXMarketHK] == QuoteLevelBmp) {
        return YES;
    }
    return NO;
}

- (BOOL)isDelay {
    if ([[YXUserManager shared] getLevelWith:self.viewModel.market] == QuoteLevelDelay) {
        return YES;
    }
    return NO;
}

- (void)rightBtnClick:(UIButton *)sender {
    [self.viewModel.pushToMyRemindsCommand execute:nil];
}

- (void)loadQuoteData {
    @weakify(self);
    Secu *secu = [[Secu alloc] initWithMarket:self.viewModel.market symbol:self.viewModel.symbol];
        
    self.quoteRequest = [[YXQuoteManager sharedInstance] subRtSimpleQuoteWithSecus:@[secu] level:[[YXUserManager shared] getLevelWith:self.viewModel.market] handler:^(NSArray<YXV2Quote *> * _Nonnull list, enum Scheme scheme) {
        @strongify(self);
//        if (scheme == SchemeHttp) {
//            [self.scrollView.mj_header endRefreshing];
//        }
        YXV2Quote *quote = list.firstObject;
        self.stockView.quote = quote;
    } failed:^{
        
    }];
}

- (void)bindViewModel {
    [super bindViewModel];
}

#pragma mark - tableView

- (NSDictionary *)cellIdentifiers {
    
    return @{@"YXReminderSingleCell": @"YXReminderSingleCell"};
}

- (NSString *)cellIdentifierAtIndexPath:(NSIndexPath *)aIndexPath {
    return @"YXReminderSingleCell";
}


- (void)configureCell:(YXReminderSingleCell *)cell atIndexPath:(NSIndexPath *)indexPath withObject:(YXReminderModel *)object {
    
    cell.model = object;
    
    @weakify(self);
    [cell setStChangeCallBack:^(UISwitch * _Nonnull st) {
        @strongify(self);
        [self.viewModel.updateCommand execute:object];
    }];
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    return [UIView new];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YXReminderModel *model = self.viewModel.dataSource[indexPath.section].firstObject;
    [self.viewModel.deleteCommand execute:model];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [YXLanguageUtility kLangWithKey:@"common_delete"];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (UIImage *)customImageForEmptyDataSet {
    if (self.viewModel.dataSource && self.viewModel.dataSource.count == 0) {
        return [UIImage imageNamed:@"empty_noData"];
    }
    return [super customImageForEmptyDataSet];
}

- (NSAttributedString *)customTitleForEmptyDataSet {
    if (self.viewModel.dataSource && self.viewModel.dataSource.count == 0) {
        return [[NSAttributedString alloc] initWithString:[YXLanguageUtility kLangWithKey:@"remind_no_data"] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [QMUITheme textColorLevel3]}];
    }
    return [super customTitleForEmptyDataSet];
}


#pragma mark - action

- (void)addBtnClick:(UIButton *)sender {
    
    if ([self isDelay]) {
      
        YXAlertView *alertView = [YXAlertView alertViewWithMessage:[YXLanguageUtility kLangWithKey:@"reminder_delay_alert_msg"]];
        YXAlertAction *cancelAction = [YXAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"common_cancel"] style:YXAlertActionStyleCancel handler:^(YXAlertAction * _Nonnull action) {
            
        }];
        YXAlertAction *accessAction = [YXAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"depth_order_get"] style:YXAlertActionStyleDefault handler:^(YXAlertAction * _Nonnull action) {
            [YXWebViewModel pushToWebVC:[YXH5Urls YX_MY_QUOTES_URLWithMarket:self.viewModel.market]];
        }];
        
        [alertView addAction:cancelAction];
        [alertView addAction:accessAction];
        
        [alertView showInWindow];
        return;
    }
    
    NSMutableDictionary *para = [NSMutableDictionary dictionaryWithDictionary:self.viewModel.params];
    // 是否有财报提醒选项
    if (self.stockView.quote.type1.value == OBJECT_SECUSecuType1_StStock && [self.stockView.quote.market isEqualToString:kYXMarketHK]) {
        para[@"isNeedFinancialReport"] = @(YES);
    }
    BOOL isNeedAnnouncement = YES;
    if ([self.stockView.quote.market isEqualToString:kYXMarketSG]) {
        isNeedAnnouncement = NO;
    }
    para[@"isNeedAnnouncement"] = @(isNeedAnnouncement);
    
    
    if (self.viewModel.formArr) {
        para[@"formArr"] = self.viewModel.formArr;
    }
    YXStockReminderTypeViewModel *viewModel = [[YXStockReminderTypeViewModel alloc] initWithServices:self.viewModel.services params:para];
    viewModel.addType = YXReminderVCTypeNew;
    viewModel.formArr = self.viewModel.formArr;
    [self.viewModel.services presentViewModel:viewModel animated:YES completion:nil];
    
}


#pragma mark - lazy load
- (YXReminderStockView *)stockView {
    if (_stockView == nil) {
        _stockView = [[YXReminderStockView alloc] init];
    }
    return _stockView;
}

- (UIView *)tipView {
    if (_tipView == nil) {
        _tipView = [[UIView alloc] init];
        _tipView.backgroundColor = QMUITheme.noticeBackgroundColor;
        [_tipView addSubview:self.tipLabel];
        [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.tipView).offset(16);
            make.top.bottom.equalTo(self.tipView);
            make.right.equalTo(self.tipView).offset(-38);
        }];
        
        UIImageView *arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"notice_arrow"]];
        [_tipView addSubview:arrowView];
        [arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.tipView).offset(-16);
            make.width.height.mas_equalTo(16);
            make.centerY.equalTo(self.tipView);
        }];
             
        UIControl *clickControl = [[UIControl alloc] init];
        [_tipView addSubview:clickControl];
        [clickControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.tipView);
        }];
        
        @weakify(self);
        [clickControl setQmui_tapBlock:^(__kindof UIControl *sender) {
            @strongify(self);
            [YXWebViewModel pushToWebVC:[YXH5Urls YX_MY_QUOTES_URLWithMarket:self.viewModel.market]];
        }];
    }
    return _tipView;
}

- (QMUIMarqueeLabel *)tipLabel {
    if (_tipLabel == nil) {
        _tipLabel = [[QMUIMarqueeLabel alloc] init];
        _tipLabel.pauseDurationWhenMoveToEdge = 0;
        _tipLabel.fadeWidthPercent = 0;
        _tipLabel.adjustsFontSizeToFitWidth = NO;
        _tipLabel.numberOfLines = 1;
        _tipLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _tipLabel.text = @"";
        _tipLabel.textColor = QMUITheme.noticeTextColor;
    }
    return _tipLabel;
}

@end
