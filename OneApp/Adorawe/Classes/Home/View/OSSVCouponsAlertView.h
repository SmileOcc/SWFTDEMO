//
//  STLCouponAlertView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/19.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSSVCouponsAlertView : UIView

-(void)showView:(UIView *)superView msg:(NSString *)msg;

@property (nonatomic, copy) void (^operateBlock)();
@end
