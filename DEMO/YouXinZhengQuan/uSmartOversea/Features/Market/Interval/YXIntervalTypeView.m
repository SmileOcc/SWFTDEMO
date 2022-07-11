//
//  YXIntervalTypeView.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/29.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXIntervalTypeView.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>
#import <YYCategories/YYCategories.h>

@interface YXIntervalTypeView ()

@property (nonatomic, strong) NSArray *buttonArrTitle;

@end

@implementation YXIntervalTypeView


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
    
    self.buttonArrTitle = @[[YXLanguageUtility kLangWithKey:@"interval_5_min"], [YXLanguageUtility kLangWithKey:@"interval_5_day"], [YXLanguageUtility kLangWithKey:@"interval_10_day"], [YXLanguageUtility kLangWithKey:@"interval_30_day"], [YXLanguageUtility kLangWithKey:@"interval_60_day"], [YXLanguageUtility kLangWithKey:@"interval_120_day"], [YXLanguageUtility kLangWithKey:@"interval_250_day"], [YXLanguageUtility kLangWithKey:@"interval_52_week"]];
    
    int column = 4;
    CGFloat left = 12;
    CGFloat top = 14;
    CGFloat margin = 20;
    CGFloat width = (YXConstant.screenWidth - 12 * 2 - (column - 1) * margin) / column;
    CGFloat height = 28;
    for (int i = 0; i < self.buttonArrTitle.count; i++) {
        UIButton *btn = [[UIButton alloc] init];
        [btn setTitle:self.buttonArrTitle[i] forState:UIControlStateNormal];
        [btn setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
        [btn setTitleColor:QMUITheme.themeTextColor forState:UIControlStateNormal];
        
        [btn setBackgroundImage:[UIImage imageWithColor:QMUITheme.themeTextColor] forState:UIControlStateSelected];
        [btn setBackgroundImage:[UIImage imageWithColor:[QMUITheme.themeTextColor colorWithAlphaComponent:0.1]] forState:UIControlStateNormal];
        btn.layer.cornerRadius = 14;
        btn.clipsToBounds = YES;
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        btn.frame = CGRectMake(left + (width + margin) * (i % column), top + (i / column) * (height + top), width, height);
        btn.tag = i;
        [btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        if (i == 0) {
            btn.selected = YES;
            self.selectBtn = btn;
        }
        
    }
}

- (void)click:(UIButton *)sender {
    if (sender.selected) {
        return;
    }
    
    sender.selected = YES;
    self.selectBtn.selected = NO;
    self.selectBtn = sender;
    
    if (self.clickCallBack) {
        self.clickCallBack(self.selectBtn);
    }
    
}

- (void)setDefalutSelect:(NSInteger)defalutSelect {
    _defalutSelect = defalutSelect;
    if (self.selectBtn.tag == defalutSelect) {
        return;
    }
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)view;
            if (btn.tag == defalutSelect) {
                self.selectBtn.selected = NO;
                btn.selected = YES;
                self.selectBtn = btn;
            }
        }
    }
}

@end
