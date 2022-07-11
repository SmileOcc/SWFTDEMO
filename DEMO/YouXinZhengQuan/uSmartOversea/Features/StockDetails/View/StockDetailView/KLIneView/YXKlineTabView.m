//
//  YXKlineTabView.m
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/10/26.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXKlineTabView.h"
#import "YXStockLineMenuView.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXKlineTabExpandBtn : UIButton

@property (nonatomic, assign) BOOL isExpand;

@property (nonatomic, assign) YXRtLineType rtType;

@property (nonatomic, assign) CGFloat fontSize;

@end

@implementation YXKlineTabExpandBtn

- (instancetype)initWithFrame:(CGRect)frame andType:(YXRtLineType)rtType andisExpand: (BOOL)isExpand {
    if (self = [super initWithFrame:frame]) {
        self.isExpand = isExpand;
        self.rtType = rtType;
        self.fontSize = 14;
        
        if (YXUserManager.curLanguage == YXLanguageTypeML) {
            self.fontSize = 12;
        }
        
        [self setUI];
    }
    return self;
}

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

- (void)setFontSize:(CGFloat)fontSize {
    _fontSize = fontSize;
    /// 触发字体改变
    self.selected = self.selected;
}

- (UIFont *)buttonNormalFont {
    return [UIFont systemFontOfSize:self.fontSize];
}

- (UIFont *)buttonSelectFont {
    return [UIFont systemFontOfSize:self.fontSize weight:UIFontWeightMedium];
}

#pragma mark - 设置UI
- (void)setUI {
    self.titleLabel.font = [self buttonNormalFont];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.minimumScaleFactor = 0.3;
    [self setTitleColor:QMUITheme.textColorLevel2 forState:UIControlStateNormal];
    [self setTitleColor:QMUITheme.themeTextColor forState:UIControlStateSelected];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        self.titleLabel.font = [self buttonSelectFont];
    } else {
        self.titleLabel.font = [self buttonNormalFont];
    }
}

- (void)setIsExpand:(BOOL)isExpand {
    _isExpand = isExpand;
    
    if (isExpand) {
        [self setImage:[UIImage imageNamed:@"kline_pull_down"] forState:UIControlStateNormal];
//        [self setImage:[UIImage imageNamed:@"pull_down_arrow"] forState:UIControlStateSelected];
        
    } else {
        [self setImage:nil forState:UIControlStateNormal];
        [self setImage:nil forState:UIControlStateSelected];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat imgW = self.imageView.mj_w;
    CGFloat imgH = self.imageView.mj_h;
    CGFloat titleW = self.titleLabel.mj_w;
    CGFloat padding = 2;
    self.titleLabel.frame = CGRectMake((self.mj_w - imgW - titleW - padding) * 0.5, 0, titleW, self.mj_h);
    self.imageView.frame = CGRectMake(CGRectGetMaxX(self.titleLabel.frame) + padding, (self.mj_h - imgH) * 0.5, imgW, imgH);
}

@end


@interface YXKlineTabView ()

@property (nonatomic, strong) NSArray *minKPopArr;

@property (nonatomic, strong) NSArray *minTsPopArr;

@property (nonatomic, strong) NSArray *mainArr;

@property (nonatomic, strong) NSArray *optionMainArr;

@property (nonatomic, strong) UIStackView *stackView;

//k线菜单栏
@property (nonatomic, strong) YXStockLineMenuView *menuKlineView;
//分时菜单栏
@property (nonatomic, strong) YXStockLineMenuView *menuTsView;
//弹出框
@property (nonatomic, strong) YXStockPopover *popover;



@end

@implementation YXKlineTabView


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
    
    self.backgroundColor = QMUITheme.foregroundColor;
    
    _minKPopArr = @[@(YXKLineSubTypeOneMin), @(YXKLineSubTypeFiveMin), @(YXKLineSubTypeFifteenMin), @(YXKLineSubTypeThirtyMin), @(YXKLineSubTypeSixtyMin)];
    _minTsPopArr = @[@(YXTimeShareLineTypeAll), @(YXTimeShareLineTypePre), @(YXTimeShareLineTypeIntra), @(YXTimeShareLineTypeAfter)];
    
    _mainArr = @[@(YXRtLineTypeDayTimeLine), @(YXRtLineTypeFiveDaysTimeLine), @(YXRtLineTypeDayKline), @(YXRtLineTypeWeekKline), @(YXRtLineTypeMonthKline), @(YXRtLineTypeSeasonKline), @(YXRtLineTypeYearKline), @(YXRtLineTypeOneMinKline)];
    _optionMainArr = @[@(YXRtLineTypeDayTimeLine), @(YXRtLineTypeFiveDaysTimeLine),  @(YXRtLineTypeDayKline), @(YXRtLineTypeOneMinKline), @(YXRtLineTypeFiveMinKline), @(YXRtLineTypeFifteenMinKline), @(YXRtLineTypeSixtyMinKline)];
    
    [self addSubview:self.stackView];
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.left.equalTo(self).offset(16);
        make.right.equalTo(self).offset(-8);
    }];
    
    [self updateStackSubViews];
}

