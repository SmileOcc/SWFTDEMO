//
//  YXStockListHeaderView.m
//  YouXinZhengQuan
//
//  Created by ellison on 2018/12/17.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXStockListHeaderView.h"
#import <Masonry/Masonry.h>
#import "UIView+Line.h"
#import "uSmartOversea-Swift.h"

@interface YXStockListHeaderView()

@property (nonatomic, strong, readwrite) NSMutableArray<YXSortButton *> *buttons;
@property (nonatomic, strong) NSArray *sortTypes;

@end

@implementation YXStockListHeaderView

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
    
    [self addSubview:self.lineView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.scrollView];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self);
        make.height.mas_equalTo(1);
    }];
    
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
            make.left.equalTo(self.mas_safeAreaLayoutGuideLeft).offset(160);
        } else {
            make.left.mas_equalTo(160);
        }
        make.top.bottom.right.equalTo(self);
    }];
    
    __block CGFloat width = 0;
    [self.buttons enumerateObjectsUsingBlock:^(YXSortButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(width, 0, 90, self.frame.size.height)];
        [view addSubview:obj];
        if (obj.mobileBrief1Type == YXMobileBrief1TypeVolume || obj.mobileBrief1Type == YXMobileBrief1TypeYXScore || obj.mobileBrief1Type == YXMobileBrief1TypeHoldingBalance) {
            view.frame = CGRectMake(width, 0, 100, self.height);
            width += (100 + 20);
        } else if (obj.mobileBrief1Type == YXMobileBrief1TypeAccer5 || obj.mobileBrief1Type == YXMobileBrief1TypePctChg5day || obj.mobileBrief1Type == YXMobileBrief1TypePctChg10day || obj.mobileBrief1Type == YXMobileBrief1TypePctChg30day || obj.mobileBrief1Type == YXMobileBrief1TypePctChg60day || obj.mobileBrief1Type == YXMobileBrief1TypePctChg120day || obj.mobileBrief1Type == YXMobileBrief1TypePctChg250day || obj.mobileBrief1Type == YXMobileBrief1TypePctChg1year || obj.mobileBrief1Type == YXMobileBrief1TypeAvgSpread || obj.mobileBrief1Type == YXMobileBrief1TypeOpenOnTime || obj.mobileBrief1Type == YXMobileBrief1TypeOneTickSpreadProducts || obj.mobileBrief1Type == YXMobileBrief1TypeOneTickSpreadDuration || obj.mobileBrief1Type == YXMobileBrief1TypeYXSelection) {

            if (YXUserManager.curLanguage == YXLanguageTypeEN || YXUserManager.curLanguage == YXLanguageTypeTH) {
                view.frame = CGRectMake(width, 0, 130, self.height);
                width += (130 + 20);
            } else {
                view.frame = CGRectMake(width, 0, 110, self.height);
                width += (110 + 20);
            }
        } else if (obj.mobileBrief1Type == YXMobileBrief1TypePreAndClosePrice || obj.mobileBrief1Type == YXMobileBrief1TypeAfterAndClosePrice || obj.mobileBrief1Type == YXMobileBrief1TypePreRoc || obj.mobileBrief1Type == YXMobileBrief1TypeAfterRoc) {
            CGFloat w = (YXConstant.screenWidth-170)/2.0;
            view.frame = CGRectMake(width, 0, w, self.height);
            width += w;
        } else if (obj.mobileBrief1Type == YXMobileBrief1TypeWarrantBuy) {
            if ( YXUserManager.curLanguage == YXLanguageTypeTH) {
                view.frame = CGRectMake(width, 0, 160, self.height);
                width += (160 + 20);
            } else {
                width += (90 + 20);
            }
        } else {
            width += (90 + 20);
        }
        [self.scrollView addSubview:view];
        [obj mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.height.centerY.equalTo(view);
        }];
    }];
    self.scrollView.contentSize = CGSizeMake(width + 5, self.frame.size.height);
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

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView lineView];
    }
    return _lineView;
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
        _nameLabel.font = [UIFont systemFontOfSize:12];
    }
    return _nameLabel;
}

- (NSMutableArray *)buttons {
    if (_buttons == nil) {
        _buttons = [[NSMutableArray alloc] init];
        [self.sortTypes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            YXSortButton *button = [YXSortButton buttonWithSortType:[obj integerValue] sortState:YXSortStateNormal];
            [_buttons addObject:button];
            [button addTarget:self action:@selector(sortButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }];
    }
    return _buttons;
}

- (void)sortButtonAction:(YXSortButton *)button {
    [self.buttons enumerateObjectsUsingBlock:^(YXSortButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (obj.mobileBrief1Type == button.mobileBrief1Type) {
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
    
    __block CGFloat width = 0;
    [self.buttons enumerateObjectsUsingBlock:^(YXSortButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(width, 0, 80, self.height)];
        [view addSubview:obj];
        if (obj.mobileBrief1Type == YXMobileBrief1TypeVolume) {
            view.frame = CGRectMake(width, 0, 100, self.height);
            width += (100 + 20);
        } else if (obj.mobileBrief1Type == YXMobileBrief1TypeAccer5 || obj.mobileBrief1Type == YXMobileBrief1TypePctChg5day || obj.mobileBrief1Type == YXMobileBrief1TypePctChg10day || obj.mobileBrief1Type == YXMobileBrief1TypePctChg30day || obj.mobileBrief1Type == YXMobileBrief1TypePctChg60day || obj.mobileBrief1Type == YXMobileBrief1TypePctChg120day || obj.mobileBrief1Type == YXMobileBrief1TypePctChg250day || obj.mobileBrief1Type == YXMobileBrief1TypePctChg1year) {

            if (YXUserManager.curLanguage == YXLanguageTypeEN || YXUserManager.curLanguage == YXLanguageTypeTH) {
                view.frame = CGRectMake(width, 0, 130, self.height);
                width += (130 + 20);
            } else {
                view.frame = CGRectMake(width, 0, 110, self.height);
                width += (110 + 20);
            }
        } else if (obj.mobileBrief1Type == YXMobileBrief1TypeWarrantBuy) {
            if ( YXUserManager.curLanguage == YXLanguageTypeTH) {
                view.frame = CGRectMake(width, 0, 160, self.height);
                width += (160 + 20);
            } else {
                width += (90 + 20);
            }
        } else {
            width += (80 + 20);
        }
        [self.scrollView addSubview:view];
        [obj mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.height.centerY.equalTo(view);
        }];
    }];
    self.scrollView.contentSize = CGSizeMake(width + 5, self.height);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
