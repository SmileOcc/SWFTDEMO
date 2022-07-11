//
//  OSSVFeedbacRepladyHeadView.m
// XStarlinkProject
//
//  Created by odd on 2021/4/20.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVFeedbacRepladyHeadView.h"

@implementation OSSVFeedbacRepladyHeadView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.timeLabel];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
    return self;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = [OSSVThemesColors col_999999];
        _timeLabel.font = [UIFont systemFontOfSize:11];
    }
    return _timeLabel;
}

@end
