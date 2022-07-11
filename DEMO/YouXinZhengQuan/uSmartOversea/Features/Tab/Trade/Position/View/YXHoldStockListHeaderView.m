//
//  YXHoldStockListHeaderView.m
//  YouXinZhengQuan
//
//  Created by ellison on 2018/12/17.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXHoldStockListHeaderView.h"
#import <Masonry/Masonry.h>
#import "UIView+Line.h"
#import "uSmartOversea-Swift.h"

@interface YXHoldStockListHeaderView()<UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray<YXSortButton *> *buttons;
@property (nonatomic, strong) NSArray *sortTypes;
@property(nonatomic, strong) UIImageView *gradientView;

@end

@implementation YXHoldStockListHeaderView

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
    [self addSubview:self.gradientView];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(16);
        } else {
            make.left.mas_equalTo(16);
        }
    }];

    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(138);
        } else {
            make.left.mas_equalTo(138);
        }
        make.top.bottom.right.equalTo(self);
    }];

    [self.gradientView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(138);
        } else {
            make.left.mas_equalTo(138);
        }
        make.top.bottom.equalTo(self);
        make.width.mas_equalTo(23);
    }];

    __block CGFloat width = 0;
    [self.buttons enumerateObjectsUsingBlock:^(YXSortButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(width, 0, 80, self.frame.size.height)];
        [view addSubview:obj];
        if (obj.mobileBrief1Type == YXMobileBrief1TypeVolume || obj.mobileBrief1Type == YXMobileBrief1TypeYXScore) {
            view.frame = CGRectMake(width, 0, 100, self.height);
            width += (100 + 15);
        } else if (obj.mobileBrief1Type == YXMobileBrief1TypeHoldingBalance) {
            CGFloat btnWidth = 80;
            if (YXUserManager.curLanguage == YXLanguageTypeEN  ||
                YXUserManager.curLanguage == YXLanguageTypeML  ||
                YXUserManager.curLanguage == YXLanguageTypeTH) {
                btnWidth = 100;
            }
            view.frame = CGRectMake(width, 0, btnWidth, self.height);
            width += (btnWidth + 15);
        }  else if (obj.mobileBrief1Type == YXMobileBrief1TypeAccer5 || obj.mobileBrief1Type == YXMobileBrief1TypePctChg5day || obj.mobileBrief1Type == YXMobileBrief1TypePctChg10day || obj.mobileBrief1Type == YXMobileBrief1TypePctChg30day || obj.mobileBrief1Type == YXMobileBrief1TypePctChg60day || obj.mobileBrief1Type == YXMobileBrief1TypePctChg120day || obj.mobileBrief1Type == YXMobileBrief1TypePctChg250day || obj.mobileBrief1Type == YXMobileBrief1TypePctChg1year || obj.mobileBrief1Type == YXMobileBrief1TypeAvgSpread || obj.mobileBrief1Type == YXMobileBrief1TypeOpenOnTime || obj.mobileBrief1Type == YXMobileBrief1TypeOneTickSpreadProducts || obj.mobileBrief1Type == YXMobileBrief1TypeOneTickSpreadDuration || obj.mobileBrief1Type == YXMobileBrief1TypeYXSelection) {

            if (YXUserManager.curLanguage == YXLanguageTypeEN  ||
                YXUserManager.curLanguage == YXLanguageTypeML  ||
                YXUserManager.curLanguage == YXLanguageTypeTH) {
                view.frame = CGRectMake(width, 0, 130, self.height);
                width += (130 + 15);
            } else {
                view.frame = CGRectMake(width, 0, 110, self.height);
                width += (110 + 15);
            }
        } else if (obj.mobileBrief1Type == YXMobileBrief1TypePreAndClosePrice || obj.mobileBrief1Type == YXMobileBrief1TypeAfterAndClosePrice || obj.mobileBrief1Type == YXMobileBrief1TypePreRoc || obj.mobileBrief1Type == YXMobileBrief1TypeAfterRoc) {
            CGFloat w = (YXConstant.screenWidth-170)/2.0;
            view.frame = CGRectMake(width, 0, w, self.height);
            width += w;
        } else {
            width += (80 + 15);
        }
        [self.scrollView addSubview:view];
        [obj mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.left.height.centerY.equalTo(view);
        }];
    }];
    self.scrollView.contentSize = CGSizeMake(width + 5, 0);
}

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [QMUITheme textColorLevel3];
        _nameLabel.text = [YXLanguageUtility kLangWithKey:@"market_codeName"];
        _nameLabel.font = [UIFont systemFontOfSize:12];
    }
    return _nameLabel;
}

- (UIImageView *)gradientView {
    if (!_gradientView) {
        _gradientView = [UIImageView holdGradientWith:CGSizeMake(23, 44)];
        _gradientView.hidden = YES;
    }
    return _gradientView;
}

