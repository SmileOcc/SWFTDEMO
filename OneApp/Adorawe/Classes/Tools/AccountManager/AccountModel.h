//
//  AccountModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//  注册成功以及 用户信息的model

#import <Foundation/Foundation.h>

@interface AccountModel : NSObject <NSCoding,NSCopying,NSMutableCopying>
@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *birthday;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *is_new;
@property (nonatomic, assign) UserEnumSexType sex;
@property (nonatomic, copy)   NSString *token;// api token
@property (nonatomic, assign) NSInteger appUnreadCouponNum;    // 是否有新优惠券
@property (nonatomic, assign) NSInteger appUnusedCouponNum;    // 优惠券数量
@property (nonatomic, assign) BOOL has_new_coin;    // 有新金币
@property (nonatomic, assign) NSInteger collect_num;    // 收藏数量
@property (nonatomic, assign) NSInteger outstandingOrderNum;  // 用户未付款订单数
@property (nonatomic, assign) NSInteger processingOrderNum;  // 用户处理中订单数
@property (nonatomic, assign) NSInteger shippedOrderNum;    // 用户运输中订单数
@property (nonatomic, assign) NSInteger reviewedNum;       // 用户待评论订单数
@property (nonatomic, assign) NSInteger feedbackMessageCount;    // 用户反馈未读
@property (nonatomic, assign) NSInteger  checkInMark;  //签到标识：1已经签到 0 未签到
@property (nonatomic, assign) NSInteger  coinCount;   //可领取的金币数量
@property (nonatomic, copy)   NSString  *coinCenterUrlStr; //到金币中心的url
@property (nonatomic, assign) NSInteger  mapCheck;  //是否显示地图按钮
@property (nonatomic, assign) NSInteger  is_first_order_time;// 1表示新用户订单
//1.3.6新增
@property (nonatomic, copy) NSString *phone;     //手机号
@property (nonatomic, copy) NSString *phoneCode; //区号
@property (nonatomic, assign) NSInteger bindPhoneAvailable; //是否绑定手机号
@property (nonatomic, strong) NSDictionary *tipDic; //文案的对象

@property (nonatomic,assign) BOOL is_kol;

//1.4.0 会员中心入口
@property (nonatomic, assign) BOOL is_show_vip;     //是否展示vip
@property (nonatomic, copy) NSString *vip_url; //vip 跳转url
@property (nonatomic, copy) NSString *vip_icon_url;     //会员等级图标URL

@property (nonatomic, assign) NSInteger is_bind_phone;// 是否绑定手机号 1是 0否
@property (nonatomic, copy)   NSString  *bind_phone_award;// 绑定手机号提示
@property (nonatomic, assign) NSInteger is_verif_phone;// 是否验证手机号 1是 0否

@property (nonatomic, strong) NSDictionary *subscribeDic; // 用户订阅的信息

@end
