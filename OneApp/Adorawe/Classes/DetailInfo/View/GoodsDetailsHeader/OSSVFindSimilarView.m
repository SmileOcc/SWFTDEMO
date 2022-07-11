//
//  OSSVFindSimilarView.m
// XStarlinkProject
//
//  Created by odd on 2021/1/19.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVFindSimilarView.h"

@implementation OSSVFindSimilarView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [OSSVThemesColors col_0D0D0D:0.4];
        [self addSubview:self.tipLabel];
        [self addSubview:self.similarButton];
        
        [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY);
            make.leading.mas_equalTo(self.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
        }];
        
        [self.similarButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.top.mas_equalTo(self.tipLabel.mas_bottom).offset(24);
            make.height.mas_equalTo(44);
        }];
    }
    return self;
}

- (void)actionSimilar:(UIButton *)sender {
    if (self.similarBlock) {
        self.similarBlock();
    }
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipLabel.textColor = [OSSVThemesColors stlWhiteColor];
        _tipLabel.font = [UIFont boldSystemFontOfSize:15];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.numberOfLines = 0;
    }
    return _tipLabel;
}

- (UIButton *)similarButton {
    if (!_similarButton) {
        _similarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_similarButton setTitle:[STLLocalizedString_(@"Goods_Find_Similar", nil) uppercaseString]  forState:UIControlStateNormal];
        _similarButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [_similarButton setTitleColor:[OSSVThemesColors col_0D0D0D] forState:UIControlStateNormal];
        _similarButton.contentEdgeInsets = UIEdgeInsetsMake(5, 12, 5, 12);
        [_similarButton addTarget:self action:@selector(actionSimilar:) forControlEvents:UIControlEventTouchUpInside];
        _similarButton.backgroundColor = [OSSVThemesColors col_ffffff:0.8];
        _similarButton.layer.cornerRadius = 2;
        _similarButton.layer.masksToBounds = YES;
    }
    return _similarButton;
}

@end
