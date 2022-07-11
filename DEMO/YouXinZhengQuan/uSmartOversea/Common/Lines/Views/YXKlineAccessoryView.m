//
//  YXKlineAccessoryView.m
//  uSmartOversea
//
//  Created by 姜轶群 on 2018/10/12.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "YXKlineAccessoryView.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>
#import <NSString+YYAdd.h>

#define kForbiddenMultipleChoice   1

@interface YXKlineAccessoryView()

@property (nonatomic, weak) UIButton *adjustButton; //复权按钮
@property (nonatomic, weak) UIButton *mainAccessoryButton; //主指标
@property (nonatomic, weak) UIButton *cyqButton; //筹码分布
@property (nonatomic, copy) NSString *market;
@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) UIView *preview;
@property (nonatomic, assign) CGFloat totalHeight;

@property (nonatomic, strong) NSMutableArray *subViewsArray;

@property (nonatomic, assign) CGFloat buttonHeight;
@property (nonatomic, assign) CGFloat buttonWidth;
@property (nonatomic, assign) CGFloat mainScrollViewWidth;

@property (nonatomic, assign) BOOL isLand;

@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (nonatomic, strong) UIScrollView *subScrollView;
@property (nonatomic, strong) UIView *chipView;

@property (nonatomic, assign) NSInteger baseTag;

@property (nonatomic, strong) NSMutableArray *mainArr;
@property (nonatomic, strong) NSMutableArray *subArr;

@property (nonatomic, assign) BOOL isShowUsmart;

@end

@implementation YXKlineAccessoryView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
    
}

- (instancetype)initWithFrame:(CGRect)frame isLand:(BOOL)isLand {
    self = [super initWithFrame:frame];
    if (self) {
        self.isLand = isLand;
        [self initUI];
    }
    return self;
}


- (void)initUI {
    self.isShowUsmart = YES;
    if (self.isLand) {
        self.buttonHeight = 26;
        self.buttonWidth = 64;
//        self.layer.borderColor = [QMUITheme lineColor].CGColor;
//        self.layer.borderWidth = 1.0;

        self.baseTag = 1000;
    } else {
        self.buttonHeight = 20;
        self.buttonWidth = 48;
        self.baseTag = 2000;
    }
    self.mainScrollViewWidth = 124;
    
    [self setUpUI];
}

- (void)setUpUI {
    
    self.mainArr = [NSMutableArray arrayWithArray:[YXKLineConfigManager shareInstance].mainArr];
    self.subArr = [NSMutableArray arrayWithArray:[YXKLineConfigManager shareInstance].subArr];

    if (self.isLand) {

        UIView *leftLineView = [UIView new];
        leftLineView.backgroundColor = QMUITheme.separatorLineColor;
        [self addSubview:leftLineView];
        [leftLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.equalTo(self);
            make.width.mas_equalTo(0.5);
        }];

        if (self.subScrollView.superview == nil) {
            [self addSubview:self.subScrollView];
            [self.subScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.top.right.bottom.mas_equalTo(self);
            }];
        }

        //设置复权类型
        NSArray *adjustArray = @[@(YXKlineAdjustTypeNotAdjust), @(YXKlineAdjustTypePreAdjust), @(YXKlineAdjustTypeAfterAdjust)];
        [self layoutVerticalGroupView:adjustArray showLine:YES];

        //设置筹码分布
        NSArray *cyqArr = @[@(YXKlineCYQTypeNormal)];
        [self layoutVerticalGroupView:cyqArr showLine:YES];

        //设置主图指标
        [self layoutVerticalGroupView:self.mainArr showLine:YES];

        //设置副图指标
        [self layoutVerticalGroupView:self.subArr showLine:NO];


    } else {

        UIView *topLineView = [UIView new];
        topLineView.backgroundColor = QMUITheme.separatorLineColor;
        [self addSubview:topLineView];
        [topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.height.mas_equalTo(0.5);
        }];

        UIView *bottomLineView = [UIView new];
        bottomLineView.backgroundColor = QMUITheme.separatorLineColor;
        [self addSubview:bottomLineView];
        [bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(self);
            make.height.mas_equalTo(0.5);
        }];

        //设置主图指标
        if (self.mainScrollView.superview == nil) {
            [self addSubview:self.mainScrollView];
            [self.mainScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(self);
                make.left.equalTo(self);
                make.width.mas_equalTo(self.mainScrollViewWidth);
            }];
        }

        [self layoutHorizontalGroupView:self.mainArr showLine:YES superView:self.mainScrollView];

        //设置副图指标
        if (self.subScrollView.superview == nil) {
            [self addSubview:self.subScrollView];
            [self.subScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(self);
                make.left.equalTo(self.mainScrollView.mas_right).offset(10);
                make.right.equalTo(self);
            }];
        }

        [self layoutHorizontalGroupView:self.subArr showLine:NO superView:self.subScrollView];

        @weakify(self)
        self.subScrollView.qmui_frameDidChangeBlock = ^(__kindof UIView * _Nonnull view, CGRect precedingFrame) {
            @strongify(self)
            if (YXKLineConfigManager.shareInstance.subAccessoryArray.count > 0) {
                [self scrollToVisibleSubType:YXKLineConfigManager.shareInstance.subAccessoryArray.firstObject.intValue];
            }
        };
    }

    if (self.quoteModel) {
        [self resetUsmartAccess];
    }
}



