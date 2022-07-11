//
//  OSSVOrdereItemeButtonView.m
// XStarlinkProject
//
//  Created by odd on 2020/12/9.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVOrdereItemeButtonView.h"

@implementation OSSVOrdereItemeButtonView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title tapBlock:(void (^)(void))block {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.button];
        [self.button setTitle:STLToString(title) forState:UIControlStateNormal];
        [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.bottom.mas_equalTo(self);
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-8);
        }];
        
        self.tapBlock = block;
    }
    return self;
}

- (void)actionTouch:(UIButton *)sender {
    if (self.tapBlock) {
        self.tapBlock();
    }
}

- (UIButton *)button {
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.backgroundColor = [UIColor clearColor];
        [_button addTarget:self action:@selector(actionTouch:) forControlEvents:UIControlEventTouchUpInside];
        _button.layer.borderColor = [OSSVThemesColors col_EEEEEE].CGColor;
        [_button setTitleColor:[OSSVThemesColors col_0D0D0D] forState:UIControlStateNormal];
        _button.titleLabel.font = [UIFont systemFontOfSize:12];
        [_button setContentEdgeInsets:UIEdgeInsetsMake(8, 12, 8, 12)];
        _button.layer.borderWidth = 0.5;
    }
    return _button;
}

@end
