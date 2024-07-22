//
//  ZFOrderReviewResultOrderCCell.m
//  ZZZZZ
//
//  Created by YW on 2019/10/29.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFOrderReviewResultOrderCCell.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFInitViewProtocol.h"

@interface ZFOrderReviewResultOrderCCell()<ZFInitViewProtocol>

@property (nonatomic, strong) UILabel *orderTitleLabel;


@end

@implementation ZFOrderReviewResultOrderCCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)zfInitView {
    [self.contentView addSubview:self.orderTitleLabel];
}

- (void)zfAutoLayoutView {
    [self.orderTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}

- (UILabel *)orderTitleLabel {
    if (!_orderTitleLabel) {
        _orderTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _orderTitleLabel.text = @"doajfodaj dsajf ";
    }
    return _orderTitleLabel;
}
@end