//上下布局
- (void)layoutVerticalGroupView:(NSArray *)groupArray showLine:(BOOL)showLine {
    YXStockMainAcessoryStatus mainAccessory = [YXKLineConfigManager shareInstance].mainAccessory;
    NSArray *subAccessoryArr = [YXKLineConfigManager shareInstance].subAccessoryArray;
    UIView *superView = self.subScrollView;
    for (int i = 0; i < groupArray.count; i ++) {
        NSNumber *index = groupArray[i];
        YXExpandAreaButton *accessoryButton = [superView viewWithTag:index.integerValue + self.baseTag];
        if (accessoryButton == nil) {
            accessoryButton = [self indexButton:index.integerValue];
            [superView addSubview:accessoryButton];
            [accessoryButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(superView.mas_left);
                make.width.mas_equalTo(self.buttonWidth);
                if (index.integerValue == YXKlineCYQTypeNormal) {
                    make.height.mas_equalTo(0);
                } else {
                    make.height.mas_equalTo(self.buttonHeight);
                }
                if (_preview == nil) {
                    make.top.mas_equalTo(superView.mas_top).offset(5);
                } else if (i == 0) {
                    make.top.mas_equalTo(_preview.mas_bottom);
                } else {
                    make.top.mas_equalTo(_preview.mas_bottom);
                }
                //最后一组设置底部和scrollView的约束，来确认scrollview的contentSize
                if (!showLine && i == groupArray.count - 1) {
                    make.bottom.equalTo(superView.mas_bottom);
                }
            }];
        } else {
            accessoryButton.hidden = NO;
            [accessoryButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(superView.mas_left);
                make.width.mas_equalTo(self.buttonWidth);
                if (index.integerValue == YXKlineCYQTypeNormal) {
                    make.height.mas_equalTo(0);
                } else {
                    make.height.mas_equalTo(self.buttonHeight);
                }
                if (_preview == nil) {
                    make.top.mas_equalTo(superView.mas_top).offset(5);
                } else if (i == 0) {
                    make.top.mas_equalTo(_preview.mas_bottom);
                } else {
                    make.top.mas_equalTo(_preview.mas_bottom);
                }
                //最后一组设置底部和scrollView的约束，来确认scrollview的contentSize
                if (!showLine && i == groupArray.count - 1) {
                    make.bottom.equalTo(superView.mas_bottom);
                }
            }];
        }


        if ([YXKLineConfigManager shareInstance].adjustType == index.integerValue) {
            self.adjustButton = accessoryButton;
            self.adjustButton.selected = YES;
        }

        if (index.integerValue == YXKlineCYQTypeNormal) {
            accessoryButton.hidden = YES;
            accessoryButton.selected = [YXCYQUtility isShowCYQ];
        }

        if (index.integerValue == mainAccessory) {
            self.mainAccessoryButton = accessoryButton;
            accessoryButton.selected = YES;
        }

        if ([subAccessoryArr containsObject:index]) {
            accessoryButton.selected = YES;
        }

        _preview = accessoryButton;

        if (showLine && i == groupArray.count - 1) {
            UIView *lineView = [superView viewWithTag:accessoryButton.tag + 1];
            if (lineView == nil) {
                lineView = [self groupLineView];
                lineView.tag = accessoryButton.tag + 1;
                [superView addSubview:lineView];
                if (index.integerValue == YXKlineCYQTypeNormal) {
                    lineView.hidden = YES;
                }
                [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(superView.mas_centerX);
                    make.height.mas_equalTo(2);
                    make.width.mas_equalTo(20);
                    make.top.mas_equalTo(_preview.mas_bottom).offset(5);
                }];
            } else {
                if (index.integerValue == YXKlineCYQTypeNormal) {
                    lineView.hidden = !self.showCYQ;
                }
                [lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(superView.mas_centerX);
                    make.height.mas_equalTo(2);
                    make.width.mas_equalTo(20);
                    make.top.mas_equalTo(_preview.mas_bottom).offset(5);
                }];
            }

            _preview = lineView;
        }
    }
}

