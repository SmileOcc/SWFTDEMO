//
//  UIViewController+PopBackButtonAction.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/20.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PopBackButtonActionProtocol <NSObject>
@optional

- (BOOL)navigationShouldPopOnBackButton;

@end

@interface UIViewController (PopBackButtonAction)<PopBackButtonActionProtocol>

@end
