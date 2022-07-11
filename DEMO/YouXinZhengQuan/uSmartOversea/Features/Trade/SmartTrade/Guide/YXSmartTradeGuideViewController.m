//
//  YXSmartTradeGuideViewController.m
//  YouXinZhengQuan
//
//  Created by Mac on 2020/4/7.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXSmartTradeGuideViewController.h"
#import "YXSmartTradeGuideViewModel.h"
#import <Masonry/Masonry.h>

#import "uSmartOversea-Swift.h"

#import "YXBannerActivityDetailModel.h"
#import "YXImageBannerView.h"

#define SMART_GUIDE_BANNER_HEIGHT (YXConstant.screenWidth / 375 * 90)

@interface YXSmartTradeGuideViewController ()<YXCycleScrollViewDelegate>

@property (nonatomic, strong) YXSmartTradeGuideViewModel *viewModel;
@property (nonatomic, strong) UIScrollView *mainScrollView;
//@property (nonatomic, strong) YXImageBannerView *topImgView;

//@property (nonatomic, strong) UILabel *riskTipLab;
//@property (nonatomic, strong) UILabel *tipTextFirstLabel;
@property (nonatomic, strong) YXSmartTradeGuideRiskView *riskView;

@property (nonatomic, strong) YXSmartTradeGuideTypeView *typeView;
//@property (nonatomic, strong) YXSmartTradeGuideHelpView *helpView;


@end

@implementation YXSmartTradeGuideViewController

@dynamic viewModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [YXLanguageUtility kLangWithKey:@"trading_smart_order"];
    
    self.navigationItem.rightBarButtonItems = @[self.messageItem];

    [self.view addSubview:self.mainScrollView];
    [self.mainScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
    }];
    
    [self.mainScrollView addSubview:self.typeView];
    CGFloat typeHeight = self.typeView.contentHeight;
    [self.typeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainScrollView).offset(0);
        make.right.equalTo(self.view).offset(0);
        make.top.equalTo(self.mainScrollView);
        make.height.mas_equalTo(typeHeight);
    }];
    
    [self.mainScrollView addSubview:self.riskView];
    [self.riskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mainScrollView).offset(16);
        make.right.equalTo(self.view.mas_right).offset(-16);
        make.top.equalTo(self.typeView.mas_bottom).offset(20);
        make.bottom.equalTo(self.mainScrollView).offset(-82);
    }];
    self.mainScrollView.backgroundColor = QMUITheme.popupLayerColor;
}

- (void)bindViewModel {
    @weakify(self)
    self.typeView.clickSmartOrderType = ^(enum SmartOrderType smartOrder) {
        @strongify(self)
        [(QMUIModalPresentationViewController *)[UIViewController currentViewController] hideWithAnimated:YES completion:^(BOOL finished) {
            [self.viewModel pushToSmartOrderWith:smartOrder];
            switch (smartOrder) {
                case SmartOrderTypeBreakBuy:
                    [self trackViewClickEventWithName:@"Breakthrough Buy_Tab" other:nil];
                    break;
                case SmartOrderTypeBreakSell:
                    [self trackViewClickEventWithName:@"Breakdown-sell_Tab" other:nil];
                    break;
                case SmartOrderTypeLowPriceBuy:
                    [self trackViewClickEventWithName:@"Buy-low_Tab" other:nil];
                    break;
                case SmartOrderTypeHighPriceSell:
                    [self trackViewClickEventWithName:@"Sell-high_Tab" other:nil];
                    break;
                default:
                    break;
            }
        }];
    };
//
//    self.helpView.clickWhat = ^{
//        [YXWebViewModel pushToWebVC:YXH5Urls.YX_SMART_GUIDE_HELP_ONE_URL];
//    };
//
//    self.helpView.clickHasTypes = ^{
//        [YXWebViewModel pushToWebVC:YXH5Urls.YX_SMART_GUIDE_HELP_TWO_URL];
//    };
//
//    [[self.viewModel.advertiseCommand execute:nil] subscribeNext:^(NSMutableArray *_Nullable activityArr) {
//        @strongify(self)
//        if (activityArr.count > 0) {
//            NSMutableArray *picArr = [[NSMutableArray alloc] init];
//            for (NSInteger i = 0; i < activityArr.count; i++) {
//                YXBannerActivityDetailModel *model = activityArr[i];
//                [picArr addObject:model.pictureUrl];
//            }
//            self.topImgView.imageURLStringsGroup = picArr;
//            [self.topImgView mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.height.mas_equalTo(SMART_GUIDE_BANNER_HEIGHT);
//            }];
//        } else {
//            [self.topImgView mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.height.mas_equalTo(0);
//            }];
//        }
//    }];
    
    
    [[self.viewModel.kindlyReminderCommand execute:nil] subscribeNext:^(NSDictionary *_Nullable data) {
        @strongify(self)
        
        NSString *value = data[@"sceneType1"];
        if (value.length > 0) {
           // self.tipTextFirstLabel.hidden = NO;
            
            NSAttributedString *attStr = [YXNewStockPurchaseUtility htmlStringWithText:value];

            NSMutableAttributedString *muAttStr = [[NSMutableAttributedString alloc] initWithAttributedString:attStr];
            
            [muAttStr addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12 weight:UIFontWeightRegular], NSForegroundColorAttributeName:[QMUITheme textColorLevel3]} range:NSMakeRange(0, attStr.length)];

           // self.tipTextFirstLabel.attributedText = muAttStr;
            //self.riskView.hidden = NO;
            self.riskView.descLab.attributedText = muAttStr;
        } else {
           // self.riskView.hidden = YES;
            //self.tipTextFirstLabel.hidden = YES;
        }
    }];
}

