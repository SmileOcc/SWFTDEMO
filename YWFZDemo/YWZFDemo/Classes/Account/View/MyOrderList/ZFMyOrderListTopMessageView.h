//
//  ZFMyOrderListTopMessageView.h
//  ZZZZZ
//
//  Created by YW on 2018/8/18.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFMyOrderListTopMessageView : UIView

@property (nonatomic, copy) void (^operateCloseBlock)(void);
@property (nonatomic, copy) void (^operateEventBlock)(void);
@property (nonatomic, assign) BOOL isAccountPage;  // 是否为个人中心页

@end
