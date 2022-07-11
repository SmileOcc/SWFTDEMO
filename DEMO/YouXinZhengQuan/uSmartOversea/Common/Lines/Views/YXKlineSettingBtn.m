//
//  YXKlineSettingBtn.m
//  uSmartOversea
//
//  Created by chenmingmao on 2019/12/5.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXKlineSettingBtn.h"

@implementation YXKlineSettingBtn


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    [self setImage: [UIImage imageNamed:@"icon_kline_check_WhiteSkin"] forState:UIControlStateNormal];
    [self setImagePosition:QMUIButtonImagePositionRight];
    self.spacingBetweenImageAndTitle = 1;
    self.backgroundColor = [UIColor qmui_colorWithHexString:@"#1919190D"];
    [self setTitle:@"MA" forState:UIControlStateNormal];
    [self setTitleColor:[UIColor qmui_colorWithHexString:@"#191919"] forState:UIControlStateNormal];
    self.layer.cornerRadius = 2;
    self.clipsToBounds = YES;
    self.titleLabel.font = [UIFont systemFontOfSize:10];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    if (self.hidden || !self.userInteractionEnabled) {
        return NO;
    }
    
    //为负数
    CGFloat expandX = -ABS(5);
    CGFloat expandY = -ABS(5);
   
    if (CGRectContainsPoint(CGRectInset(self.bounds, expandX, expandY), point)) {
        return YES;
    }
    return NO;
}


@end
