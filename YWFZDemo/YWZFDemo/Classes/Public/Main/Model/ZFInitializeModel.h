//
//  ZFInitializeModel.h
//  ZZZZZ
//
//  Created by YW on 2018/7/26.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFSupportLangModel : NSObject
//国家code
@property (nonatomic, copy) NSString *code;
//国家名字
@property (nonatomic, copy) NSString *name;

@end

//登录注册页面顶部广告语模型
@interface ZFInitCopywritingModel : NSObject
@property (nonatomic, strong) NSString *login;
@property (nonatomic, strong) NSString *registerStr;
@end


//国家数据模型
@interface ZFInitCountryInfoModel : NSObject
@property (nonatomic, strong) NSString *region_code;
@property (nonatomic, strong) NSString *region_id;
@property (nonatomic, strong) NSString *region_name;
/// 是否新兴市场用户 新增该字段，1表示是新兴国家，0不是
@property (nonatomic, assign) NSInteger is_emerging_country;
///国家站支持语言列表
@property (nonatomic, strong) NSArray<ZFSupportLangModel *> *support_lang;

@end


//汇率模型模型
@interface ZFInitExchangeModel : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *rate;
@property (nonatomic, strong) NSString *sign;
///取整精度字段
@property (nonatomic, assign) NSInteger exponet;
///千位分隔符
@property (nonatomic, copy) NSString *thousandSign;
///小数点符号
@property (nonatomic, copy) NSString *decimalSign;
///货币位置标识   1：左   2：右
@property (nonatomic, copy) NSString *position;
@end

//个人中心联系url
@interface ZFInitAccountContactModel : NSObject

@property (nonatomic, copy) NSString *zid;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;

@end

//url list
@interface ZFInitUrlList : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *tag;

@end

@interface ZFInitializeModel : NSObject
@property (nonatomic, strong) NSString *get_it_free;//我的分享地址
@property (nonatomic, strong) NSString *what_is_get;//商详页面分享弹框感叹号H5地址
@property (nonatomic, strong) NSString *status; //是否弹出更新App弹框标识
@property (nonatomic, strong) NSString *tips; //购物车顶部跑马灯提示
@property (nonatomic, strong) NSString *country_eu; //欧盟标识,  0  1 欧盟字段标识
@property (nonatomic, strong) NSString *login_expired; //1 代表token失效,需要重新登录
@property (nonatomic, strong) NSString *is_cod_sex; //1: 显示, 0:不显示, 根据IP地址判断，如为后台设置的支持COD业务的国家，即货到付款城市设置中存在的国家, 注册时增加性别选择，必填，不默认，用户需手动选择
@property (nonatomic, strong) ZFInitCopywritingModel *copywriting;//登录注册页面顶部广告语
@property (nonatomic, strong) ZFInitCountryInfoModel *countryInfo;//国家数据模型
@property (nonatomic, strong) ZFInitExchangeModel *exchange;//汇率模型模型
@property (nonatomic, strong) ZFInitAccountContactModel *contact_us;
@property (nonatomic, strong) NSArray<ZFInitUrlList *> *set_url_list;
///欧盟国家，市场价格显示的文案
@property (nonatomic, copy) NSString *rrp;
@end
