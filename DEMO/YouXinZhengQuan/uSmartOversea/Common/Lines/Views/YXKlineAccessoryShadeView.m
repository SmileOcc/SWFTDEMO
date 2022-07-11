//
//  YXKlineAccessoryShadeView.m
//  uSmartOversea
//
//  Created by chenmingmao on 2021/3/3.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXKlineAccessoryShadeView.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXKlineAccessoryShadeView ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIImageView *infoImageView;

//@property (nonatomic, strong) UIControl *clickControl;

@end

@implementation YXKlineAccessoryShadeView


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

- (instancetype)initWithFrame:(CGRect)frame andStatus:(YXKlineAccessoryShadeType)status {
    if (self = [super initWithFrame:frame]) {
        self.status = status;
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    
    
    self.titleLabel = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"trend_support_day_line"] textColor:QMUITheme.textColorLevel2 textFont:[UIFont systemFontOfSize:14] textAlignment:NSTextAlignmentLeft];
    self.titleLabel.numberOfLines = 2;
    self.infoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"stock_info"]];
//    self.clickControl = [[UIControl alloc] init];
//    [self.clickControl addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    
    self.backgroundColor = [QMUITheme.foregroundColor colorWithAlphaComponent:0.8];
    
//    [self addSubview:self.clickControl];
    [self addSubview:self.titleLabel];
    [self addSubview:self.infoImageView];
    
//    [self.clickControl mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self);
//    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.centerX.equalTo(self).offset(20);
        make.width.mas_lessThanOrEqualTo(280);
    }];
    
    [self.infoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleLabel);
        make.right.equalTo(self.titleLabel.mas_left).offset(-3);
        make.width.height.mas_equalTo(15);
    }];
}

- (void)setStatus:(YXKlineAccessoryShadeType)status {
    _status = status;
    if (status == YXKlineAccessoryShadeTypeUnsupport) {
        self.titleLabel.text = [YXLanguageUtility kLangWithKey:@"trend_support_day_line"];
    } else if (status == YXKlineAccessoryShadeTypeLogin) {
        self.titleLabel.text = [YXLanguageUtility kLangWithKey:@"trend_signal_go_login"];
    } else if (status == YXKlineAccessoryShadeTypeUpdate) {
        self.titleLabel.text = [YXLanguageUtility kLangWithKey:@"trend_signal_unlock"];
    }
}

//- (void)click:(UIControl *)sender {
//
//    if (self.clickCallBack) {
//        self.clickCallBack(self.status);
//    }
//
//}

@end
