//
//  UICollectionViewCell+ZFExtension.m
//  ZZZZZ
//
//  Created by YW on 2018/5/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "UICollectionViewCell+ZFExtension.h"
#import "ZFThemeManager.h"
#import "ZFFrameDefiner.h"

@implementation UICollectionViewCell (ZFExtension)

/**
 * 对Cell做投影与圆角
 * 投影与圆角同时出现时需要先对子视图做裁剪,然后对父视图做投影即可
 */
- (void)setShadowAndCornerCell
{
    self.backgroundColor = [UIColor clearColor];
    
    //对self做投影
    self.layer.shadowColor = ZFCOLOR(51, 51, 51, .5).CGColor;//阴影颜色
    self.layer.shadowOpacity = 0.15;//不透明度
    self.layer.shadowRadius = 3.0;//半径
    self.layer.shadowOffset = CGSizeMake(0, 0);//偏移距离
    self.layer.masksToBounds = NO; //裁剪
    self.layer.shouldRasterize = YES;//设置缓存 仅复用时设置此选项
    self.layer.rasterizationScale = KScale;//设置对应比例，防止cell出现模糊和锯齿
    //防止卡顿
    //self.contentView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    
    //对contentView做圆角
    self.contentView.layer.cornerRadius = 4;
    self.contentView.layer.masksToBounds = YES;
    self.contentView.layer.shouldRasterize = YES;
    self.contentView.layer.rasterizationScale = KScale;
}

@end
