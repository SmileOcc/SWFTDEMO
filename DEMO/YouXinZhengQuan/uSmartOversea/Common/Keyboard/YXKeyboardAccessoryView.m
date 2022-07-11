//
//  YXKeyboardAccessoryView.m
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/8/10.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXKeyboardAccessoryView.h"
#import "uSmartOversea-Swift.h"

@implementation YXKeyboardAccessoryView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, YXConstant.screenWidth, 30);
        self.backgroundColor = [UIColor qmui_colorWithHexString:@"#EDEDED"];
        
        UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
        label.text = [YXLanguageUtility kLangWithKey:@"usmart_keyboard"];
        label.textColor = [UIColor qmui_colorWithHexString:@"#191919"];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        [self addSubview:label];
        
        CGFloat lineHeight = 1/[UIScreen mainScreen].scale;
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 30 - lineHeight, YXConstant.screenWidth, lineHeight)];
        line.backgroundColor = [UIColor qmui_colorWithHexString:@"#CCCCCC"];
        [self addSubview:line];
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
