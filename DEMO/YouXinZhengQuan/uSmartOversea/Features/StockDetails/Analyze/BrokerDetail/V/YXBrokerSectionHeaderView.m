//
//  YXBrokerSectionHeaderView.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/2/26.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXBrokerSectionHeaderView.h"
#import "UILabel+create.h"
#import <Masonry/Masonry.h>
#import "uSmartOversea-Swift.h"

@interface YXBrokerSectionHeaderView ()

@end

@implementation YXBrokerSectionHeaderView


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
    UILabel *dateLabel = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"broker_date"] textColor:QMUITheme.textColorLevel3 textFont:[UIFont systemFontOfSize:12]];
    UILabel *numberLabel = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"economic_hold_num"] textColor:QMUITheme.textColorLevel3 textFont:[UIFont systemFontOfSize:12]];
    UILabel *holdLabel = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"broker_percent"] textColor:QMUITheme.textColorLevel3 textFont:[UIFont systemFontOfSize:12]];
    UILabel *changeLabel = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"economic_ratio_change"] textColor:QMUITheme.textColorLevel3 textFont:[UIFont systemFontOfSize:12]];
    UILabel *buyLabel = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"economic_change_volume"] textColor:QMUITheme.textColorLevel3 textFont:[UIFont systemFontOfSize:12]];

    numberLabel.textAlignment = NSTextAlignmentRight;
    holdLabel.textAlignment = NSTextAlignmentRight;
    changeLabel.textAlignment = NSTextAlignmentRight;
    buyLabel.textAlignment = NSTextAlignmentRight;

    [self addSubview:dateLabel];
    [self addSubview:self.scrollView];
    [self addGestureRecognizer:self.scrollView.panGestureRecognizer];
    
    [dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(16);
        make.centerY.equalTo(self);
    }];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(116);
        make.top.bottom.right.equalTo(self);
    }];
    
    numberLabel.frame = CGRectMake(0, 0, 100, 25);
    holdLabel.frame = CGRectMake(100, 0, 80, 25);
    changeLabel.frame = CGRectMake(180, 0, 80, 25);
    buyLabel.frame = CGRectMake(260, 0, 100, 25);
    
    self.scrollView.contentSize = CGSizeMake(360 + 16, 25);
    
    [self.scrollView addSubview:numberLabel];
    [self.scrollView addSubview:holdLabel];
    [self.scrollView addSubview:changeLabel];
    [self.scrollView addSubview:buyLabel];
}


- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.userInteractionEnabled = NO;
    }
    return _scrollView;
}

@end
