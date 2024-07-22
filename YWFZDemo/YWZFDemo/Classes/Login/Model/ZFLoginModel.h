//
//  YWLoginModel.h
//  ZZZZZ
//
//  Created by YW on 26/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIViewController+ZFViewControllerCategorySet.h"

@interface YWLoginModel : NSObject<NSCopying>

@property (nonatomic, copy) NSString   *email;
@property (nonatomic, copy) NSString   *password;
@property (nonatomic, copy) NSString   *sex;

@property (nonatomic, assign) YWLoginEnterType  type;

@property (nonatomic, assign) BOOL   isFirstFocus;
@property (nonatomic, assign) BOOL   isValidEmail;
@property (nonatomic, assign) BOOL   isValidPassword;
@property (nonatomic, assign) BOOL   isSubscribe;
@property (nonatomic, assign) BOOL   isConfirmInformation;
@property (nonatomic, assign) BOOL   isCountryEU; // 是否为欧盟国家
@property (nonatomic, assign) BOOL   isChangeType;
@property (nonatomic, copy) NSString   *register_ad;
@property (nonatomic, copy) NSString   *login_ad;

///新兴市场登录手机号码
@property (nonatomic, copy) NSString *phoneNum;
///新兴市场登录验证码
@property (nonatomic, copy) NSString *VerificationCodeNum;
///新兴市场选择的国家id
@property (nonatomic, copy) NSString *region_id;
@end
