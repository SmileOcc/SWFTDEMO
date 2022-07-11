//
//  UIView+Line.m
//  uSmartOversea
//
//  Created by ellison on 2018/10/17.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "UIView+Line.h"

@implementation UIView (Line)

+ (UIView *)lineView {
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.5)];
    line.backgroundColor = QMUITheme.separatorLineColor;
    return line;
}

@end