//左右布局
- (void)layoutHorizontalGroupView:(NSArray *)groupArray showLine:(BOOL)showLine superView:(UIView *)superview {
    YXStockMainAcessoryStatus mainAccessory = [YXKLineConfigManager shareInstance].mainAccessory;
    NSArray *subAccessoryArr = [YXKLineConfigManager shareInstance].subAccessoryArray;
    _preview = nil;
    
    for (UIView *view in superview.subviews) {
        if ([view isKindOfClass:[QMUIButton class]]) {
            view.hidden = YES;
        }
    }
    for (int i = 0; i < groupArray.count; i ++) {
        NSNumber *index = groupArray[i];
        YXExpandAreaButton *accessoryButton = [superview viewWithTag:index.integerValue + self.baseTag];
        if (accessoryButton == nil) {
            accessoryButton = [self indexButton:index.integerValue];
            [accessoryButton setContentEdgeInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
            [superview addSubview:accessoryButton];
            [accessoryButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(superview.mas_top);
                make.height.mas_equalTo(self.buttonHeight);
                if (_preview == nil) {
                    make.left.mas_equalTo(superview);
                } else {
                    make.left.mas_equalTo(_preview.mas_right);
                }
                //最后一组设置右边和scrollView的约束，来确认scrollview的contentSize
                if (i == groupArray.count - 1 && i != 0) {
                    make.right.equalTo(superview.mas_right).offset(-4);
                }
            }];
        } else {
            accessoryButton.hidden = NO;
            [accessoryButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(superview.mas_top);
                make.height.mas_equalTo(self.buttonHeight);
                if (_preview == nil) {
                    make.left.mas_equalTo(superview);
                } else {
                    make.left.mas_equalTo(_preview.mas_right);
                }
                //最后一组设置右边和scrollView的约束，来确认scrollview的contentSize
                if (i == groupArray.count - 1 && i != 0) {
                    make.right.equalTo(superview.mas_right).offset(-4);
                }
            }];
        }

        if (index.integerValue == mainAccessory) {
            self.mainAccessoryButton = accessoryButton;
            self.mainAccessoryButton.selected = YES;
        } else {
            accessoryButton.selected = NO;
        }

        if ([subAccessoryArr containsObject:index]) {
            accessoryButton.selected = YES;
        }
        _preview = accessoryButton;

        if (showLine && i == groupArray.count - 1) {
            UIView *lineView = [superview viewWithTag:accessoryButton.tag + 1];
            if (lineView == nil) {
                lineView = [self groupLineView];
                lineView.tag = accessoryButton.tag + 1;
                [self addSubview:lineView];
                [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.mas_equalTo(self.mas_centerY);
                    make.width.mas_equalTo(1);
                    make.height.mas_equalTo(8);
                    make.left.mas_equalTo(superview.mas_right);
                }];
            } else {
                [lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.mas_equalTo(self.mas_centerY);
                    make.width.mas_equalTo(1);
                    make.height.mas_equalTo(8);
                    make.left.mas_equalTo(superview.mas_right);
                }];
            }
        }
    }

}


- (UIView *)groupLineView {
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [QMUITheme separatorLineColor];
    return lineView;
}