- (NSMutableArray *)buttons {
    if (_buttons == nil) {
        _buttons = [[NSMutableArray alloc] init];
        [self.sortTypes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            YXSortButton *button = [YXSortButton buttonWithSortType:[obj integerValue] sortState:YXSortStateNormal];
            button.titleLabel.textAlignment = NSTextAlignmentRight;
            [_buttons addObject:button];
            [button addTarget:self action:@selector(sortButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }];
    }
    return _buttons;
}

- (void)sortButtonAction:(YXSortButton *)button {
    [self.buttons enumerateObjectsUsingBlock:^(YXSortButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        if (obj.mobileBrief1Type == button.mobileBrief1Type) {
            if (button.sortState != YXSortStateDescending) {
                button.sortState = YXSortStateDescending;
            } else {
                button.sortState = YXSortStateAscending;
            }
        } else {
            obj.sortState = YXSortStateNormal;
        }
    }];
    if (self.onClickSort) {
        self.onClickSort(button.sortState, button.mobileBrief1Type);
    }
}

- (void)setDefaultSortState:(YXSortState)state mobileBrief1Type:(YXMobileBrief1Type)type {
    [self.buttons enumerateObjectsUsingBlock:^(YXSortButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.sortState = YXSortStateNormal;
        if (obj.mobileBrief1Type == type) {
            obj.sortState = state;
        }
    }];
}

- (void)setSortState:(YXSortState)state mobileBrief1Type:(YXMobileBrief1Type)type {
    [self.buttons enumerateObjectsUsingBlock:^(YXSortButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.sortState = YXSortStateNormal;
        if (obj.mobileBrief1Type == type) {
            obj.sortState = state;
            if (self.onClickSort) {
                self.onClickSort(obj.sortState, obj.mobileBrief1Type);
            }
        }
    }];
}

- (void)scrollToVisibleMobileBrief1Type:(YXMobileBrief1Type)type animated:(BOOL)animated {
    CGRect rect = CGRectZero;
    for (YXSortButton *btn in self.buttons) {
        if (btn.mobileBrief1Type == type) {
            rect = btn.superview.frame;
            break;
        }
    }

    [self.scrollView scrollRectToVisible:rect animated:animated];
}

- (void)resetButtonsWithArr:(NSArray *)sortTypes {

    self.sortTypes = sortTypes;

    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];

    _buttons = [[NSMutableArray alloc] init];
    [self.sortTypes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        YXSortButton *button = [YXSortButton buttonWithSortType:[obj integerValue] sortState:YXSortStateNormal];
        [_buttons addObject:button];
        [button addTarget:self action:@selector(sortButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }];

    __block CGFloat width = 5;
    [self.buttons enumerateObjectsUsingBlock:^(YXSortButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(width, 0, 80, self.height)];
        [view addSubview:obj];
        if (obj.mobileBrief1Type == YXMobileBrief1TypeVolume || obj.mobileBrief1Type == YXMobileBrief1TypeYXScore) {
            view.frame = CGRectMake(width, 0, 100, self.height);
            width += (100 + 15);
        } else if (obj.mobileBrief1Type == YXMobileBrief1TypeHoldingBalance) {
            CGFloat btnWidth = 80;
            if (YXUserManager.curLanguage == YXLanguageTypeEN ||
                YXUserManager.curLanguage == YXLanguageTypeML ||
                YXUserManager.curLanguage == YXLanguageTypeTH) {
                btnWidth = 100;
            }
            view.frame = CGRectMake(width, 0, btnWidth, self.height);
            width += (btnWidth + 15);
        }  else if (obj.mobileBrief1Type == YXMobileBrief1TypeAccer5 || obj.mobileBrief1Type == YXMobileBrief1TypePctChg5day || obj.mobileBrief1Type == YXMobileBrief1TypePctChg10day || obj.mobileBrief1Type == YXMobileBrief1TypePctChg30day || obj.mobileBrief1Type == YXMobileBrief1TypePctChg60day || obj.mobileBrief1Type == YXMobileBrief1TypePctChg120day || obj.mobileBrief1Type == YXMobileBrief1TypePctChg250day || obj.mobileBrief1Type == YXMobileBrief1TypePctChg1year || obj.mobileBrief1Type == YXMobileBrief1TypeAvgSpread || obj.mobileBrief1Type == YXMobileBrief1TypeOpenOnTime || obj.mobileBrief1Type == YXMobileBrief1TypeOneTickSpreadProducts || obj.mobileBrief1Type == YXMobileBrief1TypeOneTickSpreadDuration || obj.mobileBrief1Type == YXMobileBrief1TypeYXSelection) {

            if (YXUserManager.curLanguage == YXLanguageTypeEN ||
                YXUserManager.curLanguage == YXLanguageTypeML ||
                YXUserManager.curLanguage == YXLanguageTypeTH) {
                view.frame = CGRectMake(width, 0, 130, self.height);
                width += (130 + 15);
            } else {
                view.frame = CGRectMake(width, 0, 110, self.height);
                width += (110 + 15);
            }
        } else if (obj.mobileBrief1Type == YXMobileBrief1TypePreAndClosePrice || obj.mobileBrief1Type == YXMobileBrief1TypeAfterAndClosePrice || obj.mobileBrief1Type == YXMobileBrief1TypePreRoc || obj.mobileBrief1Type == YXMobileBrief1TypeAfterRoc) {
            CGFloat w = (YXConstant.screenWidth-170)/2.0;
            view.frame = CGRectMake(width, 0, w, self.height);
            width += w;
        } else {
            width += (80 + 15);
        }
        [self.scrollView addSubview:view];
        [obj mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.left.height.centerY.equalTo(view);
        }];
    }];
    self.scrollView.contentSize = CGSizeMake(width + 5, 0);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.gradientView.hidden = scrollView.contentOffset.x <= 0;
}

@end
