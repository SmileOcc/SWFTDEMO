//
//  OSSVFreeShippingView.m
// XStarlinkProject
//
//  Created by Kevin on 2021/3/10.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVFreeShippingView.h"

@implementation OSSVFreeShippingView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.contenLabel];
    }
    return self;
}

- (UILabel *)contenLabel {
    if (!_contenLabel) {
        _contenLabel = [UILabel new];
        _contenLabel.font = [UIFont systemFontOfSize:11];
        _contenLabel.textAlignment = NSTextAlignmentCenter;
        _contenLabel.textColor = OSSVThemesColors.col_0D0D0D;

    }
    return _contenLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contenLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.mas_equalTo(self);
    }];
}
@end
