//
//  ZFAddressCountryModel.h
//  ZZZZZ
//
//  Created by YW on 2017/8/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAddressBaseModel.h"
#import "ZFAddressStateModel.h"
#import "ZFInitializeModel.h"

@interface ZFCountryExchangeModel : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *sign;
@property (nonatomic, copy) NSString *rate;
///取整精度字段
@property (nonatomic, assign) NSInteger exponet;
///千位分隔符
@property (nonatomic, copy) NSString *thousandSign;
///小数点符号
@property (nonatomic, copy) NSString *decimalSign;
///货币位置标识   1：左   2：右
@property (nonatomic, copy) NSString *position;
@end

@interface ZFAddressCountryModel : ZFAddressBaseModel


//=================== 选择国家Model时用到 ===================
/** 国家站id,接口必传参数*/
@property (nonatomic, copy) NSString *region_code;
/** 国家ID*/
@property (nonatomic, copy) NSString *region_id;
/** 国家名字*/
@property (nonatomic, copy) NSString *region_name;
/** 国家区号*/
@property (nonatomic, copy) NSString *code;
/** 运营商列表*/
@property (nonatomic, strong) NSArray *supplier_number_list;

//手机号码最大值  <V3.5.0废弃>
@property (nonatomic, copy) NSString *number;//手机号码最大值
// 可支持的剩余号码最大长度, 多个长度 <V3.5.0新增>
@property (nonatomic, strong) NSArray *scut_number_list;

/** 是否有州、省，未用*/
@property (nonatomic, assign) BOOL   is_state;
@property (nonatomic, assign) BOOL   configured_number;//1 是后台设置的 判断就直接 =  0未设置的就是 <=
@property (nonatomic, assign) BOOL   is_cod;
/** 是否有城市*/
@property (nonatomic, assign) BOOL   ownCity;
/** 是否有州、省*/
@property (nonatomic, assign) BOOL   ownState;
/** 是否有四级*/
@property (nonatomic, assign) BOOL   showFourLevel;
/** 是否需要获取城市邮编*/
@property (nonatomic, assign) BOOL   support_zip_code;
/// 是否新兴市场用户 新增该字段，1表示是新兴国家，0不是
@property (nonatomic, assign) NSInteger is_emerging_country;

//=================== 个人中心切换国家时Model用到, 只增加了一个exchange字段 ===================
@property (nonatomic, strong) ZFCountryExchangeModel *exchange;

@property (nonatomic, copy) NSArray<ZFAddressStateModel *> *provinceList;

@property (nonatomic, strong) NSArray<ZFSupportLangModel *> *support_lang;

///本地选择完国家后设置的语言
@property (nonatomic, copy) NSString *supportLanguage;

@property (nonatomic, copy) NSString                            *key;

@property (nonatomic, strong) NSMutableArray<NSString *>        *sectionKeys;
@property (nonatomic, strong) NSMutableDictionary               *sectionProvinceDic;


- (void)handleSectionData;
- (NSArray *)sectionDatasForKey:(NSString *)sectionKey;

/** 是否是俄罗斯*/
- (BOOL)isRussiaCountry;
+ (BOOL)isRussiaCountryID:(NSString *)regionId;

@end