- (YXExpandAreaButton *)indexButton:(NSInteger)index {
    YXExpandAreaButton *accessoryButton = [[YXExpandAreaButton alloc] init];
    accessoryButton.expandX = 5;
    accessoryButton.expandY = 5;
    if (index == YXKlineCYQTypeNormal) {
        if (self.isLand) {
            [accessoryButton setImage:[UIImage imageNamed:@"chip_normal"] forState:UIControlStateNormal];
            [accessoryButton setImage:[UIImage imageNamed:@"chip_selected"] forState:UIControlStateSelected];
        } else {
            accessoryButton.titleLabel.font = [UIFont systemFontOfSize:10];
            [accessoryButton setTitle:[YXKLineConfigManager getTitleWithType:index] forState:UIControlStateNormal];
            [accessoryButton setTitleColor:[QMUITheme textColorLevel2] forState:UIControlStateNormal];
            [accessoryButton setTitleColor:[QMUITheme textColorLevel2] forState:UIControlStateSelected];
            accessoryButton.titleLabel.textAlignment = NSTextAlignmentCenter;
            accessoryButton.imagePosition = QMUIButtonImagePositionRight;
            accessoryButton.spacingBetweenImageAndTitle = 4.0;
            [accessoryButton setImage:[UIImage imageNamed:@"chip_portrait"] forState:(UIControlStateNormal)];
        }

    } else {
        accessoryButton.titleLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightMedium];
        [accessoryButton setTitle:[YXKLineConfigManager getTitleWithType:index] forState:UIControlStateNormal];
        [accessoryButton setTitleColor:[QMUITheme textColorLevel3] forState:UIControlStateNormal];
        [accessoryButton setTitleColor:[QMUITheme themeTextColor] forState:UIControlStateSelected];
        accessoryButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        accessoryButton.titleLabel.adjustsFontSizeToFitWidth = true;
    }
    [accessoryButton addTarget:self action:@selector(accessoryButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    accessoryButton.tag = index + self.baseTag;
    return accessoryButton;
}

//指标点击事件
- (void)accessoryButtonEvent:(UIButton *)button{
    NSString *propViewId = @"";
    NSString *propViewName = @"";

    NSInteger buttonTag = button.tag - self.baseTag;
    if (buttonTag == YXKlineAdjustTypeNotAdjust || buttonTag == YXKlineAdjustTypePreAdjust || buttonTag == YXKlineAdjustTypeAfterAdjust) { //复权
        if (self.adjustButton == button) {
            return;
        }
        self.adjustButton.selected = false;
        self.adjustButton = button;
        button.selected = YES;
        if (self.adjustTypeCallBack) {
            self.adjustTypeCallBack(buttonTag);
        }
        
        if (buttonTag == 0) {
            propViewId = @"adjusted_none";
            propViewName = @"不复权";
        } else if (buttonTag == 1) {
            propViewId = @"adjusted_forward";
            propViewName = @"前复权";
        } else {
            propViewId = @"adjusted_backward";
            propViewName = @"后复权";
        }
    } else if (buttonTag == YXStockMainAcessoryStatusMA || buttonTag == YXStockMainAcessoryStatusEMA || buttonTag == YXStockMainAcessoryStatusBOLL || buttonTag == YXStockMainAcessoryStatusSAR || buttonTag == YXStockMainAcessoryStatusUsmart) {  //主指标

        if (self.mainAccessoryButton == button) {
            self.mainAccessoryButton.selected = !self.mainAccessoryButton.selected;
            if (self.mainAccessoryButton.isSelected) {
                if (self.mainParameterCallBack) {
                    self.mainParameterCallBack(buttonTag);
                }
            } else {
                if (self.mainParameterCallBack) {
                    self.mainParameterCallBack(YXStockMainAcessoryStatusNone);
                }
            }
        } else {
            self.mainAccessoryButton.selected = NO;
            self.mainAccessoryButton = button;
            button.selected = YES;
            if (self.mainParameterCallBack) {
                self.mainParameterCallBack(buttonTag);
            }
        }
        propViewName = [YXKLineConfigManager getTitleWithType:buttonTag];
        propViewId = [propViewName lowercaseString];
    } else if (buttonTag == YXKlineCYQTypeNormal) {
        button.selected = !button.selected;
        if (self.chipsCYQCallBack) {
            self.chipsCYQCallBack(button.selected);
        }
        propViewName = @"筹码分布";
        propViewId = @"CYQ";;

    } else {

        BOOL isSelected = button.selected;

        if (isSelected) {
            [[YXKLineConfigManager shareInstance].subAccessoryArray removeObject:@(buttonTag)];
        } else {
            //屏蔽括号里的代码可以实现多选
            if (kForbiddenMultipleChoice) {
                [self resetSubStatusToUnSelected];
                [[YXKLineConfigManager shareInstance].subAccessoryArray removeAllObjects];
            }

            if (![[YXKLineConfigManager shareInstance].subAccessoryArray containsObject:@(buttonTag)]) {
                [[YXKLineConfigManager shareInstance].subAccessoryArray addObject:@(buttonTag)];
            }
        }
        button.selected = !isSelected;
        [[YXKLineConfigManager shareInstance] saveSelectArr];
        if (self.subParameterCallBack) {
            self.subParameterCallBack(buttonTag);
        }

        if (button.isSelected) {
            [self scrollToVisibleSubType:buttonTag];
        }
        propViewName = [YXKLineConfigManager getTitleWithType:buttonTag];
        propViewId = [propViewName lowercaseString];
    }


}

//重置主副指标
- (void)resetMainAndSubStatus {

    if ((self.mainAccessoryButton.tag - self.baseTag) != YXKLineConfigManager.shareInstance.mainAccessory) {
        [self selectMainStatus:YXKLineConfigManager.shareInstance.mainAccessory];
    }

    [self resetSubStatus];
}


//设置幅图指标状态
- (void)selectMainStatus:(YXStockMainAcessoryStatus)mainStatus {
    UIView *view = [self.mainScrollView viewWithTag:mainStatus + self.baseTag];
    if (self.isLand) {
        view = [self.subScrollView viewWithTag:mainStatus + self.baseTag];
    }
    if ([view isKindOfClass:[UIButton class]]) {
        UIButton *selecBtn = (UIButton *)view;
        if (self.mainAccessoryButton == selecBtn) {
            self.mainAccessoryButton.selected = !self.mainAccessoryButton.selected;
            return;
        }
        self.mainAccessoryButton.selected = NO;
        selecBtn.selected = YES;
        self.mainAccessoryButton = selecBtn;

    } else {
        self.mainAccessoryButton.selected = NO;
    }
}

//设置幅图指标状态
- (void)resetSubStatus {

    NSArray *subAccessoryArr = YXKLineConfigManager.shareInstance.subAccessoryArray;
    NSInteger index = 0;
    for (NSNumber *subNumber in YXKLineConfigManager.shareInstance.subArr) {
        UIView *view = [self.subScrollView viewWithTag:subNumber.intValue + self.baseTag];
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            if ([subAccessoryArr containsObject:subNumber]) {
                button.selected = YES;
                if (index == 0) {
                    [self scrollToVisibleSubType:subNumber.intValue];
                }
                index ++;
            } else {
                button.selected = NO;
            }
        }
    }

}

