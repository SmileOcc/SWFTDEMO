//
//  UIResponder+Router.m
//  router
//
//  Created by tsaievan on 16/12/2.
//  Copyright © 2016年 tsaievan. All rights reserved.
//

#import "UIResponder+Router.h"

@implementation UIResponder (Router)

- (void)routerWithEventName:(NSString *)eventName userInfo:(NSDictionary *)userInfo {
    if (self.nextResponder) {
         [[self nextResponder] routerWithEventName:eventName userInfo:userInfo];
    }
}

/*
 - (void)buttonClickAction:(UIButton *)sender {
 [sender routerWithEventName:YFTransferNameEvent userInfo:@{
 YFUserName:[self userName],
 }];
 }
 
 
 使用时，只要在UI中实现这个方法就可以拦截事件，比如从cell中的button的点击事件向VC中传值
 - (void)routerWithEventName:(NSString *)eventName userInfo:(NSDictionary *)userInfo {
 if ([eventName isEqualToString:YFTransferNameEvent]) {
 NSString * name = userInfo[YFUserName];
 self.resultLabel.text = name;
 }
 }
 
 **/

@end
