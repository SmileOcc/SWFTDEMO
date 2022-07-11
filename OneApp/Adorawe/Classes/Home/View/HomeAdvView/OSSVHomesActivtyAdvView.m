//
//  HomeActivityAdvView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/3.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVHomesActivtyAdvView.h"

@implementation OSSVHomesActivtyAdvView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.advType = AdverTypeHomeActity;
        self.contentView.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.contentView];
        [self.contentView addSubview:self.bgImgView];
        
        [self addSubview:self.cloaseButton];
        
        CGFloat w = 300 * DSCREEN_WIDTH_375_SCALE;
        //CGFloat h = w * 36.0/30.0;
        [self.bgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.mas_equalTo(self);
            make.width.mas_equalTo(w);
            make.height.mas_equalTo(self.bgImgView.mas_width).multipliedBy(36.0/30.0);
        }];
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self);
            make.leading.mas_equalTo(self.mas_leading).mas_offset(38);
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-38);
            make.height.mas_equalTo(self.bgImgView.mas_height);
        }];
                
        [self.cloaseButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.bgImgView.mas_trailing);
            make.bottom.mas_equalTo(self.bgImgView.mas_top).mas_offset(-16);
            make.size.mas_equalTo(CGSizeMake(22, 22));
        }];
    }
    return self;
}


#pragma mark -

- (void)actionEvent:(UIButton *)sender {
    if (self.advDoActionBlock) {
        self.advDoActionBlock(self.advEventModel, NO);
    }
}

- (YYAnimatedImageView *)bgImgView {
    if (!_bgImgView) {
        _bgImgView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _bgImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _bgImgView;
}


@end