- (void)updateStackSubViews {
    for (UIView *view in self.stackView.subviews) {
        [view removeFromSuperview];
    }
    
    NSArray *arr = _mainArr;
    if (self.isOption) {
        arr = _optionMainArr;
    }
    
    for (NSNumber *number in arr) {
        YXKlineTabExpandBtn *btn = [[YXKlineTabExpandBtn alloc] initWithFrame:CGRectZero andType:number.intValue andisExpand:NO];
        if (number.intValue == self.rtLineType) {
            btn.selected = YES;
        } else {
            btn.selected = NO;
        }
        [btn setTitle:[YXStockDetailUtility getRtStringWithType:number.intValue] forState:UIControlStateNormal];
        [self.stackView addArrangedSubview:btn];
        
        @weakify(self);
        [btn setQmui_tapBlock:^(__kindof YXKlineTabExpandBtn *sender) {
            @strongify(self);
            
            // 分k是否弹出toatst
            if (self.hasMinKExpand && sender.rtType == YXRtLineTypeOneMinKline) {
                // 选中
                if (sender.isSelected) {
                    self.menuKlineView.selectIndex = self.subKlineType - 1;
                    [self.popover show:self.menuKlineView fromView:sender];
                } else {
                    if (self.subKlineType == YXKLineSubTypeNone) {
                        // 没选择过
                        [self.popover show:self.menuKlineView fromView:sender];
                    } else {
                        self.rtLineType = YXRtLineTypeOneMinKline;
                    }
                }
            } else if (self.hasTsExpand && sender.rtType == YXRtLineTypeDayTimeLine){
                // 选中
                if (sender.isSelected) {
                    self.menuTsView.selectIndex = self.subTsType - 1;
                    [self.popover show:self.menuTsView fromView:sender];
                } else {
                    self.rtLineType = YXRtLineTypeDayTimeLine;
                }
            } else {
                if (sender.selected) {
                    return;;
                }
                self.rtLineType = sender.rtType;
            }
        }];
    }
}

- (void)setHasTsExpand:(BOOL)hasTsExpand {
    _hasTsExpand = hasTsExpand;
    YXKlineTabExpandBtn *btn = [self getBtnWithType:YXRtLineTypeDayTimeLine];
    btn.isExpand = hasTsExpand;
    if (hasTsExpand) {
        [btn setTitle:[YXStockDetailUtility getTimeShareStringWithType:self.subTsType] forState:UIControlStateNormal];
    } else {
        self.subTsType = YXTimeShareLineTypeNone;
        [btn setTitle:[YXLanguageUtility kLangWithKey:@"stock_detail_high_line_one_day"] forState:UIControlStateNormal];
    }
    
    
    if (hasTsExpand) {
        if (YXUserManager.curLanguage == YXLanguageTypeML) {
            for (UIView *view in self.stackView.subviews) {
                if ([view isKindOfClass:[YXKlineTabExpandBtn class]]) {
                    YXKlineTabExpandBtn *btn = (YXKlineTabExpandBtn *)view;
                    btn.fontSize = 10;
                }
            }
        }
    }
}



- (void)setHasMinKExpand:(BOOL)hasMinKExpand {
    _hasMinKExpand = hasMinKExpand;
    [self getBtnWithType:YXRtLineTypeOneMinKline].isExpand = hasMinKExpand;
    
    // 无选中,且无子选项
    if (self.hasMinKExpand && self.rtLineType != YXRtLineTypeOneMinKline && self.subKlineType == YXKLineSubTypeNone) {
        YXKlineTabExpandBtn *btn = [self getBtnWithType:YXRtLineTypeOneMinKline];
        [btn setTitle:[YXLanguageUtility kLangWithKey:@"stock_detail_min_k"] forState:UIControlStateNormal];
    }
}

// 设置之前,一定要先设置子类型
- (void)setRtLineType:(YXRtLineType)rtLineType {
    YXKlineTabExpandBtn *preBtn = [self getBtnWithType:self.rtLineType];
    _rtLineType = rtLineType;
    preBtn.selected = NO;
    
    [self animationLineView];
    if (self.updateTypeCallBack) {
        self.updateTypeCallBack(self);
    }
}

- (void)animationLineView {
    YXKlineTabExpandBtn *currentBtn = [self getBtnWithType:self.rtLineType];
    currentBtn.selected = YES;
        
    if (currentBtn.mj_w == 0) {
        // 强制布局
        [self performSelector:@selector(animationLineView) withObject:nil afterDelay:0.25];
        return;
    }
}

- (void)setSubKlineType:(YXKLineSubType)subKlineType {
    _subKlineType = subKlineType;
    YXKlineTabExpandBtn *btn = [self getBtnWithType:YXRtLineTypeOneMinKline];
    [btn setTitle:[YXStockDetailUtility getSubKlineStringWithType:subKlineType] forState:UIControlStateNormal];
}

