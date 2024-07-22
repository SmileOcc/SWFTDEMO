//
//  NoPasteTextFiled.m
//  ZZZZZ
//
//  Created by YW on 17/3/6.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "NoPasteTextFiled.h"

@implementation NoPasteTextFiled

// 禁止全部功能
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController) {
        [UIMenuController sharedMenuController].menuVisible = NO;
    }
    return NO;
}

@end
