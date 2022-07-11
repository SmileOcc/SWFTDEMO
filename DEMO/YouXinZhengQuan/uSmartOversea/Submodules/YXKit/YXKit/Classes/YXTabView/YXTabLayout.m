//
//  YXTabLayout.m
//  ScrollViewDemo
//
//  Created by ellison on 2018/9/28.
//  Copyright © 2018 ellison. All rights reserved.
//

#import "YXTabLayout.h"

@implementation YXTabLayout

+ (YXTabLayout *)defaultLayout {
    YXTabLayout *layout =  [[YXTabLayout alloc] init];
    layout.titleColor = [UIColor.whiteColor colorWithAlphaComponent:0.6];
    layout.titleSelectedColor = [[UIColor alloc] initWithRed:47/255.0 green:121/255.0 blue:255/255.0 alpha:1.0];
    layout.titleFont = [UIFont systemFontOfSize:14];
    layout.titleSelectedFont = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    layout.lrMargin = 20;
    layout.tabMargin = 30;
    layout.tabPadding = 0;
    layout.leftAlign = NO;
    layout.tabWidth = 0;
    layout.tabColor = [UIColor clearColor];
    layout.tabSelectedColor = [UIColor clearColor];
    layout.lineColor = [[UIColor alloc] initWithRed:47/255.0 green:121/255.0 blue:255/255.0 alpha:1.0];
    layout.linePadding = 0;
    layout.lineCornerRadius = 0;
    layout.lineHeight = 2;
    layout.lineWidth = 28;
    layout.lineHidden = NO;
    layout.lineScrollDisable = NO;
    layout.isGradientTail = NO;
    layout.gradientTailColor = [UIColor whiteColor];
    layout.layerWidth = 0;
    layout.layerColor = [UIColor clearColor];
    layout.layerSelectedColor = [UIColor clearColor];
    
    return layout;
}

@end
