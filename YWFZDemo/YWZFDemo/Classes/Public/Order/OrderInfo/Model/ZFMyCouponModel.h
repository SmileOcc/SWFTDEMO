//
//  ZFMyCouponModel.h
//  ZZZZZ
//
//  Created by YW on 2017/12/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFMyCouponModel : NSObject

@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *exp_time;
@property (nonatomic, assign) BOOL isShowAll;
@property (nonatomic, assign) BOOL is_use_pcode_success;
@property (nonatomic, copy) NSString *pcode_amount;
@property (nonatomic, copy) NSString *pcode_msg;
@property (nonatomic, copy) NSString *preferential_all;
@property (nonatomic, copy) NSString *preferential_first;
@property (nonatomic, copy) NSString *preferential_head;

@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, assign) NSInteger tempIndex;

//@property (nonatomic, assign) NSInteger coupon_select; //只在未登录时使用, 是否选中优惠券

@property (nonatomic, assign) BOOL no_mail;
@end
