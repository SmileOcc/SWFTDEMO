//
//  YXStockDetailTickAndStatisticalView.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/1/2.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStockDetailTickAndStatisticalView.h"
#import "YXStockDetailDealView.h"
#import "YXStockDetailStatisticalView.h"
#import "YXStockDetailUtility.h"
#import "uSmartOversea-Swift.h"
#import <YXKit/YXKit.h>
#import <Masonry/Masonry.h>
#import "YXStockDetailUtility.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "YXStockConfig.h"

@interface YXStockDetailTickAndStatisticalView()<YXTabViewDelegate>

@property (nonatomic, strong) YXTabView *tabView; //tab

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation YXStockDetailTickAndStatisticalView


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame market:(NSString *)market {
    if (self = [super initWithFrame:frame]) {
        self.market = market;
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    
    [self addSubview:self.tabView];
    [self.tabView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self);
        make.height.mas_equalTo(27);
    }];

    UIView *midLineView = [[UIView alloc] init];
    midLineView.backgroundColor = [QMUITheme separatorLineColor];
    [self addSubview:midLineView];
    [midLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.tabView);
        make.height.mas_equalTo(12);
        make.width.mas_equalTo(0.5);
    }];
    
    UIView *bottomLineView = [[UIView alloc] init];
    bottomLineView.backgroundColor = [QMUITheme separatorLineColor];
    [self addSubview:bottomLineView];
    [bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.mas_equalTo(self.tabView.mas_bottom);
        make.height.mas_equalTo(0.5);
    }];
    
    [self addSubview:self.dealView];
    [self.dealView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bottomLineView.mas_bottom);
        make.bottom.equalTo(self);
        make.leading.trailing.equalTo(self);
    }];
    
    [self addSubview:self.statisticalView];
    [self.statisticalView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.dealView);
    }];
}

- (void)setPreClose:(uint32_t)preClose {
    _preClose = preClose;
    self.dealView.pclose = preClose;
}

- (void)setTickModel:(YXTickData *)tickModel {
    _tickModel = tickModel;
    self.dealView.tickModel = tickModel;
}

- (void)setStatisData:(YXAnalysisStatisticData *)statisData {
    _statisData = statisData;
    self.statisticalView.preClose = self.preClose;
    self.statisticalView.statisData = statisData;
}

- (void)setIsOptionStock:(BOOL)isOptionStock {
    _isOptionStock = isOptionStock;
    if (isOptionStock) {
        self.dealView.hidden = NO;
        self.statisticalView.hidden = YES;
        self.tabView.hidden = YES;
        [self.tabView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
}

#pragma mark - delegate
//tab的代理事件
- (void)tabView:(YXTabView *)tabView didSelectedItemAtIndex:(NSUInteger)index withScrolling:(BOOL)scrolling{
    if (index == 0) {
        self.dealView.hidden = NO;
        self.statisticalView.hidden = YES;
    } else {
        self.dealView.hidden = YES;
        self.statisticalView.hidden = NO;
    }
    
    [YXStockDetailUtility resetStcokTickType:index];
}


#pragma mark - lazy load
//tab切换view
- (YXTabView *)tabView{
    if (!_tabView) {
        YXTabLayout *layout = [YXTabLayout defaultLayout];
        layout.lrMargin = 15;
        layout.titleFont = [UIFont systemFontOfSize:10];
        layout.titleSelectedFont = [UIFont systemFontOfSize:10];
        layout.titleColor = QMUITheme.textColorLevel3;
        layout.tabMargin = 0;
        layout.titleSelectedColor = QMUITheme.themeTextColor;
        layout.lineHeight = 0;
//        layout.lineWidth = 15;
//        layout.lineColor = QMUITheme.textColorLevel1;
        
        _tabView = [[YXTabView alloc] initWithFrame:CGRectZero withLayout:layout];
        _tabView.backgroundColor = QMUITheme.foregroundColor;
        _tabView.delegate = self;
        if ([self.market isEqualToString:kYXMarketChinaSZ] || [self.market isEqualToString:kYXMarketChinaSH]) {
            _tabView.titles = @[[YXLanguageUtility kLangWithKey:@"stock_detail_tricker2"], [YXLanguageUtility kLangWithKey:@"stock_deal_transaction_statistics"]];

        } else {
            _tabView.titles = @[[YXLanguageUtility kLangWithKey:@"stock_detail_tricker"], [YXLanguageUtility kLangWithKey:@"stock_deal_transaction_statistics"]];
        }
        
        YXStockTickType type = [YXStockDetailUtility getStockTickType];
        _tabView.defaultSelectedIndex = type;
        if (type == 0) {
            self.dealView.hidden = NO;
            self.statisticalView.hidden = YES;
        } else {
            self.dealView.hidden = YES;
            self.statisticalView.hidden = NO;
        }
    }
    return _tabView;
}

//逐笔明细
- (YXStockDetailDealView *)dealView{
    if (!_dealView) {
        _dealView = [[YXStockDetailDealView alloc] initWithFrame:CGRectZero market:self.market isLandScape:NO];
    }
    return _dealView;
}

- (YXStockDetailStatisticalView *)statisticalView {
    if (_statisticalView == nil) {
        _statisticalView = [[YXStockDetailStatisticalView alloc] init];
    }
    return _statisticalView;
}


@end
