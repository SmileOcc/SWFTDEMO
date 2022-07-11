//
//  OSSVCheckOutBottomView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/14.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//  提交订单底部视图

#import <UIKit/UIKit.h>
#import "OSSVCartOrderInfoViewModel.h"

typedef NS_ENUM(NSInteger) {
    AddressViewAnimateStatusAnimate,
    AddressViewAnimateStatusShow,
    AddressViewAnimateStatusHidden
}AddressViewAnimateStatus;

@protocol OSSVCheckOutBottomViewDelegate <NSObject>

-(void)STL_CheckOutBottomDidClickBuy:(OSSVCartOrderInfoViewModel *)model;

@end

@interface OSSVCheckOutBottomView : UIView

@property (nonatomic, assign, readonly) AddressViewAnimateStatus stauts;

@property (nonatomic, strong) OSSVCartOrderInfoViewModel *dataSourceModel;

@property (nonatomic, weak) id<OSSVCheckOutBottomViewDelegate>delegate;

@end
