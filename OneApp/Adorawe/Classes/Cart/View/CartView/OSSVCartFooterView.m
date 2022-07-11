//
//  OSSVCartFooterView.m
// XStarlinkProject
//
//  Created by Kevin on 2021/7/12.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVCartFooterView.h"

@interface OSSVCartFooterView ()
@property (nonatomic, strong) UIView *grayView;
@property (nonatomic, strong) UIView *whiteView;

@end

@implementation OSSVCartFooterView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.whiteView];
        [self addSubview:self.grayView];
     }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.whiteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self);
        make.height.equalTo(8);
    }];
    
    [self.grayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.top.mas_equalTo(self.whiteView.mas_bottom);
        make.height.equalTo(8);
    }];

}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self.whiteView stlAddCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(8, 8)];
}

- (UIView *)whiteView {
    
    if (!_whiteView) {
        _whiteView = [UIView new];
        _whiteView.backgroundColor = [UIColor whiteColor];
    }
    return _whiteView;
}

- (UIView *)grayView {
    if (!_grayView) {
        _grayView = [UIView new];
        _grayView.backgroundColor = OSSVThemesColors.col_F7F7F7;;
    }
    return _grayView;
}
@end
