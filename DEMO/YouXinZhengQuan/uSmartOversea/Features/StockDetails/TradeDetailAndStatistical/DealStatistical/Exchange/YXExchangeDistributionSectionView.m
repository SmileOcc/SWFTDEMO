//
//  YXExchangeDistributionSectionView.m
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2022/1/13.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

#import "YXExchangeDistributionSectionView.h"
#import <Masonry/Masonry.h>
#import "uSmartOversea-Swift.h"

@interface YXExchangeDistributionSectionView ()

@end

@implementation YXExchangeDistributionSectionView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}


- (void)initUI {
    
    self.backgroundColor = QMUITheme.foregroundColor;

    [self addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(self);
        make.left.equalTo(self).offset(82);
        make.width.mas_equalTo(YXConstant.screenWidth-82);
        make.height.mas_equalTo(40);
    }];
    self.scrollView.contentSize = CGSizeMake(680, 40);
    
    UILabel *nameLabel = [self creatLabelWithTitle:[YXLanguageUtility kLangWithKey:@"exchange"]];
    nameLabel.frame = CGRectMake(12, 0, 70, 40);
    [self addSubview:nameLabel];
    
    NSArray *titleArr = @[[YXLanguageUtility kLangWithKey:@"market_volume"], [NSString stringWithFormat:@"%@%%", [YXLanguageUtility kLangWithKey:@"market_volume"]], [YXLanguageUtility kLangWithKey:@"market_amount"], [NSString stringWithFormat:@"%@%%", [YXLanguageUtility kLangWithKey:@"market_amount"]], [YXLanguageUtility kLangWithKey:@"stock_deal_master_buy"], [YXLanguageUtility kLangWithKey:@"stock_deal_master_sell"], [YXLanguageUtility kLangWithKey:@"stock_deal_neutral_disk"]];
    NSArray *padding = @[@(44), @(190), @(260), @(340), @(420), @(500), @(624)];
    
    for (int i = 0; i < titleArr.count; ++i) {
        NSString *title = titleArr[i];
        NSNumber *number = padding[i];
        UILabel *label = [self creatLabelWithTitle:title];
        [label sizeToFit];
        label.frame = CGRectMake(number.floatValue, 0, label.bounds.size.width, 40);
        if (i == 1) {
            label.frame = CGRectMake(number.floatValue, 0, 52, 40);
        }
        [self.scrollView addSubview:label];
    }
    
}

- (UILabel *)creatLabelWithTitle: (NSString *)title {
    UILabel *label = [UILabel labelWithText:title textColor:QMUITheme.textColorLevel2 textFont:[UIFont systemFontOfSize:12] textAlignment:NSTextAlignmentLeft];
    label.numberOfLines = 2;
    label.adjustsFontSizeToFitWidth = YES;
    return label;
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
