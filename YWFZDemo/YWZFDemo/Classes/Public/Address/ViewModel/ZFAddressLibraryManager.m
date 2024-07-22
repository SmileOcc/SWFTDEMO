//
//  ZFAddressLibraryViewModel.m
//  ZZZZZ
//
//  Created by YW on 2019/1/14.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAddressLibraryManager.h"
#import "ZFApiDefiner.h"
#import "NSStringUtils.h"
#import "Constants.h"
#import "YWCFunctionTool.h"

#import "ZFRequestModel.h"
#import <YYWebImage/YYWebImage.h>
#import <SSZipArchive/SSZipArchive.h>

#import <AFNetworking/AFNetworking.h>
#include <zlib.h>
#import <GGBrainKeeper/BrainKeeperManager.h>



@interface ZFAddressLibraryManager ()

@end

@implementation ZFAddressLibraryManager

+ (instancetype)manager {
    static ZFAddressLibraryManager *manager=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ZFAddressLibraryManager alloc] init];
    });
    return manager;
}

+ (BOOL)isCloseV456AddressLibrary {
    return YES;
}

+ (void)requestAreaLinkAge:(NSDictionary *)parmaters completion:(void (^)(ZFAddressCountryResultModel *resultModel))completion failure:(void (^)(id))failure {
    
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(Port_AreaLinkage);
    requestModel.eventName = @"country_list";
    requestModel.pageName = @"address_list";
    requestModel.parmaters = @{
                               @"token"        :   TOKEN,
                               @"country_name" :   ZFToString(parmaters[@"country_name"]),
                               @"state"        :   ZFToString(parmaters[@"state"]),
                               @"city"         :   ZFToString(parmaters[@"city"]),
                               @"town"         :   ZFToString(parmaters[@"town"]),
                               @"is_child"     :   ZFToString(parmaters[@"is_child"]),
                               @"ignore"       :   ZFToString(parmaters[@"ignore"]),
                               @"is_order"       :   ZFToString(parmaters[@"is_order"]),
                               };
    
    double startTime = [NSStringUtils getCurrentMSimestamp].doubleValue;
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        
        ZFAddressCountryResultModel *resultModel = nil;
        if (ZFJudgeNSDictionary(responseObject)) {
            if ([responseObject[@"statusCode"] integerValue] == 200) {
                resultModel = [ZFAddressCountryResultModel yy_modelWithJSON:responseObject[ZFResultKey]];
            }
        }
        
        if (resultModel) {
            if (completion) {
                completion(resultModel);
            }
        } else {
            if (failure) {
                failure(nil);
            }
        }
        
        double endTime = [NSStringUtils getCurrentMSimestamp].doubleValue;
        double time = endTime - startTime;
        YWLog(@"-------------cccccc requestAreaLinkAge: %f",time);
        
    } failure:^(NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}


+ (ZFAddressCountryModel *)transformLibraryCountry:(ZFAddressLibraryCountryModel *)country {
    ZFAddressCountryModel *model;
    if (country) {
        model = [[ZFAddressCountryModel alloc] init];
        model.region_code = ZFToString(country.rc);
        model.region_id = ZFToString(country.idx);
        model.region_name = ZFToString(country.n);
        model.code = ZFToString(country.c);
        model.supplier_number_list = country.n_sup;
        model.scut_number_list = country.n_scut;
        model.configured_number = country.n_con;
        model.is_cod = [ZFToString(country.cod) boolValue];
        model.support_zip_code = [ZFToString(country.zc) boolValue];
        model.ownState = country.provinceList.count > 0 ? YES : NO;
    }
    return model;
}

+ (ZFAddressStateModel *)transformLibraryState:(ZFAddressLibraryStateModel *)state {
    ZFAddressStateModel *model;
    if (state) {
        model = [[ZFAddressStateModel alloc] init];
        model.stateId = ZFToString(state.idx);
        model.name = ZFToString(state.n);
    }
    return model;
}

+ (ZFAddressCityModel *)transformLibraryCity:(ZFAddressLibraryCityModel *)city {
    ZFAddressCityModel *model;
    if (city) {
        model = [[ZFAddressCityModel alloc] init];
        model.cityId = ZFToString(city.idx);
        model.name = ZFToString(city.n);
    }
    return model;
}

