//
//  YXSDDealStatisticalHeaderView.m
//  YouXinZhengQuan
//
//  Created by Mac on 2019/11/18.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXSDDealStatisticalHeaderView.h"
#import <Masonry/Masonry.h>
#import "uSmartOversea-Swift.h"
#import "YXDealStatisticalBtn.h"

@interface YXSDDealStatisticalHeaderView ()

@property (nonatomic, strong) YXDealStatisticalBtn *selectBtn;
@property (nonatomic, strong) YXDealStatisticalBtn *dealPriceBtn;
@property (nonatomic, strong) YXDealStatisticalBtn *totalAskBtn;
@property (nonatomic, strong) YXDealStatisticalBtn *totalBidBtn;
@property (nonatomic, strong) YXDealStatisticalBtn *totalBothBtn;

@end

@implementation YXSDDealStatisticalHeaderView



//MARK: 构建Label

- (UILabel *)buildGrayLabelWith:(NSString *)text {
    UILabel * lab = [UILabel new];
    lab.text = text;
    lab.textColor = [[QMUITheme textColorLevel1] colorWithAlphaComponent:0.4];//0.6 0.65
    lab.font = [UIFont systemFontOfSize:14];
    if ([YXUserManager isENMode]) {
        if ([YXToolUtility is4InchScreenWidth]) {
            lab.font = [UIFont systemFontOfSize:10];
        } else {
            lab.font = [UIFont systemFontOfSize:12];
        }
    }
    lab.textAlignment = NSTextAlignmentRight;
    return lab;
}


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

#pragma mark - 设置UI
- (void)setUI {
    [self configureView];
}

- (void) configureView {
    self.backgroundColor = [QMUITheme foregroundColor];
    
    [self addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
        make.width.mas_equalTo(YXConstant.screenWidth);
        make.height.mas_equalTo(40);
    }];
    self.scrollView.contentSize = CGSizeMake(460, 40);
    
    YXDealStatisticalBtn *dealPriceBtn = [self buildBtnWith:[YXLanguageUtility kLangWithKey:@"stock_deal_final_price"]];
    self.dealPriceBtn = dealPriceBtn;
    dealPriceBtn.tag = 1000;
    self.selectBtn = dealPriceBtn;
    self.selectBtn.sortState = YXSortStateDescending;
    [self.scrollView addSubview:dealPriceBtn];
    [dealPriceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.scrollView).offset(12);
        make.top.equalTo(self).offset(14);
//        make.width.mas_equalTo(70);
    }];
    
    YXDealStatisticalBtn *totalAskBtn = [self buildBtnWith:[YXLanguageUtility kLangWithKey:@"stock_deal_master_buy"]];
    self.totalAskBtn = totalAskBtn;
    totalAskBtn.tag = 1001;
    [self.scrollView addSubview:totalAskBtn];
    [totalAskBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.scrollView.mas_leading).offset(127);
        make.top.equalTo(self).offset(14);
        make.width.mas_lessThanOrEqualTo(40);
    }];
    
    YXDealStatisticalBtn *totalBidBtn = [self buildBtnWith:[YXLanguageUtility kLangWithKey:@"stock_deal_master_sell"]];
    self.totalBidBtn = totalBidBtn;
    totalBidBtn.tag = 1002;
    [self.scrollView addSubview:totalBidBtn];
    [totalBidBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.scrollView.mas_leading).offset(191);
        make.top.equalTo(self).offset(14);
    }];
    
    YXDealStatisticalBtn *totalBothBtn = [self buildBtnWith:[YXLanguageUtility kLangWithKey:@"stock_deal_neutral_disk"]];
    self.totalBothBtn = totalBothBtn;
    totalBothBtn.tag = 1003;
    [self.scrollView addSubview:totalBothBtn];
    [totalBothBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.scrollView.mas_leading).offset(270);
//        make.width.mas_equalTo(70);
        make.top.equalTo(self).offset(14);
    }];

    
    YXDealStatisticalBtn *volumeBtn = [self buildBtnWith:[YXLanguageUtility kLangWithKey:@"market_volume"]];
    volumeBtn.tag = 1004;
    [self.scrollView addSubview:volumeBtn];
    [volumeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.scrollView).offset(300);
//        make.width.mas_equalTo(70);
        make.top.equalTo(self).offset(14);
    }];
    
    YXDealStatisticalBtn *rateBtn = [self buildBtnWith:[YXLanguageUtility kLangWithKey:@"stock_deal_Proportion"]];
    rateBtn.tag = 1005;
    [self.scrollView addSubview:rateBtn];
    [rateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.scrollView).offset(415);
        make.top.equalTo(self).offset(14);
    }];
}

