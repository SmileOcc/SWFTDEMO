//
//  YXStockLineMenuView.m
//  uSmartOversea
//
//  Created by chenmingmao on 2019/12/3.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXStockLineMenuView.h"
#import <Masonry.h>

@interface YXStockPopover ()


@end

@implementation YXStockPopover

- (instancetype)init {
    
    ASPopoverOption *option = [[ASPopoverOption alloc] init];
    option.autoAjustDirection = YES;
    option.preferedType = ASPopoverTypeDown;
    option.arrowSize = CGSizeMake(13, 5);
    option.blackOverlayColor = [QMUITheme.textColorLevel1 colorWithAlphaComponent:0];
    option.popoverColor = [QMUITheme popupLayerColor];
    option.dismissOnBlackOverlayTap = YES;
    option.animationIn = 0.2;
    option.animationOut = 0;
    option.springDamping = 1;
    option.cornerRadius = 6;
    option.sideEdge = 16;
    option.offset = 12;
    if (self = [super initWithOption:option]) {
        
    }
    
    return self;
}

@end


@interface YXStockLineMenuView ()

@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) UIScrollView *scrollview;

@property (nonatomic, assign) CGFloat itemHeight;
@end

@implementation YXStockLineMenuView


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame andTitles:(NSArray *)titles {
    if (self = [super initWithFrame:frame]) {
        self.titles = titles;
        if (titles.count > 0 && frame.size.height > 0) {
            self.itemHeight = frame.size.height / titles.count;
        } else {
            self.itemHeight = 48;
        }
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    
    [self addSubview:self.scrollview];
    self.scrollview.frame = self.bounds;
    
    for (int x = 0; x < self.titles.count; x ++) {
        
        UIButton *button = [[UIButton alloc] init];
        [button setTitle:self.titles[x] forState:UIControlStateNormal];
        [button setTitleColor:[QMUITheme textColorLevel1] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button addTarget:self action:@selector(submenuButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = x;
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        button.titleLabel.minimumScaleFactor = 0.3;
        [self.scrollview addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.scrollview.mas_centerX);
            make.height.mas_equalTo(self.itemHeight);
            make.width.equalTo(self.scrollview);
            make.top.mas_equalTo(self.scrollview.mas_top).offset(self.itemHeight * x);
        }];
        [button setTitleColor:[QMUITheme mainThemeColor] forState:UIControlStateSelected];
        if (x < (self.titles.count - 1)) {
            UIView *lineView = [[UIView alloc] init];
            lineView.backgroundColor = [QMUITheme popSeparatorLineColor];
            [self.scrollview addSubview:lineView];
            [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(QMUIHelper.pixelOne);
                make.leading.equalTo(self.scrollview).offset(8);
                make.width.mas_equalTo(self.frame.size.width - 16);
                make.bottom.equalTo(button);
            }];
        }
    }
    
    self.scrollview.contentSize = CGSizeMake(self.frame.size.width, self.titles.count * 40);
}

- (void)setSelectIndex:(NSInteger)selectIndex {
    _selectIndex = selectIndex;
    
    for (UIView *view in self.scrollview.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)view;
            if (btn.tag == selectIndex) {
                btn.selected = YES;
            } else {
                btn.selected = NO;
            }
        }
    }
}

- (void)cleanSelect {
    for (UIView *view in self.scrollview.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)view;
            btn.selected = NO;
        }
    }
}

- (void)submenuButtonEvent:(UIButton *)button {
    
    if (self.clickCallBack) {
        self.clickCallBack(button);
    }
}

- (UIScrollView *)scrollview {
    if (_scrollview == nil) {
        _scrollview = [[UIScrollView alloc] init];
//        _scrollview.backgroundColor = QMUITheme.popupLayerColor;
    }
    return _scrollview;
}

@end