+ (ZFAddressTownModel *)transformLibraryTown:(ZFAddressLibraryTownModel *)town {
    ZFAddressTownModel *model;
    if (town) {
        model = [[ZFAddressTownModel alloc] init];
        model.barangay_id = ZFToString(town.idx);
        model.barangay = ZFToString(town.n);
    }
    return model;
}


- (void)handleCountryGroupDatas:(NSArray<ZFAddressLibraryCountryModel *> *)countryList {

    if (self.countryList.count <= 0 && countryList.count > 0) {
        self.countryGroupDic = [[NSMutableDictionary alloc] init];
        double startTime = [NSStringUtils getCurrentMSimestamp].doubleValue;

        [countryList enumerateObjectsUsingBlock:^(ZFAddressLibraryCountryModel *obj, NSUInteger idx, BOOL *_Nonnull stop) {
            NSString *firstCharactor = [ZFAddressLibraryManager sectionKey:obj.k];
            
            NSMutableArray *arr;
            if ([[self.countryGroupDic allKeys] containsObject:firstCharactor]) {
                arr = [self.countryGroupDic objectForKey:firstCharactor];
                if (arr) {
                    [arr addObject:obj];
                } else {
                    arr = [[NSMutableArray alloc] init];
                    [arr addObject:obj];
                    [self.countryGroupDic setObject:arr forKey:firstCharactor];
                }
            } else {
                arr = [[NSMutableArray alloc] init];
                [arr addObject:obj];
                [self.countryGroupDic setObject:arr forKey:firstCharactor];
            }
        }];
        self.countryList = [[NSMutableArray alloc] initWithArray:countryList];
        
        // allKey排序
        NSMutableArray *groupTempArray= [NSMutableArray arrayWithArray:[[self.countryGroupDic allKeys] sortedArrayUsingSelector:@selector(compare:)]];
        self.countryGroupKeys = groupTempArray;
        
        double endTime = [NSStringUtils getCurrentMSimestamp].doubleValue;
        double time = endTime - startTime;
        YWLog(@"-------------cccccc handleCountryGroupDatas: %f",time);
    }
}


- (void)handleStateGroupDatas:(NSArray<ZFAddressLibraryStateModel *> *)stateList country:(ZFAddressLibraryCountryModel *)countryModel resultBlock:(void (^)(ZFAddressLibraryCountryModel *))completion {
    
    if (stateList.count <= 0) {
        return;
    }
    
    if (countryModel.provinceList.count > 0) {
        return;
    }
    NSArray *stateArray = [[NSArray alloc] initWithArray:stateList];
    
    double startTime = [NSStringUtils getCurrentMSimestamp].doubleValue;

    if (!ZFIsEmptyString(countryModel.n)) {
        
        if (self.countryGroupDic) {
            NSArray <ZFAddressLibraryCountryModel *> *sectionCountryList = [self.countryGroupDic objectForKey:[ZFAddressLibraryManager sectionKey:countryModel.k]];
            
            if (sectionCountryList) {
                
                [sectionCountryList enumerateObjectsUsingBlock:^(ZFAddressLibraryCountryModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([countryModel.n isEqualToString:obj.n]) {
                        *stop = YES;

                        if (obj.provinceList.count <= 0) {
                            [stateArray enumerateObjectsUsingBlock:^(ZFAddressLibraryStateModel * _Nonnull stateObj, NSUInteger idx, BOOL * _Nonnull stop) {
                                [stateObj handleSectionData];
                            }];
                            obj.provinceList = [[NSArray alloc] initWithArray:stateArray];
                            [obj handleSectionData];
                            if (completion) {
                                completion(obj);
                                
                                double endTime = [NSStringUtils getCurrentMSimestamp].doubleValue;
                                double time = endTime - startTime;
                                YWLog(@"-------------cccccc handleStateGroupDatas_time: %f",time);
                            }
                        }
                    }
                }];
            }
        }
    }
}


