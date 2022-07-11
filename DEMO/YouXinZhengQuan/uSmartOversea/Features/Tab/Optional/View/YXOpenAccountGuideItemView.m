//
//  YXBmpUpdateView.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/3/13.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXOpenAccountGuideItemView.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXOpenAccountGuideItemView ()

@property (nonatomic, copy) updateBlock callBack;

@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, strong) UIView *bgView;
@end

@implementation YXOpenAccountGuideItemView


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame andClickCallBack:(nonnull updateBlock)callback {
    if (self = [super initWithFrame:frame]) {
        self.callBack = callback;
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    self.backgroundColor = QMUITheme.backgroundColor;
    self.clipsToBounds = YES;
    
    _bgView = [[UIView alloc] init];
    _bgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_bgView];
    
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 6, 0));
    }];
    
    _label = [[QMUIMarqueeLabel alloc] init];
    _label.text = [YXLanguageUtility kLangWithKey:@"tip_quote_permission_us_unopen"];
    _label.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    _label.textColor = QMUITheme.textColorLevel2;
    _label.shouldFadeAtEdge = NO;
    
    _btn = [UIButton buttonWithType:UIButtonTypeCustom title:[YXLanguageUtility kLangWithKey:@"btn_quote_permission_unopen"] font:[UIFont systemFontOfSize:12 weight:UIFontWeightMedium] titleColor:QMUITheme.themeTextColor target:self action:@selector(clickBtn:)];
    _btn.clipsToBounds = YES;
    
    [_bgView addSubview:_btn];
    [_bgView addSubview:_label];
    
    [_btn sizeToFit];
    [_btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_bgView).offset(-12);
        make.centerY.equalTo(_bgView);
        make.size.mas_equalTo(_btn.bounds.size);
    }];
    
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_bgView).offset(18);
        make.centerY.equalTo(_bgView);
        make.right.equalTo(_btn.mas_left).offset(-12);
    }];
    

    
    UIControl *control = [[UIControl alloc] init];
    [control addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:control];
    [control mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)clickBtn:(UIButton *)sender {
    if (self.callBack) {
        self.callBack();
    }
}

@end
