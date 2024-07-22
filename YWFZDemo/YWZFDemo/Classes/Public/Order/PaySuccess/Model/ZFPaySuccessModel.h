//
//  ZFPaySuccessModel.h
//  ZZZZZ
//
//  Created by YW on 2018/4/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, OrderFinishActionType) {
    OrderFinishActionTypeOrderList = 0,
    OrderFinishActionTypeHome
};

@class ZFBannerModel;

@interface ZFPaySuccessModel : NSObject
/**
 * 1 代表显示用户引导
 */
@property (nonatomic, assign)   BOOL       is_show_popup;
@property (nonatomic, copy)     NSString   *contact_us;
@property (nonatomic, copy)     NSString   *points;
@property (nonatomic, copy)     NSString   *user_name;
@property (nonatomic, copy)     NSString   *phone;
@property (nonatomic, copy)     NSString   *address;
@property (nonatomic, copy)     NSString   *pay_name;
/**
 * 先款后货订单显示实际付款：XX元；先货后款显示：货到后付款：XX元
 */
@property (nonatomic, copy) NSString   *account;
@property (nonatomic, strong)   NSArray<ZFBannerModel *>   *banners;
/**
 * 0 : 没使用   1：使用
 */
@property (nonatomic, copy) NSString   *is_use_point;

@property (nonatomic, assign) NSInteger order_status;

///是否COD支付 （非后台传入）
@property (nonatomic, assign) BOOL isCodPay;

///线下支付token链接  (非后台传入)
@property (nonatomic, copy) NSString *offlineLink;

/// 是否显示COD确认信息
@property (nonatomic, assign) NSInteger confirm_btn_show;

/// 拆单提示
@property (nonatomic, copy) NSString *order_part_hint;

@end