- (void)handleCityGroupDatas:(NSArray<ZFAddressLibraryCityModel *> *)cityList country:(ZFAddressLibraryCountryModel *)countryModel state:(ZFAddressLibraryStateModel *)stateModel resultBlock:(void (^)(ZFAddressLibraryStateModel *stateModel))completion {
    
    if (cityList.count <= 0) {
        return;
    }
    if (stateModel.cityList > 0) {
        return;
    }
    NSArray *cityArray = [[NSArray alloc] initWithArray:cityList];
    double startTime = [NSStringUtils getCurrentMSimestamp].doubleValue;

    if (!ZFIsEmptyString(countryModel.n) && !ZFIsEmptyString(stateModel.n)) {
        if (self.countryGroupDic) {
            NSArray <ZFAddressLibraryCountryModel *> *sectionCountryList = [self.countryGroupDic objectForKey:[ZFAddressLibraryManager sectionKey:countryModel.k]];
            
            if (sectionCountryList) {
                [sectionCountryList enumerateObjectsUsingBlock:^(ZFAddressLibraryCountryModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull countryStop) {
                    
                    if ([countryModel.n isEqualToString:obj.n]) {
                        *countryStop = YES;

                        if (obj.provinceList.count >= 0) {
                            [obj.provinceList enumerateObjectsUsingBlock:^(ZFAddressLibraryStateModel * _Nonnull stateObj, NSUInteger idx, BOOL * _Nonnull stateStop) {
                                
                                if ([stateModel.n isEqualToString:stateObj.n]) {
                                    *stateStop = YES;

                                    if (stateObj.cityList.count <= 0) {
                                        [cityArray enumerateObjectsUsingBlock:^(ZFAddressLibraryCityModel * _Nonnull cityObj, NSUInteger idx, BOOL * _Nonnull cityStop) {
                                            [cityObj handleSectionData];
                                        }];
                                        stateObj.cityList = [[NSArray alloc] initWithArray:cityArray];
                                        [stateObj handleSectionData];
                                        if (completion) {
                                            completion(stateObj);
                                            
                                            double endTime = [NSStringUtils getCurrentMSimestamp].doubleValue;
                                            double time = endTime - startTime;
                                            YWLog(@"-------------cccccc handleCityGroupDatas: %f",time);
                                        }
                                    }
                                }
                            }];
                        }
                    }
                }];
            }
            
        }
    }
}

- (void)handleTownGroupDatas:(NSArray<ZFAddressLibraryTownModel *> *)townList country:(ZFAddressLibraryCountryModel *)countryModel state:(ZFAddressLibraryStateModel *)stateModel city:(ZFAddressLibraryCityModel *)cityModel resultBlock:(void (^)(ZFAddressLibraryCityModel *))completion {
    
    if (townList.count <= 0) {
        return;
    }
    if (cityModel.town_list.count > 0) {
        return;
    }
    double startTime = [NSStringUtils getCurrentMSimestamp].doubleValue;

    NSArray <ZFAddressLibraryTownModel*> *townArray = [[NSArray alloc] initWithArray:townList];
    
    if (!ZFIsEmptyString(countryModel.n) && !ZFIsEmptyString(stateModel.n)  && !ZFIsEmptyString(cityModel.n)) {
        if (self.countryGroupDic) {
            NSArray <ZFAddressLibraryCountryModel *> *sectionCountryList = [self.countryGroupDic objectForKey:[ZFAddressLibraryManager sectionKey:countryModel.k]];
            
            if (sectionCountryList) {
                [sectionCountryList enumerateObjectsUsingBlock:^(ZFAddressLibraryCountryModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull countryStop) {
                    
                    if ([countryModel.n isEqualToString:obj.n]) {
                        *countryStop = YES;

                        if (obj.provinceList.count >= 0) {
                            [obj.provinceList enumerateObjectsUsingBlock:^(ZFAddressLibraryStateModel * _Nonnull stateObj, NSUInteger idx, BOOL * _Nonnull stateStop) {
                                
                                if ([stateModel.n isEqualToString:stateObj.n]) {
                                    *stateStop = YES;
                                    
                                    if (stateObj.cityList.count >= 0) {
                                        [stateObj.cityList enumerateObjectsUsingBlock:^(ZFAddressLibraryCityModel * _Nonnull cityObj, NSUInteger idx, BOOL * _Nonnull cityStop) {
                                            
                                            if ([cityModel.n isEqualToString:cityObj.n]) {
                                                *cityStop = YES;
                                                [townArray enumerateObjectsUsingBlock:^(ZFAddressLibraryTownModel * _Nonnull townObj, NSUInteger idx, BOOL * _Nonnull cityStop) {
                                                    [townObj handleSelfKey];
                                                }];
                                                cityObj.town_list = [[NSArray alloc] initWithArray:townArray];
                                                [cityObj handleSectionData];
                                                if (completion) {
                                                    completion(cityObj);
                                                    
                                                    double endTime = [NSStringUtils getCurrentMSimestamp].doubleValue;
                                                    double time = endTime - startTime;
                                                    YWLog(@"-------------cccccc handleTownGroupDatas: %f",time);
                                                }
                                            }
                                        }];
                                    }
                                }
                            }];
                        }
                    }
                }];
            }
            
        }
    }
}