- (void)resetSubStatusToUnSelected {
    for (NSNumber *subNumber in YXKLineConfigManager.shareInstance.subArr) {
        UIView *view = [self.subScrollView viewWithTag:subNumber.intValue + self.baseTag];
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            button.selected = NO;
        }
    }
}

- (void)scrollToVisibleSubType:(YXStockSubAccessoryStatus)subStatus {
    if (!self.isLand) {
        UIView *view = [self.subScrollView viewWithTag:subStatus + self.baseTag];
        if ([view isKindOfClass:[UIButton class]]) {

            NSArray *subIndexArr = [YXKLineConfigManager shareInstance].subArr;
            CGFloat offset = self.subScrollView.contentSize.width / subIndexArr.count;
            //NSInteger index = [subIndexArr indexOfObject:@(subStatus)];
            CGFloat viewX = view.frame.origin.x;
            CGFloat centerX = self.subScrollView.frame.size.width / 2.0;
            CGFloat positon = viewX - self.subScrollView.contentOffset.x;
            if (positon > centerX + offset/2.0) {
                //往右移动
                CGFloat maxOffset = self.subScrollView.contentSize.width - self.subScrollView.frame.size.width;
                if (self.subScrollView.contentOffset.x < maxOffset) {
                    CGFloat rightOffset = self.subScrollView.contentOffset.x + 1.5 * offset;
                    if (viewX - self.subScrollView.contentOffset.x > 2 * centerX) {
                        rightOffset = viewX + 1.5 * offset;
                    }
                    if (rightOffset > maxOffset) {
                        rightOffset = maxOffset;
                    }
                    [self.subScrollView setContentOffset:CGPointMake(rightOffset, self.subScrollView.contentOffset.y)];
                }
            } else if (positon < centerX - offset/2.0) {
                //往左移动
                if (self.subScrollView.contentOffset.x > 0) {
                    CGFloat leftOffset = self.subScrollView.contentOffset.x - 1.5 * offset;
                    if (leftOffset < 0 || viewX == 0) {
                        leftOffset = 0;
                    }
                    [self.subScrollView setContentOffset:CGPointMake(leftOffset, self.subScrollView.contentOffset.y)];
                }
            }
        }
    }
}

