//
//  PaymentListModel.h
//  Dezzal
//
//  Created by 7FD75 on 16/8/6.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OfferMessage : NSObject

@property (nonatomic, copy) NSString *tips;
@property (nonatomic, copy) NSString *discount;
@property (nonatomic, copy) NSString *amount;

@end

@interface PaymentIconModel : NSObject

///code对应本地图标名称
@property (nonatomic, copy) NSString *app_code;
@property (nonatomic, copy) NSString *pay_code;
@property (nonatomic, copy) NSString *pay_name;
///icon对应网络图标链接
@property (nonatomic, copy) NSString *pay_icon;
@property (nonatomic, copy) NSString *sort;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@end

@interface PaymentListModel : NSObject

@property (nonatomic, copy) NSString *pay_code;

@property (nonatomic, copy) NSString *pay_id;

@property (nonatomic, copy) NSString *pay_name;

@property (nonatomic, copy) NSString *pay_shuoming;

@property (nonatomic, copy) NSString *default_select;

///是否只有一个支付方式(本地赋值,非后台传入)
@property (nonatomic, assign) BOOL isOnlyOne;

///优惠折扣
@property (nonatomic, strong) OfferMessage *offer_message;

///是否可以使用cod  0 正常可用 1 soa风控  2 网站风控
@property (nonatomic, assign) NSInteger cod_state;

///成为COD会员的url
@property (nonatomic, copy) NSString *join_member_url;

///本地获取的iconImage
@property (nonatomic, strong) NSArray <UIImage *> *payIconImageList;

///同payIconImageList count 一致的保存size的数组
@property (nonatomic, strong, readonly) NSMutableArray *iconSizeList;

///支付图标数组
@property (nonatomic, strong) NSArray <PaymentIconModel *>*pay_desc_list;

///paypal支付方式
-(BOOL)isPayPalPayment;

///cod支付方式
-(BOOL)isCodePayment;

///online支付方式
-(BOOL)isOnlinePayment;

@end
