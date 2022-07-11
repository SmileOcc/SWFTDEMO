//
//  YXStockDetailLongPressSubLabel.m
//  uSmartOversea
//
//  Created by youxin on 2021/4/22.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXStockDetailLongPressSubLabel.h"
#import <Masonry/Masonry.h>
#import "UILabel+create.h"
#import "YXToolUtility.h"
#import "uSmartOversea-Swift.h"

@implementation YXStockDetailLongPressSubLabel

- (instancetype)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;

}

- (void)initUI{

    [self addSubview:self.titleLabel];
    [self addSubview:self.paraLabel];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(self);
    }];
    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

    [self.paraLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self);
        make.left.mas_greaterThanOrEqualTo(self.titleLabel.mas_right).offset(5);
        make.right.equalTo(self.mas_right);
    }];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.minimumScaleFactor = 0.3;
    self.paraLabel.adjustsFontSizeToFitWidth = YES;
    self.paraLabel.minimumScaleFactor = 0.3;
    self.paraLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    self.paraLabel.numberOfLines = 1;
}

#pragma mark - lazy load

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [UILabel labelWithText:@"" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:12] textAlignment:NSTextAlignmentLeft];
    }
    return _titleLabel;
}

- (UILabel *)paraLabel{
    if (!_paraLabel) {
        _paraLabel = [UILabel labelWithText:@"" textColor:[QMUITheme textColorLevel1] textFont:[UIFont systemFontOfSize:12] textAlignment:NSTextAlignmentLeft];
    }
    return _paraLabel;
}

- (void)setMargin:(CGFloat)margin{

    _margin = margin;
    [self.paraLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_greaterThanOrEqualTo(self.titleLabel.mas_right).offset(margin);
    }];

}

- (void)setMaxTitleWidth:(CGFloat)maxTitleWidth {
    _maxTitleWidth = maxTitleWidth;
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(self);
        make.width.mas_lessThanOrEqualTo(maxTitleWidth);
    }];

}

- (void)setRightAlignment {
    [self.paraLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self);
        make.left.equalTo(self.titleLabel.mas_right).offset(_margin > 0 ? _margin : 5);
        make.right.mas_lessThanOrEqualTo(self.mas_right).offset(-1);
    }];
}

@end