//MARK: SDCycleScrollViewDelegate
-(void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    if (self.viewModel.bannerList.count > index) {
        YXBannerActivityDetailModel *model = self.viewModel.bannerList[index];
        [(NavigatorServices *)self.viewModel.services gotoBannerWith:model];
    }
}


//MARK: 私有方法
- (UILabel *)buildLabelWith:(NSString *)text textColor:(UIColor *)textColor {
    UILabel *lab = UILabel.new;
    lab.textColor = textColor;
    lab.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    lab.text = text;
    return lab;
}

- (UIButton *)buildBtnWith:(NSString *)text bgColor:(UIColor *)bgColor {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = bgColor;
    [btn setTitle:text forState:UIControlStateNormal];
    [btn setTitleColor:[QMUITheme textColorLevel1] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    return btn;
}

- (void)addShadowLayer:(UIView *)view {
    view.layer.backgroundColor = [QMUITheme popupLayerColor].CGColor;
    view.layer.cornerRadius = 10;
    view.layer.borderColor = [[QMUITheme textColorLevel1] colorWithAlphaComponent:0.05].CGColor;
    view.layer.borderWidth = 1;
    view.layer.shadowColor = [[QMUITheme textColorLevel1] colorWithAlphaComponent:0.05].CGColor;
    view.layer.shadowOpacity = 1.0;
}

//MARK: getter方法
- (UIScrollView *)mainScrollView {
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, YXConstant.screenHeight - [YXConstant navBarHeight])];
        _mainScrollView.backgroundColor = [QMUITheme popupLayerColor];
    }
    return _mainScrollView;
}

//- (YXImageBannerView *)topImgView {
//    if (!_topImgView) {
//        _topImgView = [YXImageBannerView cycleScrollViewWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, SMART_GUIDE_BANNER_HEIGHT) delegate:self placeholderImage:[UIImage imageNamed:@"placeholder_4bi1"]];
//    }
//    return _topImgView;
//}

- (YXSmartTradeGuideTypeView *)typeView {
    if (!_typeView) {
        _typeView = [[YXSmartTradeGuideTypeView alloc] initWithFrame:CGRectZero];
        _typeView.backgroundColor = QMUITheme.popupLayerColor;
        _typeView.configs = self.viewModel.configs;
//        [self addShadowLayer:_typeView];
    }
    return _typeView;
}
//- (YXSmartTradeGuideHelpView *)helpView {
//    if (!_helpView) {
//        _helpView = [[YXSmartTradeGuideHelpView alloc] initWithFrame:CGRectZero];
//        _helpView.backgroundColor = [QMUITheme foregroundColor];
////        [self addShadowLayer:_helpView];
//    }
//    return _helpView;
//}

//- (UILabel *)riskTipLab {
//    if (!_riskTipLab) {
//        _riskTipLab = [UILabel new];
//        _riskTipLab.textColor = [QMUITheme textColorLevel3];
//        _riskTipLab.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
//        _riskTipLab.text = [YXLanguageUtility kLangWithKey:@"usStock_subs_risk_tip"];
//    }
//    return _riskTipLab;
//}
//
//- (UILabel *)tipTextFirstLabel {
//    if (!_tipTextFirstLabel) {
//        _tipTextFirstLabel = [UILabel new];
//        _tipTextFirstLabel.textColor = [QMUITheme textColorLevel3];
//        _tipTextFirstLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
//        _tipTextFirstLabel.numberOfLines = 0;
//    }
//    return _tipTextFirstLabel;
//}

- (YXSmartTradeGuideRiskView*)riskView{
    if (!_riskView) {
        _riskView = [[YXSmartTradeGuideRiskView alloc] initWithFrame: CGRectMake(0, 0, 0, 0)];
    }
    return  _riskView;
}

- (NSString *)pageName {
    return @"Stock Smart Order";
}

@end
