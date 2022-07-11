//
//  YXLiveHeaderView.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/8/6.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXLiveHeaderView.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@implementation YXLiveHeaderView


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
    UIView *vView = [[UIView alloc] init];
    vView.backgroundColor = QMUITheme.themeTintColor;
    
    [self addSubview:self.titleLabel];
    [self addSubview:vView];
    [self addSubview:self.arrowView];
    
    [vView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.width.mas_equalTo(4);
        make.height.mas_equalTo(17);
        make.centerY.equalTo(self);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(12);
        make.centerY.equalTo(self);
    }];
    
    [self.arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-8);
        make.width.height.mas_equalTo(15);
        make.centerY.equalTo(self.titleLabel);
    }];
    
    UIControl *click = [[UIControl alloc] init];
    [click addTarget:self action:@selector(arrowClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:click];
    [click mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)arrowClick:(UIControl *)sender {
    if (self.arrowCallBack) {
        self.arrowCallBack();
    }
}


#pragma mark - 懒加载

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:18 weight:UIFontWeightMedium]];
    }
    return _titleLabel;
}

- (UIImageView *)arrowView {
    if (_arrowView == nil) {
        _arrowView = [[UIImageView alloc] init];
        _arrowView.image = [UIImage imageNamed:@"stock_r_arrow"];
    }
    return _arrowView;
}

@end
