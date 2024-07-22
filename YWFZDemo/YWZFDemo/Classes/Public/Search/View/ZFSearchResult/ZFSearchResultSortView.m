//
//  ZFSearchResultSortView.m
//  ZZZZZ
//
//  Created by YW on 2018/3/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSearchResultSortView.h"
#import "ZFInitViewProtocol.h"
#import "ZFSearchResultPriceSortView.h"
#import "ZFThemeManager.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFSearchResultSortView() <ZFInitViewProtocol>

@property (nonatomic, strong) UIButton                      *recommendButton;
@property (nonatomic, strong) UIButton                      *otherSortButton;
@property (nonatomic, strong) ZFSearchResultPriceSortView   *priceSortButton;
@property (nonatomic, strong) UIView                        *lineView;
@end

@implementation ZFSearchResultSortView
#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - action methods
- (void)recommendButtonAction:(UIButton *)sender {
    self.selectType = ZFSearchResultSortTypeRecommend;
    if (self.searchResultSortCompletionHandler) {
        self.searchResultSortCompletionHandler(ZFSearchResultSortTypeRecommend);
    }
}

- (void)otherSortButtonAction:(UIButton *)sender {
    self.selectType = ZFSearchResultSortTypeNewArrival;
    if (self.searchResultSortCompletionHandler) {
        self.searchResultSortCompletionHandler(ZFSearchResultSortTypeNewArrival);
    }
}



#pragma mark - private methods
- (void)clearAllButtonSelectNormalOption {
    //选中状态
    self.recommendButton.selected = NO;
    self.recommendButton.titleLabel.font = [UIFont systemFontOfSize:14];
    self.otherSortButton.selected = NO;
    self.otherSortButton.titleLabel.font = [UIFont systemFontOfSize:14];
    self.priceSortButton.sortType = ZFSearchResultPriceSortTypeNormal;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.recommendButton];
    [self addSubview:self.otherSortButton];
    [self addSubview:self.priceSortButton];
    [self addSubview:self.lineView];
}

- (void)zfAutoLayoutView {
    [self.recommendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.mas_equalTo(self);
        make.bottom.mas_equalTo(self.mas_bottom).offset(.5f);
        make.width.mas_equalTo(KScreenWidth / 3.0);
    }];
    
    [self.otherSortButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.recommendButton.mas_trailing);
        make.top.mas_equalTo(self);
        make.bottom.mas_equalTo(self.mas_bottom).offset(.5f);
        make.width.mas_equalTo(KScreenWidth / 3.0);
    }];
    
    [self.priceSortButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.otherSortButton.mas_trailing);
        make.bottom.mas_equalTo(self.mas_bottom).offset(.5f);
        make.top.trailing.mas_equalTo(self);
        make.width.mas_equalTo(KScreenWidth / 3.0);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
}

#pragma mark - setter
- (void)setSelectType:(ZFSearchResultSortType)selectType {
    _selectType = selectType;
    //清空按钮状态
    [self clearAllButtonSelectNormalOption];
    switch (selectType) {
        case ZFSearchResultSortTypeRecommend:
            self.recommendButton.selected = YES;
            self.recommendButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];

            self.priceSortButton.sortType = ZFSearchResultPriceSortTypeNormal;
            break;
        case ZFSearchResultSortTypeNewArrival:
            self.otherSortButton.selected = YES;
            self.otherSortButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
            self.priceSortButton.sortType = ZFSearchResultPriceSortTypeNormal;
            break;
        case ZFSearchResultSortTypeHighToLow:
            self.priceSortButton.sortType = ZFSearchResultPriceSortTypeHighToLow;
            break;
        case ZFSearchResultSortTypeLowToHigh:
            self.priceSortButton.sortType = ZFSearchResultPriceSortTypeLowToHigh;
            break;
    }
}

#pragma mark - getter
- (UIButton *)recommendButton {
    if (!_recommendButton) {
        NSString *title = ZFLocalizedString(@"GoodsSortViewController_Type_Recommend", nil);
        _recommendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recommendButton setTitle:title forState:UIControlStateNormal];
        [_recommendButton setTitleColor:ZFCOLOR(153, 153, 153, 1.f) forState:UIControlStateNormal];
        [_recommendButton setTitle:title forState:UIControlStateSelected];
        [_recommendButton setTitleColor:ZFCOLOR(45, 45, 45, 1.f) forState:UIControlStateSelected];
        _recommendButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_recommendButton addTarget:self action:@selector(recommendButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recommendButton;
}

- (UIButton *)otherSortButton {
    if (!_otherSortButton) {
        NSString *title = ZFLocalizedString(@"GoodsSortViewController_Type_New", nil);
        _otherSortButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_otherSortButton setTitle:title forState:UIControlStateNormal];
        [_otherSortButton setTitleColor:ZFCOLOR(153, 153, 153, 1.f) forState:UIControlStateNormal];
        [_otherSortButton setTitle:title forState:UIControlStateSelected];
        [_otherSortButton setTitleColor:ZFCOLOR(45, 45, 45, 1.f) forState:UIControlStateSelected];
        _otherSortButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_otherSortButton addTarget:self action:@selector(otherSortButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _otherSortButton;
}

- (ZFSearchResultPriceSortView *)priceSortButton {
    if (!_priceSortButton) {
        _priceSortButton = [[ZFSearchResultPriceSortView alloc] initWithFrame:CGRectZero];
        _priceSortButton.sortType = ZFSearchResultPriceSortTypeNormal;
        @weakify(self);
        _priceSortButton.searchResultPriceSortCompletionHandler = ^(ZFSearchResultPriceSortType type) {
            @strongify(self);
            if (type == ZFSearchResultPriceSortTypeNormal) {
                self.selectType = ZFSearchResultSortTypeRecommend;
            } else if (type == ZFSearchResultPriceSortTypeHighToLow) {
                self.selectType = ZFSearchResultSortTypeHighToLow;
            } else if (type == ZFSearchResultPriceSortTypeLowToHigh) {
                self.selectType = ZFSearchResultSortTypeLowToHigh;
            }
            if (self.searchResultSortCompletionHandler) {
                self.searchResultSortCompletionHandler(self.selectType);
            }
        };
    }
    return _priceSortButton;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = [UIColor colorWithHex:0xdddddd];
    }
    return _lineView;
}

@end
