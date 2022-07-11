//
//  YXMarginAssetsViewController.m
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2020/3/24.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXMarginAssetsViewController.h"
#import "YXMarginAssetsViewModel.h"
#import "NSNumber+YYAdd.h"
#import <Masonry/Masonry.h>
#import "uSmartOversea-Swift.h"
#import "YXRequest.h"

@interface YXMarginAssetsViewController ()
@property (nonatomic, strong) YXMarginAssetsViewModel *viewModel;

@property (nonatomic, strong) UIScrollView *contentView;

@property (nonatomic, strong) NSNumberFormatter *moneyFormatter;

@end

@implementation YXMarginAssetsViewController
@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *aboutBarItem = [UIBarButtonItem qmui_itemWithImage:[UIImage imageNamed:@"stock_about"] target:self action:@selector(aboutButtonAction)];
    aboutBarItem.imageInsets = UIEdgeInsetsMake(0, 15, 0, -15);
    self.navigationItem.rightBarButtonItems = @[self.messageItem, aboutBarItem];
    
    [self.view addSubview:self.contentView];
    
    if (self.viewModel.exchangeType == 0) {
        self.title = [YXLanguageUtility kLangWithKey:@"hold_hk_margin_account"];
    } else if (self.viewModel.exchangeType == 5){
        self.title = [YXLanguageUtility kLangWithKey:@"hold_us_margin_account"];
    } else {
        self.title = [YXLanguageUtility kLangWithKey:@"hold_cn_margin_account"];
    }
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.view);
    }];
    
    UIImageView *iconView1 = [[UIImageView alloc] init];
    iconView1.image = [UIImage imageNamed:@"icon_asset"];
    [self.contentView addSubview:iconView1];
    
    [iconView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.top.mas_equalTo(20);
    }];
    
    UILabel *titleLabel1 = [[UILabel alloc] init];
    titleLabel1.textColor = QMUITheme.textColorLevel2;
    titleLabel1.font = [UIFont systemFontOfSize:16];
    if (self.viewModel.exchangeType == 0) {
        titleLabel1.text = [YXLanguageUtility kLangWithKey:@"hold_assets_hk"];
    } else if (self.viewModel.exchangeType == 5) {
        titleLabel1.text = [YXLanguageUtility kLangWithKey:@"hold_assets_us"];
    } else {
        titleLabel1.text = [YXLanguageUtility kLangWithKey:@"hold_assets_cn"];
    }
    [self.contentView addSubview:titleLabel1];
    
    [titleLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iconView1.mas_right).offset(8);
        make.centerY.equalTo(iconView1);
    }];
    
    UIView *firstBgView = [[UIView alloc] init];
    [self.contentView addSubview:firstBgView];
    
    [firstBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(self.contentView);
        make.top.mas_equalTo(60);
        make.height.mas_equalTo(238);
    }];
    
    UILabel *leftLabel1 = [self leftLabel];
    leftLabel1.text = [YXLanguageUtility kLangWithKey:@"hold_net_liquidation_value"];
    [firstBgView addSubview:leftLabel1];
    
    UILabel *leftLabel2 = [self leftLabel];
    leftLabel2.text = [YXLanguageUtility kLangWithKey:@"newStock_certified_funds"];
    [firstBgView addSubview:leftLabel2];
    
    UILabel *leftLabel3 = [self leftLabel];
    leftLabel3.text = [YXLanguageUtility kLangWithKey:@"trading_change_condition_max_buy_power"];
    [firstBgView addSubview:leftLabel3];
    
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [infoButton setImage:[[UIImage imageNamed:@"onway_about"] qmui_imageWithTintColor:QMUITheme.textColorLevel1] forState:UIControlStateNormal];
    [firstBgView addSubview: infoButton];
    
    [infoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(leftLabel3.mas_right).offset(2);
        make.centerY.equalTo(leftLabel3);
    }];

    [[infoButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [YXWebViewModel pushToWebVC:[YXH5Urls goTradeAssetDescUrl]];
    }];
    
    UILabel *leftLabel4 = [self leftLabel];
    leftLabel4.text =  [YXLanguageUtility kLangWithKey:@"hold_cash_available"];
    [firstBgView addSubview:leftLabel4];
    
    UILabel *leftLabel5 = [self leftLabel];
    leftLabel5.text = [YXLanguageUtility kLangWithKey:@"hold_freezing_cash"];
    [firstBgView addSubview:leftLabel5];
    
    UILabel *leftLabel14 = [self leftLabel];
    leftLabel14.text = [YXLanguageUtility kLangWithKey:@"account_cash_in_transit"];
    [firstBgView addSubview:leftLabel14];
    
    UILabel *leftLabel15 = [self leftLabel];
    leftLabel15.text = [YXLanguageUtility kLangWithKey:@"hold_stock_market_value"];
    [firstBgView addSubview:leftLabel15];
    
    NSArray *leftLabels1 = @[leftLabel1, leftLabel2, leftLabel3, leftLabel4, leftLabel5, leftLabel14, leftLabel15];
    [leftLabels1 mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedSpacing:14 leadSpacing:0 tailSpacing:0];
    [leftLabels1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.height.mas_equalTo(22);
    }];
    
    UILabel *rightLabel1 = [self rightLabel];
    [firstBgView addSubview:rightLabel1];
    
    UILabel *rightLabel2 = [self rightLabel];
    [firstBgView addSubview:rightLabel2];
    
    UILabel *rightLabel3 = [self rightLabel];
    [firstBgView addSubview:rightLabel3];
    
    UILabel *rightLabel4 = [self rightLabel];
    [firstBgView addSubview:rightLabel4];
    
    UILabel *rightLabel5 = [self rightLabel];
    [firstBgView addSubview:rightLabel5];
    
    UILabel *rightLabel14 = [self rightLabel];
    [firstBgView addSubview:rightLabel14];
    
    UILabel *rightLabel15 = [self rightLabel];
    [firstBgView addSubview:rightLabel15];
    
    NSArray *rightLabels1 = @[rightLabel1, rightLabel2, rightLabel3, rightLabel4, rightLabel5, rightLabel14, rightLabel15];
    [rightLabels1 mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedSpacing:14 leadSpacing:0 tailSpacing:0];
    [rightLabels1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(firstBgView).offset(-12);
        make.height.mas_equalTo(22);
    }];
    
    UIImageView *iconView2 = [[UIImageView alloc] init];
    iconView2.image = [UIImage imageNamed:@"icon_margin"];
    [self.contentView addSubview:iconView2];
    
    [iconView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.top.mas_equalTo(328);
    }];
    
    UILabel *titleLabel2 = [[UILabel alloc] init];
    titleLabel2.textColor = QMUITheme.textColorLevel2;
    titleLabel2.font = [UIFont systemFontOfSize:16];
    if (self.viewModel.exchangeType == 0) {
        titleLabel2.text = [YXLanguageUtility kLangWithKey:@"hold_margin_hk"];
    } else if (self.viewModel.exchangeType == 5) {
        titleLabel2.text = [YXLanguageUtility kLangWithKey:@"hold_margin_us"];
    } else {
        titleLabel2.text = [YXLanguageUtility kLangWithKey:@"hold_margin_cn"];
    }
    [self.contentView addSubview:titleLabel2];
    
    [titleLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iconView2.mas_right).offset(8);
        make.centerY.equalTo(iconView2);
    }];
    
    UIView *secondBgView = [[UIView alloc] init];
    [self.contentView addSubview:secondBgView];
    
    [secondBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(self.contentView);
        make.top.mas_equalTo(368);
        make.height.mas_equalTo(316);
    }];
    
    UILabel *leftLabel6 = [self leftLabel];
    leftLabel6.text = [YXLanguageUtility kLangWithKey:@"hold_risk_level"];
    [secondBgView addSubview:leftLabel6];
    
    UILabel *leftLabel7 = [self leftLabel];
    leftLabel7.text = [YXLanguageUtility kLangWithKey:@"hold_margin_loans"];
    [secondBgView addSubview:leftLabel7];
    
    UILabel *leftLabel8 = [self leftLabel];
    leftLabel8.text = [YXLanguageUtility kLangWithKey:@"hold_margin_call"];
    [secondBgView addSubview:leftLabel8];
    
    UILabel *leftLabel9 = [self leftLabel];
    leftLabel9.text = [YXLanguageUtility kLangWithKey:@"hold_interest"];
    [secondBgView addSubview:leftLabel9];
    
    UILabel *leftLabel10 = [self leftLabel];
    leftLabel10.text = [YXLanguageUtility kLangWithKey:@"hold_collateral_value"];
    [secondBgView addSubview:leftLabel10];
    
    UILabel *leftLabel11 = [self leftLabel];
    leftLabel11.text = [YXLanguageUtility kLangWithKey:@"hold_credit_line"];
    [secondBgView addSubview:leftLabel11];
    
    UILabel *leftLabel12 = [self leftLabel];
    leftLabel12.text = [YXLanguageUtility kLangWithKey:@"hold_credit_ratio"];
    [secondBgView addSubview:leftLabel12];
    
    UILabel *leftLabel13 = [self leftLabel];
    leftLabel13.text = [YXLanguageUtility kLangWithKey:@"hold_margin_rate"];
    [secondBgView addSubview:leftLabel13];
    
    NSArray *leftLabels2 = @[leftLabel6, leftLabel7, leftLabel8, leftLabel9, leftLabel10, leftLabel11, leftLabel12,  leftLabel13];
    [leftLabels2 mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedSpacing:14 leadSpacing:0 tailSpacing:20];
    [leftLabels2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.height.mas_equalTo(22);
    }];
    
    UILabel *rightLabel6 = [self rightLabel];
    rightLabel6.userInteractionEnabled = YES;
    [secondBgView addSubview:rightLabel6];
    
    @weakify(self)
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        [YXHoldInfoView showRiskLevelCustomView:sender];
    }];
    [rightLabel6 addGestureRecognizer:tap];
    
    UILabel *rightLabel7 = [self rightLabel];
    [secondBgView addSubview:rightLabel7];
    
    UILabel *rightLabel8 = [self rightLabel];
    [secondBgView addSubview:rightLabel8];
    
    UILabel *rightLabel9 = [self rightLabel];
    [secondBgView addSubview:rightLabel9];
    
    UILabel *rightLabel10 = [self rightLabel];
    [secondBgView addSubview:rightLabel10];
    
    UILabel *rightLabel11 = [self rightLabel];
    [secondBgView addSubview:rightLabel11];
    
    UILabel *rightLabel12 = [self rightLabel];
    [secondBgView addSubview:rightLabel12];
    
    UILabel *rightLabel13 = [self rightLabel];
    rightLabel13.numberOfLines = 2;
    [secondBgView addSubview:rightLabel13];
    
    NSArray *rightLabels2 = @[rightLabel6, rightLabel7, rightLabel8, rightLabel9, rightLabel10, rightLabel11, rightLabel12,  rightLabel13];
    [rightLabels2 mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedSpacing:14 leadSpacing:0 tailSpacing:20];
    [rightLabels2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(secondBgView).offset(-12);
        make.height.mas_equalTo(22);
    }];
    
    YXRefreshHeader *header = [YXRefreshHeader headerWithRefreshingBlock:^{
        @strongify(self)
        YXMarginDetailRequestModel *requestModel = [[YXMarginDetailRequestModel alloc] init];
        requestModel.exchangeType = self.viewModel.exchangeType;
        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
        
        
        [request startWithBlockWithSuccess:^(__kindof YXStockAssetResponseModel *responseModel) {
            @strongify(self)
            
            NSNumber *asset = [NSNumber numberWithString:responseModel.result.asset];
            NSString *assetString = [self.moneyFormatter stringFromNumber:asset];
            rightLabel1.text = assetString.length ? assetString : @"--";
            
            NSNumber *enableBalance = [NSNumber numberWithString:responseModel.result.enableBalance];
            NSString *enableBalanceString = [self.moneyFormatter stringFromNumber:enableBalance];
            rightLabel2.text = enableBalanceString.length ? enableBalanceString : @"--";
            
            NSNumber *purchasePower = [NSNumber numberWithString:responseModel.result.purchasePower];
            NSString *purchasePowerString = [self.moneyFormatter stringFromNumber:purchasePower];
            rightLabel3.text = enableBalanceString.length ? purchasePowerString : @"--";
            
            NSNumber *withdrawBalance = [NSNumber numberWithString:responseModel.result.withdrawBalance];
            NSString *withdrawBalanceString = [self.moneyFormatter stringFromNumber:withdrawBalance];
            rightLabel4.text = withdrawBalanceString.length ? withdrawBalanceString : @"--";
            
            NSNumber *frozenBalance = [NSNumber numberWithString:responseModel.result.frozenBalance];
            NSString *frozenBalanceString = [self.moneyFormatter stringFromNumber:frozenBalance];
            rightLabel5.text = frozenBalanceString.length ? frozenBalanceString : @"--";
            
            if (responseModel.result.mv.length > 0) {
                rightLabel6.text = nil;
                NSString *mv = [NSString stringWithFormat:@"  %.2f%%", responseModel.result.mv.floatValue * 100];
                NSAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:mv attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: QMUITheme.textColorLevel1}];
                UIColor *color = [UIColor qmui_colorWithHexString:@"#00BA60"];
                NSInteger riskStatusCode = responseModel.result.riskStatusCode;
                if (riskStatusCode == 2) {
                    color = [UIColor qmui_colorWithHexString:@"#FF7127"];
                } else if (riskStatusCode == 3) {
                    color = [UIColor qmui_colorWithHexString:@"#FF3131"];
                } else if (riskStatusCode == 4) {
                    color = [UIColor qmui_colorWithHexString:@"#C40000"];
                }
                NSMutableAttributedString *riskStatusText = [[NSMutableAttributedString alloc] initWithString:responseModel.result.riskStatusName attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: color}];
                [riskStatusText appendAttributedString:attr];
                rightLabel6.attributedText = riskStatusText;
            } else {
                rightLabel6.text = @"--";
            }
            
            NSNumber *debitBalance = [NSNumber numberWithString:responseModel.result.debitBalance];
            NSString *debitBalanceString = [self.moneyFormatter stringFromNumber:debitBalance];
            rightLabel7.text = debitBalanceString.length ? debitBalanceString : @"--";
            
            NSNumber *callMarginCall = [NSNumber numberWithString:responseModel.result.callMarginCall];
            NSString *callMarginCallString = [self.moneyFormatter stringFromNumber:callMarginCall];
            rightLabel8.text = callMarginCallString.length ? callMarginCallString : @"--";
            
            NSNumber *anticipatedInterest = [NSNumber numberWithString:responseModel.result.anticipatedInterest];
            NSString *anticipatedInterestString = [self.moneyFormatter stringFromNumber:anticipatedInterest];
            rightLabel9.text = anticipatedInterestString.length ? anticipatedInterestString : @"--";
            
            NSNumber *mortgageMarketValue = [NSNumber numberWithString:responseModel.result.mortgageMarketValue];
            NSString *mortgageMarketValueString = [self.moneyFormatter stringFromNumber:mortgageMarketValue];
            rightLabel10.text = mortgageMarketValueString.length ? mortgageMarketValueString : @"--";
            
            NSNumber *creditAmount = [NSNumber numberWithString:responseModel.result.creditAmount];
            NSString *creditAmountString = [self.moneyFormatter stringFromNumber:creditAmount];
            rightLabel11.text = creditAmountString.length ? creditAmountString : @"--";
            
            NSNumber *creditRatio = [NSNumber numberWithString:responseModel.result.creditRatio];
            rightLabel12.text = responseModel.result.creditRatio.length ? [NSString stringWithFormat:@"%.2f%%", creditRatio.floatValue*100.0] : @"--";
            
            NSString *marginRatioYearString = responseModel.result.marginRatioYear.length ? responseModel.result.marginRatioYear : @"--";
            NSString *marginRatioDayString = responseModel.result.marginRatioDay.length ? responseModel.result.marginRatioDay : @"--";
            if (responseModel.result.marginRatioYear.length > 0) {
                rightLabel13.text = [NSString stringWithFormat:@"%@(%@)", marginRatioYearString, [YXLanguageUtility kLangWithKey:@"hold_interest_rate_pa"]];
            } else {
                rightLabel13.text = [NSString stringWithFormat:@"%@(%@)", marginRatioDayString, [YXLanguageUtility kLangWithKey:@"hold_interest_rate_daily"]];
            }
            
            NSNumber *onWayBalance = [NSNumber numberWithString:responseModel.result.onWayBalance];
            NSString *onWayBalanceString = [self.moneyFormatter stringFromNumber:onWayBalance];
            rightLabel14.text = onWayBalanceString.length ? onWayBalanceString : @"--";
            
            NSNumber *stockMarketValue = [NSNumber numberWithString:responseModel.result.marketValue];
            NSString *stockMarketValueString = [self.moneyFormatter stringFromNumber:stockMarketValue];
            rightLabel15.text = stockMarketValueString.length ? stockMarketValueString : @"--";
            
            
            [self.contentView.mj_header endRefreshing];
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            
        }];
    }];
    self.contentView.mj_header = header;
    
    [header beginRefreshing];
}

- (void)aboutButtonAction {
    [YXWebViewModel pushToWebVC:YXH5Urls.YX_TRADE_ASSET_DESC_URL];
}

- (UIScrollView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    }
    return _contentView;
}

- (UILabel *)leftLabel {
    UILabel *label = [[UILabel alloc] init];
    label.textColor = QMUITheme.textColorLevel1;
    label.font = [UIFont systemFontOfSize:14];
    return label;
}

- (UILabel *)rightLabel {
    UILabel *label = [[UILabel alloc] init];
    label.textColor = QMUITheme.textColorLevel2;
    label.font = [UIFont systemFontOfSize:14];
    label.text = @"--";
    label.textAlignment = NSTextAlignmentRight;
    return label;
}

- (NSNumberFormatter *)moneyFormatter {
    if (_moneyFormatter == nil) {
        _moneyFormatter = [[NSNumberFormatter alloc] init];
        _moneyFormatter.positiveFormat = @"###,##0.00";
        _moneyFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh"];
    }
    
    return _moneyFormatter;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
