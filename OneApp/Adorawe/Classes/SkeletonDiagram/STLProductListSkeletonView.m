//
//  STLProductListSkeletonView.m
// XStarlinkProject
//
//  Created by Kevin on 2021/6/15.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLProductListSkeletonView.h"

@interface STLProductListSkeletonView ()
@end

@implementation STLProductListSkeletonView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        for (int i = 0 ; i < 11; i++) {
            STLProductView *view = [[STLProductView alloc] init];
            view.backgroundColor = [UIColor clearColor];
            [self addSubview:view];
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.mas_leading);
                make.trailing.mas_equalTo(self.mas_trailing);
                make.height.equalTo(286);
                make.top.mas_equalTo(self.mas_top).offset(i*286);
            }];
        }
    }
    return self;
}


@end
//左右产品骨架图

@interface STLProductView ()
@property (nonatomic, strong) UIImageView *leftProductImageView;
@property (nonatomic, strong) UIView      *leftPriceView;
@property (nonatomic, strong) UIView      *leftOldPriceView;


@property (nonatomic, strong) UIImageView *rightProductImageView;
@property (nonatomic, strong) UIView      *rightPriceView;
@property (nonatomic, strong) UIView      *rightOldPriceView;

@end

@implementation STLProductView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.leftProductImageView];
        [self addSubview:self.leftPriceView];
        [self addSubview:self.leftOldPriceView];
        
        [self addSubview:self.rightProductImageView];
        [self addSubview:self.rightPriceView];
        [self addSubview:self.rightOldPriceView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = (SCREEN_WIDTH - 36)/2;
    [self.leftProductImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(12);
        make.top.mas_equalTo(self.mas_top).offset(12);
        make.width.equalTo(width);
        make.height.equalTo(226);
    }];
    
    [self.leftPriceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.leftProductImageView.mas_leading);
        make.top.mas_equalTo(self.leftProductImageView.mas_bottom).offset(8);
        make.trailing.mas_equalTo(self.leftProductImageView.mas_trailing).offset(-60);
        make.height.equalTo(16);
    }];
    
    [self.leftOldPriceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.leftProductImageView.mas_leading);
        make.top.mas_equalTo(self.leftPriceView.mas_bottom).offset(8);
        make.trailing.mas_equalTo(self.leftProductImageView.mas_trailing).offset(-90);
        make.height.equalTo(16);
    }];
    
    [self.rightProductImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
        make.top.mas_equalTo(self.mas_top).offset(12);
        make.width.equalTo(width);
        make.height.equalTo(226);
    }];
    
    [self.rightPriceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.rightProductImageView.mas_leading);
        make.top.mas_equalTo(self.rightProductImageView.mas_bottom).offset(8);
        make.trailing.mas_equalTo(self.rightProductImageView.mas_trailing).offset(-60);
        make.height.equalTo(16);
    }];
    
    [self.rightOldPriceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.rightProductImageView.mas_leading);
        make.top.mas_equalTo(self.rightPriceView.mas_bottom).offset(8);
        make.trailing.mas_equalTo(self.rightProductImageView.mas_trailing).offset(-90);
        make.height.equalTo(16);
    }];
}

- (UIImageView *)leftProductImageView {
    if (!_leftProductImageView) {
        _leftProductImageView = [UIImageView new];
        _leftProductImageView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _leftProductImageView;
}

- (UIView *)leftPriceView {
    if (!_leftPriceView) {
        _leftPriceView = [UIImageView new];
        _leftPriceView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _leftPriceView;
}

- (UIView *)leftOldPriceView {
    if (!_leftOldPriceView) {
        _leftOldPriceView = [UIImageView new];
        _leftOldPriceView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _leftOldPriceView;
}


- (UIImageView *)rightProductImageView {
    if (!_rightProductImageView) {
        _rightProductImageView = [UIImageView new];
        _rightProductImageView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _rightProductImageView;
}

- (UIView *)rightPriceView {
    if (!_rightPriceView) {
        _rightPriceView = [UIImageView new];
        _rightPriceView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _rightPriceView;
}

- (UIView *)rightOldPriceView {
    if (!_rightOldPriceView) {
        _rightOldPriceView = [UIImageView new];
        _rightOldPriceView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _rightOldPriceView;
}

@end
