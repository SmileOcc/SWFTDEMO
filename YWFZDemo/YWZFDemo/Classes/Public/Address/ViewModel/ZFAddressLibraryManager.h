//
//  ZFAddressLibraryViewModel.h
//  ZZZZZ
//
//  Created by YW on 2019/1/14.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "BaseViewModel.h"
#import "YWLocalHostManager.h"

#import "ZFAddressCountryModel.h"

#import "ZFAddressLibraryCountryModel.h"
#import "ZFAddressLibraryStateModel.h"
#import "ZFAddressLibraryCityModel.h"
#import "ZFAddressLibraryTownModel.h"

@class ZFAddressCountryResultModel;

//异或（^）运算: 0^0=0,0^1=1,1^0=1,1^1=0
//或（|）运算: 0|0=0,0|1=1,1|0=1,1|1=1
//与（&）运算: 0&0=0,0&1=0,1&0=0,1&1=1

typedef NS_ENUM(NSInteger, ZFAddressLibraryIgnoreLeve) {
    /**忽略国家级别*/
    ZFAddressLibraryIgnoreLeveCountry = 1,
    /**忽略州省级别*/
    ZFAddressLibraryIgnoreLeveState = 2,
    /**忽略城市级别*/
    ZFAddressLibraryIgnoreLeveCity = 4,
    /**忽略城镇级别*/
    ZFAddressLibraryIgnoreLeveTown = 8,
    /**忽略集合判断判断*/
    ZFAddressLibraryIgnoreLeveCondifion = 0xF,//8+4+2+1 = 1111(二进制）
};

@interface ZFAddressLibraryManager : BaseViewModel


@property (nonatomic, strong) NSMutableArray<ZFAddressLibraryCountryModel *>         *countryList;;
@property (nonatomic, strong) NSMutableArray                                         *countryGroupKeys;
@property (nonatomic, strong) NSMutableDictionary                                    *countryGroupDic;


+(instancetype)manager;


//模型转换
+ (ZFAddressCountryModel *)transformLibraryCountry:(ZFAddressLibraryCountryModel *)country;
+ (ZFAddressStateModel *)transformLibraryState:(ZFAddressLibraryStateModel *)state;
+ (ZFAddressCityModel *)transformLibraryCity:(ZFAddressLibraryCityModel *)city;
+ (ZFAddressTownModel *)transformLibraryTown:(ZFAddressLibraryTownModel *)town;

/**
 返回首字母，无返回#
 */
+ (NSString *)sectionKey:(NSString *)key;


/**
 处理国家级别数组
 */
- (void)handleCountryGroupDatas:(NSArray<ZFAddressLibraryCountryModel *> *)countryList;


/**
 处理州省级别数组

 @param stateList
 @param countryModel 当前国家
 @param completion 州省所在的国家
 */
- (void)handleStateGroupDatas:(NSArray<ZFAddressLibraryStateModel *> *)stateList country:(ZFAddressLibraryCountryModel *)countryModel resultBlock:(void (^)(ZFAddressLibraryCountryModel *countryModel))completion;


/**
 处理城市级别数组

 @param cityList
 @param countryModel 当前国家
 @param stateModel 当前州省
 @param completion 城市所在的州省
 */
- (void)handleCityGroupDatas:(NSArray<ZFAddressLibraryCityModel *> *)cityList country:(ZFAddressLibraryCountryModel *)countryModel state:(ZFAddressLibraryStateModel *)stateModel resultBlock:(void (^)(ZFAddressLibraryStateModel *stateModel))completion;


/**
 处理城镇级别的数组

 @param townList
 @param countryModel 当前国家
 @param stateModel 当前州省
 @param cityModel 当前的城市
 @param completion 城镇所在的城市
 */
- (void)handleTownGroupDatas:(NSArray<ZFAddressLibraryTownModel *> *)townList country:(ZFAddressLibraryCountryModel *)countryModel state:(ZFAddressLibraryStateModel *)stateModel city:(ZFAddressLibraryCityModel *)cityModel resultBlock:(void (^)(ZFAddressLibraryCityModel *cityModel))completion;


- (void)handleAddressGroupDatas:(ZFAddressCountryResultModel *)resultModel country:(ZFAddressLibraryCountryModel *)countryModel state:(ZFAddressLibraryStateModel *)stateModel city:(ZFAddressLibraryCityModel *)cityModel resultBlock:(void (^)(ZFAddressLibraryCountryModel *countryModel,ZFAddressLibraryStateModel *stateModel, ZFAddressLibraryCityModel *cityModel, ZFAddressLibraryTownModel *townModel))completion;



/**
 获取地址数据

 country_name: 国家名（1）
 state: 省份名称（2）
 city: 城市名称（4）
 town: 镇名称（8）
 is_child: 默认0-查全部级别，1-只查子集
 ignore: (当is_child为0的时候，才有效）忽略层级数据查询，1 + 2 + 4 + 8，
 1:忽略国家，3:忽略国家、省，7:忽略国家、省、城市
 is_order:1 标识订单地址，不返回其他国家数据
 */
+ (void)requestAreaLinkAge:(NSDictionary *)parmaters completion:(void (^)(ZFAddressCountryResultModel *resultModel))completion failure:(void (^)(id))failure;


+ (NSMutableArray *)smartMatchSearchList:(NSArray *)sourceList searchKey:(NSString *)key;

/**
 清空地址数据
 
 *
 */
- (void)removeAddressLibrary;

@end



@interface ZFAddressCountryResultModel : NSObject

@property (nonatomic, strong) NSArray<ZFAddressLibraryCountryModel*> *country;
@property (nonatomic, strong) NSArray<ZFAddressLibraryStateModel*> *state;
@property (nonatomic, strong) NSArray<ZFAddressLibraryCityModel*> *city;
@property (nonatomic, strong) NSArray<ZFAddressLibraryTownModel*> *town;

@end
