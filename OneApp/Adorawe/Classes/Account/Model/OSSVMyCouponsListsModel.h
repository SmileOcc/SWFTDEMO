//
//  OSSVMyCouponsListsModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSSVMyCouponsListsModel : NSObject

@property (nonatomic, copy) NSString *couponCode; // 优惠码
@property (nonatomic, copy) NSString *startTime; // 开始时间
@property (nonatomic, copy) NSString *endTime; // 结束时间
@property (nonatomic, strong) NSArray *over; // 满减
@property (nonatomic, strong) NSArray *save; // 直减
@property (nonatomic, copy) NSString *userId; // 用户ID
@property (nonatomic, copy) NSString *flag; // 标识符(unused,expired,used)
@property (nonatomic, assign) NSInteger discountMode; // 折扣的模式(1 货币,2 百分比 3..)
@property (nonatomic, assign) NSInteger showFlag; // 显示Coupon类型
@property (nonatomic, assign) NSInteger isOnlyApp; // 是否仅App才可用的Coupon
@property (nonatomic, copy) NSString *condition; // 什么条件下可用的Coupon

@property (nonatomic, copy) NSString *use_type;  // 1 通用， 2 包邮券 3 cod服务
@property (nonatomic, copy) NSString *coupon_desc;
@property (nonatomic, copy) NSString *coupon_name;
@property (nonatomic, copy) NSString *type_notes; //优惠券提示语

@property (nonatomic, copy) NSString *coupon_title;
@property (nonatomic, copy) NSString *coupon_sub;

@property (nonatomic, copy) NSString *uc_id;

@property (nonatomic,assign) BOOL is_new;

// 不可用
@property (nonatomic, assign) BOOL    unAvailabel;

// 自定义 是否选中
@property (nonatomic, assign) BOOL   isSelected;

@end
