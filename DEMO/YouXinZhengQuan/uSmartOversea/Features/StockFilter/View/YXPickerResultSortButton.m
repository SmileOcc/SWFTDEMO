//
//  YXPickerResultSortButton.m
//  uSmartOversea
//
//  Created by youxin on 2020/9/8.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXPickerResultSortButton.h"
#import "uSmartOversea-Swift.h"

@implementation YXPickerResultSortButton

+ (instancetype)buttonWithSortType:(NSInteger)filterType sortState:(YXSortState)sortState {
    YXPickerResultSortButton *button = [YXPickerResultSortButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    button.titleLabel.textAlignment = NSTextAlignmentRight;
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.titleLabel.minimumScaleFactor = 0.7;
    button.titleLabel.numberOfLines = 2;
    button.filterType = filterType;
    button.sortState = sortState;
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [button setTitleColor:[[QMUITheme textColorLevel1] colorWithAlphaComponent:0.65] forState:UIControlStateNormal];
    button.imagePosition = QMUIButtonImagePositionRight;
    button.spacingBetweenImageAndTitle = 4.0;
    button.adjustsImageWhenHighlighted = NO;
    return button;
}


- (void)setFilterType:(NSInteger)filterType {
    _filterType = filterType;
    [self updateFilterType];
}

- (void)setSortState:(YXSortState)sortState {
    _sortState = sortState;
    [self updateSortStatus];
}

- (void)updateFilterType {

}

- (void)updateSortStatus {
    UIImage *image = nil;

    if (self.filterType == YXStockFilterItemTypeMarket || self.filterType == YXStockFilterItemTypeIndustry || self.filterType == YXStockFilterItemTypeIndex || self.filterType == YXStockFilterItemTypeAh ||
        self.filterType == YXStockFilterItemTypeHkschs ||
        self.filterType == YXStockFilterItemTypeHsschk ||
        self.filterType == YXStockFilterItemTypeMargin ||
        self.filterType == YXStockFilterItemTypeExchange ||
        self.filterType == YXStockFilterItemTypeBoard) {

    } else {
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
    }

    [self setImage:image forState:UIControlStateNormal];
}

@end
