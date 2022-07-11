//
//  OSSVFlashSaleProgressView.m
// XStarlinkProject
//
//  Created by Kevin on 2020/11/7.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVFlashSaleProgressView.h"

@implementation OSSVFlashSaleProgressView

- (instancetype)init {
    self = [super init];
    if (self) {
        _progressBgV = [[UIView alloc] init];
        _progressBgV.backgroundColor = [OSSVThemesColors col_EEEEEE];
        [self addSubview:_progressBgV];
        
        _progressV = [[UIView alloc] init];
        _progressV.backgroundColor = [OSSVThemesColors col_FDC845];
        [self addSubview:_progressV];
        
//        [self.progressBgV mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.leading.trailing.top.bottom.mas_equalTo(self);
//        }];
//
//        [self.progressV mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.leading.top.bottom.mas_equalTo(self);
//            make.width.mas_equalTo(self.progressBgV.mas_width).multipliedBy(0);
//        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _progressBgV.frame = self.bounds;
//    _progressBgV.layer.cornerRadius = self.bounds.size.height/2;
    
//    _progressV.layer.cornerRadius = self.bounds.size.height/2;
}

- (void)setProgress:(float)progress {
    _progress = progress;
    _progressV.frame = CGRectMake(0, 0, 0, self.height);
}

- (void)startProgressAnimation {
    if (self.progress > 0) {
        self.progressV.frame = CGRectMake(0, 0, self.progressBgV.width * self.progress, self.height);
        //        @weakify(self)
//        _progressV.frame = CGRectMake(0, 0, 0, self.height);
//        [UIView animateWithDuration:0.6 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
//            @strongify(self)
//            self.progressV.frame = CGRectMake(0, 0, self.progressBgV.width * self.progress, self.height);
//        } completion:^(BOOL finished) {
//
//        }];
    } else {
        _progressV.frame = CGRectMake(0, 0, 0, self.height);
    }
}

@end
