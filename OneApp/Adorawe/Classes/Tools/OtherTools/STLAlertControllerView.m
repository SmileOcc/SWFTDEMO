//
//  STLAlertControllerView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/3.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLAlertControllerView.h"

@implementation STLAlertControllerView

+ (BOOL)isEmptyString:(id)string {
    return string==nil || string==[NSNull null] || ![string isKindOfClass:[NSString class]] || [(NSString *)string length]==0 || [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0;
}

+ (NSString *)emptyStringReplaceNSNull:(id)string {
    if ([self isEmptyString:string]) {
        return @"";
    }else{
        return string;
    }
}

+ (void)showCtrl:(UIViewController *)viewController message:(NSString *)message oneMsg:(NSString *)oneMsg {
    STLAlertViewController *alertController = [STLAlertViewController alertControllerWithTitle:nil
                                                                             message:[STLAlertControllerView emptyStringReplaceNSNull:message]
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    if ([viewController isKindOfClass:[UIViewController class]]) {
        [viewController presentViewController:alertController animated:YES completion:^{}];
    }
}

+ (void)showCtrl:(UIViewController *)viewController alertTitle:(NSString *)title message:(NSString *)message oneMsg:(NSString *)oneMsg twoMsg:(NSString *)towMsg completionHandler:(void(^) (NSInteger flag))completionHandler {
    
    
    
    STLAlertViewController *alertController = [STLAlertViewController alertControllerWithTitle:title
                                                                             message:[STLAlertControllerView emptyStringReplaceNSNull:message]
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    if (oneMsg && [oneMsg isKindOfClass:[NSString class]]) {
        [alertController addAction:[UIAlertAction actionWithTitle:oneMsg
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              if (completionHandler) {
                                                                  completionHandler(1);
                                                              }
                                                          }]];
    }
    if (towMsg && [towMsg isKindOfClass:[NSString class]]) {
        [alertController addAction:[UIAlertAction actionWithTitle:towMsg
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              if (completionHandler) {
                                                                  completionHandler(2);
                                                              }
                                                          }]];
    }
    
#if DEBUG
    [alertController addAction:[UIAlertAction actionWithTitle:@"这个是测试的取消按钮"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {}]];
#endif
    
    if ([viewController isKindOfClass:[UIViewController class]]) {
        [viewController presentViewController:alertController animated:YES completion:^{}];
    }

}
@end
