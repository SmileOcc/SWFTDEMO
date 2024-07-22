//
//  AccountModel.h
//  Yoshop
//
//  Created by YW on 16/5/31.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYModel.h"

//用户性别  0 保密 1 男  2 女
typedef NS_ENUM(NSUInteger, UserEnumSexType){
    UserEnumSexTypePrivacy = 0,
    UserEnumSexTypeMale = 1,
    UserEnumSexTypeFemale = 2
};

@class ZFBannerModel;

@interface AccountModel : NSObject <NSCoding,NSCopying,NSMutableCopying>

@property (nonatomic, assign)UserEnumSexType    sex;//性别{0未知1男2女}
@property (nonatomic, copy) NSString            *email;  ///邮箱
@property (nonatomic, copy) NSString            *firstname;//名
@property (nonatomic, copy) NSString            *lastname;//姓
@property (nonatomic, copy) NSString            *nickname;//昵称
@property (nonatomic, copy) NSString            *addressId;// 用户地址ID
@property (nonatomic, copy) NSString            *phone;//电话
@property (nonatomic, copy) NSString            *birthday;// 生日
@property (nonatomic, copy) NSString            *avatar;//头像
@property (nonatomic, copy) NSString            *token;// api token
@property (nonatomic, copy) NSString            *sess_id;
@property (nonatomic, copy) NSString            *user_id;//用户编号
@property (nonatomic, copy) NSString            *point_tips;   // 修改信息积分提示语
@property (nonatomic, copy) NSString            *has_new_coupon;  // 是否有新的优惠券
@property (nonatomic, copy) NSString            *not_paying_order; //未支付的订单数量
@property (nonatomic, copy) NSString            *paid_order_number; // //已支付的订单数量
@property (nonatomic, assign) BOOL              user_review_sku; ///个人中心是否显示评论入口
@property (nonatomic, copy) NSString            *webf_email;
@property (nonatomic, copy) NSString            *webf_email_sign;
@property (nonatomic, copy) NSString            *webf_email_sign_expire;
@property (nonatomic, copy) NSString            *order_number; //订单总数
@property (nonatomic, copy) NSString            *coupon_number; //优惠劵
@property (nonatomic, copy) NSString            *collect_number; //收藏
@property (nonatomic, copy) NSString            *avaid_point; //积分

///游客标识：0 正常用户 1 游客账号 2 转正账号
@property (nonatomic, assign) NSInteger         is_guest;
///学生卡等级 0:普通 1:认证 2:vip
@property (nonatomic, assign) NSInteger         student_level;

@property (nonatomic, copy) NSString            *fbuid;

///谷歌登录获取的生日
@property (nonatomic, copy) NSString *googleLoginBirthday;
///谷歌登录获取的性别
@property (nonatomic, copy) NSString *googleLoginGender;

///faceBook登录获取的生日
@property (nonatomic, copy) NSString *facebookLoginBirthday;
///faceBook登录获取的性别
@property (nonatomic, copy) NSString *facebookLoginGender;


//是否生日 1 生日期间  2 非生日期间
@property (nonatomic, assign) BOOL is_birthday;

//是否新兴市场登录 1 新兴手机号注册 0邮箱注册
@property (nonatomic, assign) NSInteger is_emerging_country;

//手机号注册前缀
@property (nonatomic, copy) NSString *prefix;

//是否修改过生日 0 未修改  1已修改 
@property (nonatomic, assign) BOOL is_update_birthday;

//是否注册 1 表示注册 0 标识登录
@property (nonatomic, assign) BOOL is_register;

// v5.0.0 帖子分享后缀链接带入
@property (nonatomic, copy) NSString            *link_id;


@end