- (void)setSubTsType:(YXTimeShareLineType)subTsType {
    _subTsType = subTsType;
    YXKlineTabExpandBtn *btn = [self getBtnWithType:YXRtLineTypeDayTimeLine];
    [btn setTitle:[YXStockDetailUtility getTimeShareStringWithType:subTsType] forState:UIControlStateNormal];
}

- (void)setIsOption:(BOOL)isOption {
    _isOption = isOption;
    if (isOption) {
        self.hasTsExpand = NO;
        self.hasMinKExpand = NO;
        [self updateStackSubViews];
    }
    
}

#pragma mark - lazy load

- (UIStackView *)stackView {
    if (_stackView == nil) {
        _stackView = [[UIStackView alloc] initWithFrame:CGRectMake(0, 0, self.mj_w - 16, 30)];
        _stackView.distribution = UIStackViewDistributionEqualSpacing;
        _stackView.axis = UILayoutConstraintAxisHorizontal;
    }
    return _stackView;
}

- (YXStockLineMenuView *)menuKlineView{
    
    if (!_menuKlineView) {
        
        NSArray *title = [self.minKPopArr qmui_mapWithBlock:^id _Nonnull(NSNumber *item) {
            return [YXStockDetailUtility getSubKlineStringWithType:item.intValue];
        }];
        _menuKlineView = [[YXStockLineMenuView alloc] initWithFrame:CGRectMake(0, 0, 80, title.count * 40) andTitles:title];
        @weakify(self);
        [_menuKlineView setClickCallBack:^(UIButton * _Nonnull sender) {
            @strongify(self);
            [self.popover dismiss];
            if (sender.selected) {
                return;
            }
            self.subKlineType = [self.minKPopArr[sender.tag] intValue];
            self.rtLineType = YXRtLineTypeOneMinKline;
        }];
    }
    return _menuKlineView;
}

- (YXStockLineMenuView *)menuTsView {
    
    if (!_menuTsView) {
        
        NSArray *title = [self.minTsPopArr qmui_mapWithBlock:^id _Nonnull(NSNumber *item) {
            if ([YXUserManager isENMode]) {
                return [YXStockDetailUtility getTimeShareStringWithType:item.intValue];
            } else {
                return [NSString stringWithFormat:@"%@%@", [YXStockDetailUtility getTimeShareStringWithType:item.intValue], [YXLanguageUtility kLangWithKey:@"stock_detail_high_line_one_day"]];
            }
            
        }];
        CGFloat width = YXUserManager.isENMode ? 100 : 80;
        _menuTsView = [[YXStockLineMenuView alloc] initWithFrame:CGRectMake(0, 0, width, title.count * 40) andTitles:title];
        @weakify(self);
        [_menuTsView setClickCallBack:^(UIButton * _Nonnull sender) {
            @strongify(self);
            [self.popover dismiss];
            if (sender.selected) {
                return;
            }
            
            if (![YXUserManager isLogin]) {
                [YXToolUtility handleBusinessWithLogin:^{
                    
                }];
            } else if ([[YXUserManager shared] getLevelWith:kYXMarketUS] == QuoteLevelDelay) {
                // 引导升级
                YXAlertView *alertView = [YXAlertView alertViewWithTitle:[YXLanguageUtility kLangWithKey:@"no_squote_desc"] message:@""];
                YXAlertAction *cancelAction = [YXAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"common_cancel"] style:YXAlertActionStyleCancel handler:^(YXAlertAction * _Nonnull action) {
                    
                }];
                YXAlertAction *updateAction = [YXAlertAction actionWithTitle:[YXLanguageUtility kLangWithKey:@"depth_order_get"] style:YXAlertActionStyleDefault handler:^(YXAlertAction * _Nonnull action) {
//                    [YXWebViewModel push
                    [YXWebViewModel pushToWebVC:[YXH5Urls myQuotesUrl]];                    
                    [alertView hideInWindow];
                }];
                [alertView addAction:cancelAction];
                [alertView addAction:updateAction];
                [alertView showInWindow];
            } else {
                self.subTsType = [self.minTsPopArr[sender.tag] intValue];
                self.rtLineType = YXRtLineTypeDayTimeLine;
            }
        }];
    }
    return _menuTsView;
}

- (YXStockPopover *)popover {
    if (!_popover) {
        _popover = [[YXStockPopover alloc] init];
        _popover.option.offset = 0;
    }
    return _popover;
}


- (nullable YXKlineTabExpandBtn *)getBtnWithType: (YXRtLineType)type {
    
    for (UIView *view in self.stackView.subviews) {
        if ([view isKindOfClass:[YXKlineTabExpandBtn class]]) {
            YXKlineTabExpandBtn *btn = (YXKlineTabExpandBtn *)view;
            if (btn.rtType == type) {
                return btn;
            }
        }
    }
    return nil;
}

@end
