//
//  ZFAddressInfoModel.h
//  ZZZZZ
//
//  Created by YW on 2017/8/29.
//  Copyright © 2018年 YW. All rights reserved.
//


#import <Foundation/Foundation.h>

// 对应简码 v460：251 ：AE ； 13：CA；21：IN；41：US ;229:IE;239:HK ;172:SA;232:PE;14:CO;

//国家为以下几种选填zip
static NSString  *kZF_IRELAND_ID = @"229";
static NSString  *kZF_CHINA_HONG_KONG_ID = @"239";
static NSString  *kZF_SAUDI_ARABIA_ID = @"172";
static NSString  *kZF_UNITED_ARAB_EMIRATES_ID = @"251";
static NSString  *kZF_PERU_ID = @"232";
static NSString  *kZF_COLOMBIA_ID = @"14";
//印度国家zip只能填写6位数字的格式，不允许填写字母、空格或者标点符号
static NSString  *kZF_INDIA_ID = @"21";
//长度控制在6<=长度<=9位，并且只能是“数字”、“-”、“空格”和“字母”
static NSString  *kZF_CANADA_ID = @"13";
//菲律宾 邮编只能4位限制
static NSString  *kZF_PHILIPPINES_ID = @"283";

/// 俄罗斯
static NSString  *kZF_RUSSIAN_ID = @"32";

/// 罗马尼亚
static NSString  *kZF_ROMANIA_ID = @"167";

// occ测试数据
static NSString *kZF_TEST_ID = @"110";


@interface ZFAddressInfoModel : NSObject <NSMutableCopying>

@property (nonatomic, copy) NSString *address_id;
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *firstname;
@property (nonatomic, copy) NSString *lastname;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *tel;
@property (nonatomic, copy) NSString *code;//电话区号
@property (nonatomic, copy) NSString *country_id;
@property (nonatomic, copy) NSString *country_str; // 国家名
@property (nonatomic, copy) NSString *province_id;
@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *id_card;
@property (nonatomic, copy) NSString *zipcode;
@property (nonatomic, copy) NSString *addressline1;
@property (nonatomic, copy) NSString *addressline2;
@property (nonatomic, copy) NSString *landmark;
@property (nonatomic, copy) NSString *telspare;  //备选电话号码
@property (nonatomic, copy) NSString *whatsapp;
@property (nonatomic, copy) NSString *supplier_number_spare;
@property (nonatomic, assign) BOOL    is_cod;
@property (nonatomic, strong) NSArray *supplier_number_list; //运营商号列表
@property (nonatomic, copy) NSString *supplier_number;      //当前运营商号
@property (nonatomic, copy) NSString *region_code; //国家简码

//手机号码最大位数 <V3.5.0废弃>
//@property (nonatomic, copy) NSString *number;
// 可支持的剩余号码最大长度, 多个长度 <V3.5.0新增>
@property (nonatomic, strong) NSArray         *scut_number_list;
@property (nonatomic, copy) NSString          *maxPhoneLength; //最大兼容数固定20位, 非服务端返回, 本地写死的
@property (nonatomic, copy) NSString          *minPhoneLength;   //最小兼容数固定6位, 非服务端返回, 本地写死的

@property (nonatomic, assign) BOOL            is_default;              //是否是默认邮寄地址 [0-否，1-是]
@property (nonatomic, assign) BOOL            ownState;
@property (nonatomic, assign) BOOL            ownCity;
@property (nonatomic, assign) BOOL            ownBarangay;
/** 当前地址 可以获取城市邮编*/
@property (nonatomic, assign) BOOL            support_zip_code;

@property (nonatomic, assign) BOOL            configured_number;   //1 是后台设置的 判断就直接 =  0未设置的就是 <=
@property (nonatomic, copy) NSString          *google_longitude;//google_longitude:google地图经度
@property (nonatomic, copy) NSString          *google_latitude;//google_latitude:google地图纬度

@property (nonatomic, assign) NSInteger       is_emerging_country;

/** 城镇、村*/
@property (nonatomic, copy) NSString         *barangay;
/** 是否一直显示4级 城镇、村，（YES：一直显示编辑、或选择）*/
@property (nonatomic, assign) BOOL           showFourLevel;


/**自定义，zip处理四位数提示*/
@property (nonatomic, assign) BOOL          isZipFourTip;
@property (nonatomic, copy) NSString        *zipFourTipMsg;


@property (nonatomic, assign) BOOL          isStateTip;
@property (nonatomic, copy) NSString        *stateTipMsg;

@property (nonatomic, assign) BOOL          isCityTip;
@property (nonatomic, copy) NSString        *cityTipMsg;

/**是保存地址返回错误*/
@property (nonatomic, assign) BOOL          isSaveErrorFillZipTip;
@property (nonatomic, copy) NSString        *saveErrorFillZipMsg;



//是否必填Zip
- (BOOL)isMustZip;
//是否印度国家
- (BOOL)isIndiaCountry;
//是否加拿大国家
- (BOOL)isCanadaCountry;
//是否菲律宾国家
- (BOOL)isPhilippinesCountry;

//地址1 不能为全数字
- (BOOL)isAllNumberFirstAddressLine;
//地址1 判断是否输入双引号
- (BOOL)isContainSpecialMarkFirstAddressLine;
//地址1 判断是否输入双@符合
- (BOOL)isContainSpecialEmailMarkFirstAddressLine;

//name 限制以下特殊支付（~ ` # $ % ^ *()=[]{}\‘“;<>）
- (BOOL)isContainSpecialMarkName:(NSString *)name;

//是否韩国
- (BOOL)isSouthKoreaCountry;

//是否罗马尼亚
- (BOOL)isRomaniaCountry;

- (BOOL)isTestCountry;
@end
