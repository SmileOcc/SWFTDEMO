//
//  OSSVPayMentDiscountChangePopView.h
// XStarlinkProject
//
//  Created by Kevin on 2020/12/29.
//  Copyright © 2020 starlink. All rights reserved.
//  -----支付方式优惠改变时候的弹窗

#import <UIKit/UIKit.h>

@protocol OSSVPayMentDiscountChangePopViewDelegate <NSObject>

@optional
- (void)updateOrderMakeSure;

@end

@interface OSSVPayMentDiscountChangePopView : UIView
@property (nonatomic, weak) id<OSSVPayMentDiscountChangePopViewDelegate>delegate;
-(void)showView;
-(void)hiddenView;

@end

