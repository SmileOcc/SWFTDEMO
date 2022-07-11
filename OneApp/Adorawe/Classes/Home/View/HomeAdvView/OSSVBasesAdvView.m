//
//  BaseAdvView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/3.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVBasesAdvView.h"

@implementation OSSVBasesAdvView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [OSSVThemesColors col_000000:0.7];
    }
    return self;
}


- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _bgView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(advertImgViewDoAction)];
        [_contentView addGestureRecognizer:tap];
    }
    return _contentView;
}

- (UIButton *)cloaseButton {
    if (!_cloaseButton) {
        _cloaseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cloaseButton setImage:[UIImage imageNamed:@"advClose"] forState:UIControlStateNormal];
        [_cloaseButton addTarget:self action:@selector(actionClose:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cloaseButton;
}

#pragma mark - Action

- (void)actionClose:(UIButton *)button {
    if (self.superview) {
        [self removeFromSuperview];
    }
    self.hidden = YES;
    
    if (self.advDoActionBlock) {
        self.advDoActionBlock(nil,YES);
    }
}

- (void)advertImgViewDoAction {

    if (self.superview) {
        [self removeFromSuperview];
    }
    self.hidden = YES;
    
    if (self.advDoActionBlock) {
        self.advDoActionBlock(_advEventModel,NO);
    }
}

@end
