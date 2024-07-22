//
//  ZFLiveProgressLineView.m
//  ZZZZZ
//
//  Created by YW on 2019/12/20.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFLiveProgressLineView.h"
#import "Masonry.h"
#import "ZFThemeManager.h"
@implementation ZFLiveProgressLineView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.grayLineView];
        [self addSubview:self.lightLineView];
        
        [self.grayLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.bottom.mas_equalTo(self);
        }];
        
        [self.lightLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.bottom.mas_equalTo(self);
            make.width.mas_equalTo(self.mas_width).multipliedBy(0);
        }];
    }
    return self;
}

- (void)setProgress:(CGFloat)progress {
    
    if (progress >= 1) {
        progress = 1.0;
    }
    if (progress <= 0) {
        progress = 0;
    }
    
    _progress = progress;
    [self.lightLineView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.mas_width).multipliedBy(progress);
    }];
}

- (UIView *)grayLineView {
    if (!_grayLineView) {
        _grayLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _grayLineView.backgroundColor = ZFC0xCCCCCC();
        _grayLineView.alpha = 0.5;
    }
    return _grayLineView;
}

- (UIView *)lightLineView {
    if (!_lightLineView) {
        _lightLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lightLineView.backgroundColor = ZFC0xFE5269();
    }
    return _lightLineView;
}

@end
