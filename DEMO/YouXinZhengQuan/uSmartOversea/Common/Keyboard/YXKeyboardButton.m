//
//  YXKeyboardButton.m
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/8/6.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXKeyboardButton.h"
#import <QMUIKit/QMUIKit.h>
#import "uSmartOversea-Swift.h"
#import <YYCategories/YYCategories.h>

#define kYXKeyboardButtonTitleColor [UIColor colorWithHexString:@"#2A2B2C"]
#define kYXKeyboardButtonDefaultColor [UIColor colorWithHexString:@"#FFFFFF"]
#define kYXKeyboardButtonDefaultHighlightColor [UIColor colorWithHexString:@"#F6F6F7"]
#define kYXKeyboardButtonTitleFont [UIFont systemFontOfSize:22]
#define kYXKeyboardButtonFunctionTitleFont [UIFont systemFontOfSize:18]

#define kYXKeyboardBorderColor [UIColor colorWithHexString:@"#CCCCCC"]

#define kYXKeyboardButtonOtherColor [UIColor colorWithHexString:@"#F6F6F7"]
#define kYXKeyboardButtonOtherHighlightColor [UIColor colorWithHexString:@"#FFFFFF"]

#define kYXKeyboardButtonCompleteColor [UIColor colorWithHexString:@"#0D50D8"]
#define kYXKeyboardButtonCompleteTitleColor [UIColor colorWithHexString:@"#FFFFFF"]
#define kYXKeyboardButtonCompleteHighlightTitleColor [[UIColor colorWithHexString:@"#191919"] colorWithAlphaComponent:0.65]
#define kYXKeyboardButtonCompleteTitleFont [UIFont systemFontOfSize:20]



@implementation YXKeyboardButton

- (void)setKeyboardButtonType:(YXKeyboardButtonType)KeyboardButtonType {
    _KeyboardButtonType = KeyboardButtonType;
    
    UIImage *defaultBackground = [[UIImage imageWithColor:kYXKeyboardButtonDefaultColor size:self.bounds.size] qmui_imageWithBorderColor:kYXKeyboardBorderColor borderWidth:1/[UIScreen mainScreen].scale borderPosition:QMUIImageBorderPositionRight | QMUIImageBorderPositionBottom];
    UIImage *highlightBackground = [[UIImage imageWithColor:kYXKeyboardButtonDefaultHighlightColor size:self.bounds.size] qmui_imageWithBorderColor:kYXKeyboardBorderColor borderWidth:1/[UIScreen mainScreen].scale borderPosition:QMUIImageBorderPositionRight | QMUIImageBorderPositionBottom];
    UIImage *completeBackground = [[UIImage imageWithColor:kYXKeyboardButtonCompleteColor size:self.bounds.size] qmui_imageWithBorderColor:kYXKeyboardBorderColor borderWidth:1/[UIScreen mainScreen].scale borderPosition:QMUIImageBorderPositionRight | QMUIImageBorderPositionBottom];
    
    [self setTitleColor:kYXKeyboardButtonTitleColor forState:UIControlStateNormal];
    self.titleLabel.font = kYXKeyboardButtonTitleFont;
    [self setBackgroundImage:defaultBackground forState:UIControlStateNormal];
    [self setBackgroundImage:highlightBackground forState:UIControlStateHighlighted];

    switch (KeyboardButtonType) {
        case YXKeyboardButtonTypeDelete:
            [self setImage:[UIImage imageNamed:@"keyboard_delete"] forState:UIControlStateNormal];
            [self configFunctionBtn];
            break;
        case YXKeyboardButtonTypeResign:
            [self setImage:[UIImage imageNamed:@"keyboard_resign"] forState:UIControlStateNormal];
            [self configFunctionBtn];
            break;
        case YXKeyboardButtonTypeDecimal:
            [self setTitle:@"." forState:UIControlStateNormal];
            break;
        case YXKeyboardButtonType00:
            [self setTitle:@"00" forState:UIControlStateNormal];
            break;
        case YXKeyboardButtonType000:
            [self setTitle:@"000" forState:UIControlStateNormal];
            break;
        case YXKeyboardButtonTypeComplete:
            [self setBackgroundImage:completeBackground forState:UIControlStateNormal];
            [self setBackgroundImage:highlightBackground forState:UIControlStateHighlighted];
            [self setTitle:[YXLanguageUtility kLangWithKey:@"common_confirm2"] forState:UIControlStateNormal];
            [self setTitleColor:kYXKeyboardButtonCompleteTitleColor forState:UIControlStateNormal];
            [self setTitleColor:kYXKeyboardButtonTitleColor forState:UIControlStateHighlighted];
            self.titleLabel.font = kYXKeyboardButtonCompleteTitleFont;
            break;
        case YXKeyboardButtonTypeNone:
            [self setBackgroundImage:defaultBackground forState:UIControlStateHighlighted];
            break;
        case YXKeyboardButtonTypeFull:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"trading_all"] forState:UIControlStateNormal];
            [self configFunctionBtn];
            break;
        case YXKeyboardButtonTypeHalf:
            [self setTitle:[YXLanguageUtility kLangWithKey:@"trading_half"] forState:UIControlStateNormal];
            [self configFunctionBtn];
            break;
        case YXKeyboardButtonTypeOneThird:
            [self setTitle:@"1/3" forState:UIControlStateNormal];
            [self configFunctionBtn];
            break;
        case YXKeyboardButtonTypeQuarter:
            [self setTitle:@"1/4" forState:UIControlStateNormal];
            [self configFunctionBtn];
            break;
        default:
            break;
    }
}

- (void)configFunctionBtn {
    UIImage *defaultBackground = [[UIImage imageWithColor:kYXKeyboardButtonDefaultColor size:self.bounds.size] qmui_imageWithBorderColor:kYXKeyboardBorderColor borderWidth:1/[UIScreen mainScreen].scale borderPosition:QMUIImageBorderPositionRight | QMUIImageBorderPositionBottom];
    UIImage *highlightBackground = [[UIImage imageWithColor:kYXKeyboardButtonDefaultHighlightColor size:self.bounds.size] qmui_imageWithBorderColor:kYXKeyboardBorderColor borderWidth:1/[UIScreen mainScreen].scale borderPosition:QMUIImageBorderPositionRight | QMUIImageBorderPositionBottom];
    self.titleLabel.font = kYXKeyboardButtonFunctionTitleFont;
    
    [self setBackgroundImage:highlightBackground forState:UIControlStateNormal];
    [self setBackgroundImage:defaultBackground forState:UIControlStateHighlighted];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
