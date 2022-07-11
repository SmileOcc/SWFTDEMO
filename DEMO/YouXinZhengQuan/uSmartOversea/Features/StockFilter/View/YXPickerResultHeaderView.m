//
//  YXPickerResultHeaderView.m
//  uSmartOversea
//
//  Created by youxin on 2020/9/8.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXPickerResultHeaderView.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXPickerResultHeaderView()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) NSMutableArray<YXPickerResultSortButton *> *buttons;
@property (nonatomic, strong) NSArray *sortTypes;

@end

@implementation YXPickerResultHeaderView

- (instancetype)initWithFrame:(CGRect)frame sortTypes:(NSArray *)sortTypes
{
    self = [super initWithFrame:frame];
    if (self) {
        self.sortTypes = sortTypes;
        self.backgroundColor = QMUITheme.foregroundColor;
        [self initializeViews];
    }
    return self;
}

- (void)initializeViews {

    [self addSubview:self.nameLabel];
    [self addSubview:self.scrollView];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(23);
        } else {
            make.left.mas_equalTo(23);
        }
    }];

    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(160);
        } else {
            make.left.mas_equalTo(160);
        }
        make.top.bottom.right.equalTo(self);
    }];

    __block CGFloat width = 0;
    CGFloat fixWidth = 80;
    if ([YXUserManager isENMode]) {
        fixWidth = 100;
    }
    [self.buttons enumerateObjectsUsingBlock:^(YXPickerResultSortButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(width, 0, fixWidth, self.height)];
        [view addSubview:obj];

        if ([YXUserManager isENMode]) {
            width += (fixWidth + 20);
        } else {
            if (obj.filterType == YXStockFilterItemTypeRangeChng5Day || obj.filterType == YXStockFilterItemTypeRangeChng5Day || obj.filterType == YXStockFilterItemTypeRangeChng10Day || obj.filterType == YXStockFilterItemTypeRangeChng30Day || obj.filterType == YXStockFilterItemTypeRangeChng60Day || obj.filterType == YXStockFilterItemTypeRangeChng120Day ||
                obj.filterType == YXStockFilterItemTypeRangeChng250Day || obj.filterType == YXStockFilterItemTypeRangeChngThisYear || obj.filterType == YXStockFilterItemTypeVolume ||
                obj.filterType == YXStockFilterItemTypeIndex ||
                obj.filterType == YXStockFilterItemTypeIndustry) {
                view.frame = CGRectMake(width, 0, 100, self.height);
                width += (100 + 20);
            }  else {
                width += (fixWidth + 20);
            }
        }

        [self.scrollView addSubview:view];
        [obj mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.height.centerY.equalTo(view);
            make.left.equalTo(view).offset(5);
        }];
    }];
    self.scrollView.contentSize = CGSizeMake(width + 5, self.height);
}

- (void)setNeedIcon:(BOOL)needIcon {
    _needIcon = needIcon;
    if (needIcon) {
        [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            if (@available(iOS 11.0, *)) {
                make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(12);
            } else {
                make.left.mas_equalTo(12);
            }
        }];
    }
}

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [QMUITheme textColorLevel3];
        _nameLabel.text = [YXLanguageUtility kLangWithKey:@"market_codeName"];
        _nameLabel.font = [UIFont systemFontOfSize:14];
    }
    return _nameLabel;
}

- (NSMutableArray *)buttons {
    if (_buttons == nil) {
        _buttons = [[NSMutableArray alloc] init];
        [self.sortTypes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            YXPickerResultSortButton *button = [YXPickerResultSortButton buttonWithSortType:[obj integerValue] sortState:YXSortStateNormal];
            [_buttons addObject:button];
            [button addTarget:self action:@selector(sortButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }];
    }
    return _buttons;
}


- (void)setNamesDictionary:(NSDictionary *)namesDictionary {
    _namesDictionary = namesDictionary;
    [self.buttons enumerateObjectsUsingBlock:^(YXPickerResultSortButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        NSString *name = namesDictionary[@(obj.filterType).stringValue];
        [obj setTitle: name ? : @"" forState:UIControlStateNormal];
    }];
}

- (void)sortButtonAction:(YXPickerResultSortButton *)button {

    if (button.filterType == YXStockFilterItemTypeMarket || button.filterType == YXStockFilterItemTypeIndustry || button.filterType == YXStockFilterItemTypeIndex || button.filterType == YXStockFilterItemTypeAh ||
        button.filterType == YXStockFilterItemTypeHkschs ||
        button.filterType == YXStockFilterItemTypeHsschk ||
        button.filterType == YXStockFilterItemTypeMargin ||
        button.filterType == YXStockFilterItemTypeExchange ||
        button.filterType == YXStockFilterItemTypeBoard) {

        return;
    }

    [self.buttons enumerateObjectsUsingBlock:^(YXPickerResultSortButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        if (obj.filterType == button.filterType) {
            if (self.isNormal) {
                switch (button.sortState) {
                    case YXSortStateNormal:
                        button.sortState = YXSortStateDescending;
                        break;
                    case YXSortStateDescending:
                        button.sortState = YXSortStateAscending;
                        break;
                    case YXSortStateAscending:
                        button.sortState = YXSortStateNormal;
                        break;
                    default:
                        break;
                }
            } else {
                if (button.sortState != YXSortStateDescending) {
                    button.sortState = YXSortStateDescending;
                } else {
                    button.sortState = YXSortStateAscending;
                }
            }

            //            if (self.onClickSort) {
            //                self.onClickSort(button.sortState, button.mobileBrief1Type);
            //            }
        } else {
            obj.sortState = YXSortStateNormal;
        }
    }];
    if (self.onClickSort) {
        self.onClickSort(button.sortState, button.filterType);
    }
}

- (void)setDefaultSortState:(YXSortState)state filterType:(NSInteger)type {
    [self.buttons enumerateObjectsUsingBlock:^(YXPickerResultSortButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.sortState = YXSortStateNormal;
        if (obj.filterType == type) {
            obj.sortState = state;
        }
    }];
}

- (void)setSortState:(YXSortState)state filterType:(NSInteger)type {
    [self.buttons enumerateObjectsUsingBlock:^(YXPickerResultSortButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.sortState = YXSortStateNormal;
        if (obj.filterType == type) {
            obj.sortState = state;
            if (self.onClickSort) {
                self.onClickSort(obj.sortState, obj.filterType);
            }
        }
    }];
}

- (void)scrollToVisibleFilterType:(NSInteger)type animated:(BOOL)animated {
    CGRect rect = CGRectZero;
    for (YXPickerResultSortButton *btn in self.buttons) {
        if (btn.filterType == type) {
            rect = btn.superview.frame;
            break;
        }
    }

    [self.scrollView scrollRectToVisible:rect animated:animated];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