//FIXME: occ Bug 1101 本想一次性全部处理，然。。。。。。
- (void)handleAddressGroupDatas:(ZFAddressCountryResultModel *)resultModel country:(ZFAddressLibraryCountryModel *)countryModel state:(ZFAddressLibraryStateModel *)stateModel city:(ZFAddressLibraryCityModel *)cityModel resultBlock:(void (^)(ZFAddressLibraryCountryModel *, ZFAddressLibraryStateModel *, ZFAddressLibraryCityModel *, ZFAddressLibraryTownModel *))completion {

    double startTime = [NSStringUtils getCurrentMSimestamp].doubleValue;

//    __block ZFAddressLibraryCountryModel *tempCountryModel = nil;
//    __block ZFAddressLibraryStateModel *tempStateModel = nil;
//    __block ZFAddressLibraryCityModel *tempCityModel = nil;
//    __block ZFAddressLibraryTownModel *tempTownModel = nil;


    NSArray <ZFAddressLibraryStateModel*> *tempStateArray = [[NSArray alloc] initWithArray:resultModel.state];
    NSArray <ZFAddressLibraryCityModel*> *tempCityArray = [[NSArray alloc] initWithArray:resultModel.city];
    NSArray <ZFAddressLibraryTownModel*> *tempTownArray = [[NSArray alloc] initWithArray:resultModel.town];


    if (self.countryGroupDic) {
        NSArray <ZFAddressLibraryCountryModel *> *sectionCountryList = [self.countryGroupDic objectForKey:[ZFAddressLibraryManager sectionKey:countryModel.k]];

        [sectionCountryList enumerateObjectsUsingBlock:^(ZFAddressLibraryCountryModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull countryStop) {

            if ([countryModel.n isEqualToString:obj.n]) {
                *countryStop = YES;

                // 州省
                if (obj.provinceList.count <= 0 && tempTownArray.count > 0) {
                    [tempStateArray enumerateObjectsUsingBlock:^(ZFAddressLibraryStateModel * _Nonnull stateObj, NSUInteger idx, BOOL * _Nonnull stateStop) {
                        [stateObj handleSectionData];
                        
                        // 城市
                        if (stateModel && tempCityArray.count > 0) {
                            if ([stateModel.n isEqualToString:stateObj.n]) {
                                
                                [tempCityArray enumerateObjectsUsingBlock:^(ZFAddressLibraryCityModel * _Nonnull cityObj, NSUInteger idx, BOOL * _Nonnull cityStop) {
                                    [cityObj handleSectionData];
                                    
                                    //城镇
                                    if (cityModel && tempTownArray.count > 0) {
                                        [tempTownArray enumerateObjectsUsingBlock:^(ZFAddressLibraryTownModel * _Nonnull townObj, NSUInteger idx, BOOL * _Nonnull cityStop) {
                                            [townObj handleSelfKey];
                                        }];
                                        cityObj.town_list = [[NSArray alloc] initWithArray:tempTownArray];
                                        [cityObj handleSectionData];
                                    }
                                }];
                                stateObj.cityList = [[NSArray alloc] initWithArray:tempCityArray];
                                [stateObj handleSectionData];
                            }
                        }
                        
                    }];
                    obj.provinceList = [[NSArray alloc] initWithArray:tempStateArray];
                    [obj handleSectionData];
                    
                } else if (obj.provinceList.count > 0 && stateModel) {
                    [obj.provinceList enumerateObjectsUsingBlock:^(ZFAddressLibraryStateModel * _Nonnull stateObj, NSUInteger idx, BOOL * _Nonnull stateStop) {
                        if ([stateModel.n isEqualToString:stateObj.n]) {
                            *stateStop = YES;
                            
                            // 城市
                            if (stateObj.cityList <= 0 && tempCityArray > 0) {
                                if ([stateModel.n isEqualToString:stateObj.n]) {
                                    
                                    [tempCityArray enumerateObjectsUsingBlock:^(ZFAddressLibraryCityModel * _Nonnull cityObj, NSUInteger idx, BOOL * _Nonnull cityStop) {
                                        [cityObj handleSectionData];
                                        
                                        //城镇
                                        if (cityModel && tempTownArray.count > 0) {
                                            [tempTownArray enumerateObjectsUsingBlock:^(ZFAddressLibraryTownModel * _Nonnull townObj, NSUInteger idx, BOOL * _Nonnull cityStop) {
                                                [townObj handleSelfKey];
                                            }];
                                            cityObj.town_list = [[NSArray alloc] initWithArray:tempTownArray];
                                            [cityObj handleSectionData];
                                        }
                                    }];
                                    stateObj.cityList = [[NSArray alloc] initWithArray:tempCityArray];
                                    [stateObj handleSectionData];
                                }
                                
                            } else if (stateObj.cityList > 0 && cityModel) {
                                
                            }
                        }
                        
                    }];
                }
            }
        }];

    }

    double endTime = [NSStringUtils getCurrentMSimestamp].doubleValue;
    double time = endTime - startTime;
    YWLog(@"-------------cccccc handleAddressGroupDatas: %f",time);
}


