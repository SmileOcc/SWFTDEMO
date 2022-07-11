//
//  YXDealStatisticalBtn.m
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2020/7/20.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXDealStatisticalBtn.h"
#import "uSmartOversea-Swift.h"

@implementation YXDealStatisticalBtn


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
    if ([YXUserManager isENMode]) {
        self.titleLabel.font = [UIFont systemFontOfSize:10];
    } else {
        self.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    
    self.sortState = YXSortStateNormal;
    [self setTitleColor:[[QMUITheme textColorLevel1] colorWithAlphaComponent:0.6] forState:UIControlStateNormal];
    [self setImagePosition:QMUIButtonImagePositionRight];
    self.spacingBetweenImageAndTitle = 0;
    self.adjustsImageWhenHighlighted = NO;
    [self setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -5)];

}

- (void)setSortState:(YXSortState)sortState {
    _sortState = sortState;
    [self updateSortStatus];
}


- (void)updateSortStatus {
    UIImage *image = nil;
    switch (_sortState) {
        case YXSortStateNormal:
            image = [UIImage imageNamed:@"optional_sort"];
            break;
        case YXSortStateDescending:
            image = [UIImage imageNamed:@"optional_sort_descending"];
            break;
        case YXSortStateAscending:
            image = [UIImage imageNamed:@"optional_sort_ascending"];
            break;
        default:
            break;
    }
    [self setImage:image forState:UIControlStateNormal];
}


@end