- (YXDealStatisticalBtn *)buildBtnWith:(NSString *)text {
    YXDealStatisticalBtn *btn = [[YXDealStatisticalBtn alloc] init];
    [btn setTitle:text forState:UIControlStateNormal];
    btn.contentMode = UIViewContentModeLeft;
    [btn addTarget:self action:@selector(btnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.numberOfLines = 2;
    btn.titleLabel.adjustsFontSizeToFitWidth = YES;
    return btn;
}

- (void)btnDidClick:(YXDealStatisticalBtn *)sender {
    
    if (sender == self.selectBtn) {
        if (sender.sortState == YXSortStateDescending) {
            sender.sortState = YXSortStateAscending;
        } else {
            sender.sortState = YXSortStateDescending;
        }
    } else {
        sender.sortState = YXSortStateDescending;
        self.selectBtn.sortState = YXSortStateNormal;
        self.selectBtn = sender;
    }
    if (self.refreshData) {
        NSInteger sortMode = 0;
        if (self.selectBtn.sortState == YXSortStateAscending) {
            sortMode = 1;
        }
        self.refreshData(sender.tag - 1000, sortMode);
    }
    
}

- (void)setBidOrAskType:(NSInteger)bidOrAskType {
    _bidOrAskType = bidOrAskType;
    if (bidOrAskType == 1) {
        // 主买
        [self.totalBothBtn setImage:nil forState:UIControlStateNormal];
        self.totalBothBtn.enabled = NO;
        [self.totalBidBtn setImage:nil forState:UIControlStateNormal];
        self.totalBidBtn.enabled = NO;
        if (self.selectBtn != self.totalAskBtn) {
            self.totalAskBtn.sortState = YXSortStateNormal;
            self.totalAskBtn.enabled = YES;
        }
    } else if (bidOrAskType == 2) {
        // 主卖
        [self.totalBothBtn setImage:nil forState:UIControlStateNormal];
        self.totalBothBtn.enabled = NO;
        [self.totalAskBtn setImage:nil forState:UIControlStateNormal];
        self.totalAskBtn.enabled = NO;
        if (self.selectBtn != self.totalBidBtn) {
            self.totalBidBtn.sortState = YXSortStateNormal;
            self.totalBidBtn.enabled = YES;
        }
    } else if (bidOrAskType == 3) {
        // 主买主卖
        [self.totalBothBtn setImage:nil forState:UIControlStateNormal];
        self.totalBothBtn.enabled = NO;
        if (self.selectBtn != self.totalAskBtn) {
            self.totalAskBtn.sortState = YXSortStateNormal;
            self.totalAskBtn.enabled = YES;
        }
        if (self.selectBtn != self.totalBidBtn) {
            self.totalBidBtn.sortState = YXSortStateNormal;
            self.totalBidBtn.enabled = YES;
        }
        
    } else if (bidOrAskType == 4) {
        // 中性盘
        [self.totalBidBtn setImage:nil forState:UIControlStateNormal];
        self.totalBidBtn.enabled = NO;
        [self.totalAskBtn setImage:nil forState:UIControlStateNormal];
        self.totalAskBtn.enabled = NO;
        if (self.selectBtn != self.totalBothBtn) {
            self.totalBothBtn.sortState = YXSortStateNormal;
            self.totalBothBtn.enabled = YES;
        }
    } else {
        if (self.selectBtn != self.totalBothBtn) {
            self.totalBothBtn.sortState = YXSortStateNormal;
            self.totalBothBtn.enabled = YES;
        }
        if (self.selectBtn != self.totalAskBtn) {
            self.totalAskBtn.sortState = YXSortStateNormal;
            self.totalAskBtn.enabled = YES;
        }
        if (self.selectBtn != self.totalBidBtn) {
            self.totalBidBtn.sortState = YXSortStateNormal;
            self.totalBidBtn.enabled = YES;
        }
    }
    
    [self.totalBothBtn sizeToFit];
    [self.totalBidBtn sizeToFit];
    [self.totalAskBtn sizeToFit];
}

- (void)resetSelectBtn {
    self.selectBtn.sortState = YXSortStateNormal;
    self.selectBtn = self.dealPriceBtn;
    self.dealPriceBtn.sortState = YXSortStateDescending;
}

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}




@end