+ (NSString *)sectionKey:(NSString *)key {
    if (ZFIsEmptyString(key)) {
        return @"#";
    }
    // 数据多的时候，循环调用这个非常耗时
//    NSMutableString *source = [key mutableCopy];
//    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformMandarinLatin, NO);
//    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformStripDiacritics, NO);//这一行是去声调的
//
//    //转化为大写拼音
//    NSString *pinYin = [source capitalizedString];
    

    //转化为大写拼音
//    NSString *pinYin = [key capitalizedString];
    
    //获取并返回首字母
    if (key.length > 0) {
        return [key substringToIndex:1];
    }
    return @"#";
}


+ (NSMutableArray *)smartMatchSearchList:(NSArray *)sourceList searchKey:(NSString *)key {
    
    if (ZFJudgeNSArray(sourceList)) {
        
        NSMutableArray *searchResult = [NSMutableArray array];
        [sourceList enumerateObjectsUsingBlock:^(ZFAddressBaseModel *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            NSUInteger first = 0, hash = 0; //hash记录权值， INF为不匹配状态，否则为匹配状态，使用二进制按位标记。权值小排前面，权值相同采用字典序。
            BOOL isMatch = NO;
            NSString * name = ZFToString(obj.n);

            while (first + key.length <= name.length && !isMatch) {
                NSString * first_str = [[name substringWithRange:NSMakeRange(first, key.length)] lowercaseString];
                if ([first_str isEqualToString:[key lowercaseString]]) {   //匹配到对应位置，
                    /*
                     for (NSInteger i = first; i <= first+key.length; ++i) {
                     hash |= (1 << i);
                     }
                     */
                    hash |= (((1 << key.length) - 1) << first);
                    isMatch = YES;
                } else {
                    ++first;
                }
            }
            
            //判断当前second是不是已经匹配完key, 如果匹配完，更新权值，并将匹配到的model加入到搜索结果数组中。
            if (isMatch) { //匹配完状态
                obj.hashCost = hash;
                [searchResult addObject:obj];
            }
        }];
        NSMutableArray *sortSearchArray = [NSMutableArray arrayWithArray:[searchResult sortedArrayUsingComparator:^NSComparisonResult(ZFAddressBaseModel *_Nonnull obj1, ZFAddressBaseModel *_Nonnull obj2) {
            return obj1.hashCost > obj2.hashCost ? NSOrderedDescending : obj1.hashCost < obj2.hashCost ? NSOrderedAscending : NSOrderedSame;
        }]];
        return sortSearchArray;
    }
    return [NSMutableArray array];
}

- (void)removeAddressLibrary {
    [self.countryList removeAllObjects];
    [self.countryGroupKeys removeAllObjects];
    [self.countryGroupDic removeAllObjects];
}
#pragma mark - Property Method

- (NSMutableArray<ZFAddressLibraryCountryModel *> *)countryList {
    if (!_countryList) {
        _countryList = [[NSMutableArray alloc] init];
    }
    return _countryList;
}

- (NSMutableArray *)countryGroupKeys {
    if (!_countryGroupKeys) {
        _countryGroupKeys = [[NSMutableArray alloc] init];
    }
    return _countryGroupKeys;
}



@end




@implementation ZFAddressCountryResultModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"country" : [ZFAddressLibraryCountryModel class],
             @"state" : [ZFAddressLibraryStateModel class],
             @"city" : [ZFAddressLibraryCityModel class],
             @"town" : [ZFAddressLibraryTownModel class],
             };
}

@end
