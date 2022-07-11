//
//  UIResponder+Router.h
//  router
//
//  Created by tsaievan on 16/12/2.
//  Copyright © 2016年 tsaievan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIResponder (Router)


- (void)routerWithEventName:(NSString *)eventName userInfo:(NSDictionary *)userInfo;
@end