#pragma mark - Setter Method
- (void)setQuoteModel:(YXV2Quote *)quoteModel {
    _quoteModel = quoteModel;
    self.market = quoteModel.market;
    self.symbol = quoteModel.symbol;
    self.name = quoteModel.name;
    
    [self resetUsmartAccess];
}

- (void)resetUsmartAccess {
    self.isShowUsmart = YES;
    // 股票确认的时候, 根据类型,选择指标(不是正股和高级adr,选择了趋势长盈,要重置为MA)
    // 非港美股要重置
    self.mainArr = [NSMutableArray arrayWithArray:[YXKLineConfigManager shareInstance].mainArr];
    if ([self.market isEqualToString:kYXMarketChinaSH] || [self.market isEqualToString:kYXMarketChinaSZ]) {
        self.isShowUsmart = NO;
    }
    if (!(self.quoteModel.type1.value == OBJECT_SECUSecuType1_StStock && self.quoteModel.type2.value != OBJECT_SECUSecuType2_StLowAdr)) {
        self.isShowUsmart = NO;
    }
    if (!self.isShowUsmart) {
        NSNumber *usmartNumber = nil;
        for (NSNumber *obj in self.mainArr) {
            if (obj.integerValue == YXStockMainAcessoryStatusUsmart) {
                usmartNumber = obj;
                break;
            }
        }
        if (usmartNumber) {
            [self.mainArr removeObject:usmartNumber];
            if (self.isLand) {
                //设置主图指标
                QMUIButton *accessoryButton = [self.subScrollView viewWithTag:YXStockMainAcessoryStatusUsmart + self.baseTag];
                if (accessoryButton) {
                    [accessoryButton mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.height.mas_equalTo(0);
                    }];
                    accessoryButton.hidden = YES;
                }
            } else {
                [self layoutHorizontalGroupView:self.mainArr showLine:YES superView:self.mainScrollView];
            }
            
            if ((self.mainAccessoryButton.tag - self.baseTag) != YXKLineConfigManager.shareInstance.mainAccessory) {
                [self selectMainStatus:YXKLineConfigManager.shareInstance.mainAccessory];
            }
        }
    } else {
        if (self.isLand) {
            //设置主图指标
            QMUIButton *accessoryButton = [self.subScrollView viewWithTag:YXStockMainAcessoryStatusUsmart + self.baseTag];
            if (accessoryButton) {
                [accessoryButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(self.buttonHeight);
                }];
                accessoryButton.hidden = NO;
            }
        } else {
            [self layoutHorizontalGroupView:self.mainArr showLine:YES superView:self.mainScrollView];
        }
        if ((self.mainAccessoryButton.tag - self.baseTag) != YXKLineConfigManager.shareInstance.mainAccessory) {
            [self selectMainStatus:YXKLineConfigManager.shareInstance.mainAccessory];
        }
    }
}


- (void)setShowCYQ:(BOOL)showCYQ {
    if (_showCYQ == showCYQ) {
        return;
    }
    _showCYQ = showCYQ;
    if (self.isLand) {
        YXExpandAreaButton *button = [self viewWithTag:YXKlineCYQTypeNormal + self.baseTag];
        UIView *lineView = [self viewWithTag:YXKlineCYQTypeNormal + 1 + self.baseTag];
        button.hidden = !showCYQ;
        lineView.hidden = !showCYQ;
        [button mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(showCYQ ? self.buttonHeight : 0);
        }];
    }


}

#pragma mark - lazy load
- (UIScrollView *)subScrollView{
    
    if (!_subScrollView) {
        _subScrollView = [[UIScrollView alloc] init];
        _subScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _subScrollView;
}

- (UIScrollView *)mainScrollView{

    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] init];
        _mainScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _mainScrollView;
}

@end
