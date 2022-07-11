//
//  STLSysInitModel.h
// XStarlinkProject
//
//  Created by fan wang on 2021/8/3.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>

NS_ASSUME_NONNULL_BEGIN

///system/init 返回模型
@interface STLSysInitModel : NSObject<YYModel>
@property (nonatomic,copy) NSString *latitude;
@property (nonatomic,copy) NSString *longitude;
///search AB 开关
@property (nonatomic,assign) BOOL abtest_switch;

///recommend AB 开关
@property (nonatomic,assign) BOOL recommend_abtest_switch;
@property (nonatomic,copy) NSString *customer_service_email;
@property (nonatomic,copy) NSString *customer_service_phone;
@property (nonatomic,copy) NSString *customer_service_email_title;
@property (nonatomic,copy) NSString *customer_service_url;

///是否开启短信验证ab
@property (nonatomic,assign) BOOL cod_confirm_sms_abtest;
///是否开启短信验证
@property (nonatomic,assign) BOOL cod_confirm_sms_open;
//是否显示whatapps订阅
@property (nonatomic,assign) BOOL isShowWhatsAppSubscribe;

///1.4.6 隐私协议弹窗控制
@property (nonatomic,assign) BOOL is_show_privacy;

@end

NS_ASSUME_NONNULL_END
