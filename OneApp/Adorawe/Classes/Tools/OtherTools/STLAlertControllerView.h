//
//  STLAlertControllerView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/3.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STLAlertControllerView : NSObject

+ (void)showCtrl:(UIViewController *)viewController message:(NSString *)message oneMsg:(NSString *)oneMsg;

+ (void)showCtrl:(UIViewController *)viewController alertTitle:(NSString *)title message:(NSString *)message oneMsg:(NSString *)oneMsg twoMsg:(NSString *)towMsg completionHandler:(void(^) (NSInteger flag))completionHandler;
@end
